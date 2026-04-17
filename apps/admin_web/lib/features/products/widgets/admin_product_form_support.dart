
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_core/shared_core.dart';

// File: admin_product_form_support.dart

String? requiredValidator(String? value) {
  if ((value ?? '').trim().isEmpty) {
    return 'Required';
  }
  return null;
}

String simpleSlug(String input) {
  var value = input.trim().toLowerCase();
  value = value.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  value = value.replaceAll(RegExp(r'-+'), '-');
  value = value.replaceAll(RegExp(r'^-|-$'), '');
  return value;
}

String asTextDouble(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toString();
}

String asTextNullableDouble(double? value) {
  if (value == null) return '';
  return asTextDouble(value);
}

double parseDouble(String value, {double fallback = 0.0}) {
  return double.tryParse(value.trim()) ?? fallback;
}

double? parseNullableDouble(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

int parseInt(String value, {int fallback = 0}) {
  return int.tryParse(value.trim()) ?? fallback;
}

int? parseNullableInt(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return null;
  return int.tryParse(normalized);
}

String formatDateTime(DateTime? value) {
  if (value == null) return '';
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}

Future<DateTime?> pickDateTime(
    BuildContext context, {
      DateTime? initial,
    }) async {
  final now = DateTime.now();
  final initialDate = initial ?? now;

  final pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );
  if (pickedDate == null) return null;

  if (!context.mounted) return null;

  final pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate),
  );
  if (pickedTime == null) {
    return DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
  }

  return DateTime(
    pickedDate.year,
    pickedDate.month,
    pickedDate.day,
    pickedTime.hour,
    pickedTime.minute,
  );
}

List<String> splitCsv(String raw) {
  return raw
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

String deriveThumbnailUrl(List<MBProductMedia> mediaItems) {
  for (final item in mediaItems) {
    if (!item.isEnabled) continue;
    if (item.role == 'thumbnail' || item.isPrimary) {
      final value = item.effectiveThumbUrl.trim();
      if (value.isNotEmpty) return value;
    }
  }
  for (final item in mediaItems) {
    if (!item.isEnabled) continue;
    final value = item.effectiveFullUrl.trim();
    if (value.isNotEmpty) return value;
  }
  return '';
}

String? normalizeDropdownValue({
  required String? value,
  required List<String> options,
}) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return options.contains(normalized) ? normalized : null;
}

String makeEditorId(String prefix) {
  final now = DateTime.now().microsecondsSinceEpoch;
  return '${prefix}_$now';
}

Map<String, String> attributeTextToMap(String raw) {
  final lines = raw.split('\n');
  final result = <String, String>{};

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    final parts = trimmed.split('=');
    if (parts.length < 2) continue;
    final key = parts.first.trim();
    final value = parts.sublist(1).join('=').trim();
    if (key.isEmpty || value.isEmpty) continue;
    result[key] = value;
  }

  return result;
}

String attributeMapToText(Map<String, String> value) {
  if (value.isEmpty) return '';
  return value.entries.map((entry) => '${entry.key}=${entry.value}').join('');
}

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  String? hintText,
  int maxLines = 1,
  String? Function(String?)? validator,
  bool readOnly = false,
}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    readOnly: readOnly,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      border: const OutlineInputBorder(),
    ),
  );
}

Widget buildNumberField({
  required TextEditingController controller,
  required String label,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}

Widget buildIntField({
  required TextEditingController controller,
  required String label,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}

Widget buildDropdownField<T>({
  required String label,
  required T value,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) {
  return InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        isExpanded: true,
        value: value,
        items: items,
        onChanged: onChanged,
      ),
    ),
  );
}

Widget buildDateTimeField({
  required TextEditingController controller,
  required String label,
  required VoidCallback onPick,
  required VoidCallback onClear,
}) {
  return TextFormField(
    controller: controller,
    readOnly: true,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.clear),
          ),
          IconButton(
            onPressed: onPick,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
    ),
  );
}

Widget buildFilterChip({
  required String label,
  required bool selected,
  required ValueChanged<bool> onSelected,
}) {
  return FilterChip(
    selected: selected,
    onSelected: onSelected,
    label: Text(label),
  );
}

Widget buildInfoChip(String text) {
  return Chip(label: Text(text));
}

Widget buildReadOnlyInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value.isEmpty ? '-' : value)),
      ],
    ),
  );
}

Widget buildIntStepper(
    BuildContext context, {
      required String label,
      required int value,
      required ValueChanged<int> onChanged,
    }) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        IconButton(
          onPressed: () => onChanged(value - 1),
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(value.toString(), style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    ),
  );
}

Widget dialogTextField(
    TextEditingController controller,
    String label, {
      String? Function(String?)? validator,
      int maxLines = 1,
    }) {
  return TextFormField(
    controller: controller,
    validator: validator,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}

Widget dialogDropdown({
  required String label,
  required String value,
  required List<String> items,
  required ValueChanged<String> onChanged,
}) {
  return InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          onChanged(value);
        },
      ),
    ),
  );
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                ?action,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class EditableTile extends StatelessWidget {
  const EditableTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
    this.leading,
  });

  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
          IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
    );
  }
}

class EmptyBlock extends StatelessWidget {
  const EmptyBlock({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message),
    );
  }
}

class PreviewImage extends StatelessWidget {
  const PreviewImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 56,
          height: 56,
          color: Colors.black12,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}

class PreviewLargeImage extends StatelessWidget {
  const PreviewLargeImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: 180,
          color: Colors.black12,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}

class EmptyPreviewImage extends StatelessWidget {
  const EmptyPreviewImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 42),
    );
  }
}

class MediaItemDialog extends StatefulWidget {
  const MediaItemDialog({
    super.key,
    required this.initialValue,
    this.maxItems = 10,
    this.currentItemCount = 0,
    this.useProductPortraitPreset = false,
    this.forceImageOnly = false,
  });

  final MBProductMedia initialValue;
  final int maxItems;
  final int currentItemCount;
  final bool useProductPortraitPreset;
  final bool forceImageOnly;

  @override
  State<MediaItemDialog> createState() => _MediaItemDialogState();
}

