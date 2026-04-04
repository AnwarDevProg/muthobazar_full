import 'dart:math' as math;
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class MBOriginalPickedImage {
  const MBOriginalPickedImage({
    required this.originalBytes,
    required this.width,
    required this.height,
    required this.originalFileName,
    required this.baseName,
    required this.mimeType,
    required this.originalByteLength,
  });

  final Uint8List originalBytes;
  final int width;
  final int height;
  final String originalFileName;
  final String baseName;
  final String mimeType;
  final int originalByteLength;
}

class MBPreparedImageSet {
  const MBPreparedImageSet({
    required this.fullBytes,
    required this.thumbBytes,
    required this.fullWidth,
    required this.fullHeight,
    required this.thumbWidth,
    required this.thumbHeight,
    required this.originalFileName,
    required this.baseName,
    required this.mimeType,
    required this.fullByteLength,
    required this.thumbByteLength,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.requestSquareCrop,
  });

  final Uint8List fullBytes;
  final Uint8List thumbBytes;

  final int fullWidth;
  final int fullHeight;
  final int thumbWidth;
  final int thumbHeight;

  final String originalFileName;
  final String baseName;
  final String mimeType;

  final int fullByteLength;
  final int thumbByteLength;

  final int sourceWidth;
  final int sourceHeight;

  final bool requestSquareCrop;

  Uint8List get previewBytes => fullBytes;
}

class MBUploadedImageSet {
  const MBUploadedImageSet({
    required this.fullUrl,
    required this.thumbUrl,
    required this.fullPath,
    required this.thumbPath,
    required this.fullWidth,
    required this.fullHeight,
    required this.thumbWidth,
    required this.thumbHeight,
  });

  final String fullUrl;
  final String thumbUrl;
  final String fullPath;
  final String thumbPath;
  final int fullWidth;
  final int fullHeight;
  final int thumbWidth;
  final int thumbHeight;
}

class MBImagePipelineService {
  MBImagePipelineService._();

