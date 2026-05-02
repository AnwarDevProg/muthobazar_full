import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'mb_image_pipeline_service.dart';

// Manual crop dialog for admin image flows.
//
// Behavior:
// - Opens with the full original image visible inside the crop area.
// - Crop ratio remains locked.
// - User must zoom/move the image until the crop area is fully covered before
//   applying crop.
// - This prevents the dialog from looking pre-zoomed while also preventing
//   invalid crops with empty background.
class MBImageCropDialog extends StatefulWidget {
  const MBImageCropDialog({
    super.key,
    required this.original,
    this.cropAspectRatioX = 4,
    this.cropAspectRatioY = 5,
    this.title = 'Crop Image',
  });

  final MBOriginalPickedImage original;
  final int cropAspectRatioX;
  final int cropAspectRatioY;
  final String title;

  static Future<MBCroppedImageResult?> show(
    BuildContext context, {
    required MBOriginalPickedImage original,
    int cropAspectRatioX = 4,
    int cropAspectRatioY = 5,
    String title = 'Crop Image',
  }) {
    return showDialog<MBCroppedImageResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 980,
          height: 760,
          child: MBImageCropDialog(
            original: original,
            cropAspectRatioX: cropAspectRatioX,
            cropAspectRatioY: cropAspectRatioY,
            title: title,
          ),
        ),
      ),
    );
  }

  @override
  State<MBImageCropDialog> createState() => _MBImageCropDialogState();
}

class _MBImageCropDialogState extends State<MBImageCropDialog> {
  final TransformationController _transformationController =
      TransformationController();

  bool _isCropping = false;
  String? _errorText;

  late Size _baseImageDisplaySize;
  late double _currentScale;

  double _minScale = 1.0;

  static const double _maxScale = 4.0;