class _MediaItemDialogState extends State<MediaItemDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _idController;
  late final TextEditingController _labelEnController;
  late final TextEditingController _labelBnController;
  late final TextEditingController _altEnController;
  late final TextEditingController _altBnController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _urlController;
  late final TextEditingController _storagePathController;

  late bool _isPrimary;
  late bool _isEnabled;
  late String _type;
  late String _role;

  bool _isProcessing = false;
  String? _errorText;
  String _ratioText(int width, int height) {
    if (height == 0) return '-';
    return (width / height).toStringAsFixed(3);
  }

  String _bytesText(int value) {
    if (value < 1024) return '$value B';
    if (value < 1024 * 1024) {
      return '${(value / 1024).toStringAsFixed(1)} KB';
    }
    return '${(value / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String get _effectiveRole => _isPrimary ? 'thumbnail' : 'gallery';

  Future<void> _pickResizeAndUploadImage() async {
    setState(() {
      _isProcessing = true;
      _errorText = null;
    });

    try {
      final MBOriginalPickedImage? original =
      await MBImagePipelineService.instance.pickOriginalImage();

      if (original == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final MBCroppedImageResult? cropped = await MBImageCropDialog.show(
        context,
        original: original,
        cropAspectRatioX: 4,
        cropAspectRatioY: 5,
        title: 'Crop Product Image',
      );

      if (cropped == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final MBPreparedImageSet prepared =
      await MBImagePipelineService.instance.prepareImageSetFromCropped(
        cropped: cropped,
        fullMaxWidth: _productFullMaxWidth,
        fullMaxHeight: _productFullMaxHeight,
        fullJpegQuality: _productFullJpegQuality,
        thumbSize: _productThumbSize,
        thumbJpegQuality: _productThumbJpegQuality,
        requestSquareCrop: false,
        requestAspectCrop: true,
        cropAspectRatioX: 4,
        cropAspectRatioY: 5,
        thumbWidth: _productThumbWidth,
        thumbHeight: _productThumbHeight,
      );

      final String mediaId = _idController.text.trim().isEmpty
          ? makeEditorId('media')
          : _idController.text.trim();

      final MBUploadedImageSet uploaded =
      await MBImagePipelineService.instance.uploadPreparedImageSet(
        prepared: prepared,
        storageFolder: 'products/media',
        entityId: mediaId,
        fileStem: _labelEnController.text.trim().isEmpty
            ? prepared.baseName
            : _labelEnController.text.trim(),
        customMetadata: <String, String>{
          'mediaId': mediaId,
          'role': _effectiveRole,
          'type': 'image',
        },
      );

      if (_labelEnController.text.trim().isEmpty) {
        _labelEnController.text = prepared.baseName.replaceAll('_', ' ');
      }

      setState(() {
        _preparedImage = prepared;
        _uploadedImage = uploaded;
        _type = 'image';
        _role = _effectiveRole;
        _urlController.text = uploaded.fullUrl;
        _storagePathController.text = uploaded.fullPath;
        _isProcessing = false;
      });
    } catch (error) {
      setState(() {
        _isProcessing = false;
        _errorText = error.toString();
      });
    }
  }

  String get _currentFullPreviewUrl {
    final current = _urlController.text.trim();
    if (current.isNotEmpty) return current;
    return widget.initialValue.effectiveFullUrl.trim();
  }

  String get _currentThumbPreviewUrl {
    final uploadedThumb = (_uploadedImage?.thumbUrl ?? '').trim();
    if (uploadedThumb.isNotEmpty) return uploadedThumb;

    final current = widget.initialValue.effectiveThumbUrl.trim();
    if (current.isNotEmpty) return current;

    return _currentFullPreviewUrl;
  }

  bool get _showThumbAndFullMediaPreview =>
      _isPrimary || _effectiveRole == 'thumbnail';

  Widget _buildPreviewTile(
      BuildContext context, {
        required String label,
        required String url,
        Uint8List? memoryBytes,
        double height = 280,
      }) {
    final Widget child;

    if (memoryBytes != null) {
      child = Image.memory(
        memoryBytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
      );
    } else if (url.trim().isNotEmpty) {
      child = Image.network(
        url.trim(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: const Icon(Icons.broken_image_outlined, size: 42),
        ),
      );
    } else {
      child = Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Icon(Icons.image_outlined, size: 42),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ],
    );
  }

  Widget _buildPreviewBox(BuildContext context) {
    if (_showThumbAndFullMediaPreview) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildPreviewTile(
              context,
              label: 'Thumbnail Preview',
              url: _currentThumbPreviewUrl,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPreviewTile(
              context,
              label: 'Full Preview',
              url: _currentFullPreviewUrl,
              memoryBytes: _preparedImage?.previewBytes,
            ),
          ),
        ],
      );
    }

    return _buildPreviewTile(
      context,
      label: 'Full Preview',
      url: _currentFullPreviewUrl,
      memoryBytes: _preparedImage?.previewBytes,
    );
  }


  MBPreparedImageSet? _preparedImage;
  MBUploadedImageSet? _uploadedImage;

  static const int _productFullMaxWidth = 1080;
  static const int _productFullMaxHeight = 1350;
  static const int _productFullJpegQuality = 90;
  static const int _productThumbWidth = 400;
  static const int _productThumbHeight = 500;
  static const int _productThumbSize = 400;
  static const int _productThumbJpegQuality = 85;



  @override
  void initState() {
    super.initState();

    final item = widget.initialValue;

    _idController = TextEditingController(
      text: item.id.trim().isEmpty ? makeEditorId('media') : item.id,
    );
    _labelEnController = TextEditingController(text: item.labelEn);
    _labelBnController = TextEditingController(text: item.labelBn);
    _altEnController = TextEditingController(text: item.altEn);
    _altBnController = TextEditingController(text: item.altBn);
    _sortOrderController = TextEditingController(
      text: item.sortOrder.toString(),
    );
    _urlController = TextEditingController(text: item.effectiveFullUrl);
    _storagePathController =
        TextEditingController(text: item.effectiveFullStoragePath);

    _isPrimary = item.isPrimary;
    _isEnabled = item.isEnabled;
    _type = widget.forceImageOnly ? 'image' : item.type;
    _role = item.role.trim().isEmpty
        ? (item.isPrimary ? 'thumbnail' : 'gallery')
        : item.role;
  }

  @override
  void dispose() {
    _idController.dispose();
    _labelEnController.dispose();
    _labelBnController.dispose();
    _altEnController.dispose();
    _altBnController.dispose();
    _sortOrderController.dispose();
    _urlController.dispose();
    _storagePathController.dispose();
    super.dispose();
  }


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value),
          ),
        ],
      ),
    );
  }

  MBProductMedia _buildResult() {
    final existing = widget.initialValue;
    final fullUrl = _currentFullPreviewUrl;
    final fullStoragePath = _storagePathController.text.trim();
    final thumbUrl = _currentThumbPreviewUrl;

    return existing.copyWith(
      id: _idController.text.trim(),
      url: fullUrl,
      storagePath: fullStoragePath,
      fullUrl: fullUrl,
      fullStoragePath: fullStoragePath,
      thumbUrl: thumbUrl,
      type: _type,
      role: _effectiveRole,
      labelEn: _labelEnController.text.trim(),
      labelBn: _labelBnController.text.trim(),
      altEn: _altEnController.text.trim(),
      altBn: _altBnController.text.trim(),
      sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
      isPrimary: _isPrimary,
      isEnabled: _isEnabled,
      width: _uploadedImage?.fullWidth ?? existing.width,
      height: _uploadedImage?.fullHeight ?? existing.height,
      sizeBytes: _preparedImage?.fullByteLength ?? existing.sizeBytes,
      fullWidth: _uploadedImage?.fullWidth ?? existing.fullWidth,
      fullHeight: _uploadedImage?.fullHeight ?? existing.fullHeight,
      fullSizeBytes: _preparedImage?.fullByteLength ?? existing.fullSizeBytes,
      thumbWidth: _preparedImage?.thumbWidth ?? existing.thumbWidth,
      thumbHeight: _preparedImage?.thumbHeight ?? existing.thumbHeight,
      thumbSizeBytes: _preparedImage?.thumbByteLength ?? existing.thumbSizeBytes,
      originalWidth: _preparedImage?.sourceWidth ?? existing.originalWidth,
      originalHeight: _preparedImage?.sourceHeight ?? existing.originalHeight,
      createdAt: existing.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAtLimit =
        widget.currentItemCount >= widget.maxItems && widget.initialValue.url.trim().isEmpty;

    return AlertDialog(
      title: const Text('Media Item'),
      content: SizedBox(
        width: 900,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Image-only phase. Pick an image, crop it manually in portrait ratio, then upload resized full and thumb outputs. The first image becomes the product thumbnail automatically.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPreviewBox(context),
                const SizedBox(height: 12),
                if (_errorText != null && _errorText!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: (_isProcessing || isAtLimit)
                            ? null
                            : _pickResizeAndUploadImage,
                        icon: _isProcessing
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(
                          _urlController.text.trim().isEmpty
                              ? 'Pick, Resize & Upload'
                              : 'Replace Image',
                        ),
                      ),
                    ),
                  ],
                ),
                if (isAtLimit) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Media limit reached (${widget.maxItems}). Edit or delete an existing image to continue.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _buildInfoRow('Uploaded URL', _urlController.text.trim()),
                _buildInfoRow('Storage Path', _storagePathController.text.trim()),
                _buildInfoRow('Generated Thumb URL', _uploadedImage?.thumbUrl ?? ''),
                const SizedBox(height: 8),
                if (_preparedImage != null) ...[
                  _buildInfoRow(
                    'Original Pixels',
                    '${_preparedImage!.sourceWidth} × ${_preparedImage!.sourceHeight}',
                  ),
                  _buildInfoRow(
                    'Original Ratio',
                    _ratioText(_preparedImage!.sourceWidth, _preparedImage!.sourceHeight),
                  ),
                  _buildInfoRow(
                    'Cropped Pixels',
                    '${_preparedImage!.croppedWidth} × ${_preparedImage!.croppedHeight}',
                  ),
                  _buildInfoRow(
                    'Crop Ratio',
                    '${_preparedImage!.cropAspectRatioX}:${_preparedImage!.cropAspectRatioY}',
                  ),
                  _buildInfoRow(
                    'Crop Zoom',
                    _preparedImage!.zoomScale.toStringAsFixed(2),
                  ),
                  _buildInfoRow(
                    'Cropped Size',
                    _bytesText(_preparedImage!.croppedByteLength),
                  ),
                  _buildInfoRow(
                    'Full Pixels',
                    '${_preparedImage!.fullWidth} × ${_preparedImage!.fullHeight}',
                  ),
                  _buildInfoRow(
                    'Full Size',
                    _bytesText(_preparedImage!.fullByteLength),
                  ),
                  _buildInfoRow(
                    'Thumb Pixels',
                    '${_preparedImage!.thumbWidth} × ${_preparedImage!.thumbHeight}',
                  ),
                  _buildInfoRow(
                    'Thumb Size',
                    _bytesText(_preparedImage!.thumbByteLength),
                  ),
                ] else ...[
                  _buildInfoRow('Original Pixels', '-'),
                  _buildInfoRow('Original Ratio', '-'),
                  _buildInfoRow('Cropped Pixels', '-'),
                  _buildInfoRow('Crop Ratio', '-'),
                  _buildInfoRow('Crop Zoom', '-'),
                  _buildInfoRow('Cropped Size', '-'),
                  _buildInfoRow('Full Pixels', '-'),
                  _buildInfoRow('Full Size', '-'),
                  _buildInfoRow('Thumb Pixels', '-'),
                  _buildInfoRow('Thumb Size', '-'),
                ],

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _idController,
                        'Id',
                        validator: requiredValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _sortOrderController,
                        'Sort Order',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _labelEnController,
                        'Label (English)',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _labelBnController,
                        'Label (Bangla)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _altEnController,
                        'Alt Text (English)',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _altBnController,
                        'Alt Text (Bangla)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    buildFilterChip(
                      label: 'Primary Thumbnail',
                      selected: _isPrimary,
                      onSelected: (value) {
                        setState(() {
                          _isPrimary = value;
                          _role = value ? 'thumbnail' : 'gallery';
                        });
                      },
                    ),
                    buildFilterChip(
                      label: 'Enabled',
                      selected: _isEnabled,
                      onSelected: (value) {
                        setState(() {
                          _isEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isProcessing
              ? null
              : () {
            if (!_formKey.currentState!.validate()) return;

            if (_urlController.text.trim().isEmpty) {
              setState(() {
                _errorText = 'Please pick and upload an image first.';
              });
              return;
            }

            Navigator.of(context).pop(_buildResult());
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class AttributeValueDialog extends StatefulWidget {
  const AttributeValueDialog({super.key, required this.initialValue});

  final MBProductAttributeValue initialValue;

  @override
  State<AttributeValueDialog> createState() => _AttributeValueDialogState();
}

class _AttributeValueDialogState extends State<AttributeValueDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _idController;
  late final TextEditingController _labelEnController;
  late final TextEditingController _labelBnController;
  late final TextEditingController _valueController;
  late final TextEditingController _colorHexController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _sortOrderController;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final value = widget.initialValue;
    _idController = TextEditingController(text: value.id);
    _labelEnController = TextEditingController(text: value.labelEn);
    _labelBnController = TextEditingController(text: value.labelBn);
    _valueController = TextEditingController(text: value.value);
    _colorHexController = TextEditingController(text: value.colorHex ?? '');
    _imageUrlController = TextEditingController(text: value.imageUrl ?? '');
    _sortOrderController = TextEditingController(text: value.sortOrder.toString());
    _isEnabled = value.isEnabled;
  }

  @override
  void dispose() {
    _idController.dispose();
    _labelEnController.dispose();
    _labelBnController.dispose();
    _valueController.dispose();
    _colorHexController.dispose();
    _imageUrlController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Attribute Value'),
      content: SizedBox(
        width: 640,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              dialogTextField(_idController, 'Id', validator: requiredValidator),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: dialogTextField(
                      _labelEnController,
                      'Label (English)',
                      validator: requiredValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: dialogTextField(
                      _labelBnController,
                      'Label (Bangla)',
                      validator: requiredValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: dialogTextField(
                      _valueController,
                      'Value',
                      validator: requiredValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: dialogTextField(_sortOrderController, 'Sort Order')),
                ],
              ),
              const SizedBox(height: 12),
              dialogTextField(_colorHexController, 'Color Hex'),
              const SizedBox(height: 12),
              dialogTextField(_imageUrlController, 'Image URL'),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isEnabled,
                onChanged: (value) => setState(() => _isEnabled = value),
                contentPadding: EdgeInsets.zero,
                title: const Text('Enabled'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              MBProductAttributeValue(
                id: _idController.text.trim(),
                labelEn: _labelEnController.text.trim(),
                labelBn: _labelBnController.text.trim(),
                value: _valueController.text.trim(),
                colorHex: _colorHexController.text.trim().isEmpty
                    ? null
                    : _colorHexController.text.trim(),
                imageUrl: _imageUrlController.text.trim().isEmpty
                    ? null
                    : _imageUrlController.text.trim(),
                sortOrder: parseInt(_sortOrderController.text),
                isEnabled: _isEnabled,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class AttributeDialog extends StatefulWidget {
  const AttributeDialog({super.key, required this.initialValue});

  final MBProductAttribute initialValue;

  @override
  State<AttributeDialog> createState() => _AttributeDialogState();
}

class _AttributeDialogState extends State<AttributeDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _idController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameBnController;
  late final TextEditingController _codeController;
  late final TextEditingController _sortOrderController;

  late bool _isVisible;
  late bool _useForVariation;
  late bool _isRequired;
  late String _displayType;
  late List<MBProductAttributeValue> _values;

  String get _attributeModeHelpText {
    if (_useForVariation) {
      return 'This attribute participates in variation combinations. Make sure values are clean and unique.';
    }

    return 'This attribute is display-only for now and does not generate variation combinations.';
  }

  @override
  void initState() {
    super.initState();
    final value = widget.initialValue;
    _idController = TextEditingController(text: value.id);
    _nameEnController = TextEditingController(text: value.nameEn);
    _nameBnController = TextEditingController(text: value.nameBn);
    _codeController = TextEditingController(text: value.code);
    _sortOrderController = TextEditingController(text: value.sortOrder.toString());
    _isVisible = value.isVisible;
    _useForVariation = value.useForVariation;
    _isRequired = value.isRequired;
    _displayType = value.displayType;
    _values = [...value.values]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameEnController.dispose();
    _nameBnController.dispose();
    _codeController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _addValue() async {
    final result = await showDialog<MBProductAttributeValue>(
      context: context,
      builder: (_) => AttributeValueDialog(
        initialValue: MBProductAttributeValue(
          id: makeEditorId('attr_value'),
          labelEn: '',
          labelBn: '',
          value: '',
          sortOrder: _values.length,
        ),
      ),
    );

    if (result == null) return;
    setState(() {
      _values.add(result);
      _values.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  Future<void> _editValue(MBProductAttributeValue value) async {
    final result = await showDialog<MBProductAttributeValue>(
      context: context,
      builder: (_) => AttributeValueDialog(initialValue: value),
    );

    if (result == null) return;
    setState(() {
      final index = _values.indexWhere((element) => element.id == value.id);
      if (index != -1) {
        _values[index] = result;
        _values.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Attribute'),
      content: SizedBox(
        width: 860,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    _attributeModeHelpText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example / Sample',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Example 1\n'
                            'Name (English): Size\n'
                            'Name (Bangla): সাইজ\n'
                            'Code: size\n'
                            'Use For Variation: ON\n'
                            'Display Type: text\n'
                            'Values: 500g, 1kg',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Example 2\n'
                            'Name (English): Color\n'
                            'Code: color\n'
                            'Use For Variation: ON\n'
                            'Display Type: color\n'
                            'Values: Red (#FF0000), Green (#00AA00)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Attribute Identity',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),

                dialogTextField(
                  _idController,
                  'Id',
                  validator: requiredValidator,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _nameEnController,
                        'Name (English)',
                        validator: requiredValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _nameBnController,
                        'Name (Bangla)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _codeController,
                        'Code',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _sortOrderController,
                        'Sort Order',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Behavior',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        value: _isVisible,
                        onChanged: (value) =>
                            setState(() => _isVisible = value),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Visible'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SwitchListTile(
                        value: _useForVariation,
                        onChanged: (value) =>
                            setState(() => _useForVariation = value),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Use For Variation'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        value: _isRequired,
                        onChanged: (value) =>
                            setState(() => _isRequired = value),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Required'),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _displayType,
                  decoration: const InputDecoration(
                    labelText: 'Display Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'text', child: Text('text')),
                    DropdownMenuItem(value: 'color', child: Text('color')),
                    DropdownMenuItem(value: 'image', child: Text('image')),
                    DropdownMenuItem(value: 'chip', child: Text('chip')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _displayType = value);
                  },
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Attribute Values',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _addValue,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Value'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'These values will later connect to variation combinations for variable products.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),

                if (_values.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('No attribute values added yet.'),
                  )
                else
                  Column(
                    children: _values
                        .map(
                          (item) => EditableTile(
                        title: item.labelEn.trim().isEmpty
                            ? item.value
                            : item.labelEn,
                        subtitle:
                        'value: ${item.value} • order: ${item.sortOrder} • enabled: ${item.isEnabled}',
                        onEdit: () => _editValue(item),
                        onDelete: () {
                          setState(() {
                            _values.removeWhere(
                                  (element) => element.id == item.id,
                            );
                          });
                        },
                      ),
                    )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            Navigator.of(context).pop(
              MBProductAttribute(
                id: _idController.text.trim(),
                nameEn: _nameEnController.text.trim(),
                nameBn: _nameBnController.text.trim(),
                code: _codeController.text.trim(),
                sortOrder: parseInt(_sortOrderController.text),
                isVisible: _isVisible,
                useForVariation: _useForVariation,
                isRequired: _isRequired,
                displayType: _displayType,
                values: [..._values]..sort(
                      (a, b) => a.sortOrder.compareTo(b.sortOrder),
                ),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class VariationDialog extends StatefulWidget {
  const VariationDialog({
    super.key,
    required this.initialValue,
    this.variationAttributes = const <MBProductAttribute>[],
  });

  final MBProductVariation initialValue;
  final List<MBProductAttribute> variationAttributes;

  @override
  State<VariationDialog> createState() => _VariationDialogState();
}

class _VariationDialogState extends State<VariationDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _idController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _titleEnController;
  late final TextEditingController _titleBnController;
  late final TextEditingController _imageUrlController; // full image URL
  late final TextEditingController _thumbImageUrlController; // thumb image URL
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _descriptionBnController;
  late final TextEditingController _priceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _stockQtyController;
  late final TextEditingController _reservedQtyController;
  late final TextEditingController _sortOrderController;

  late bool _trackInventory;
  late bool _allowBackorder;
  late bool _isDefault;
  late bool _isEnabled;

  late Map<String, String?> _selectedAttributeValues;

  bool _isImageProcessing = false;
  String? _imageErrorText;
  MBPreparedImageSet? _preparedImage;
  MBUploadedImageSet? _uploadedImage;

  static const int _variationFullMaxWidth = 1080;
  static const int _variationFullMaxHeight = 1350;
  static const int _variationFullJpegQuality = 90;
  static const int _variationThumbWidth = 400;
  static const int _variationThumbHeight = 500;
  static const int _variationThumbSize = 400;
  static const int _variationThumbJpegQuality = 85;

  List<MBProductAttributeValue> _enabledValuesFor(MBProductAttribute attribute) {
    final values = attribute.values
        .where((value) => value.isEnabled && value.value.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return values;
  }

  String? _initialSelectedValueFor(
      MBProductAttribute attribute,
      MBProductVariation variation,
      ) {
    final byId = variation.attributeValues[attribute.id]?.trim() ?? '';
    if (byId.isNotEmpty) {
      return byId;
    }

    final code = attribute.code.trim();
    if (code.isNotEmpty) {
      final byCode = variation.attributeValues[code]?.trim() ?? '';
      if (byCode.isNotEmpty) {
        return byCode;
      }
    }

    final enabledValues = _enabledValuesFor(attribute);
    if (enabledValues.length == 1) {
      return enabledValues.first.value.trim();
    }

    return null;
  }

  String _ratioText(int width, int height) {
    if (height == 0) return '-';
    return (width / height).toStringAsFixed(3);
  }

  String _bytesText(int value) {
    if (value < 1024) return '$value B';
    if (value < 1024 * 1024) {
      return '${(value / 1024).toStringAsFixed(1)} KB';
    }
    return '${(value / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Widget _buildVariationImageInfo() {
    if (_preparedImage == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Original Pixels: -'),
          Text('Original Ratio: -'),
          Text('Cropped Pixels: -'),
          Text('Crop Ratio: -'),
          Text('Crop Zoom: -'),
          Text('Cropped Size: -'),
          Text('Full Pixels: -'),
          Text('Full Size: -'),
          Text('Thumb Pixels: -'),
          Text('Thumb Size: -'),
        ],
      );
    }

    final p = _preparedImage!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Original Pixels: ${p.sourceWidth} × ${p.sourceHeight}'),
        Text('Original Ratio: ${_ratioText(p.sourceWidth, p.sourceHeight)}'),
        Text('Cropped Pixels: ${p.croppedWidth} × ${p.croppedHeight}'),
        Text('Crop Ratio: ${p.cropAspectRatioX}:${p.cropAspectRatioY}'),
        Text('Crop Zoom: ${p.zoomScale.toStringAsFixed(2)}'),
        Text('Cropped Size: ${_bytesText(p.croppedByteLength)}'),
        Text('Full Pixels: ${p.fullWidth} × ${p.fullHeight}'),
        Text('Full Size: ${_bytesText(p.fullByteLength)}'),
        Text('Thumb Pixels: ${p.thumbWidth} × ${p.thumbHeight}'),
        Text('Thumb Size: ${_bytesText(p.thumbByteLength)}'),
      ],
    );
  }


  Map<String, String> _buildSelectedAttributeMap() {
    final result = <String, String>{};

    for (final attribute in widget.variationAttributes) {
      final selected = (_selectedAttributeValues[attribute.id] ?? '').trim();
      if (selected.isNotEmpty) {
        result[attribute.id] = selected;
      }
    }

    return result;
  }

  Future<void> _pickResizeAndUploadVariationImage() async {
    setState(() {
      _isImageProcessing = true;
      _imageErrorText = null;
    });

    try {
      final MBOriginalPickedImage? original =
      await MBImagePipelineService.instance.pickOriginalImage();

      if (original == null) {
        setState(() {
          _isImageProcessing = false;
        });
        return;
      }

      final MBCroppedImageResult? cropped = await MBImageCropDialog.show(
        context,
        original: original,
        cropAspectRatioX: 4,
        cropAspectRatioY: 5,
        title: 'Crop Variation Image',
      );

      if (cropped == null) {
        setState(() {
          _isImageProcessing = false;
        });
        return;
      }

      final MBPreparedImageSet prepared =
      await MBImagePipelineService.instance.prepareImageSetFromCropped(
        cropped: cropped,
        fullMaxWidth: _variationFullMaxWidth,
        fullMaxHeight: _variationFullMaxHeight,
        fullJpegQuality: _variationFullJpegQuality,
        thumbSize: _variationThumbSize,
        thumbJpegQuality: _variationThumbJpegQuality,
        requestSquareCrop: false,
        requestAspectCrop: true,
        cropAspectRatioX: 4,
        cropAspectRatioY: 5,
        thumbWidth: _variationThumbWidth,
        thumbHeight: _variationThumbHeight,
      );

      final String variationId = _idController.text.trim().isEmpty
          ? makeEditorId('variation')
          : _idController.text.trim();

      final MBUploadedImageSet uploaded =
      await MBImagePipelineService.instance.uploadPreparedImageSet(
        prepared: prepared,
        storageFolder: 'products/variations',
        entityId: variationId,
        fileStem: _titleEnController.text.trim().isEmpty
            ? prepared.baseName
            : _titleEnController.text.trim(),
        customMetadata: <String, String>{
          'variationId': variationId,
          'mediaOwner': 'variation',
          'type': 'image',
        },
      );

      setState(() {
        _preparedImage = prepared;
        _uploadedImage = uploaded;
        _imageUrlController.text = uploaded.fullUrl;
        _thumbImageUrlController.text = uploaded.thumbUrl;
        _isImageProcessing = false;
      });
    } catch (error) {
      setState(() {
        _isImageProcessing = false;
        _imageErrorText = error.toString();
      });
    }
  }
  String get _currentVariationFullPreviewUrl {
    final current = _imageUrlController.text.trim();
    if (current.isNotEmpty) return current;
    return widget.initialValue.effectiveFullImageUrl.trim();
  }

  String get _currentVariationThumbPreviewUrl {
    final current = _thumbImageUrlController.text.trim();
    if (current.isNotEmpty) return current;
    return widget.initialValue.effectiveThumbImageUrl.trim();
  }

  Widget _buildVariationPreviewTile(
      BuildContext context, {
        required String label,
        required String url,
        Uint8List? memoryBytes,
        double height = 220,
      }) {
    final Widget child;

    if (memoryBytes != null) {
      child = Image.memory(
        memoryBytes,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (url.trim().isNotEmpty) {
      child = Image.network(
        url.trim(),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: const Icon(Icons.broken_image_outlined, size: 42),
        ),
      );
    } else {
      child = Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Icon(Icons.image_outlined, size: 42),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ],
    );
  }




  Widget _buildVariationImagePreview(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildVariationPreviewTile(
            context,
            label: 'Thumbnail Preview',
            url: _currentVariationThumbPreviewUrl,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildVariationPreviewTile(
            context,
            label: 'Full Preview',
            url: _currentVariationFullPreviewUrl,
            memoryBytes: _preparedImage?.previewBytes,
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeSelectors(BuildContext context) {
    if (widget.variationAttributes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No variation attributes available. Add an attribute with "Use For Variation" and at least one enabled value first.',
        ),
      );
    }

    return Column(
      children: widget.variationAttributes.map((attribute) {
        final values = _enabledValuesFor(attribute);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            initialValue: (_selectedAttributeValues[attribute.id] ?? '').trim().isEmpty
                ? null
                : _selectedAttributeValues[attribute.id],
            decoration: InputDecoration(
              labelText: attribute.nameEn.isEmpty
                  ? attribute.id
                  : '${attribute.nameEn} (${attribute.id})',
              border: const OutlineInputBorder(),
            ),
            items: values
                .map(
                  (item) => DropdownMenuItem<String>(
                value: item.value.trim(),
                child: Text(
                  item.labelEn.trim().isEmpty
                      ? item.value
                      : '${item.labelEn} (${item.value})',
                ),
              ),
            )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedAttributeValues[attribute.id] = value;
              });
            },
            validator: (value) {
              if (!attribute.useForVariation) return null;
              if ((value ?? '').trim().isEmpty) {
                return 'Select a value for ${attribute.nameEn.isEmpty ? attribute.id : attribute.nameEn}';
              }
              return null;
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    final value = widget.initialValue;

    _idController = TextEditingController(
      text: value.id.trim().isEmpty ? makeEditorId('variation') : value.id,
    );
    _skuController = TextEditingController(text: value.sku);
    _barcodeController = TextEditingController(text: value.barcode ?? '');
    _titleEnController = TextEditingController(text: value.titleEn);
    _titleBnController = TextEditingController(text: value.titleBn);
    _imageUrlController =
        TextEditingController(text: value.effectiveFullImageUrl);
    _thumbImageUrlController =
        TextEditingController(text: value.effectiveThumbImageUrl);
    _descriptionEnController = TextEditingController(text: value.descriptionEn);
    _descriptionBnController = TextEditingController(text: value.descriptionBn);
    _priceController = TextEditingController(text: asTextDouble(value.price));
    _salePriceController =
        TextEditingController(text: asTextNullableDouble(value.salePrice));
    _costPriceController =
        TextEditingController(text: asTextNullableDouble(value.costPrice));
    _stockQtyController = TextEditingController(text: value.stockQty.toString());
    _reservedQtyController =
        TextEditingController(text: value.reservedQty.toString());
    _sortOrderController =
        TextEditingController(text: value.sortOrder.toString());

    _trackInventory = value.trackInventory;
    _allowBackorder = value.allowBackorder;
    _isDefault = value.isDefault;
    _isEnabled = value.isEnabled;

    _selectedAttributeValues = <String, String?>{};
    for (final attribute in widget.variationAttributes) {
      _selectedAttributeValues[attribute.id] =
          _initialSelectedValueFor(attribute, value);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _titleEnController.dispose();
    _titleBnController.dispose();
    _imageUrlController.dispose();
    _thumbImageUrlController.dispose();
    _descriptionEnController.dispose();
    _descriptionBnController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _costPriceController.dispose();
    _stockQtyController.dispose();
    _reservedQtyController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Variation'),
      content: SizedBox(
        width: 860,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Each variation now keeps a full image and a thumbnail image. The same shared product portrait resize pipeline is used here.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Identity',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                dialogTextField(
                  _idController,
                  'Id',
                  validator: requiredValidator,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _skuController,
                        'SKU',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _barcodeController,
                        'Barcode',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _titleEnController,
                        'Title (English)',
                        validator: requiredValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _titleBnController,
                        'Title (Bangla)',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Variation Image',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                _buildVariationImagePreview(context),
                const SizedBox(height: 12),
                if (_imageErrorText != null && _imageErrorText!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _imageErrorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isImageProcessing
                            ? null
                            : _pickResizeAndUploadVariationImage,
                        icon: _isImageProcessing
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(
                          _imageUrlController.text.trim().isEmpty
                              ? 'Pick, Resize & Upload'
                              : 'Replace Variation Image',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _thumbImageUrlController,
                        'Variation Thumb URL',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _imageUrlController,
                        'Variation Full URL',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildVariationImageInfo(),


                const SizedBox(height: 20),
                Text(
                  'Variation Descriptions',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _descriptionEnController,
                        'Description (English)',
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _descriptionBnController,
                        'Description (Bangla)',
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Variation Pricing',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _priceController,
                        'Price',
                        validator: requiredValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _salePriceController,
                        'Sale Price',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _costPriceController,
                        'Cost Price',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Variation Inventory',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _stockQtyController,
                        'Stock Qty',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _reservedQtyController,
                        'Reserved Qty',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _sortOrderController,
                        'Sort Order',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    buildFilterChip(
                      label: 'Track Inventory',
                      selected: _trackInventory,
                      onSelected: (value) =>
                          setState(() => _trackInventory = value),
                    ),
                    buildFilterChip(
                      label: 'Allow Backorder',
                      selected: _allowBackorder,
                      onSelected: (value) =>
                          setState(() => _allowBackorder = value),
                    ),
                    buildFilterChip(
                      label: 'Default',
                      selected: _isDefault,
                      onSelected: (value) =>
                          setState(() => _isDefault = value),
                    ),
                    buildFilterChip(
                      label: 'Enabled',
                      selected: _isEnabled,
                      onSelected: (value) =>
                          setState(() => _isEnabled = value),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Attribute Values',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select one value for each variation attribute.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                _buildAttributeSelectors(context),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImageProcessing
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isImageProcessing
              ? null
              : () {
            if (!_formKey.currentState!.validate()) return;

            if (_imageUrlController.text.trim().isEmpty) {
              setState(() {
                _imageErrorText = 'Please pick and upload one variation image first.';
              });
              return;
            }

            Navigator.of(context).pop(
              MBProductVariation(
                id: _idController.text.trim(),
                sku: _skuController.text.trim(),
                barcode: _barcodeController.text.trim().isEmpty
                    ? null
                    : _barcodeController.text.trim(),
                titleEn: _titleEnController.text.trim(),
                titleBn: _titleBnController.text.trim(),
                imageUrl: _imageUrlController.text.trim(),
                fullImageUrl: _imageUrlController.text.trim(),
                thumbImageUrl: _thumbImageUrlController.text.trim(),
                fullImageStoragePath:
                _uploadedImage?.fullPath ?? widget.initialValue.fullImageStoragePath,
                thumbImageStoragePath:
                _uploadedImage?.thumbPath ?? widget.initialValue.thumbImageStoragePath,
                fullImageWidth:
                _uploadedImage?.fullWidth ?? widget.initialValue.fullImageWidth,
                fullImageHeight:
                _uploadedImage?.fullHeight ?? widget.initialValue.fullImageHeight,
                thumbImageWidth:
                _preparedImage?.thumbWidth ?? widget.initialValue.thumbImageWidth,
                thumbImageHeight:
                _preparedImage?.thumbHeight ?? widget.initialValue.thumbImageHeight,
                fullImageSizeBytes:
                _preparedImage?.fullByteLength ?? widget.initialValue.fullImageSizeBytes,
                thumbImageSizeBytes:
                _preparedImage?.thumbByteLength ?? widget.initialValue.thumbImageSizeBytes,
                originalImageWidth:
                _preparedImage?.sourceWidth ?? widget.initialValue.originalImageWidth,
                originalImageHeight:
                _preparedImage?.sourceHeight ?? widget.initialValue.originalImageHeight,
                descriptionEn: _descriptionEnController.text.trim(),
                descriptionBn: _descriptionBnController.text.trim(),
                price: parseDouble(_priceController.text),
                salePrice: parseNullableDouble(_salePriceController.text),
                costPrice: parseNullableDouble(_costPriceController.text),
                stockQty: parseInt(_stockQtyController.text),
                reservedQty: parseInt(_reservedQtyController.text),
                trackInventory: _trackInventory,
                allowBackorder: _allowBackorder,
                attributeValues: _buildSelectedAttributeMap(),
                sortOrder: parseInt(_sortOrderController.text),
                isDefault: _isDefault,
                isEnabled: _isEnabled,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class PurchaseOptionDialog extends StatefulWidget {
  const PurchaseOptionDialog({super.key, required this.initialValue});

  final MBProductPurchaseOption initialValue;

  @override
  State<PurchaseOptionDialog> createState() => _PurchaseOptionDialogState();
}

class _PurchaseOptionDialogState extends State<PurchaseOptionDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _idController;
  late final TextEditingController _labelEnController;
  late final TextEditingController _labelBnController;
  late final TextEditingController _priceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _minScheduleDaysController;
  late final TextEditingController _maxScheduleDaysController;
  late final TextEditingController _availableShiftsController;
  late final TextEditingController _cutoffTimeController;
  late final TextEditingController _helperTextEnController;
  late final TextEditingController _helperTextBnController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _maxQtyPerOrderController;

  late String _mode;
  late String _fulfillmentType;
  late bool _isEnabled;
  late bool _supportsDateSelection;
  late bool _isDefault;
  bool get _isScheduledMode =>
      _mode.trim().toLowerCase() == 'scheduled' ||
          _mode.trim().toLowerCase() == 'preorder';

  bool get _showScheduleFields => _isScheduledMode || _supportsDateSelection;

  String get _purchaseOptionHelpText {
    if (_showScheduleFields) {
      return 'This purchase option uses scheduling-related fields such as schedule window, shifts, and cutoff.';
    }

    return 'This purchase option is mainly instant/today style. Keep schedule-only fields minimal unless needed.';
  }

  @override
  void initState() {
    super.initState();
    final value = widget.initialValue;
    _idController = TextEditingController(text: value.id);
    _labelEnController = TextEditingController(text: value.labelEn);
    _labelBnController = TextEditingController(text: value.labelBn);
    _priceController = TextEditingController(text: asTextDouble(value.price));
    _salePriceController = TextEditingController(text: asTextNullableDouble(value.salePrice));
    _minScheduleDaysController = TextEditingController(text: value.minScheduleDays.toString());
    _maxScheduleDaysController = TextEditingController(text: value.maxScheduleDays.toString());
    _availableShiftsController = TextEditingController(text: value.availableShifts.join(', '));
    _cutoffTimeController = TextEditingController(text: value.cutoffTime ?? '');
    _helperTextEnController = TextEditingController(text: value.helperTextEn ?? '');
    _helperTextBnController = TextEditingController(text: value.helperTextBn ?? '');
    _sortOrderController = TextEditingController(text: value.sortOrder.toString());
    _maxQtyPerOrderController = TextEditingController(text: asTextNullableDouble(value.maxQtyPerOrder));
    _mode = value.mode.isEmpty ? 'instant' : value.mode;
    _fulfillmentType = value.fulfillmentType.isEmpty ? 'standard' : value.fulfillmentType;
    _isEnabled = value.isEnabled;
    _supportsDateSelection = value.supportsDateSelection;
    _isDefault = value.isDefault;
  }

  @override
  void dispose() {
    _idController.dispose();
    _labelEnController.dispose();
    _labelBnController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _minScheduleDaysController.dispose();
    _maxScheduleDaysController.dispose();
    _availableShiftsController.dispose();
    _cutoffTimeController.dispose();
    _helperTextEnController.dispose();
    _helperTextBnController.dispose();
    _sortOrderController.dispose();
    _maxQtyPerOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Purchase Option'),
      content: SizedBox(
        width: 860,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    _purchaseOptionHelpText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Identity',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),

                dialogTextField(
                  _idController,
                  'Id',
                  validator: requiredValidator,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: dialogDropdown(
                        label: 'Mode',
                        value: _mode,
                        items: const ['instant', 'scheduled', 'today', 'preorder'],
                        onChanged: (value) => setState(() => _mode = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogDropdown(
                        label: 'Fulfillment Type',
                        value: _fulfillmentType,
                        items: const ['standard', 'instant', 'scheduled', 'fresh'],
                        onChanged: (value) =>
                            setState(() => _fulfillmentType = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _labelEnController,
                        'Label (English)',
                        validator: requiredValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _labelBnController,
                        'Label (Bangla)',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Pricing',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _priceController,
                        'Price',
                        validator: requiredValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _salePriceController,
                        'Sale Price',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _maxQtyPerOrderController,
                        'Max Qty Per Order',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Scheduling',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    buildFilterChip(
                      label: 'Enabled',
                      selected: _isEnabled,
                      onSelected: (value) =>
                          setState(() => _isEnabled = value),
                    ),
                    buildFilterChip(
                      label: 'Date Selection',
                      selected: _supportsDateSelection,
                      onSelected: (value) =>
                          setState(() => _supportsDateSelection = value),
                    ),
                    buildFilterChip(
                      label: 'Default',
                      selected: _isDefault,
                      onSelected: (value) =>
                          setState(() => _isDefault = value),
                    ),
                  ],
                ),

                if (_showScheduleFields) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: dialogTextField(
                          _minScheduleDaysController,
                          'Min Schedule Days',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: dialogTextField(
                          _maxScheduleDaysController,
                          'Max Schedule Days',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: dialogTextField(
                          _sortOrderController,
                          'Sort Order',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  dialogTextField(
                    _availableShiftsController,
                    'Available Shifts (comma separated)',
                  ),
                  const SizedBox(height: 12),
                  dialogTextField(
                    _cutoffTimeController,
                    'Cutoff Time',
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  dialogTextField(
                    _sortOrderController,
                    'Sort Order',
                  ),
                ],

                const SizedBox(height: 20),
                Text(
                  'Helper Text',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _helperTextEnController,
                        'Helper Text (English)',
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _helperTextBnController,
                        'Helper Text (Bangla)',
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              MBProductPurchaseOption(
                id: _idController.text.trim(),
                mode: _mode,
                labelEn: _labelEnController.text.trim(),
                labelBn: _labelBnController.text.trim(),
                price: parseDouble(_priceController.text),
                salePrice: parseNullableDouble(_salePriceController.text),
                isEnabled: _isEnabled,
                supportsDateSelection: _supportsDateSelection,
                minScheduleDays: parseInt(_minScheduleDaysController.text),
                maxScheduleDays: parseInt(_maxScheduleDaysController.text),
                availableShifts: splitCsv(_availableShiftsController.text),
                cutoffTime: _cutoffTimeController.text.trim().isEmpty
                    ? null
                    : _cutoffTimeController.text.trim(),
                helperTextEn: _helperTextEnController.text.trim().isEmpty
                    ? null
                    : _helperTextEnController.text.trim(),
                helperTextBn: _helperTextBnController.text.trim().isEmpty
                    ? null
                    : _helperTextBnController.text.trim(),
                sortOrder: parseInt(_sortOrderController.text),
                isDefault: _isDefault,
                maxQtyPerOrder: parseNullableDouble(_maxQtyPerOrderController.text),
                fulfillmentType: _fulfillmentType,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

