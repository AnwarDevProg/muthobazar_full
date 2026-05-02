
import 'dart:convert';
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
        fit: BoxFit.contain,
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
        fit: BoxFit.contain,
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

      final MBPreparedImageSet prepared =
          await MBImagePipelineService.instance.prepareImageSetFromOriginal(
        original: original,
        fullMaxWidth: _productFullMaxWidth,
        fullMaxHeight: _productFullMaxHeight,
        fullJpegQuality: _productFullJpegQuality,
        thumbSize: _productThumbSize,
        thumbJpegQuality: _productThumbJpegQuality,
        requestSquareCrop: false,
        requestAspectCrop: false,
        cropAspectRatioX: 4,
        cropAspectRatioY: 5,
        thumbWidth: _productThumbWidth,
        thumbHeight: _productThumbHeight,
        originalMaxLongSide: _productOriginalMaxLongSide,
        originalJpegQuality: _productOriginalJpegQuality,
        cardWidth: _productCardWidth,
        cardHeight: _productCardHeight,
        cardJpegQuality: _productCardJpegQuality,
        tinyWidth: _productTinyWidth,
        tinyHeight: _productTinyHeight,
        tinyJpegQuality: _productTinyJpegQuality,
      );

      if (_labelEnController.text.trim().isEmpty) {
        _labelEnController.text = prepared.baseName.replaceAll('_', ' ');
      }

      setState(() {
        _pickedOriginalImage = original;
        _preparedImage = prepared;
        // Upload intentionally does not happen inside the Media Item dialog.
        // These bytes stay in memory and are uploaded only when Save Product
        // is clicked in the main product dialog.
        _uploadedImage = null;
        _cardCropPreparedImage = null;
        _cardCropUploadedImage = null;
        _type = 'image';
        _role = _effectiveRole;
        _isProcessing = false;
      });
    } catch (error) {
      setState(() {
        _isProcessing = false;
        _errorText = error.toString();
      });
    }
  }

  Future<void> _cropAndUploadCardImage() async {
    final original = _pickedOriginalImage;
    if (original == null) {
      setState(() {
        _errorText =
            'Pick or replace the image first. Card crop is available during the current upload session.';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorText = null;
    });

    try {
      final MBCroppedImageResult? cropped = await MBImageCropDialog.show(
        context,
        original: original,
        cropAspectRatioX: 4,
        cropAspectRatioY: 5,
        title: 'Edit Card Crop',
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
        originalMaxLongSide: _productOriginalMaxLongSide,
        originalJpegQuality: _productOriginalJpegQuality,
        cardWidth: _productCardWidth,
        cardHeight: _productCardHeight,
        cardJpegQuality: _productCardJpegQuality,
        tinyWidth: _productTinyWidth,
        tinyHeight: _productTinyHeight,
        tinyJpegQuality: _productTinyJpegQuality,
      );

      setState(() {
        // Keep crop result local only. Product save uploads it later.
        _cardCropPreparedImage = prepared;
        _cardCropUploadedImage = null;
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
    final uploadedFull = (_uploadedImage?.fullUrl ?? '').trim();
    if (uploadedFull.isNotEmpty) return uploadedFull;

    final current = _urlController.text.trim();
    if (current.isNotEmpty) return current;

    return widget.initialValue.effectiveFullUrl.trim();
  }

  String get _currentOriginalPreviewUrl {
    final uploadedOriginal = (_uploadedImage?.originalUrl ?? '').trim();
    if (uploadedOriginal.isNotEmpty) return uploadedOriginal;

    final current = widget.initialValue.effectiveOriginalUrl.trim();
    if (current.isNotEmpty) return current;

    return _currentFullPreviewUrl;
  }

  String get _currentCardPreviewUrl {
    final manualCard = (_cardCropUploadedImage?.cardUrl ?? '').trim();
    if (manualCard.isNotEmpty) return manualCard;

    final uploadedCard = (_uploadedImage?.cardUrl ?? '').trim();
    if (uploadedCard.isNotEmpty) return uploadedCard;

    final current = widget.initialValue.effectiveCardUrl.trim();
    if (current.isNotEmpty) return current;

    return _currentFullPreviewUrl;
  }

  String get _currentThumbPreviewUrl {
    final uploadedThumb = (_uploadedImage?.thumbUrl ?? '').trim();
    if (uploadedThumb.isNotEmpty) return uploadedThumb;

    final current = widget.initialValue.effectiveThumbUrl.trim();
    if (current.isNotEmpty) return current;

    return _currentCardPreviewUrl;
  }

  String get _currentTinyPreviewUrl {
    final uploadedTiny = (_uploadedImage?.tinyUrl ?? '').trim();
    if (uploadedTiny.isNotEmpty) return uploadedTiny;

    final current = widget.initialValue.effectiveTinyUrl.trim();
    if (current.isNotEmpty) return current;

    return _currentThumbPreviewUrl;
  }

  bool get _hasCurrentSessionOriginal => _pickedOriginalImage != null;

  Widget _buildImageInfoCard(
    BuildContext context, {
    required String status,
    int? width,
    int? height,
    int? byteLength,
    String extra = '',
  }) {
    final theme = Theme.of(context);
    final details = <String>[
      if (width != null && height != null) '$width Ã- $height px',
      if (byteLength != null) _bytesText(byteLength),
      if (extra.trim().isNotEmpty) extra.trim(),
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              details.join(' â€¢ '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewTile(
    BuildContext context, {
    required String label,
    required String url,
    Uint8List? memoryBytes,
    int? width,
    int? heightPx,
    int? byteLength,
    String status = 'Existing remote image',
    String extra = '',
    double height = 220,
    BoxFit fit = BoxFit.contain,
  }) {
    final Widget child;

    if (memoryBytes != null) {
      child = Image.memory(
        memoryBytes,
        fit: fit,
        width: double.infinity,
        height: height,
      );
    } else if (url.trim().isNotEmpty) {
      child = Image.network(
        url.trim(),
        fit: fit,
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          clipBehavior: Clip.hardEdge,
          child: child,
        ),
        _buildImageInfoCard(
          context,
          status: memoryBytes != null ? status : (url.trim().isEmpty ? 'No image selected' : 'Existing remote image'),
          width: width,
          height: heightPx,
          byteLength: byteLength,
          extra: extra,
        ),
      ],
    );
  }

  Widget _buildPreviewBox(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPreviewTile(
                context,
                label: 'Original Preview',
                url: _currentOriginalPreviewUrl,
                memoryBytes: _pickedOriginalImage?.originalBytes,
                width: _preparedImage?.sourceWidth ?? widget.initialValue.effectiveOriginalWidth,
                heightPx: _preparedImage?.sourceHeight ?? widget.initialValue.effectiveOriginalHeight,
                byteLength: _pickedOriginalImage?.originalByteLength ?? widget.initialValue.effectiveOriginalSizeBytes,
                status: 'Local original - not uploaded yet',
                extra: 'Kept visible; upload happens on Save Product',
                height: 260,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPreviewTile(
                context,
                label: 'Full Preview',
                url: _currentFullPreviewUrl,
                memoryBytes: _preparedImage?.fullBytes,
                width: _preparedImage?.fullWidth ?? widget.initialValue.effectiveFullWidth,
                heightPx: _preparedImage?.fullHeight ?? widget.initialValue.effectiveFullHeight,
                byteLength: _preparedImage?.fullByteLength ?? widget.initialValue.effectiveFullSizeBytes,
                status: 'Local optimized full - pending upload',
                extra: 'Used on product details page',
                height: 260,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPreviewTile(
                context,
                label: 'Card Preview 4:5',
                url: _currentCardPreviewUrl,
                memoryBytes:
                    _cardCropPreparedImage?.cardBytes ?? _preparedImage?.cardBytes,
                width: _cardCropPreparedImage?.cardWidth ?? _preparedImage?.cardWidth ?? widget.initialValue.effectiveCardWidth,
                heightPx: _cardCropPreparedImage?.cardHeight ?? _preparedImage?.cardHeight ?? widget.initialValue.effectiveCardHeight,
                byteLength: _cardCropPreparedImage?.cardByteLength ?? _preparedImage?.cardByteLength ?? widget.initialValue.effectiveCardSizeBytes,
                status: _cardCropPreparedImage == null
                    ? 'Local card contain-fit - pending upload'
                    : 'Local manual card crop - pending upload',
                extra: 'Used in product card/grid',
                height: 220,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPreviewTile(
                context,
                label: 'Thumb Preview',
                url: _currentThumbPreviewUrl,
                memoryBytes: _preparedImage?.thumbBytes,
                width: _preparedImage?.thumbWidth ?? widget.initialValue.effectiveThumbWidth,
                heightPx: _preparedImage?.thumbHeight ?? widget.initialValue.effectiveThumbHeight,
                byteLength: _preparedImage?.thumbByteLength ?? widget.initialValue.effectiveThumbSizeBytes,
                status: 'Local thumbnail - pending upload',
                extra: 'Used in admin/cart/order lists',
                height: 220,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPreviewTile(
                context,
                label: 'Tiny Preview',
                url: _currentTinyPreviewUrl,
                memoryBytes: _preparedImage?.tinyBytes,
                width: _preparedImage?.tinyWidth ?? widget.initialValue.effectiveTinyWidth,
                heightPx: _preparedImage?.tinyHeight ?? widget.initialValue.effectiveTinyHeight,
                byteLength: _preparedImage?.tinyByteLength ?? widget.initialValue.effectiveTinySizeBytes,
                status: 'Local tiny preview - pending upload',
                extra: 'Used in tiny rows/chips',
                height: 220,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    );
  }


  MBOriginalPickedImage? _pickedOriginalImage;
  MBPreparedImageSet? _preparedImage;
  MBUploadedImageSet? _uploadedImage;
  MBPreparedImageSet? _cardCropPreparedImage;
  MBUploadedImageSet? _cardCropUploadedImage;

  static const int _productOriginalMaxLongSide = 2048;
  static const int _productOriginalJpegQuality = 90;
  static const int _productFullMaxWidth = 1400;
  static const int _productFullMaxHeight = 1400;
  static const int _productFullJpegQuality = 84;
  static const int _productCardWidth = 600;
  static const int _productCardHeight = 750;
  static const int _productCardJpegQuality = 80;
  static const int _productThumbWidth = 240;
  static const int _productThumbHeight = 300;
  static const int _productThumbSize = 240;
  static const int _productThumbJpegQuality = 76;
  static const int _productTinyWidth = 120;
  static const int _productTinyHeight = 150;
  static const int _productTinyJpegQuality = 72;




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
    final prepared = _preparedImage;
    final cardPrepared = _cardCropPreparedImage;
    final hasPendingImage = prepared != null;
    final fitMode = cardPrepared == null ? 'contain' : 'manualCrop';

    return existing.copyWith(
      id: _idController.text.trim(),
      // For pending media, keep existing remote URLs until Save Product uploads
      // the new bytes. New media will have empty URLs until product save.
      url: hasPendingImage ? existing.url : _currentFullPreviewUrl,
      storagePath: hasPendingImage
          ? existing.storagePath
          : _storagePathController.text.trim(),
      fullUrl: hasPendingImage ? existing.fullUrl : _currentFullPreviewUrl,
      fullStoragePath: hasPendingImage
          ? existing.fullStoragePath
          : _storagePathController.text.trim(),
      cardUrl: hasPendingImage ? existing.cardUrl : _currentCardPreviewUrl,
      cardStoragePath: hasPendingImage
          ? existing.cardStoragePath
          : existing.cardStoragePath,
      thumbUrl: hasPendingImage ? existing.thumbUrl : _currentThumbPreviewUrl,
      thumbStoragePath: hasPendingImage
          ? existing.thumbStoragePath
          : existing.thumbStoragePath,
      tinyUrl: hasPendingImage ? existing.tinyUrl : _currentTinyPreviewUrl,
      tinyStoragePath: hasPendingImage
          ? existing.tinyStoragePath
          : existing.tinyStoragePath,
      originalUrl: hasPendingImage ? existing.originalUrl : _currentOriginalPreviewUrl,
      originalStoragePath: hasPendingImage
          ? existing.originalStoragePath
          : existing.originalStoragePath,
      type: _type,
      role: _effectiveRole,
      labelEn: _labelEnController.text.trim(),
      labelBn: _labelBnController.text.trim(),
      altEn: _altEnController.text.trim(),
      altBn: _altBnController.text.trim(),
      sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
      isPrimary: _isPrimary,
      isEnabled: _isEnabled,
      width: prepared?.fullWidth ?? existing.width,
      height: prepared?.fullHeight ?? existing.height,
      sizeBytes: prepared?.fullByteLength ?? existing.sizeBytes,
      fullWidth: prepared?.fullWidth ?? existing.fullWidth,
      fullHeight: prepared?.fullHeight ?? existing.fullHeight,
      fullSizeBytes: prepared?.fullByteLength ?? existing.fullSizeBytes,
      cardWidth: cardPrepared?.cardWidth ?? prepared?.cardWidth ?? existing.cardWidth,
      cardHeight: cardPrepared?.cardHeight ?? prepared?.cardHeight ?? existing.cardHeight,
      cardSizeBytes:
          cardPrepared?.cardByteLength ?? prepared?.cardByteLength ?? existing.cardSizeBytes,
      thumbWidth: prepared?.thumbWidth ?? existing.thumbWidth,
      thumbHeight: prepared?.thumbHeight ?? existing.thumbHeight,
      thumbSizeBytes: prepared?.thumbByteLength ?? existing.thumbSizeBytes,
      tinyWidth: prepared?.tinyWidth ?? existing.tinyWidth,
      tinyHeight: prepared?.tinyHeight ?? existing.tinyHeight,
      tinySizeBytes: prepared?.tinyByteLength ?? existing.tinySizeBytes,
      originalWidth: prepared?.sourceWidth ?? existing.originalWidth,
      originalHeight: prepared?.sourceHeight ?? existing.originalHeight,
      originalSizeBytes:
          prepared?.originalByteLength ?? existing.originalSizeBytes,
      fitMode: hasPendingImage ? fitMode : existing.fitMode,
      cropAspectRatioX: hasPendingImage ? 4 : existing.cropAspectRatioX,
      cropAspectRatioY: hasPendingImage ? 5 : existing.cropAspectRatioY,
      cropWidth: cardPrepared?.croppedWidth ?? prepared?.croppedWidth ?? existing.cropWidth,
      cropHeight: cardPrepared?.croppedHeight ?? prepared?.croppedHeight ?? existing.cropHeight,
      cropSizeBytes: cardPrepared?.croppedByteLength ??
          prepared?.croppedByteLength ??
          existing.cropSizeBytes,
      cropZoomScale: cardPrepared?.zoomScale ?? prepared?.zoomScale ?? existing.cropZoomScale,
      pendingOriginalBytes: prepared?.originalBytes,
      pendingFullBytes: prepared?.fullBytes,
      pendingCardBytes: cardPrepared?.cardBytes ?? prepared?.cardBytes,
      pendingThumbBytes: prepared?.thumbBytes,
      pendingTinyBytes: prepared?.tinyBytes,
      pendingOriginalFileName: prepared?.originalFileName,
      pendingBaseName: prepared?.baseName,
      pendingMimeType: prepared?.mimeType,
      clearPendingUpload: !hasPendingImage,
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
                    'Image-only phase. Pick an image once; the original preview stays visible and optimized original/full/card/thumb/tiny images are generated automatically. Crop is optional and only affects the card image.',
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
                              ? 'Pick & Optimize Image'
                              : 'Replace Image',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: (_isProcessing || !_hasCurrentSessionOriginal)
                            ? null
                            : _cropAndUploadCardImage,
                        icon: const Icon(Icons.crop),
                        label: const Text('Edit Card Crop (Optional)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _hasCurrentSessionOriginal
                      ? 'Optional card crop is available for this local image. Full/original image will stay unchanged.'
                      : 'Pick or replace an image to enable optional card crop.',
                  style: Theme.of(context).textTheme.bodySmall,
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
                _buildInfoRow(
                  'Upload Status',
                  _preparedImage == null
                      ? (_urlController.text.trim().isEmpty ? 'No image selected' : 'Existing remote image')
                      : 'Local pending image. It will upload only after Save Product.',
                ),
                if (_urlController.text.trim().isNotEmpty)
                  _buildInfoRow('Existing Uploaded URL', _urlController.text.trim()),
                if (_storagePathController.text.trim().isNotEmpty)
                  _buildInfoRow('Existing Storage Path', _storagePathController.text.trim()),
                const SizedBox(height: 8),
                if (_preparedImage != null) ...[
                  _buildInfoRow(
                    'Original Pixels',
                    '${_preparedImage!.sourceWidth} Ãƒâ€” ${_preparedImage!.sourceHeight}',
                  ),
                  _buildInfoRow(
                    'Original Ratio',
                    _ratioText(_preparedImage!.sourceWidth, _preparedImage!.sourceHeight),
                  ),
                  _buildInfoRow(
                    'Card/Crop Pixels',
                    '${_preparedImage!.croppedWidth} Ãƒâ€” ${_preparedImage!.croppedHeight}',
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
                    'Card/Crop Size',
                    _bytesText(_preparedImage!.croppedByteLength),
                  ),
                  _buildInfoRow(
                    'Full Pixels',
                    '${_preparedImage!.fullWidth} Ãƒâ€” ${_preparedImage!.fullHeight}',
                  ),
                  _buildInfoRow(
                    'Full Size',
                    _bytesText(_preparedImage!.fullByteLength),
                  ),
                  _buildInfoRow(
                    'Thumb Pixels',
                    '${_preparedImage!.thumbWidth} Ãƒâ€” ${_preparedImage!.thumbHeight}',
                  ),
                  _buildInfoRow(
                    'Thumb Size',
                    _bytesText(_preparedImage!.thumbByteLength),
                  ),
                  _buildInfoRow(
                    'Tiny Pixels',
                    '${_preparedImage!.tinyWidth} Ã- ${_preparedImage!.tinyHeight}',
                  ),
                  _buildInfoRow(
                    'Tiny Size',
                    _bytesText(_preparedImage!.tinyByteLength),
                  ),
                ] else ...[
                  _buildInfoRow('Original Pixels', '-'),
                  _buildInfoRow('Original Ratio', '-'),
                  _buildInfoRow('Card/Crop Pixels', '-'),
                  _buildInfoRow('Crop Ratio', '-'),
                  _buildInfoRow('Crop Zoom', '-'),
                  _buildInfoRow('Card/Crop Size', '-'),
                  _buildInfoRow('Full Pixels', '-'),
                  _buildInfoRow('Full Size', '-'),
                  _buildInfoRow('Thumb Pixels', '-'),
                  _buildInfoRow('Thumb Size', '-'),
                  _buildInfoRow('Tiny Pixels', '-'),
                  _buildInfoRow('Tiny Size', '-'),
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

            if (_urlController.text.trim().isEmpty && _preparedImage == null) {
              setState(() {
                _errorText = 'Please pick an image first.';
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
  const AttributeValueDialog({
    super.key,
    required this.initialValue,
    this.suggestedValues = const <String>[],
  });

  final MBProductAttributeValue initialValue;
  final List<String> suggestedValues;

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
                    child: Autocomplete<String>(
                      initialValue: TextEditingValue(text: _valueController.text),
                      optionsBuilder: (textEditingValue) {
                        final query = textEditingValue.text.trim().toLowerCase();
                        if (widget.suggestedValues.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        if (query.isEmpty) {
                          return widget.suggestedValues;
                        }
                        return widget.suggestedValues.where(
                              (item) => item.toLowerCase().contains(query),
                        );
                      },
                      onSelected: (value) {
                        _valueController.text = value;
                        if (_labelEnController.text.trim().isEmpty) {
                          _labelEnController.text = value;
                        }
                      },
                      fieldViewBuilder:
                          (context, textController, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: textController,
                          focusNode: focusNode,
                          validator: requiredValidator,
                          decoration: const InputDecoration(
                            labelText: 'Value',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _valueController.value = TextEditingValue(
                              text: value,
                              selection: TextSelection.collapsed(
                                offset: value.length,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: dialogTextField(_sortOrderController, 'Sort Order'),
                  ),
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

  String get _attributeModeHelpText =>
      'This attribute will be used for product variations. Pick a known preset if possible so value suggestions become faster and cleaner.';

  MBAttributePreset? get _matchedPreset {
    return findAttributePreset(
      nameEn: _nameEnController.text,
      code: _codeController.text,
    );
  }

  void _applyAttributePreset(MBAttributePreset preset) {
    _nameEnController.text = preset.nameEn;

    if (_nameBnController.text.trim().isEmpty && preset.nameBn.trim().isNotEmpty) {
      _nameBnController.text = preset.nameBn;
    }

    _codeController.text = preset.code;

    setState(() {
      _displayType = preset.displayType;
    });
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
    _isVisible = true;
    _useForVariation = true;
    _isRequired = false;
    _displayType = value.displayType.trim().isEmpty ? 'text' : value.displayType;
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
    final preset = _matchedPreset;

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
        suggestedValues: preset?.suggestedValues ?? const <String>[],
      ),
    );

    if (result == null) return;
    setState(() {
      _values.add(result);
      _values.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  Future<void> _editValue(MBProductAttributeValue value) async {
    final preset = _matchedPreset;

    final result = await showDialog<MBProductAttributeValue>(
      context: context,
      builder: (_) => AttributeValueDialog(
        initialValue: value,
        suggestedValues: preset?.suggestedValues ?? const <String>[],
      ),
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
                            'Name (Bangla): Ã Â¦Â¸Ã Â¦Â¾Ã Â¦â€¡Ã Â¦Å“\n'
                            'Code: size\n'
                            'Display Type: text\n'
                            'Values: 500g, 1kg',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Example 2\n'
                            'Name (English): Color\n'
                            'Code: color\n'
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
                      child: Autocomplete<MBAttributePreset>(
                        initialValue: TextEditingValue(text: _nameEnController.text),
                        displayStringForOption: (option) => option.nameEn,
                        optionsBuilder: (textEditingValue) {
                          final query = textEditingValue.text.trim().toLowerCase();
                          if (query.isEmpty) return kMbAttributePresets;
                          return kMbAttributePresets.where(
                                (item) =>
                            item.nameEn.toLowerCase().contains(query) ||
                                item.code.toLowerCase().contains(query),
                          );
                        },
                        onSelected: _applyAttributePreset,
                        fieldViewBuilder:
                            (context, textController, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: textController,
                            focusNode: focusNode,
                            validator: requiredValidator,
                            decoration: const InputDecoration(
                              labelText: 'Name (English)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _nameEnController.value = TextEditingValue(
                                text: value,
                                selection: TextSelection.collapsed(
                                  offset: value.length,
                                ),
                              );
                            },
                          );
                        },
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
                      child: Autocomplete<MBAttributePreset>(
                        initialValue: TextEditingValue(text: _codeController.text),
                        displayStringForOption: (option) => option.code,
                        optionsBuilder: (textEditingValue) {
                          final query = textEditingValue.text.trim().toLowerCase();
                          if (query.isEmpty) return kMbAttributePresets;
                          return kMbAttributePresets.where(
                                (item) =>
                            item.code.toLowerCase().contains(query) ||
                                item.nameEn.toLowerCase().contains(query),
                          );
                        },
                        onSelected: _applyAttributePreset,
                        fieldViewBuilder:
                            (context, textController, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: textController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Code',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _codeController.value = TextEditingValue(
                                text: value,
                                selection: TextSelection.collapsed(
                                  offset: value.length,
                                ),
                              );
                            },
                          );
                        },
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
                  'Display',
                  style: Theme.of(context).textTheme.titleSmall,
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
                        'value: ${item.value} Ã¢â‚¬Â¢ order: ${item.sortOrder} Ã¢â‚¬Â¢ enabled: ${item.isEnabled}',
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
                isVisible: true,
                useForVariation: true,
                isRequired: false,
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
  late final TextEditingController _shortDescriptionEnController;
  late final TextEditingController _shortDescriptionBnController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _thumbImageUrlController;
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _descriptionBnController;

  late final TextEditingController _priceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _saleStartsAtController;
  late final TextEditingController _saleEndsAtController;
  late final TextEditingController _estimatedSchedulePriceController;
  late final TextEditingController _publishAtController;
  late final TextEditingController _unpublishAtController;

  late final TextEditingController _stockQtyController;
  late final TextEditingController _reservedQtyController;
  late final TextEditingController _instantCutoffTimeController;
  late final TextEditingController _todayInstantCapController;
  late final TextEditingController _todayInstantSoldController;
  late final TextEditingController _maxScheduleQtyPerDayController;
  late final TextEditingController _minScheduleNoticeHoursController;
  late final TextEditingController _reorderLevelController;

  late final TextEditingController _quantityValueController;
  late final TextEditingController _toleranceController;
  late final TextEditingController _minOrderQtyController;
  late final TextEditingController _maxOrderQtyController;
  late final TextEditingController _stepQtyController;
  late final TextEditingController _unitLabelEnController;
  late final TextEditingController _unitLabelBnController;
  late final TextEditingController _sortOrderController;

  late final TextEditingController _viewsController;
  late final TextEditingController _totalSoldController;
  late final TextEditingController _addToCartCountController;
  late final TextEditingController _cardLayoutTypeController;
  late final TextEditingController _cardDesignJsonController;
  late final TextEditingController _taxClassIdController;
  late final TextEditingController _vatRateController;
  late final TextEditingController _weightValueController;
  late final TextEditingController _weightUnitController;
  late final TextEditingController _lengthController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  late final TextEditingController _dimensionUnitController;
  late final TextEditingController _shippingClassIdController;
  late final TextEditingController _adminNoteController;
  late final TextEditingController _metadataJsonController;
  late final TextEditingController _createdByController;
  late final TextEditingController _updatedByController;
  late final TextEditingController _deletedByController;
  late final TextEditingController _deleteReasonController;

  late String _inventoryMode;
  late String _schedulePriceType;
  late String _status;
  late String _quantityType;
  late String _toleranceType;
  late String _deliveryShift;

  late bool _trackInventory;
  late bool _supportsInstantOrder;
  late bool _supportsScheduledOrder;
  late bool _allowBackorder;
  late bool _isToleranceActive;
  late bool _isDefault;
  late bool _isEnabled;
  late bool _isTaxIncluded;
  late bool _isDeleted;

  // Variation-level merchandising flags
  late bool _isFeatured;
  late bool _isFlashSale;
  late bool _isNewArrival;
  late bool _isBestSeller;

  DateTime? _saleStartsAt;
  DateTime? _saleEndsAt;
  DateTime? _publishAt;
  DateTime? _unpublishAt;
  DateTime? _deletedAt;

  late List<MBProductPurchaseOption> _purchaseOptions;

  late Map<String, String?> _selectedAttributeValues;


  bool _isImageProcessing = false;
  String? _imageErrorText;
  MBPreparedImageSet? _preparedImage;
  MBUploadedImageSet? _uploadedImage;

  static const int _variationFullMaxWidth = 1400;
  static const int _variationFullMaxHeight = 1400;
  static const int _variationFullJpegQuality = 84;
  static const int _variationThumbWidth = 240;
  static const int _variationThumbHeight = 300;
  static const int _variationThumbSize = 240;
  static const int _variationThumbJpegQuality = 76;

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
        Text('Original Pixels: ${p.sourceWidth} Ãƒâ€” ${p.sourceHeight}'),
        Text('Original Ratio: ${_ratioText(p.sourceWidth, p.sourceHeight)}'),
        Text('Cropped Pixels: ${p.croppedWidth} Ãƒâ€” ${p.croppedHeight}'),
        Text('Crop Ratio: ${p.cropAspectRatioX}:${p.cropAspectRatioY}'),
        Text('Crop Zoom: ${p.zoomScale.toStringAsFixed(2)}'),
        Text('Cropped Size: ${_bytesText(p.croppedByteLength)}'),
        Text('Full Pixels: ${p.fullWidth} Ãƒâ€” ${p.fullHeight}'),
        Text('Full Size: ${_bytesText(p.fullByteLength)}'),
        Text('Thumb Pixels: ${p.thumbWidth} Ãƒâ€” ${p.thumbHeight}'),
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



  String _metadataJsonText(Map<String, dynamic> metadata) {
    if (metadata.isEmpty) {
      return '';
    }

    try {
      return const JsonEncoder.withIndent('  ').convert(metadata);
    } catch (_) {
      return jsonEncode(metadata);
    }
  }

  Map<String, dynamic> _parseMetadataJson(
    String raw, {
    Map<String, dynamic> fallback = const <String, dynamic>{},
  }) {
    final value = raw.trim();
    if (value.isEmpty) {
      return const <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return fallback;
    }

    return fallback;
  }

  String? _metadataJsonValidator(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return null;
      }
    } catch (_) {
      return 'Metadata must be a valid JSON object.';
    }

    return 'Metadata must be a JSON object like {"key":"value"}.';
  }

  Future<void> _addVariationPurchaseOption() async {
    final nextIndex = _purchaseOptions.length;
    final result = await showDialog<MBProductPurchaseOption>(
      context: context,
      builder: (_) => PurchaseOptionDialog(
        initialValue: MBProductPurchaseOption(
          id: makeEditorId('purchase_option'),
          mode: _supportsScheduledOrder ? 'scheduled' : 'instant',
          labelEn: _supportsScheduledOrder ? 'Scheduled' : 'Instant',
          labelBn: '',
          price: parseDouble(_priceController.text),
          salePrice: parseNullableDouble(_salePriceController.text),
          sortOrder: nextIndex,
          isDefault: _purchaseOptions.isEmpty,
          supportsDateSelection: _supportsScheduledOrder,
          fulfillmentType: _supportsScheduledOrder ? 'scheduled' : 'instant',
        ),
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _purchaseOptions = [..._purchaseOptions, result]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  Future<void> _editVariationPurchaseOption(MBProductPurchaseOption option) async {
    final result = await showDialog<MBProductPurchaseOption>(
      context: context,
      builder: (_) => PurchaseOptionDialog(initialValue: option),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _purchaseOptions = _purchaseOptions
          .map((item) => item.id == option.id ? result : item)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  Widget _buildVariationPurchaseOptionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Variation Purchase Options',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            FilledButton.icon(
              onPressed: _addVariationPurchaseOption,
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Optional. If empty, the product-level purchase options can be used as fallback.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (_purchaseOptions.isEmpty)
          const EmptyBlock(
            message: 'No variation-specific purchase options added.',
          )
        else
          Column(
            children: _purchaseOptions
                .map(
                  (item) => EditableTile(
                    title: item.labelEn.trim().isEmpty ? item.id : item.labelEn,
                    subtitle:
                        'mode: ${item.mode} Ã¢â‚¬Â¢ price: ${item.price} Ã¢â‚¬Â¢ default: ${item.isDefault}',
                    onEdit: () => _editVariationPurchaseOption(item),
                    onDelete: () {
                      setState(() {
                        _purchaseOptions.removeWhere(
                          (element) => element.id == item.id,
                        );
                      });
                    },
                  ),
                )
                .toList(),
          ),
      ],
    );
  }



  String get _variationMerchandisingHelpText {
    final List<String> selected = <String>[
      if (_isFeatured) 'Featured',
      if (_isFlashSale) 'Flash Sale',
      if (_isNewArrival) 'New Arrival',
      if (_isBestSeller) 'Best Seller',
    ];

    if (selected.isEmpty) {
      return 'No merchandising flag is active for this variation. Dynamic home sections that rely on variation-level merchandising will ignore this variation.';
    }

    return 'Active flags for this variation: ${selected.join(', ')}';
  }

  Widget _buildVariationMerchandisingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variation Merchandising',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Use these flags for variable-product auto sections. For variable products, merchandising should live in the variation, not only at the product root.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            buildFilterChip(
              label: 'Featured',
              selected: _isFeatured,
              onSelected: (value) => setState(() => _isFeatured = value),
            ),
            buildFilterChip(
              label: 'Flash Sale',
              selected: _isFlashSale,
              onSelected: (value) => setState(() => _isFlashSale = value),
            ),
            buildFilterChip(
              label: 'New Arrival',
              selected: _isNewArrival,
              onSelected: (value) => setState(() => _isNewArrival = value),
            ),
            buildFilterChip(
              label: 'Best Seller',
              selected: _isBestSeller,
              onSelected: (value) => setState(() => _isBestSeller = value),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
            _variationMerchandisingHelpText,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
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

      final MBPreparedImageSet prepared =
          await MBImagePipelineService.instance.prepareImageSetFromOriginal(
        original: original,
        fullMaxWidth: _variationFullMaxWidth,
        fullMaxHeight: _variationFullMaxHeight,
        fullJpegQuality: _variationFullJpegQuality,
        thumbSize: _variationThumbSize,
        thumbJpegQuality: _variationThumbJpegQuality,
        requestSquareCrop: false,
        requestAspectCrop: false,
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
        uploadOriginalCardTiny: true,
        entityId: variationId,
        fileStem: _titleEnController.text.trim().isEmpty
            ? prepared.baseName
            : _titleEnController.text.trim(),
        customMetadata: <String, String>{
          'variationId': variationId,
          'mediaOwner': 'variation',
          'type': 'image',
          'fitMode': 'contain',
          'pipeline': 'muthobazar_multi_size_v1',
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
        fit: BoxFit.contain,
      );
    } else if (url.trim().isNotEmpty) {
      child = Image.network(
        url.trim(),
        height: height,
        width: double.infinity,
        fit: BoxFit.contain,
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
    _shortDescriptionEnController = TextEditingController(
      text: value.shortDescriptionEn,
    );
    _shortDescriptionBnController = TextEditingController(
      text: value.shortDescriptionBn,
    );
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

    _saleStartsAt = value.saleStartsAt;
    _saleEndsAt = value.saleEndsAt;
    _saleStartsAtController =
        TextEditingController(text: formatDateTime(_saleStartsAt));
    _saleEndsAtController =
        TextEditingController(text: formatDateTime(_saleEndsAt));
    _estimatedSchedulePriceController = TextEditingController(
      text: asTextNullableDouble(value.estimatedSchedulePrice),
    );
    _publishAt = value.publishAt;
    _unpublishAt = value.unpublishAt;
    _publishAtController =
        TextEditingController(text: formatDateTime(_publishAt));
    _unpublishAtController =
        TextEditingController(text: formatDateTime(_unpublishAt));

    _stockQtyController = TextEditingController(text: value.stockQty.toString());
    _reservedQtyController =
        TextEditingController(text: value.reservedQty.toString());
    _instantCutoffTimeController =
        TextEditingController(text: value.instantCutoffTime ?? '');
    _todayInstantCapController =
        TextEditingController(text: value.todayInstantCap.toString());
    _todayInstantSoldController =
        TextEditingController(text: value.todayInstantSold.toString());
    _maxScheduleQtyPerDayController =
        TextEditingController(text: value.maxScheduleQtyPerDay.toString());
    _minScheduleNoticeHoursController =
        TextEditingController(text: value.minScheduleNoticeHours.toString());
    _reorderLevelController =
        TextEditingController(text: value.reorderLevel.toString());

    _quantityValueController =
        TextEditingController(text: asTextDouble(value.quantityValue));
    _toleranceController =
        TextEditingController(text: asTextDouble(value.tolerance));
    _minOrderQtyController =
        TextEditingController(text: asTextNullableDouble(value.minOrderQty));
    _maxOrderQtyController =
        TextEditingController(text: asTextNullableDouble(value.maxOrderQty));
    _stepQtyController =
        TextEditingController(text: asTextNullableDouble(value.stepQty));
    _unitLabelEnController =
        TextEditingController(text: value.unitLabelEn ?? '');
    _unitLabelBnController =
        TextEditingController(text: value.unitLabelBn ?? '');
    _sortOrderController =
        TextEditingController(text: value.sortOrder.toString());
    _viewsController = TextEditingController(text: value.views.toString());
    _totalSoldController =
        TextEditingController(text: value.totalSold.toString());
    _addToCartCountController =
        TextEditingController(text: value.addToCartCount.toString());
    _cardLayoutTypeController = TextEditingController(
      text: value.cardLayoutType ?? '',
    );
    _cardDesignJsonController = TextEditingController(
      text: value.cardDesignJson ?? '',
    );
    _taxClassIdController = TextEditingController(
      text: value.taxClassId ?? '',
    );
    _vatRateController = TextEditingController(
      text: asTextNullableDouble(value.vatRate),
    );
    _weightValueController = TextEditingController(
      text: asTextNullableDouble(value.weightValue),
    );
    _weightUnitController = TextEditingController(
      text: value.weightUnit ?? '',
    );
    _lengthController = TextEditingController(
      text: asTextNullableDouble(value.length),
    );
    _widthController = TextEditingController(
      text: asTextNullableDouble(value.width),
    );
    _heightController = TextEditingController(
      text: asTextNullableDouble(value.height),
    );
    _dimensionUnitController = TextEditingController(
      text: value.dimensionUnit ?? '',
    );
    _shippingClassIdController = TextEditingController(
      text: value.shippingClassId ?? '',
    );
    _adminNoteController = TextEditingController(
      text: value.adminNote ?? '',
    );
    _metadataJsonController = TextEditingController(
      text: _metadataJsonText(value.metadata),
    );
    _createdByController = TextEditingController(
      text: value.createdBy ?? '',
    );
    _updatedByController = TextEditingController(
      text: value.updatedBy ?? '',
    );
    _deletedByController = TextEditingController(
      text: value.deletedBy ?? '',
    );
    _deleteReasonController = TextEditingController(
      text: value.deleteReason ?? '',
    );

    _inventoryMode = value.inventoryMode;
    _schedulePriceType = value.schedulePriceType.trim().isEmpty
        ? 'fixed'
        : value.schedulePriceType;
    _status = value.status.trim().isEmpty ? 'active' : value.status;
    _quantityType = value.quantityType;
    _toleranceType = value.toleranceType;
    _deliveryShift = value.deliveryShift;

    _trackInventory = value.trackInventory;
    _supportsInstantOrder = value.supportsInstantOrder;
    _supportsScheduledOrder = value.supportsScheduledOrder;
    _allowBackorder = value.allowBackorder;
    _isToleranceActive = value.isToleranceActive;
    _isDefault = value.isDefault;
    _isEnabled = value.isEnabled;
    _isFeatured = value.isFeatured;
    _isFlashSale = value.isFlashSale;
    _isNewArrival = value.isNewArrival;
    _isBestSeller = value.isBestSeller;
    _isTaxIncluded = value.isTaxIncluded;
    _isDeleted = value.isDeleted;
    _deletedAt = value.deletedAt;
    _purchaseOptions = [...value.purchaseOptions]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

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
    _shortDescriptionEnController.dispose();
    _shortDescriptionBnController.dispose();
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
    _saleStartsAtController.dispose();
    _saleEndsAtController.dispose();
    _estimatedSchedulePriceController.dispose();
    _publishAtController.dispose();
    _unpublishAtController.dispose();
    _instantCutoffTimeController.dispose();
    _todayInstantCapController.dispose();
    _todayInstantSoldController.dispose();
    _maxScheduleQtyPerDayController.dispose();
    _minScheduleNoticeHoursController.dispose();
    _reorderLevelController.dispose();
    _quantityValueController.dispose();
    _toleranceController.dispose();
    _minOrderQtyController.dispose();
    _maxOrderQtyController.dispose();
    _stepQtyController.dispose();
    _unitLabelEnController.dispose();
    _unitLabelBnController.dispose();
    _viewsController.dispose();
    _totalSoldController.dispose();
    _addToCartCountController.dispose();
    _cardLayoutTypeController.dispose();
    _cardDesignJsonController.dispose();
    _taxClassIdController.dispose();
    _vatRateController.dispose();
    _weightValueController.dispose();
    _weightUnitController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _dimensionUnitController.dispose();
    _shippingClassIdController.dispose();
    _adminNoteController.dispose();
    _metadataJsonController.dispose();
    _createdByController.dispose();
    _updatedByController.dispose();
    _deletedByController.dispose();
    _deleteReasonController.dispose();
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
                      'Each variation keeps its own image, pricing, inventory, quantity settings, and now also merchandising flags. For variable products, featured / flash sale / new arrival / best seller should be managed here.',
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _shortDescriptionEnController,
                        'Short Description (English)',
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _shortDescriptionBnController,
                        'Short Description (Bangla)',
                        maxLines: 2,
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
                              ? 'Pick & Optimize Image'
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: buildDateTimeField(
                        controller: _saleStartsAtController,
                        label: 'Sale Starts At',
                        onPick: () async {
                          final picked = await pickDateTime(
                            context,
                            initial: _saleStartsAt,
                          );
                          if (picked == null) return;
                          setState(() {
                            _saleStartsAt = picked;
                            _saleStartsAtController.text = formatDateTime(picked);
                          });
                        },
                        onClear: () {
                          setState(() {
                            _saleStartsAt = null;
                            _saleStartsAtController.clear();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildDateTimeField(
                        controller: _saleEndsAtController,
                        label: 'Sale Ends At',
                        onPick: () async {
                          final picked = await pickDateTime(
                            context,
                            initial: _saleEndsAt,
                          );
                          if (picked == null) return;
                          setState(() {
                            _saleEndsAt = picked;
                            _saleEndsAtController.text = formatDateTime(picked);
                          });
                        },
                        onClear: () {
                          setState(() {
                            _saleEndsAt = null;
                            _saleEndsAtController.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogDropdown(
                        label: 'Schedule Price Type',
                        value: _schedulePriceType,
                        items: const ['fixed', 'estimated', 'market'],
                        onChanged: (value) {
                          setState(() => _schedulePriceType = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _estimatedSchedulePriceController,
                        'Estimated Schedule Price',
                      ),
                    ),
                  ],
                ),


                const SizedBox(height: 20),
                _buildVariationPurchaseOptionsSection(context),

                const SizedBox(height: 20),
                _buildVariationMerchandisingSection(context),

                  const SizedBox(height: 12),
                  Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                  buildInfoChip('featured: $_isFeatured'),
                  buildInfoChip('flash_sale: $_isFlashSale'),
                  buildInfoChip('new_arrival: $_isNewArrival'),
                  buildInfoChip('best_seller: $_isBestSeller'),
                  ],
                  ),

                const SizedBox(height: 20),
                Text(
                  'Variation Status and Publishing',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogDropdown(
                        label: 'Status',
                        value: _status,
                        items: const [
                          'draft',
                          'active',
                          'inactive',
                          'scheduled',
                          'archived',
                          'out_of_stock',
                        ],
                        onChanged: (value) {
                          setState(() => _status = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: buildFilterChip(
                          label: 'Deleted',
                          selected: _isDeleted,
                          onSelected: (value) {
                            setState(() {
                              _isDeleted = value;
                              if (!value) {
                                _deletedAt = null;
                                _deletedByController.clear();
                                _deleteReasonController.clear();
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: buildDateTimeField(
                        controller: _publishAtController,
                        label: 'Publish At',
                        onPick: () async {
                          final picked = await pickDateTime(
                            context,
                            initial: _publishAt,
                          );
                          if (picked == null) return;
                          setState(() {
                            _publishAt = picked;
                            _publishAtController.text = formatDateTime(picked);
                          });
                        },
                        onClear: () {
                          setState(() {
                            _publishAt = null;
                            _publishAtController.clear();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildDateTimeField(
                        controller: _unpublishAtController,
                        label: 'Unpublish At',
                        onPick: () async {
                          final picked = await pickDateTime(
                            context,
                            initial: _unpublishAt,
                          );
                          if (picked == null) return;
                          setState(() {
                            _unpublishAt = picked;
                            _unpublishAtController.text = formatDateTime(picked);
                          });
                        },
                        onClear: () {
                          setState(() {
                            _unpublishAt = null;
                            _unpublishAtController.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),


                const SizedBox(height: 20),
                Text(
                  'Variation Inventory and Availability',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogDropdown(
                        label: 'Inventory Mode',
                        value: _inventoryMode,
                        items: const [
                          'stocked',
                          'hybrid_fresh',
                          'schedule_only',
                          'untracked',
                        ],
                        onChanged: (value) {
                          setState(() => _inventoryMode = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _instantCutoffTimeController,
                        'Instant Cutoff Time',
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
                      label: 'Supports Instant Order',
                      selected: _supportsInstantOrder,
                      onSelected: (value) =>
                          setState(() => _supportsInstantOrder = value),
                    ),
                    buildFilterChip(
                      label: 'Supports Scheduled Order',
                      selected: _supportsScheduledOrder,
                      onSelected: (value) =>
                          setState(() => _supportsScheduledOrder = value),
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
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _todayInstantCapController,
                        'Today Instant Cap',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _todayInstantSoldController,
                        'Today Instant Sold',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _maxScheduleQtyPerDayController,
                        'Max Schedule Qty / Day',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _minScheduleNoticeHoursController,
                        'Min Schedule Notice Hours',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _reorderLevelController,
                        'Reorder Level',
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Variation Quantity, Packaging, and Tolerance',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogDropdown(
                        label: 'Quantity Type',
                        value: _quantityType,
                        items: const ['pcs', 'kg', 'g', 'litre', 'ml', 'pack'],
                        onChanged: (value) {
                          setState(() => _quantityType = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _quantityValueController,
                        'Quantity Value',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogDropdown(
                        label: 'Tolerance Type',
                        value: _toleranceType,
                        items: const ['g', 'kg', '%', 'ml'],
                        onChanged: (value) {
                          setState(() => _toleranceType = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _toleranceController,
                        'Tolerance',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _minOrderQtyController,
                        'Min Order Qty',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _maxOrderQtyController,
                        'Max Order Qty',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _stepQtyController,
                        'Step Qty',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _unitLabelEnController,
                        'Unit Label (English)',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _unitLabelBnController,
                        'Unit Label (Bangla)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogDropdown(
                        label: 'Delivery Shift',
                        value: _deliveryShift,
                        items: const ['any', 'morning', 'afternoon', 'evening'],
                        onChanged: (value) {
                          setState(() => _deliveryShift = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: buildFilterChip(
                          label: 'Tolerance Active',
                          selected: _isToleranceActive,
                          onSelected: (value) =>
                              setState(() => _isToleranceActive = value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Tax, Shipping, Physical Info, and Analytics',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _taxClassIdController,
                        'Tax Class ID',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _vatRateController,
                        'VAT Rate (%)',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: buildFilterChip(
                          label: 'Tax Included',
                          selected: _isTaxIncluded,
                          onSelected: (value) =>
                              setState(() => _isTaxIncluded = value),
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
                        _weightValueController,
                        'Weight Value',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _weightUnitController,
                        'Weight Unit',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _shippingClassIdController,
                        'Shipping Class ID',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _lengthController,
                        'Length',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _widthController,
                        'Width',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _heightController,
                        'Height',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _dimensionUnitController,
                        'Dimension Unit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _viewsController,
                        'Views',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _totalSoldController,
                        'Total Sold',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _addToCartCountController,
                        'Add To Cart Count',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Card Override and Audit',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _cardLayoutTypeController,
                        'Card Layout Type Override',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _createdByController,
                        'Created By',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _updatedByController,
                        'Updated By',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                dialogTextField(
                  _cardDesignJsonController,
                  'Card Design JSON Override',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                dialogTextField(
                  _adminNoteController,
                  'Admin Note',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: dialogTextField(
                        _deletedByController,
                        'Deleted By',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dialogTextField(
                        _deleteReasonController,
                        'Delete Reason',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                dialogTextField(
                  _metadataJsonController,
                  'Metadata JSON',
                  maxLines: 5,
                  validator: _metadataJsonValidator,
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

            final parsedMetadata = _parseMetadataJson(
              _metadataJsonController.text,
              fallback: widget.initialValue.metadata,
            );
            final now = DateTime.now();

            Navigator.of(context).pop(
              MBProductVariation(
                id: _idController.text.trim(),
                sku: _skuController.text.trim(),
                barcode: _barcodeController.text.trim().isEmpty
                    ? null
                    : _barcodeController.text.trim(),
                titleEn: _titleEnController.text.trim(),
                titleBn: _titleBnController.text.trim(),
                shortDescriptionEn: _shortDescriptionEnController.text.trim(),
                shortDescriptionBn: _shortDescriptionBnController.text.trim(),
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
                saleStartsAt: _saleStartsAt,
                saleEndsAt: _saleEndsAt,
                schedulePriceType: _schedulePriceType,
                estimatedSchedulePrice: parseNullableDouble(
                  _estimatedSchedulePriceController.text,
                ),
                stockQty: parseInt(_stockQtyController.text),
                reservedQty: parseInt(_reservedQtyController.text),
                inventoryMode: _inventoryMode,
                trackInventory: _trackInventory,
                supportsInstantOrder: _supportsInstantOrder,
                supportsScheduledOrder: _supportsScheduledOrder,
                allowBackorder: _allowBackorder,
                instantCutoffTime: _instantCutoffTimeController.text.trim().isEmpty
                    ? null
                    : _instantCutoffTimeController.text.trim(),
                todayInstantCap: parseInt(
                  _todayInstantCapController.text,
                  fallback: 999999,
                ),
                todayInstantSold: parseInt(_todayInstantSoldController.text),
                maxScheduleQtyPerDay: parseInt(
                  _maxScheduleQtyPerDayController.text,
                  fallback: 999999,
                ),
                minScheduleNoticeHours: parseInt(
                  _minScheduleNoticeHoursController.text,
                ),
                reorderLevel: parseInt(_reorderLevelController.text),
                quantityType: _quantityType,
                quantityValue: parseDouble(_quantityValueController.text),
                toleranceType: _toleranceType,
                tolerance: parseDouble(_toleranceController.text),
                isToleranceActive: _isToleranceActive,
                deliveryShift: _deliveryShift,
                minOrderQty: parseNullableDouble(_minOrderQtyController.text),
                maxOrderQty: parseNullableDouble(_maxOrderQtyController.text),
                stepQty: parseNullableDouble(_stepQtyController.text),
                unitLabelEn: _unitLabelEnController.text.trim().isEmpty
                    ? null
                    : _unitLabelEnController.text.trim(),
                unitLabelBn: _unitLabelBnController.text.trim().isEmpty
                    ? null
                    : _unitLabelBnController.text.trim(),
                purchaseOptions: [..._purchaseOptions]
                  ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
                attributeValues: _buildSelectedAttributeMap(),
                sortOrder: parseInt(_sortOrderController.text),
                isDefault: _isDefault,
                isEnabled: _isEnabled,
                isFeatured: _isFeatured,
                isFlashSale: _isFlashSale,
                isNewArrival: _isNewArrival,
                isBestSeller: _isBestSeller,
                publishAt: _publishAt,
                unpublishAt: _unpublishAt,
                views: parseInt(_viewsController.text),
                totalSold: parseInt(_totalSoldController.text),
                addToCartCount: parseInt(_addToCartCountController.text),
                cardLayoutType: _cardLayoutTypeController.text.trim().isEmpty
                    ? null
                    : _cardLayoutTypeController.text.trim(),
                cardConfig: widget.initialValue.cardConfig,
                cardDesignJson: _cardDesignJsonController.text.trim().isEmpty
                    ? null
                    : _cardDesignJsonController.text.trim(),
                status: _status.trim().isEmpty ? 'active' : _status.trim(),
                taxClassId: _taxClassIdController.text.trim().isEmpty
                    ? null
                    : _taxClassIdController.text.trim(),
                vatRate: parseNullableDouble(_vatRateController.text),
                isTaxIncluded: _isTaxIncluded,
                weightValue: parseNullableDouble(_weightValueController.text),
                weightUnit: _weightUnitController.text.trim().isEmpty
                    ? null
                    : _weightUnitController.text.trim(),
                length: parseNullableDouble(_lengthController.text),
                width: parseNullableDouble(_widthController.text),
                height: parseNullableDouble(_heightController.text),
                dimensionUnit: _dimensionUnitController.text.trim().isEmpty
                    ? null
                    : _dimensionUnitController.text.trim(),
                shippingClassId: _shippingClassIdController.text.trim().isEmpty
                    ? null
                    : _shippingClassIdController.text.trim(),
                adminNote: _adminNoteController.text.trim().isEmpty
                    ? null
                    : _adminNoteController.text.trim(),
                metadata: parsedMetadata,
                isDeleted: _isDeleted,
                deletedAt: _isDeleted ? (_deletedAt ?? now) : null,
                deletedBy: _deletedByController.text.trim().isEmpty
                    ? (_isDeleted ? 'admin' : null)
                    : _deletedByController.text.trim(),
                deleteReason: _deleteReasonController.text.trim().isEmpty
                    ? null
                    : _deleteReasonController.text.trim(),
                createdBy: _createdByController.text.trim().isEmpty
                    ? widget.initialValue.createdBy
                    : _createdByController.text.trim(),
                updatedBy: _updatedByController.text.trim().isEmpty
                    ? widget.initialValue.updatedBy
                    : _updatedByController.text.trim(),
                createdAt: widget.initialValue.createdAt ?? now,
                updatedAt: now,
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