  static final MBImagePipelineService instance = MBImagePipelineService._();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<MBOriginalPickedImage?> pickOriginalImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) {
      return null;
    }

    final Uint8List pickedBytes = await picked.readAsBytes();
    if (pickedBytes.isEmpty) {
      throw Exception('Picked image is empty.');
    }

    final img.Image? decoded = img.decodeImage(pickedBytes);
    if (decoded == null) {
      throw Exception('Failed to decode selected image.');
    }

    final String originalName =
    picked.name.trim().isEmpty ? 'image.jpg' : picked.name.trim();

    final String baseName = _sanitizeBaseName(
      p.basenameWithoutExtension(originalName),
    );

    return MBOriginalPickedImage(
      originalBytes: pickedBytes,
      width: decoded.width,
      height: decoded.height,
      originalFileName: originalName,
      baseName: baseName,
      mimeType: 'image/jpeg',
      originalByteLength: pickedBytes.lengthInBytes,
    );
  }

  Future<MBPreparedImageSet> prepareImageSetFromOriginal({
    required MBOriginalPickedImage original,
    required int fullMaxWidth,
    required int fullMaxHeight,
    required int fullJpegQuality,
    required int thumbSize,
    required int thumbJpegQuality,
    bool requestSquareCrop = false,
  }) async {
    _validateResizeInputs(
      fullMaxWidth: fullMaxWidth,
      fullMaxHeight: fullMaxHeight,
      fullJpegQuality: fullJpegQuality,
      thumbSize: thumbSize,
      thumbJpegQuality: thumbJpegQuality,
    );

    final img.Image? decoded = img.decodeImage(original.originalBytes);
    if (decoded == null) {
      throw Exception('Failed to decode original image for resize.');
    }

    final img.Image preparedBase = requestSquareCrop
        ? _buildCenteredSquare(decoded)
        : img.Image.from(decoded);

    final img.Image fullImage = _resizeContain(
      preparedBase,
      maxWidth: fullMaxWidth,
      maxHeight: fullMaxHeight,
    );

    final img.Image thumbImage = requestSquareCrop
        ? _buildSquareThumb(
      preparedBase,
      thumbSize: thumbSize,
    )
        : _resizeContain(
      preparedBase,
      maxWidth: thumbSize,
      maxHeight: thumbSize,
    );

    final Uint8List fullBytes = Uint8List.fromList(
      img.encodeJpg(
        fullImage,
        quality: fullJpegQuality,
      ),
    );

    final Uint8List thumbBytes = Uint8List.fromList(
      img.encodeJpg(
        thumbImage,
        quality: thumbJpegQuality,
      ),
    );

    return MBPreparedImageSet(
      fullBytes: fullBytes,
      thumbBytes: thumbBytes,
      fullWidth: fullImage.width,
      fullHeight: fullImage.height,
      thumbWidth: thumbImage.width,
      thumbHeight: thumbImage.height,
      originalFileName: original.originalFileName,
      baseName: original.baseName,
      mimeType: original.mimeType,
      fullByteLength: fullBytes.lengthInBytes,
      thumbByteLength: thumbBytes.lengthInBytes,
      sourceWidth: original.width,
      sourceHeight: original.height,
      requestSquareCrop: requestSquareCrop,
    );
  }

  Future<MBPreparedImageSet?> pickCropAndPrepareImage({
    int fullMaxWidth = 1600,
    int fullMaxHeight = 1600,
    int fullJpegQuality = 88,
    int thumbSize = 320,
    int thumbJpegQuality = 82,
    bool requestSquareCrop = false,
  }) async {
    final MBOriginalPickedImage? original = await pickOriginalImage();
    if (original == null) {
      return null;
    }

    return prepareImageSetFromOriginal(
      original: original,
      fullMaxWidth: fullMaxWidth,
      fullMaxHeight: fullMaxHeight,
      fullJpegQuality: fullJpegQuality,
      thumbSize: thumbSize,
      thumbJpegQuality: thumbJpegQuality,
      requestSquareCrop: requestSquareCrop,
    );
  }

  Future<MBUploadedImageSet> uploadPreparedImageSet({
    required MBPreparedImageSet prepared,
    required String storageFolder,
    required String entityId,
    String? fileStem,
    Map<String, String>? customMetadata,
  }) async {
    final String safeFolder = _sanitizePathSegment(storageFolder);
    final String safeEntityId = _sanitizePathSegment(entityId);
    final String safeStem = _sanitizeBaseName(
      (fileStem ?? prepared.baseName).trim().isEmpty
          ? 'image'
          : (fileStem ?? prepared.baseName).trim(),
    );

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    final String fullPath =
        '$safeFolder/$safeEntityId/${safeStem}_${timestamp}_full.jpg';
    final String thumbPath =
        '$safeFolder/$safeEntityId/${safeStem}_${timestamp}_thumb.jpg';

    final Reference fullRef = _storage.ref(fullPath);
    final Reference thumbRef = _storage.ref(thumbPath);

    final SettableMetadata fullMetadata = SettableMetadata(
      contentType: prepared.mimeType,
      customMetadata: <String, String>{
        'variant': 'full',
        'entityId': safeEntityId,
        'originalFileName': prepared.originalFileName,
        'width': prepared.fullWidth.toString(),
        'height': prepared.fullHeight.toString(),
        'byteLength': prepared.fullByteLength.toString(),
        'sourceWidth': prepared.sourceWidth.toString(),
        'sourceHeight': prepared.sourceHeight.toString(),
        'squareCrop': prepared.requestSquareCrop.toString(),
        ...?customMetadata,
      },
    );

    final SettableMetadata thumbMetadata = SettableMetadata(
      contentType: prepared.mimeType,
      customMetadata: <String, String>{
        'variant': 'thumb',
        'entityId': safeEntityId,
        'originalFileName': prepared.originalFileName,
        'width': prepared.thumbWidth.toString(),
        'height': prepared.thumbHeight.toString(),
        'byteLength': prepared.thumbByteLength.toString(),
        'sourceWidth': prepared.sourceWidth.toString(),
        'sourceHeight': prepared.sourceHeight.toString(),
        'squareCrop': prepared.requestSquareCrop.toString(),
        ...?customMetadata,
      },
    );

    await fullRef.putData(prepared.fullBytes, fullMetadata);
    await thumbRef.putData(prepared.thumbBytes, thumbMetadata);

    final String fullUrl = await fullRef.getDownloadURL();
    final String thumbUrl = await thumbRef.getDownloadURL();

    return MBUploadedImageSet(
      fullUrl: fullUrl,
      thumbUrl: thumbUrl,
      fullPath: fullPath,
      thumbPath: thumbPath,
      fullWidth: prepared.fullWidth,
      fullHeight: prepared.fullHeight,
      thumbWidth: prepared.thumbWidth,
      thumbHeight: prepared.thumbHeight,
    );
  }

  void _validateResizeInputs({
    required int fullMaxWidth,
    required int fullMaxHeight,
    required int fullJpegQuality,
    required int thumbSize,
    required int thumbJpegQuality,
  }) {
    if (fullMaxWidth <= 0 || fullMaxHeight <= 0) {
      throw Exception('Full image target size must be greater than zero.');
    }

    if (thumbSize <= 0) {
      throw Exception('Thumb size must be greater than zero.');
    }

    if (fullJpegQuality < 1 || fullJpegQuality > 100) {
      throw Exception('Full image JPEG quality must be between 1 and 100.');
    }

    if (thumbJpegQuality < 1 || thumbJpegQuality > 100) {
      throw Exception('Thumb image JPEG quality must be between 1 and 100.');
    }
  }

  img.Image _resizeContain(
      img.Image source, {
        required int maxWidth,
        required int maxHeight,
      }) {
    if (source.width <= maxWidth && source.height <= maxHeight) {
      return img.Image.from(source);
    }

    final double widthRatio = maxWidth / source.width;
    final double heightRatio = maxHeight / source.height;
    final double scale = math.min(widthRatio, heightRatio);

    final int targetWidth = math.max(1, (source.width * scale).round());
    final int targetHeight = math.max(1, (source.height * scale).round());

    return img.copyResize(
      source,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.average,
    );
  }

  img.Image _buildCenteredSquare(img.Image source) {
    final int squareSide = math.min(source.width, source.height);
    final int offsetX = ((source.width - squareSide) / 2).round();
    final int offsetY = ((source.height - squareSide) / 2).round();

    return img.copyCrop(
      source,
      x: offsetX,
      y: offsetY,
      width: squareSide,
      height: squareSide,
    );
  }

  img.Image _buildSquareThumb(
      img.Image source, {
        required int thumbSize,
      }) {
    final img.Image cropped = source.width == source.height
        ? img.Image.from(source)
        : _buildCenteredSquare(source);

    return img.copyResize(
      cropped,
      width: thumbSize,
      height: thumbSize,
      interpolation: img.Interpolation.average,
    );
  }

  String _sanitizeBaseName(String input) {
    final String cleaned = input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    return cleaned.isEmpty ? 'image' : cleaned;
  }

  String _sanitizePathSegment(String input) {
    final String cleaned = input
        .trim()
        .replaceAll(RegExp(r'[^\w\-/]+'), '_')
        .replaceAll(RegExp(r'/+'), '/')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^/+|/+$'), '');

    return cleaned.isEmpty ? 'unknown' : cleaned;
  }
}