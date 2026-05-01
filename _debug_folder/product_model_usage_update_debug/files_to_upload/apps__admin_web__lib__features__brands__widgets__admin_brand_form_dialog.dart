import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_core/media/mb_image_pipeline_service.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';

import '../controllers/admin_brand_controller.dart';

class AdminBrandFormDialog extends StatefulWidget {
  const AdminBrandFormDialog({
    super.key,
    this.brand,
  });

  final MBBrand? brand;

  @override
  State<AdminBrandFormDialog> createState() => _AdminBrandFormDialogState();
}

class _AdminBrandFormDialogState extends State<AdminBrandFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AdminBrandController _controller;
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameBnController;
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _descriptionBnController;
  late final TextEditingController _logoUrlController;
  late final TextEditingController _slugController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _productsCountController;

  late final String _generatedId;

  bool _isFeatured = false;
  bool _showOnHome = false;
  bool _isActive = true;
  bool _useUploadedThumbAsLogo = true;
  bool _removeExistingImage = false;

  bool _isSaving = false;
  bool _isPickingImage = false;
  bool _isResizingImage = false;
  bool _isAutoUpdatingSlug = false;
  bool _isAutoUpdatingSort = false;
  bool _slugTouchedManually = false;
  bool _sortTouchedManually = false;

  String? _slugErrorText;
  String? _sortErrorText;
  String? _submitError;

  MBOriginalPickedImage? _originalPickedImage;
  MBPreparedImageSet? _preparedImage;
  late MBAdminImageResizePreset _selectedPreset;

  bool get isEdit => widget.brand != null;

  String get _draftEntityId {
    final String existingId = widget.brand?.id.trim() ?? '';
    if (existingId.isNotEmpty) return existingId;
    return _generatedId;
  }

  String get _existingPrimaryImageUrl {
    final String imageUrl = widget.brand?.imageUrl.trim() ?? '';
    final String logoUrl = widget.brand?.logoUrl.trim() ?? '';
    return imageUrl.isNotEmpty ? imageUrl : logoUrl;
  }

  bool get _hasStoredImageAtOpen =>
      (widget.brand?.imageUrl.trim().isNotEmpty ?? false) ||
          (widget.brand?.logoUrl.trim().isNotEmpty ?? false);

  bool get _hasExistingImage => !_removeExistingImage && _hasStoredImageAtOpen;
  bool get _hasPreparedImage => _preparedImage != null;

  bool get _isFormBasicsValid {
    return _nameEnController.text.trim().isNotEmpty &&
        MBAdminSlugUtils.normalize(_slugController.text).isNotEmpty &&
        int.tryParse(_sortOrderController.text.trim()) != null &&
        (int.tryParse(_sortOrderController.text.trim()) ?? -1) >= 0 &&
        (_slugErrorText == null || _slugErrorText!.trim().isEmpty) &&
        (_sortErrorText == null || _sortErrorText!.trim().isEmpty);
  }

  bool get _canSubmit {
    if (_isSaving || _isPickingImage || _isResizingImage) return false;
    if (!_isFormBasicsValid) return false;

    if (isEdit) {
      if (_hasExistingImage) return true;
      return _hasPreparedImage;
    }

    return _hasPreparedImage;
  }

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AdminBrandController>();
    _generatedId = FirebaseFirestore.instance.collection('brands').doc().id;
    _selectedPreset = MBAdminImageResizePresets.defaultBrandSquare();

    final MBBrand? brand = widget.brand;

    _nameEnController = TextEditingController(text: brand?.nameEn ?? '');
    _nameBnController = TextEditingController(text: brand?.nameBn ?? '');
    _descriptionEnController =
        TextEditingController(text: brand?.descriptionEn ?? '');
    _descriptionBnController =
        TextEditingController(text: brand?.descriptionBn ?? '');
    _logoUrlController = TextEditingController(text: '');

    final String initialSlug = (brand?.slug.trim().isNotEmpty ?? false)
        ? brand!.slug.trim()
        : MBAdminSlugUtils.normalize(brand?.nameEn ?? '');
    _slugController = TextEditingController(text: initialSlug);

    _sortOrderController = TextEditingController(
      text: (brand?.sortOrder ?? 0).toString(),
    );
    _productsCountController = TextEditingController(
      text: (brand?.productsCount ?? 0).toString(),
    );

    _isFeatured = brand?.isFeatured ?? false;
    _showOnHome = brand?.showOnHome ?? false;
    _isActive = brand?.isActive ?? true;

    _slugTouchedManually = isEdit &&
        initialSlug.isNotEmpty &&
        initialSlug != MBAdminSlugUtils.normalize(brand?.nameEn ?? '');
    _sortTouchedManually = isEdit;

    _nameEnController.addListener(_handleNameChanged);
    _slugController.addListener(_handleSlugChanged);
    _sortOrderController.addListener(_handleSortChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!isEdit) {
        await _applySuggestedSortIfAllowed(force: true);
        _applyAutoSlugIfAllowed(force: true);
      }
      _runClientSideValidation();
    });
  }

  @override
  void dispose() {
    _nameEnController.removeListener(_handleNameChanged);
    _slugController.removeListener(_handleSlugChanged);
    _sortOrderController.removeListener(_handleSortChanged);

    _nameEnController.dispose();
    _nameBnController.dispose();
    _descriptionEnController.dispose();
    _descriptionBnController.dispose();
    _logoUrlController.dispose();
    _slugController.dispose();
    _sortOrderController.dispose();
    _productsCountController.dispose();
    super.dispose();
  }

  void _handleNameChanged() {
    _submitError = null;
    _applyAutoSlugIfAllowed();
    if (mounted) setState(() {});
  }

  void _handleSlugChanged() {
    if (_isAutoUpdatingSlug) return;
    _submitError = null;
    _slugTouchedManually = true;
    if (mounted) {
      setState(() {
        _slugErrorText = _buildSlugError();
      });
    }
  }

  void _handleSortChanged() {
    if (_isAutoUpdatingSort) return;
    _submitError = null;
    _sortTouchedManually = true;
    if (mounted) {
      setState(() {
        _sortErrorText = _buildSortError();
      });
    }
  }

  void _runClientSideValidation() {
    setState(() {
      _slugErrorText = _buildSlugError();
      _sortErrorText = _buildSortError();
    });
  }

  void _applyAutoSlugIfAllowed({bool force = false}) {
    if (!force && _slugTouchedManually) return;

    final String normalized = MBAdminSlugUtils.normalize(_nameEnController.text);
    _isAutoUpdatingSlug = true;
    _slugController.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
    _isAutoUpdatingSlug = false;
    _slugErrorText = _buildSlugError();
  }

  Future<void> _applySuggestedSortIfAllowed({bool force = false}) async {
    if (!force && _sortTouchedManually) return;

    try {
      final int suggested = await _controller.suggestSortOrder(
        excludeBrandId: widget.brand?.id,
      );
      if (!mounted) return;

      final String text = suggested.toString();
      _isAutoUpdatingSort = true;
      _sortOrderController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      _isAutoUpdatingSort = false;
      _sortErrorText = _buildSortError();
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      final String text = '0';
      _isAutoUpdatingSort = true;
      _sortOrderController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      _isAutoUpdatingSort = false;
      _sortErrorText = _buildSortError();
      setState(() {});
    }
  }

  String? _buildSlugError() {
    final String normalized = MBAdminSlugUtils.normalize(_slugController.text);
    if (normalized.isEmpty) {
      return 'Slug is required.';
    }

    final String currentId = widget.brand?.id.trim() ?? '';
    final bool duplicate = _controller.brands.any((MBBrand item) {
      if (currentId.isNotEmpty && item.id.trim() == currentId) {
        return false;
      }
      return item.slug.trim().toLowerCase() == normalized;
    });

    if (duplicate) {
      return 'This slug already exists.';
    }

    return null;
  }

  String? _buildSortError() {
    final int? parsed = int.tryParse(_sortOrderController.text.trim());
    if (parsed == null) {
      return 'Enter a valid integer.';
    }
    if (parsed < 0) {
      return 'Sort order must be 0 or greater.';
    }

    final String currentId = widget.brand?.id.trim() ?? '';
    final bool duplicate = _controller.brands.any((MBBrand item) {
      if (currentId.isNotEmpty && item.id.trim() == currentId) {
        return false;
      }
      return item.sortOrder == parsed;
    });

    if (duplicate) {
      return 'This sort order already exists.';
    }

    return null;
  }

  String _cleanError(Object error) {
    final String raw = error.toString().trim();
    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '').trim();
    }
    return raw;
  }

  Future<void> _pickOriginalImage() async {
    if (_isSaving || _isPickingImage || _isResizingImage) return;

    setState(() {
      _submitError = null;
      _isPickingImage = true;
    });

    try {
      final MBOriginalPickedImage? picked = await _controller.pickOriginalImage();
      if (!mounted) return;

      setState(() {
        _originalPickedImage = picked;
        _preparedImage = null;
        _removeExistingImage = false;
        _isPickingImage = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = _cleanError(error);
        _isPickingImage = false;
      });
    }
  }

  Future<void> _resizeSelectedImage() async {
    final MBOriginalPickedImage? original = _originalPickedImage;
    if (original == null || _isSaving || _isResizingImage) return;

    setState(() {
      _submitError = null;
      _isResizingImage = true;
    });

    try {
      final MBPreparedImageSet prepared = await _controller.resizeSelectedImage(
        original: original,
        fullMaxWidth: _selectedPreset.fullMaxWidth,
        fullMaxHeight: _selectedPreset.fullMaxHeight,
        fullJpegQuality: _selectedPreset.fullJpegQuality,
        thumbSize: _selectedPreset.thumbSize,
        thumbJpegQuality: _selectedPreset.thumbJpegQuality,
        requestSquareCrop: _selectedPreset.requestSquareCrop,
      );

      if (!mounted) return;
      setState(() {
        _preparedImage = prepared;
        _isResizingImage = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = _cleanError(error);
        _isResizingImage = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit || _isSaving) return;

    final FormState? state = _formKey.currentState;
    if (state == null || !state.validate()) return;

    setState(() {
      _slugErrorText = _buildSlugError();
      _sortErrorText = _buildSortError();
      _submitError = null;
    });

    if (_slugErrorText != null || _sortErrorText != null) {
      setState(() {
        _submitError = _slugErrorText ?? _sortErrorText;
      });
      return;
    }

    final String slug = MBAdminSlugUtils.normalize(_slugController.text);
    final int sortOrder = int.parse(_sortOrderController.text.trim());

    setState(() {
      _isSaving = true;
    });

    try {
      String finalImageUrl = widget.brand?.imageUrl.trim() ?? '';
      String finalLogoUrl = widget.brand?.logoUrl.trim() ?? '';
      String finalImagePath = widget.brand?.imagePath.trim() ?? '';
      String finalThumbPath = widget.brand?.thumbPath.trim() ?? '';

      if (_removeExistingImage && _preparedImage == null) {
        finalImageUrl = '';
        finalLogoUrl = '';
        finalImagePath = '';
        finalThumbPath = '';
      }

      if (_preparedImage != null) {
        final uploaded = await MBImagePipelineService.instance.uploadPreparedImageSet(
          prepared: _preparedImage!,
          storageFolder: 'brand_images',
          entityId: _draftEntityId,
          fileStem: 'brand_main',
          customMetadata: <String, String>{
            'entityType': 'brand',
            'slug': slug,
          },
        );

        finalImageUrl = uploaded.fullUrl;
        finalImagePath = uploaded.fullPath;
        finalThumbPath = uploaded.thumbPath;

        if (_useUploadedThumbAsLogo) {
          finalLogoUrl = uploaded.thumbUrl;
        }
      }

      if (_logoUrlController.text.trim().isNotEmpty) {
        finalLogoUrl = _logoUrlController.text.trim();
      }

      if (finalImageUrl.trim().isEmpty && finalLogoUrl.trim().isEmpty) {
        throw Exception(
          isEdit
              ? 'Please keep the previous image or prepare a new image before updating.'
              : 'Please prepare an image before creating this brand.',
        );
      }

      final DateTime now = DateTime.now();
      final MBBrand? existing = widget.brand;

      final MBBrand brand = MBBrand(
        id: existing?.id ?? _draftEntityId,
        nameEn: _nameEnController.text.trim(),
        nameBn: _nameBnController.text.trim(),
        descriptionEn: _descriptionEnController.text.trim(),
        descriptionBn: _descriptionBnController.text.trim(),
        imageUrl: finalImageUrl,
        logoUrl: finalLogoUrl,
        imagePath: finalImagePath,
        thumbPath: finalThumbPath,
        slug: slug,
        isFeatured: _isFeatured,
        showOnHome: _showOnHome,
        isActive: _isActive,
        sortOrder: sortOrder,
        productsCount: existing?.productsCount ?? 0,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      await _controller.saveBrand(
        brand: brand,
        isEdit: isEdit,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = _cleanError(error);
        _isSaving = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1180,
          maxHeight: 860,
        ),
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(MBSpacing.xl),
                child: Column(
                  children: [
                    if ((_submitError ?? '').trim().isNotEmpty)
                      MBAdminFormErrorBanner(message: _submitError!),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 960) {
                          return Column(
                            children: [
                              _buildFormSection(),
                              MBSpacing.h(MBSpacing.lg),
                              _buildFlagsSection(),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildFormSection()),
                            MBSpacing.w(MBSpacing.lg),
                            Expanded(flex: 2, child: _buildFlagsSection()),
                          ],
                        );
                      },
                    ),
                    MBSpacing.h(MBSpacing.lg),
                    MBAdminDualImagePanels(
                      left: _buildOriginalImagePanel(),
                      right: _buildResizedImagePanel(),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            MBAdminFormActionFooter(
              primaryLabel: isEdit ? 'Update Brand' : 'Create Brand',
              isPrimaryEnabled: _canSubmit,
              onPrimaryTap: _submit,
              onCancelTap: _isSaving ? null : () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(MBSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Brand' : 'Create Brand',
                  style: MBTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xs),
                Text(
                  'Manage bilingual brand data, image processing, visibility, and display order.',
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isSaving ? null : () => Get.back(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return MBAdminFormSectionCard(
      title: 'Brand details',
      subtitle: 'Core fields used by admin web and app-side brand presentation.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _nameEnController,
                    decoration: const InputDecoration(
                      labelText: 'Name (English)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'English name is required.';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _nameBnController,
                    decoration: const InputDecoration(
                      labelText: 'Name (Bangla)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _slugController,
                    decoration: InputDecoration(
                      labelText: 'Slug',
                      border: const OutlineInputBorder(),
                      helperText: _slugErrorText ?? 'Auto-generated from English name.',
                      helperStyle: TextStyle(
                        color: _slugErrorText == null
                            ? MBColors.textSecondary
                            : MBColors.error,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _sortOrderController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Sort Order',
                      border: const OutlineInputBorder(),
                      helperText: _sortErrorText ?? 'Unique across brands.',
                      helperStyle: TextStyle(
                        color: _sortErrorText == null
                            ? MBColors.textSecondary
                            : MBColors.error,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _logoUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Custom logo URL (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _productsCountController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Products Count',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            TextFormField(
              controller: _descriptionEnController,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description (English)',
                border: OutlineInputBorder(),
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            TextFormField(
              controller: _descriptionBnController,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description (Bangla)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagsSection() {
    return MBAdminFormSectionCard(
      title: 'Flags',
      subtitle: 'Brand visibility and merchandizing controls.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilterChip(
                label: const Text('Featured'),
                selected: _isFeatured,
                onSelected: _isSaving
                    ? null
                    : (value) => setState(() => _isFeatured = value),
              ),
              FilterChip(
                label: const Text('Show on home'),
                selected: _showOnHome,
                onSelected: _isSaving
                    ? null
                    : (value) => setState(() => _showOnHome = value),
              ),
              FilterChip(
                label: const Text('Active'),
                selected: _isActive,
                onSelected: _isSaving
                    ? null
                    : (value) => setState(() => _isActive = value),
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(MBSpacing.md),
            decoration: BoxDecoration(
              color: MBColors.background,
              borderRadius: BorderRadius.circular(MBRadius.lg),
              border: Border.all(
                color: MBColors.border.withValues(alpha: 0.90),
              ),
            ),
            child: Text(
              _canSubmit
                  ? 'Ready to submit.'
                  : isEdit
                  ? 'Update stays locked until the form is valid and a valid image remains available.'
                  : 'Create stays locked until the form is valid and a resized image is ready.',
              style: MBTextStyles.caption.copyWith(
                color: _canSubmit ? MBColors.success : MBColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalImagePanel() {
    final MBOriginalPickedImage? original = _originalPickedImage;

    Widget preview;
    final List<Widget> infoRows = <Widget>[];
    final List<Widget> actions = <Widget>[];
    final List<Widget> bottom = <Widget>[];

    if (original != null) {
      preview = MBAdminImagePreviewBox(
        isBusy: _isPickingImage,
        busyLabel: 'Loading image...',
        child: Image.memory(
          original.originalBytes,
          fit: BoxFit.cover,
        ),
      );
      infoRows.addAll([
        MBAdminInfoRow(label: 'Name', value: original.originalFileName),
        MBAdminInfoRow(
          label: 'Source',
          value: '${original.width} × ${original.height}',
        ),
        MBAdminInfoRow(label: 'Bytes', value: '${original.originalByteLength}'),
      ]);
    } else if (_hasExistingImage) {
      preview = MBAdminImagePreviewBox(
        child: Image.network(
          _existingPrimaryImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const MBAdminEmptyImageBox(
            icon: Icons.broken_image_outlined,
            text: 'Existing image could not be loaded.',
          ),
        ),
      );
      infoRows.addAll([
        MBAdminInfoRow(label: 'Image URL', value: widget.brand?.imageUrl ?? ''),
        MBAdminInfoRow(label: 'Logo URL', value: widget.brand?.logoUrl ?? ''),
        MBAdminInfoRow(label: 'Image path', value: widget.brand?.imagePath ?? ''),
        MBAdminInfoRow(label: 'Thumb path', value: widget.brand?.thumbPath ?? ''),
      ]);
    } else {
      preview = MBAdminImagePreviewBox(
        isBusy: _isPickingImage,
        busyLabel: 'Loading image...',
        child: const MBAdminEmptyImageBox(
          icon: Icons.image_outlined,
          text: 'Select a brand image to continue.',
        ),
      );
    }

    actions.add(
      FilledButton.icon(
        onPressed: _isSaving ? null : _pickOriginalImage,
        icon: const Icon(Icons.image_search_rounded),
        label: Text(
          _originalPickedImage != null
              ? 'Select another image'
              : (_hasExistingImage ? 'Replace image' : 'Select image'),
        ),
      ),
    );

    if (isEdit && _hasExistingImage) {
      bottom.add(
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _removeExistingImage,
          onChanged: _isSaving
              ? null
              : (value) {
            setState(() {
              _removeExistingImage = value ?? false;
              if (_removeExistingImage) {
                _originalPickedImage = null;
                _preparedImage = null;
              }
            });
          },
          title: const Text('Remove previous image and require a new one'),
        ),
      );
    }

    return MBAdminImagePanel(
      title: original != null
          ? 'Original image'
          : _hasExistingImage
          ? 'Current image'
          : 'Original image',
      subtitle: original != null
          ? 'This panel shows the selected original image and source details.'
          : _hasExistingImage
          ? 'The current stored image stays active until you pick a new image.'
          : 'After image selection, the original preview and metadata will appear here.',
      preview: preview,
      infoRows: infoRows,
      actions: actions,
      bottom: bottom,
    );
  }

  Widget _buildResizedImagePanel() {
    Widget preview;
    final List<Widget> infoRows = <Widget>[];
    final List<Widget> actions = <Widget>[];
    final List<Widget> bottom = <Widget>[];

    if (_preparedImage != null) {
      preview = MBAdminImagePreviewBox(
        isBusy: _isResizingImage,
        busyLabel: 'Resizing image...',
        child: Image.memory(
          _preparedImage!.previewBytes,
          fit: BoxFit.cover,
        ),
      );
      infoRows.addAll([
        MBAdminInfoRow(
          label: 'Full',
          value:
          '${_preparedImage!.fullWidth} × ${_preparedImage!.fullHeight} • ${_preparedImage!.fullByteLength} bytes',
        ),
        MBAdminInfoRow(
          label: 'Thumb',
          value:
          '${_preparedImage!.thumbWidth} × ${_preparedImage!.thumbHeight} • ${_preparedImage!.thumbByteLength} bytes',
        ),
        MBAdminInfoRow(
          label: 'Source',
          value: '${_preparedImage!.sourceWidth} × ${_preparedImage!.sourceHeight}',
        ),
      ]);
    } else {
      preview = MBAdminImagePreviewBox(
        isBusy: _isResizingImage,
        busyLabel: 'Resizing image...',
        child: MBAdminEmptyImageBox(
          icon: Icons.crop_square_rounded,
          text: isEdit && _originalPickedImage == null
              ? 'Resize options stay idle until you select a new image.'
              : 'Select an original image, then resize it here.',
        ),
      );
    }

    if (_originalPickedImage != null || _isResizingImage) {
      actions.add(
        MBAdminImagePresetSelector(
          presets: MBAdminImageResizePresets.brandSquare,
          selectedPreset: _selectedPreset,
          enabled: !_isSaving && !_isResizingImage,
          onSelected: (preset) {
            setState(() {
              _selectedPreset = preset;
            });
          },
        ),
      );

      bottom.add(
        FilledButton.tonalIcon(
          onPressed: _isSaving ? null : _resizeSelectedImage,
          icon: const Icon(Icons.auto_fix_high_rounded),
          label: Text(_preparedImage == null ? 'Resize image' : 'Resize again'),
        ),
      );

      bottom.add(
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _useUploadedThumbAsLogo,
          onChanged: _isSaving
              ? null
              : (value) {
            setState(() {
              _useUploadedThumbAsLogo = value ?? true;
            });
          },
          title: const Text('Use generated thumb as logo URL'),
        ),
      );
    }

    return MBAdminImagePanel(
      title: 'Resized image',
      subtitle: _preparedImage != null
          ? 'Prepared image is ready for upload.'
          : 'This panel stays empty until the image is resized.',
      preview: preview,
      infoRows: infoRows,
      actions: actions,
      bottom: bottom,
    );
  }
}
