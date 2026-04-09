import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_core/media/mb_image_pipeline_service.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

import '../controllers/admin_brand_controller.dart';

enum _BrandImageResizeOption {
  small,
  recommended,
  large,
}

extension _BrandImageResizeOptionX on _BrandImageResizeOption {
  String get label {
    switch (this) {
      case _BrandImageResizeOption.small:
        return 'Small (256 × 256)';
      case _BrandImageResizeOption.recommended:
        return 'Recommended (512 × 512)';
      case _BrandImageResizeOption.large:
        return 'Large (768 × 768)';
    }
  }

  int get size {
    switch (this) {
      case _BrandImageResizeOption.small:
        return 256;
      case _BrandImageResizeOption.recommended:
        return 512;
      case _BrandImageResizeOption.large:
        return 768;
    }
  }

  int get thumbSize {
    switch (this) {
      case _BrandImageResizeOption.small:
        return 120;
      case _BrandImageResizeOption.recommended:
        return 160;
      case _BrandImageResizeOption.large:
        return 220;
    }
  }

  String get note {
    switch (this) {
      case _BrandImageResizeOption.small:
        return 'Lightweight square logo for compact listing use.';
      case _BrandImageResizeOption.recommended:
        return 'Balanced size for mobile, tablet, and admin previews.';
      case _BrandImageResizeOption.large:
        return 'Sharper square image for richer brand presentation.';
    }
  }
}

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

  final FocusNode _nameEnFocusNode = FocusNode();
  final FocusNode _slugFocusNode = FocusNode();
  final FocusNode _sortOrderFocusNode = FocusNode();

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

  _BrandImageResizeOption _selectedResizeOption =
      _BrandImageResizeOption.recommended;

  late final String _generatedId;

  bool get isEdit => widget.brand != null;

  String get _draftEntityId {
    final existingId = widget.brand?.id.trim() ?? '';
    if (existingId.isNotEmpty) {
      return existingId;
    }
    return _generatedId;
  }

  String get _existingPrimaryImageUrl {
    final imageUrl = widget.brand?.imageUrl.trim() ?? '';
    final logoUrl = widget.brand?.logoUrl.trim() ?? '';
    return imageUrl.isNotEmpty ? imageUrl : logoUrl;
  }

  bool get _hasStoredImageAtOpen =>
      (widget.brand?.imageUrl.trim().isNotEmpty ?? false) ||
          (widget.brand?.logoUrl.trim().isNotEmpty ?? false);

  bool get _hasExistingImage => !_removeExistingImage && _hasStoredImageAtOpen;

  bool get _hasPreparedImage => _preparedImage != null;

  bool get _showResizeControls {
    if (_isResizingImage) return true;
    return _originalPickedImage != null;
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

  bool get _isFormBasicsValid {
    return _nameEnController.text.trim().isNotEmpty &&
        _normalizeSlug(_slugController.text).isNotEmpty &&
        int.tryParse(_sortOrderController.text.trim()) != null &&
        (int.tryParse(_sortOrderController.text.trim()) ?? -1) >= 0 &&
        (_slugErrorText == null || _slugErrorText!.trim().isEmpty) &&
        (_sortErrorText == null || _sortErrorText!.trim().isEmpty);
  }

  @override
  void initState() {
    super.initState();

    _controller = Get.find<AdminBrandController>();
    _generatedId = FirebaseFirestore.instance.collection('brands').doc().id;

    final brand = widget.brand;
    final initialSlug = (brand?.slug.trim().isNotEmpty ?? false)
        ? brand!.slug.trim()
        : _normalizeSlug(brand?.nameEn ?? '');

    _nameEnController = TextEditingController(text: brand?.nameEn ?? '');
    _nameBnController = TextEditingController(text: brand?.nameBn ?? '');
    _descriptionEnController =
        TextEditingController(text: brand?.descriptionEn ?? '');
    _descriptionBnController =
        TextEditingController(text: brand?.descriptionBn ?? '');
    _logoUrlController = TextEditingController(
      text: brand?.logoUrl ?? '',
    );
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
        initialSlug != _normalizeSlug(brand?.nameEn ?? '');
    _sortTouchedManually = isEdit;

    _nameEnController.addListener(_handleNameChanged);
    _slugController.addListener(_handleSlugChanged);
    _sortOrderController.addListener(_handleSortChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!isEdit) {
        _applySuggestedSortIfAllowed(force: true);
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

    _nameEnFocusNode.dispose();
    _slugFocusNode.dispose();
    _sortOrderFocusNode.dispose();

    super.dispose();
  }

  void _handleNameChanged() {
    _submitError = null;
    _applyAutoSlugIfAllowed();

    if (mounted) {
      setState(() {});
    }
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

  String _normalizeSlug(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '')
        .replaceAll(RegExp(r'-{2,}'), '-');
  }

  List<MBBrand> get _otherBrands {
    final currentId = widget.brand?.id.trim() ?? '';
    final items = _controller.brands.where((item) {
      if (currentId.isEmpty) return true;
      return item.id.trim() != currentId;
    }).toList();

    items.sort((a, b) {
      final bySort = a.sortOrder.compareTo(b.sortOrder);
      if (bySort != 0) return bySort;
      return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
    });

    return items;
  }

  int _firstAvailableSortOrder() {
    final used = _otherBrands.map((e) => e.sortOrder).toSet().toList()..sort();

    int expected = 0;
    for (final value in used) {
      if (value != expected) {
        return expected;
      }
      expected += 1;
    }

    return expected;
  }

  void _applySuggestedSortIfAllowed({bool force = false}) {
    if (!force && _sortTouchedManually) return;

    final suggested = _firstAvailableSortOrder().toString();

    _isAutoUpdatingSort = true;
    _sortOrderController.value = TextEditingValue(
      text: suggested,
      selection: TextSelection.collapsed(offset: suggested.length),
    );
    _isAutoUpdatingSort = false;

    _sortErrorText = _buildSortError();
  }

  void _applyAutoSlugIfAllowed({bool force = false}) {
    if (!force && _slugTouchedManually) return;

    final normalized = _normalizeSlug(_nameEnController.text);

    _isAutoUpdatingSlug = true;
    _slugController.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
    _isAutoUpdatingSlug = false;

    _slugErrorText = _buildSlugError();
  }

  String? _buildSlugError() {
    final normalized = _normalizeSlug(_slugController.text);

    if (normalized.isEmpty) {
      return 'Slug is required.';
    }

    final duplicate = _otherBrands.any(
          (item) => item.slug.trim().toLowerCase() == normalized,
    );
    if (duplicate) {
      return 'This slug is already used by another brand.';
    }

    return null;
  }

  String? _buildSortError() {
    final parsed = int.tryParse(_sortOrderController.text.trim());

    if (parsed == null) {
      return 'Sort order must be a number.';
    }

    if (parsed < 0) {
      return 'Sort order cannot be negative.';
    }

    final duplicate = _otherBrands.any((item) => item.sortOrder == parsed);
    if (duplicate) {
      return 'This sort order is already used by another brand.';
    }

    return null;
  }

  Future<void> _pickOriginalImage() async {
    if (_isSaving || _isPickingImage || _isResizingImage) return;

    setState(() {
      _submitError = null;
      _isPickingImage = true;
    });

    try {
      final picked = await _controller.pickOriginalImage();

      if (!mounted) return;

      setState(() {
        _originalPickedImage = picked;
        _preparedImage = null;
        _removeExistingImage = false;
        _isPickingImage = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _submitError = e.toString();
        _isPickingImage = false;
      });
    }
  }

  Future<void> _resizeSelectedImage() async {
    final original = _originalPickedImage;
    if (original == null || _isSaving || _isResizingImage) return;

    setState(() {
      _submitError = null;
      _isResizingImage = true;
    });

    try {
      final prepared = await _controller.resizeSelectedImage(
        original: original,
        fullMaxWidth: _selectedResizeOption.size,
        fullMaxHeight: _selectedResizeOption.size,
        fullJpegQuality: 90,
        thumbSize: _selectedResizeOption.thumbSize,
        thumbJpegQuality: 85,
        requestSquareCrop: true,
      );

      if (!mounted) return;

      setState(() {
        _preparedImage = prepared;
        _isResizingImage = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _submitError = e.toString();
        _isResizingImage = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit || _isSaving) return;

    final state = _formKey.currentState;
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

    setState(() {
      _isSaving = true;
    });

    try {
      final slug = _normalizeSlug(_slugController.text);
      final sortOrder = int.parse(_sortOrderController.text.trim());

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
        final uploaded = await MBImagePipelineService.instance
            .uploadPreparedImageSet(
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

      final now = DateTime.now();
      final existing = widget.brand;

      final brand = MBBrand(
        id: existing?.id ?? '',
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
        productsCount: int.tryParse(_productsCountController.text.trim()) ?? 0,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      if (existing == null) {
        await _controller.createBrand(brand);
      } else {
        await _controller.updateBrand(brand);
      }

      if (!mounted) return;
      Get.back();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _submitError = e.toString();
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
            Divider(
              height: 1,
              color: MBColors.border.withValues(alpha: 0.85),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(MBSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_submitError != null && _submitError!.trim().isNotEmpty)
                        _buildErrorBanner(_submitError!),
                      if (_submitError != null && _submitError!.trim().isNotEmpty)
                        MBSpacing.h(MBSpacing.lg),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 980;

                          if (!isWide) {
                            return Column(
                              children: [
                                _buildImageColumn(),
                                MBSpacing.h(MBSpacing.lg),
                                _buildFormColumn(),
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 380,
                                child: _buildImageColumn(),
                              ),
                              MBSpacing.w(MBSpacing.xl),
                              Expanded(
                                child: _buildFormColumn(),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              color: MBColors.border.withValues(alpha: 0.85),
            ),
            Padding(
              padding: const EdgeInsets.all(MBSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: _canSubmit ? _submit : null,
                      child: Text(
                        _isSaving
                            ? 'Saving...'
                            : (isEdit ? 'Update Brand' : 'Create Brand'),
                      ),
                    ),
                  ),
                ],
              ),
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
            child: Text(
              isEdit ? 'Edit Brand' : 'Create Brand',
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
                color: MBColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: _isSaving ? null : () => Get.back(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildImageColumn() {
    return Column(
      children: [
        _buildOriginalImageCard(),
        MBSpacing.h(MBSpacing.lg),
        _buildResizedImageCard(),
      ],
    );
  }

  Widget _buildFormColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          title: 'Basic information',
          subtitle: 'Brand names, descriptions, and visibility options.',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameEnController,
                      focusNode: _nameEnFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Name (English)',
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Enter English name';
                        }
                        return null;
                      },
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _nameBnController,
                      decoration: const InputDecoration(
                        labelText: 'Name (Bangla)',
                      ),
                    ),
                  ),
                ],
              ),
              MBSpacing.h(MBSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _descriptionEnController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Description (English)',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _descriptionBnController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Description (Bangla)',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        MBSpacing.h(MBSpacing.lg),
        _buildCard(
          title: 'Slug and ordering',
          subtitle: 'These values are used for stable listing and filtering.',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _slugController,
                      focusNode: _slugFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Slug',
                        errorText: _slugErrorText,
                      ),
                      validator: (_) => _buildSlugError(),
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _sortOrderController,
                      focusNode: _sortOrderFocusNode,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Sort Order',
                        errorText: _sortErrorText,
                      ),
                      validator: (_) => _buildSortError(),
                    ),
                  ),
                ],
              ),
              MBSpacing.h(MBSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Slug auto-generates from English name until you edit it manually.',
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.textSecondary,
                      ),
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  TextButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () {
                      setState(() {
                        _slugTouchedManually = false;
                        _sortTouchedManually = false;
                        _applyAutoSlugIfAllowed(force: true);
                        _applySuggestedSortIfAllowed(force: true);
                      });
                    },
                    icon: const Icon(Icons.auto_fix_high_rounded),
                    label: const Text('Auto-fill'),
                  ),
                ],
              ),
            ],
          ),
        ),
        MBSpacing.h(MBSpacing.lg),
        _buildCard(
          title: 'Brand image settings',
          subtitle: 'Optional manual logo URL or use the uploaded thumbnail as logo.',
          child: Column(
            children: [
              TextFormField(
                controller: _logoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Manual Logo URL (optional)',
                ),
              ),
              MBSpacing.h(MBSpacing.md),
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
                title: const Text('Use uploaded thumb as logo'),
                subtitle: const Text(
                  'If enabled, the uploaded thumbnail becomes the brand logo automatically.',
                ),
              ),
            ],
          ),
        ),
        MBSpacing.h(MBSpacing.lg),
        _buildCard(
          title: 'Status',
          subtitle: 'Visibility and storefront behavior.',
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Featured'),
                subtitle: const Text('Highlight this brand in admin and storefront sections.'),
                value: _isFeatured,
                onChanged: _isSaving
                    ? null
                    : (value) {
                  setState(() {
                    _isFeatured = value;
                  });
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show on Home'),
                subtitle: const Text('Allow this brand to appear in home page modules.'),
                value: _showOnHome,
                onChanged: _isSaving
                    ? null
                    : (value) {
                  setState(() {
                    _showOnHome = value;
                  });
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                subtitle: const Text('Inactive brands stay hidden from normal active listings.'),
                value: _isActive,
                onChanged: _isSaving
                    ? null
                    : (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
        MBSpacing.h(MBSpacing.lg),
        _buildCard(
          title: 'Counters',
          subtitle: 'Products count is kept here for visibility and admin checks.',
          child: TextFormField(
            controller: _productsCountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Products Count',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOriginalImageCard() {
    final original = _originalPickedImage;

    Widget imageBody;
    List<Widget> infoWidgets = [];

    if (original != null) {
      imageBody = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.memory(
            original.originalBytes,
            fit: BoxFit.cover,
          ),
        ),
      );

      infoWidgets = [
        _infoRow('Name', original.originalFileName),
        _infoRow('Source size', '${original.width} × ${original.height}'),
        _infoRow('Bytes', '${original.originalByteLength}'),
      ];
    } else if (_hasExistingImage) {
      imageBody = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            _existingPrimaryImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _emptyImageBox(
              icon: Icons.broken_image_outlined,
              text: 'Existing image could not be loaded.',
            ),
          ),
        ),
      );

      infoWidgets = [
        _infoRow('Image URL', widget.brand?.imageUrl.trim() ?? ''),
        _infoRow('Logo URL', widget.brand?.logoUrl.trim() ?? ''),
        _infoRow('Image path', widget.brand?.imagePath.trim() ?? ''),
        _infoRow('Thumb path', widget.brand?.thumbPath.trim() ?? ''),
      ];
    } else {
      imageBody = _emptyImageBox(
        icon: Icons.image_outlined,
        text: 'Select a brand image to continue.',
      );
    }

    return _buildCard(
      title: original != null
          ? 'Original image'
          : _hasExistingImage
          ? 'Current image'
          : 'Original image',
      subtitle: original != null
          ? 'This card shows the selected original image and source details.'
          : _hasExistingImage
          ? 'The current stored image stays active until you pick a new image.'
          : 'After image selection, the original preview and metadata will appear here.',
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageBody,
              const SizedBox(height: 16),
              ...infoWidgets,
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _pickOriginalImage,
                      icon: const Icon(Icons.image_search_rounded),
                      label: Text(
                        _originalPickedImage != null
                            ? 'Select another image'
                            : (_hasExistingImage ? 'Replace image' : 'Select image'),
                      ),
                    ),
                  ),
                ],
              ),
              if (isEdit && _hasExistingImage) ...[
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _removeExistingImage,
                  onChanged: _isSaving
                      ? null
                      : (value) {
                    setState(() {
                      _removeExistingImage = value ?? false;
                    });
                  },
                  title: const Text('Remove current stored image'),
                  subtitle: const Text(
                    'If checked, you must prepare a new image before updating unless a manual logo URL is kept.',
                  ),
                ),
              ],
            ],
          ),
          if (_isPickingImage)
            Positioned.fill(
              child: _busyOverlay('Opening image picker...'),
            ),
        ],
      ),
    );
  }

  Widget _buildResizedImageCard() {
    final prepared = _preparedImage;

    Widget topBody;
    List<Widget> infoWidgets = [];

    if (prepared != null) {
      topBody = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.memory(
            prepared.previewBytes,
            fit: BoxFit.cover,
          ),
        ),
      );

      infoWidgets = [
        _infoRow(
          'Full image',
          '${prepared.fullWidth} × ${prepared.fullHeight} • ${prepared.fullByteLength} bytes',
        ),
        _infoRow(
          'Thumb image',
          '${prepared.thumbWidth} × ${prepared.thumbHeight} • ${prepared.thumbByteLength} bytes',
        ),
        _infoRow(
          'Source',
          '${prepared.sourceWidth} × ${prepared.sourceHeight}',
        ),
      ];
    } else {
      topBody = _emptyImageBox(
        icon: Icons.crop_square_rounded,
        text: isEdit && _originalPickedImage == null
            ? 'Resize options stay hidden until you select a new image.'
            : 'Select an original image, then resize it here.',
      );
    }

    final bool showControls =
        _showResizeControls && (!isEdit || _originalPickedImage != null);

    return _buildCard(
      title: 'Resized image',
      subtitle: prepared != null
          ? 'This prepared image will be uploaded when you save.'
          : 'Choose a resize option, then generate the prepared image.',
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              topBody,
              const SizedBox(height: 16),
              ...infoWidgets,
              if (showControls) ...[
                const SizedBox(height: 16),
                Text(
                  'Resize option',
                  style: MBTextStyles.bodyMedium.copyWith(
                    color: MBColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ..._BrandImageResizeOption.values.map(
                      (option) => RadioListTile<_BrandImageResizeOption>(
                    contentPadding: EdgeInsets.zero,
                    value: option,
                    groupValue: _selectedResizeOption,
                    onChanged: _isSaving
                        ? null
                        : (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedResizeOption = value;
                      });
                    },
                    title: Text(option.label),
                    subtitle: Text(option.note),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: (_originalPickedImage == null || _isSaving)
                            ? null
                            : _resizeSelectedImage,
                        icon: const Icon(Icons.photo_size_select_large_rounded),
                        label: Text(
                          prepared == null ? 'Resize image' : 'Resize again',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          if (_isResizingImage)
            Positioned.fill(
              child: _busyOverlay('Preparing resized image...'),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MBTextStyles.bodyMedium.copyWith(
              color: MBColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: MBTextStyles.body.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: MBColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MBColors.error.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: MBColors.error,
          ),
          MBSpacing.w(MBSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: MBTextStyles.body.copyWith(
                color: MBColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyImageBox({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.lg),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.9),
        ),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 42,
                color: MBColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: MBTextStyles.body.copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '—' : value,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _busyOverlay(String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MBSpacing.lg,
            vertical: MBSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              MBSpacing.w(MBSpacing.sm),
              Text(
                text,
                style: MBTextStyles.bodyMedium.copyWith(
                  color: MBColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}