  @override
  void initState() {
    super.initState();
    _currentScale = 1.0;
    _baseImageDisplaySize = Size.zero;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  double get _targetAspectRatio =>
      widget.cropAspectRatioX / widget.cropAspectRatioY;

  Size _buildCropViewportSize(BoxConstraints constraints) {
    final double maxWidth = math.min(constraints.maxWidth, 560);
    final double maxHeight = math.min(constraints.maxHeight, 560);

    double width = maxWidth;
    double height = width / _targetAspectRatio;

    if (height > maxHeight) {
      height = maxHeight;
      width = height * _targetAspectRatio;
    }

    return Size(width, height);
  }

  Size _buildContainDisplaySize({
    required Size viewportSize,
  }) {
    final double imageWidth = widget.original.width.toDouble();
    final double imageHeight = widget.original.height.toDouble();

    if (imageWidth <= 0 || imageHeight <= 0) {
      return viewportSize;
    }

    final double imageAspect = imageWidth / imageHeight;

    double width = viewportSize.width;
    double height = width / imageAspect;

    if (height > viewportSize.height) {
      height = viewportSize.height;
      width = height * imageAspect;
    }

    return Size(width, height);
  }

  void _resetTransform(Size viewportSize) {
    _baseImageDisplaySize = _buildContainDisplaySize(
      viewportSize: viewportSize,
    );

    final double dx = (viewportSize.width - _baseImageDisplaySize.width) / 2;
    final double dy = (viewportSize.height - _baseImageDisplaySize.height) / 2;

    final Matrix4 next = Matrix4.identity()
      ..storage[0] = 1.0
      ..storage[5] = 1.0
      ..storage[10] = 1.0
      ..storage[12] = dx
      ..storage[13] = dy;

    _transformationController.value = next;
    _currentScale = 1.0;
    _minScale = 1.0;
  }

  void _syncScaleFromController() {
    final double nextScale = _transformationController.value.storage[0];

    if (!mounted) {
      return;
    }

    setState(() {
      _currentScale = nextScale.clamp(_minScale, _maxScale).toDouble();
    });
  }

  void _setScale(
    double newScale, {
    required Size viewportSize,
  }) {
    final double clampedScale = newScale.clamp(_minScale, _maxScale).toDouble();
    final Matrix4 current = _transformationController.value.clone();

    final double currentTranslationX = current.storage[12];
    final double currentTranslationY = current.storage[13];

    final Offset viewportCenter = Offset(
      viewportSize.width / 2,
      viewportSize.height / 2,
    );

    final double scaleFactor = clampedScale / _currentScale;

    final double translatedDx =
        viewportCenter.dx - (viewportCenter.dx - currentTranslationX) * scaleFactor;
    final double translatedDy =
        viewportCenter.dy - (viewportCenter.dy - currentTranslationY) * scaleFactor;

    final Matrix4 next = Matrix4.identity()
      ..storage[0] = clampedScale
      ..storage[5] = clampedScale
      ..storage[10] = 1.0
      ..storage[12] = translatedDx
      ..storage[13] = translatedDy;

    _transformationController.value = next;

    setState(() {
      _currentScale = clampedScale;
      _errorText = null;
    });
  }

  Rect _imageRectInViewportSpace() {
    final Matrix4 matrix = _transformationController.value;

    final double scaleX = matrix.storage[0];
    final double scaleY = matrix.storage[5];
    final double translateX = matrix.storage[12];
    final double translateY = matrix.storage[13];

    return Rect.fromLTWH(
      translateX,
      translateY,
      _baseImageDisplaySize.width * scaleX,
      _baseImageDisplaySize.height * scaleY,
    );
  }

  bool _isCropAreaCovered(Size viewportSize) {
    if (_baseImageDisplaySize == Size.zero) {
      return false;
    }

    final Rect imageRect = _imageRectInViewportSpace();
    const double tolerance = 0.5;

    return imageRect.left <= tolerance &&
        imageRect.top <= tolerance &&
        imageRect.right >= viewportSize.width - tolerance &&
        imageRect.bottom >= viewportSize.height - tolerance;
  }

  Rect _visibleChildRectInBaseSpace(Size viewportSize) {
    final Matrix4 matrix = _transformationController.value.clone();
    final Matrix4 inverse = Matrix4.inverted(matrix);

    final Offset topLeft = MatrixUtils.transformPoint(
      inverse,
      Offset.zero,
    );
    final Offset bottomRight = MatrixUtils.transformPoint(
      inverse,
      Offset(viewportSize.width, viewportSize.height),
    );

    final double left = math.min(topLeft.dx, bottomRight.dx);
    final double top = math.min(topLeft.dy, bottomRight.dy);
    final double right = math.max(topLeft.dx, bottomRight.dx);
    final double bottom = math.max(topLeft.dy, bottomRight.dy);

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Future<void> _cropAndReturn(Size viewportSize) async {
    if (!_isCropAreaCovered(viewportSize)) {
      setState(() {
        _errorText =
            'Zoom and move the image until it fully covers the crop frame.';
      });
      return;
    }

    setState(() {
      _isCropping = true;
      _errorText = null;
    });

    try {
      final img.Image? decoded = img.decodeImage(widget.original.originalBytes);
      if (decoded == null) {
        throw Exception('Failed to decode selected image for crop.');
      }

      final Rect visibleRect = _visibleChildRectInBaseSpace(viewportSize);

      final double scaleX = widget.original.width / _baseImageDisplaySize.width;
      final double scaleY = widget.original.height / _baseImageDisplaySize.height;

      int cropX = (visibleRect.left * scaleX).round();
      int cropY = (visibleRect.top * scaleY).round();
      int cropWidth = (visibleRect.width * scaleX).round();
      int cropHeight = (visibleRect.height * scaleY).round();

      cropX = cropX.clamp(0, math.max(0, decoded.width - 1));
      cropY = cropY.clamp(0, math.max(0, decoded.height - 1));
      cropWidth = cropWidth.clamp(1, decoded.width - cropX);
      cropHeight = cropHeight.clamp(1, decoded.height - cropY);

      final img.Image cropped = img.copyCrop(
        decoded,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      final Uint8List croppedBytes = Uint8List.fromList(
        img.encodeJpg(
          cropped,
          quality: 96,
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(
        MBCroppedImageResult(
          croppedBytes: croppedBytes,
          width: cropped.width,
          height: cropped.height,
          originalFileName: widget.original.originalFileName,
          baseName: widget.original.baseName,
          mimeType: widget.original.mimeType,
          croppedByteLength: croppedBytes.lengthInBytes,
          sourceWidth: widget.original.width,
          sourceHeight: widget.original.height,
          cropAspectRatioX: widget.cropAspectRatioX,
          cropAspectRatioY: widget.cropAspectRatioY,
          zoomScale: _currentScale,
        ),
      );
    } catch (error) {
      setState(() {
        _errorText = error.toString();
        _isCropping = false;
      });
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size viewportSize = _buildCropViewportSize(constraints);

        if (_baseImageDisplaySize == Size.zero) {
          _resetTransform(viewportSize);
        }

        final bool cropAreaCovered = _isCropAreaCovered(viewportSize);

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed:
                        _isCropping ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Text(
                              'Original image is shown first. Zoom and move it until the crop frame is fully covered. '
                              'Crop ratio is locked to ${widget.cropAspectRatioX}:${widget.cropAspectRatioY}.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Center(
                              child: Container(
                                width: viewportSize.width,
                                height: viewportSize.height,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  children: [
                                    Container(
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
                                    ),
                                    InteractiveViewer(
                                      transformationController:
                                          _transformationController,
                                      minScale: _minScale,
                                      maxScale: _maxScale,
                                      panEnabled: true,
                                      scaleEnabled: true,
                                      constrained: false,
                                      boundaryMargin:
                                          const EdgeInsets.all(1000),
                                      onInteractionUpdate: (_) =>
                                          _syncScaleFromController(),
                                      onInteractionEnd: (_) =>
                                          _syncScaleFromController(),
                                      child: SizedBox(
                                        width: _baseImageDisplaySize.width,
                                        height: _baseImageDisplaySize.height,
                                        child: Image.memory(
                                          widget.original.originalBytes,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    IgnorePointer(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: cropAreaCovered
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: cropAreaCovered
                                ? Text(
                                    'Ready to crop.',
                                    key: const ValueKey('ready'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  )
                                : Text(
                                    'Zoom in until the full crop frame is covered.',
                                    key: const ValueKey('needs_zoom'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color:
                                              Theme.of(context).colorScheme.error,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _isCropping
                                    ? null
                                    : () => _setScale(
                                          _currentScale - 0.1,
                                          viewportSize: viewportSize,
                                        ),
                                icon: const Icon(Icons.zoom_out),
                              ),
                              Expanded(
                                child: Slider(
                                  value:
                                      _currentScale.clamp(_minScale, _maxScale),
                                  min: _minScale,
                                  max: _maxScale,
                                  onChanged: _isCropping
                                      ? null
                                      : (value) => _setScale(
                                            value,
                                            viewportSize: viewportSize,
                                          ),
                                ),
                              ),
                              IconButton(
                                onPressed: _isCropping
                                    ? null
                                    : () => _setScale(
                                          _currentScale + 0.1,
                                          viewportSize: viewportSize,
                                        ),
                                icon: const Icon(Icons.zoom_in),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: _isCropping
                                    ? null
                                    : () {
                                        setState(() {
                                          _baseImageDisplaySize = Size.zero;
                                          _errorText = null;
                                        });
                                      },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reset'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Image Information',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Original file',
                              widget.original.originalFileName,
                            ),
                            _buildInfoRow(
                              'Original bytes',
                              '${widget.original.originalByteLength} B',
                            ),
                            _buildInfoRow(
                              'Original pixels',
                              '${widget.original.width} × ${widget.original.height}',
                            ),
                            _buildInfoRow(
                              'Original ratio',
                              (widget.original.height == 0)
                                  ? '-'
                                  : (widget.original.width /
                                          widget.original.height)
                                      .toStringAsFixed(3),
                            ),
                            _buildInfoRow(
                              'Crop ratio',
                              '${widget.cropAspectRatioX}:${widget.cropAspectRatioY}',
                            ),
                            _buildInfoRow(
                              'Current zoom',
                              _currentScale.toStringAsFixed(2),
                            ),
                            _buildInfoRow(
                              'Crop ready',
                              cropAreaCovered ? 'Yes' : 'No',
                            ),
                            if (_errorText != null &&
                                _errorText!.trim().isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                _errorText!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed:
                        _isCropping ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: (_isCropping || !cropAreaCovered)
                        ? null
                        : () => _cropAndReturn(viewportSize),
                    icon: _isCropping
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.crop),
                    label: Text(
                      _isCropping
                          ? 'Cropping...'
                          : cropAreaCovered
                              ? 'Apply Crop'
                              : 'Zoom to Fill',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
