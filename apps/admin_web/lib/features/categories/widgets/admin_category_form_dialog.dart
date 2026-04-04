import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_core/media/mb_image_pipeline_service.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';

enum _CategoryImageResizeOption {
  small,
  recommended,
  large,
}

extension _CategoryImageResizeOptionX on _CategoryImageResizeOption {
  String get label {
    switch (this) {
      case _CategoryImageResizeOption.small:
        return 'Small (320 × 320)';
      case _CategoryImageResizeOption.recommended:
        return 'Recommended (512 × 512)';
      case _CategoryImageResizeOption.large:
        return 'Large (640 × 640)';
    }
  }

  int get size {
    switch (this) {
      case _CategoryImageResizeOption.small:
        return 320;
      case _CategoryImageResizeOption.recommended:
        return 512;
      case _CategoryImageResizeOption.large:
        return 640;
    }
  }

  int get thumbSize {
    switch (this) {
      case _CategoryImageResizeOption.small:
        return 120;
      case _CategoryImageResizeOption.recommended:
        return 160;
      case _CategoryImageResizeOption.large:
        return 200;
    }
  }

  String get note {
    switch (this) {
      case _CategoryImageResizeOption.small:
        return 'Compact square icon for lightweight category display.';
      case _CategoryImageResizeOption.recommended:
        return 'Best balance for mobile, tablet, and future scaling.';
      case _CategoryImageResizeOption.large:
        return 'Larger square image for higher-density displays.';
    }
  }
}

class AdminCategoryFormDialog extends StatefulWidget {
  const AdminCategoryFormDialog({
    super.key,
    this.category,
    required this.categories,
  });

  final MBCategory? category;
  final List<MBCategory> categories;

  @override
  State<AdminCategoryFormDialog> createState() =>
      _AdminCategoryFormDialogState();
}

class _AdminCategoryFormDialogState extends State<AdminCategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameEnController;
  late final TextEditingController _nameBnController;
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _descriptionBnController;
  late final TextEditingController _iconUrlController;
  late final TextEditingController _slugController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _productsCountController;

  bool _isFeatured = false;
  bool _showOnHome = false;
  bool _isActive = true;
  bool _useUploadedThumbAsIcon = true;
  bool _removeExistingImage = false;

  String? _selectedParentId;
  String? _slugErrorText;
  String? _submitError;
  String? _sortSuggestionText;

  bool _isSaving = false;
  bool _isPickingImage = false;
  bool _isResizingImage = false;

  MBOriginalPickedImage? _originalPickedImage;
  MBPreparedImageSet? _preparedImage;
  _CategoryImageResizeOption _selectedResizeOption =
      _CategoryImageResizeOption.recommended;

  bool get isEdit => widget.category != null;

  late final String _generatedId;

  String get _draftEntityId {
    final existingId = widget.category?.id.trim() ?? '';
    if (existingId.isNotEmpty) {
      return existingId;
    }
    return _generatedId;
  }

  bool get _isNewImageSelected => _originalPickedImage != null;

  bool get _hasPreparedImage => _preparedImage != null;

  bool get _hasExistingImage {
    return !_removeExistingImage && _currentPreviewUrl.isNotEmpty;
  }

  bool get _mustRequirePreparedImageForSubmit {
    if (!isEdit) return true;
    if (_removeExistingImage) return true;
    if (_isNewImageSelected) return true;
    return false;
  }

  bool get _isImageRequirementSatisfied {
    if (_mustRequirePreparedImageForSubmit) {
      return _isNewImageSelected && _hasPreparedImage;
    }
    return _hasExistingImage;
  }

  bool get _canResize {
    return _originalPickedImage != null &&
        !_isPickingImage &&
        !_isResizingImage &&
        !_isSaving;
  }

  bool get _canSubmit {
    return !_isSaving &&
        !_isPickingImage &&
        !_isResizingImage &&
        _isImageRequirementSatisfied;
  }

  bool get _isDialogBlocked {
    return _isSaving || _isPickingImage || _isResizingImage;
  }

  String _normalizeParentId(String? parentId) {
    return parentId?.trim() ?? '';
  }

  @override
  void initState() {
    super.initState();

    _generatedId = 'cat_${DateTime.now().microsecondsSinceEpoch}';

    final category = widget.category;

    _nameEnController = TextEditingController(text: category?.nameEn ?? '');
    _nameBnController = TextEditingController(text: category?.nameBn ?? '');
    _descriptionEnController =
        TextEditingController(text: category?.descriptionEn ?? '');
    _descriptionBnController =
        TextEditingController(text: category?.descriptionBn ?? '');
    _iconUrlController = TextEditingController(
      text: category?.iconUrl ?? '',
    );
    _slugController = TextEditingController(text: category?.slug ?? '');
    _sortOrderController =
        TextEditingController(text: '${category?.sortOrder ?? 0}');
    _productsCountController =
        TextEditingController(text: '${category?.productsCount ?? 0}');

    _isFeatured = category?.isFeatured ?? false;
    _showOnHome = category?.showOnHome ?? false;
    _isActive = category?.isActive ?? true;
    _selectedParentId = category?.parentId;

    _nameEnController.addListener(_handleNameChanged);

    if (!isEdit && _slugController.text.trim().isEmpty) {
      _slugController.text = _generateSlug(_nameEnController.text);
    }

    if (!isEdit) {
      _applySuggestedSortOrder(forceReplace: true);
    } else {
      _updateSortSuggestionLabel();
    }
  }

  void _handleNameChanged() {
    if (!mounted) return;

    if (!isEdit) {
      final nextSlug = _generateSlug(_nameEnController.text);
      if (_slugController.text != nextSlug) {
        _slugController.text = nextSlug;
      }
    }

    if (_slugErrorText != null) {
      setState(() {
        _slugErrorText = null;
      });
    } else {
      setState(() {});
    }
  }

  String _generateSlug(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'[\s_-]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  Set<String> _collectDescendantIds(String rootId) {
    final Map<String, List<String>> parentToChildren = <String, List<String>>{};

    for (final category in widget.categories) {
      final parentId = category.parentId?.trim();
      if (parentId == null || parentId.isEmpty) continue;

      parentToChildren.putIfAbsent(parentId, () => <String>[]).add(category.id);
    }

    final Set<String> descendants = <String>{};
    final List<String> stack = <String>[rootId];

    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      final children = parentToChildren[current] ?? <String>[];

      for (final childId in children) {
        if (descendants.add(childId)) {
          stack.add(childId);
        }
      }
    }

    return descendants;
  }

  List<MBCategory> get _parentOptions {
    final String? currentId = widget.category?.id;
    final Set<String> blockedIds = <String>{};

    if (currentId != null && currentId.trim().isNotEmpty) {
      blockedIds.add(currentId);
      blockedIds.addAll(_collectDescendantIds(currentId));
    }

    final items = widget.categories
        .where((cat) => !blockedIds.contains(cat.id))
        .toList()
      ..sort((a, b) {
        final bySort = a.sortOrder.compareTo(b.sortOrder);
        if (bySort != 0) return bySort;
        return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
      });

    return items;
  }

  List<MBCategory> _categoriesInCurrentGroup() {
    final normalizedParentId = _normalizeParentId(_selectedParentId);
    final editingId = widget.category?.id.trim() ?? '';

    final items = widget.categories.where((item) {
      if (editingId.isNotEmpty && item.id == editingId) {
        return false;
      }

      return _normalizeParentId(item.parentId) == normalizedParentId;
    }).toList()
      ..sort((a, b) {
        final int bySort = a.sortOrder.compareTo(b.sortOrder);
        if (bySort != 0) return bySort;
        return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
      });

    return items;
  }

  int _suggestSortOrder() {
    final items = _categoriesInCurrentGroup();
    final used = items.map((e) => e.sortOrder).toSet();

    for (int i = 0; i < used.length + 1; i++) {
      if (!used.contains(i)) {
        return i;
      }
    }

    return used.length;
  }

  bool _isSortDuplicate(int value) {
    final editingId = widget.category?.id.trim() ?? '';
    final normalizedParentId = _normalizeParentId(_selectedParentId);

    return widget.categories.any((item) {
      if (editingId.isNotEmpty && item.id == editingId) {
        return false;
      }

      return _normalizeParentId(item.parentId) == normalizedParentId &&
          item.sortOrder == value;
    });
  }

  void _updateSortSuggestionLabel() {
    final suggested = _suggestSortOrder();

    setState(() {
      _sortSuggestionText =
      'Suggested sort number for this group: $suggested';
    });
  }

  void _applySuggestedSortOrder({
    required bool forceReplace,
  }) {
    final suggested = _suggestSortOrder();

    if (forceReplace || _sortOrderController.text.trim().isEmpty) {
      _sortOrderController.text = suggested.toString();
    }

    _sortSuggestionText =
    'Suggested sort number for this group: $suggested';
  }

  Uint8List? get _originalPreviewBytes {
    return _originalPickedImage?.originalBytes;
  }

  Uint8List? get _resizedPreviewBytes {
    return _preparedImage?.previewBytes;
  }

  String get _currentPreviewUrl {
    if (_removeExistingImage) {
      return '';
    }

    final String imageUrl = widget.category?.imageUrl.trim() ?? '';
    final String iconUrl = widget.category?.iconUrl.trim() ?? '';

    if (imageUrl.isNotEmpty) return imageUrl;
    if (iconUrl.isNotEmpty) return iconUrl;

    return '';
  }

  Future<void> _pickOriginalImage() async {
    if (_isPickingImage || _isSaving || _isResizingImage) return;

    setState(() {
      _isPickingImage = true;
      _submitError = null;
    });

    try {
      final original = await MBImagePipelineService.instance.pickOriginalImage();

      if (!mounted) return;

      if (original == null) {
        setState(() {
          _isPickingImage = false;
        });
        return;
      }

      setState(() {
        _originalPickedImage = original;
        _preparedImage = null;
        _selectedResizeOption = _CategoryImageResizeOption.recommended;
        _removeExistingImage = false;
        _isPickingImage = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isPickingImage = false;
        _submitError = 'Image selection failed: $e';
      });
    }
  }

  Future<void> _resizeSelectedImage() async {
    if (_originalPickedImage == null || _isResizingImage || _isSaving) return;

    setState(() {
      _isResizingImage = true;
      _submitError = null;
    });

    try {
      final prepared =
      await MBImagePipelineService.instance.prepareImageSetFromOriginal(
        original: _originalPickedImage!,
        fullMaxWidth: _selectedResizeOption.size,
        fullMaxHeight: _selectedResizeOption.size,
        fullJpegQuality: 88,
        thumbSize: _selectedResizeOption.thumbSize,
        thumbJpegQuality: 82,
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
        _isResizingImage = false;
        _submitError = 'Image resize failed: $e';
      });
    }
  }

  void _removePreparedOrExistingImage() {
    setState(() {
      _preparedImage = null;
      _originalPickedImage = null;

      if (_currentPreviewUrl.isNotEmpty) {
        _removeExistingImage = true;
      }
    });
  }

  Future<bool> _isSlugAvailable({
    required String slug,
    String? excludeCategoryId,
  }) async {
    if (slug.trim().isEmpty) return false;

    final exists = await AdminCategoryRepository.instance.slugExists(
      slug: slug.trim(),
      excludeCategoryId: excludeCategoryId,
    );

    return !exists;
  }

  String _formatBytesFromLength(int? length) {
    if (length == null || length <= 0) return 'N/A';

    if (length < 1024) return '$length B';

    final double kb = length / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';

    final double mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MBSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: MBTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: MBColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: MBTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameEnController.removeListener(_handleNameChanged);

    _nameEnController.dispose();
    _nameBnController.dispose();
    _descriptionEnController.dispose();
    _descriptionBnController.dispose();
    _iconUrlController.dispose();
    _slugController.dispose();
    _sortOrderController.dispose();
    _productsCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedParent = _selectedParentId != null &&
        _parentOptions.any((cat) => cat.id == _selectedParentId);

    final String? dropdownInitialValue =
    hasSelectedParent ? _selectedParentId : null;

    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1100,
          maxHeight: 900,
        ),
        child: Stack(
          children: [
            AbsorbPointer(
              absorbing: _isDialogBlocked,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(MBSpacing.xl),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEdit ? 'Edit Category' : 'Create Category',
                            style: MBTextStyles.sectionTitle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _isDialogBlocked
                              ? null
                              : () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(MBSpacing.xl),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: MBTextField(
                                              controller: _nameEnController,
                                              labelText: 'Name (English)',
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
                                            child: MBTextField(
                                              controller: _nameBnController,
                                              labelText: 'Name (Bangla)',
                                            ),
                                          ),
                                        ],
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: MBTextField(
                                              controller:
                                              _descriptionEnController,
                                              labelText: 'Description (English)',
                                              maxLines: 3,
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child: MBTextField(
                                              controller:
                                              _descriptionBnController,
                                              labelText: 'Description (Bangla)',
                                              maxLines: 3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: MBTextField(
                                              controller: _slugController,
                                              labelText: 'Slug',
                                              enabled: false,
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child:
                                            DropdownButtonFormField<String>(
                                              initialValue: dropdownInitialValue,
                                              decoration: const InputDecoration(
                                                labelText: 'Parent Category',
                                                border: OutlineInputBorder(),
                                              ),
                                              items: [
                                                const DropdownMenuItem<String>(
                                                  value: null,
                                                  child: Text('None'),
                                                ),
                                                ..._parentOptions.map(
                                                      (cat) =>
                                                      DropdownMenuItem<String>(
                                                        value: cat.id,
                                                        child: Text(
                                                          cat.nameEn.trim().isEmpty
                                                              ? 'Unnamed Category'
                                                              : cat.nameEn,
                                                        ),
                                                      ),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedParentId = value;
                                                  _applySuggestedSortOrder(
                                                    forceReplace: !isEdit,
                                                  );
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_slugErrorText != null) ...[
                                        MBSpacing.h(MBSpacing.sm),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _slugErrorText!,
                                                style:
                                                MBTextStyles.body.copyWith(
                                                  color: MBColors.error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      MBSpacing.h(MBSpacing.md),
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                MBTextField(
                                                  controller:
                                                  _sortOrderController,
                                                  labelText: 'Sort Order',
                                                  keyboardType:
                                                  TextInputType.number,
                                                  validator: (value) {
                                                    final sortValue =
                                                        int.tryParse(
                                                          (value ?? '').trim(),
                                                        ) ??
                                                            -1;

                                                    if (sortValue < 0) {
                                                      return 'Enter valid sort number';
                                                    }

                                                    if (_isSortDuplicate(sortValue)) {
                                                      return 'Sort number already exists in this group';
                                                    }

                                                    return null;
                                                  },
                                                ),
                                                MBSpacing.h(MBSpacing.xs),
                                                Text(
                                                  _sortSuggestionText ??
                                                      'Suggested sort number will appear here.',
                                                  style: MBTextStyles.bodySmall.copyWith(
                                                    color: MBColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                MBTextField(
                                                  controller:
                                                  _productsCountController,
                                                  labelText: 'Products Count',
                                                  keyboardType:
                                                  TextInputType.number,
                                                  enabled: false,
                                                ),
                                                MBSpacing.h(MBSpacing.xs),
                                                Text(
                                                  'This value is auto-calculated from product creation/update.',
                                                  style:
                                                  MBTextStyles.bodySmall.copyWith(
                                                    color:
                                                    MBColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      MBTextField(
                                        controller: _iconUrlController,
                                        labelText:
                                        'Icon URL override (optional, leave blank to use uploaded thumb)',
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      MBCard(
                                        padding:
                                        const EdgeInsets.all(MBSpacing.md),
                                        child: Column(
                                          children: [
                                            SwitchListTile(
                                              title: const Text('Featured'),
                                              value: _isFeatured,
                                              onChanged: (value) {
                                                setState(() {
                                                  _isFeatured = value;
                                                });
                                              },
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            SwitchListTile(
                                              title: const Text('Show On Home'),
                                              value: _showOnHome,
                                              onChanged: (value) {
                                                setState(() {
                                                  _showOnHome = value;
                                                });
                                              },
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            SwitchListTile(
                                              title: const Text('Active'),
                                              value: _isActive,
                                              onChanged: (value) {
                                                setState(() {
                                                  _isActive = value;
                                                });
                                              },
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            SwitchListTile(
                                              title: const Text(
                                                'Use uploaded thumb as icon',
                                              ),
                                              value: _useUploadedThumbAsIcon,
                                              onChanged: (value) {
                                                setState(() {
                                                  _useUploadedThumbAsIcon =
                                                      value;
                                                });
                                              },
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                MBSpacing.w(MBSpacing.lg),
                                Expanded(
                                  flex: 2,
                                  child: _buildImagePanel(),
                                ),
                              ],
                            ),
                            if (_submitError != null) ...[
                              MBSpacing.h(MBSpacing.md),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(MBSpacing.md),
                                decoration: BoxDecoration(
                                  color: MBColors.error.withValues(alpha: 0.08),
                                  borderRadius:
                                  BorderRadius.circular(MBRadius.lg),
                                  border: Border.all(
                                    color:
                                    MBColors.error.withValues(alpha: 0.20),
                                  ),
                                ),
                                child: Text(
                                  _submitError!,
                                  style: MBTextStyles.body.copyWith(
                                    color: MBColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(MBSpacing.xl),
                    child: Row(
                      children: [
                        Expanded(
                          child: MBSecondaryButton(
                            text: 'Cancel',
                            isLoading: _isSaving,
                            onPressed: _isDialogBlocked
                                ? null
                                : () => Navigator.of(context).pop(false),
                          ),
                        ),
                        MBSpacing.w(MBSpacing.md),
                        Expanded(
                          child: MBPrimaryButton(
                            text: isEdit ? 'Update Category' : 'Create Category',
                            isLoading: _isSaving,
                            onPressed:
                            _isDialogBlocked || !_canSubmit ? null : _submit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isDialogBlocked) _buildGlobalOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalOverlay() {
    String message = 'Processing...';

    if (_isPickingImage) {
      message = 'Picking image...';
    } else if (_isResizingImage) {
      message = 'Resizing image...';
    } else if (_isSaving) {
      message = 'Saving category...';
    }

    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(MBRadius.lg),
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 6,
                  sigmaY: 6,
                ),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(MBSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(MBRadius.lg),
                    border: Border.all(
                      color: MBColors.border.withValues(alpha: 0.9),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(),
                      ),
                      MBSpacing.h(MBSpacing.md),
                      Text(
                        message,
                        style: MBTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      MBSpacing.h(MBSpacing.xs),
                      Text(
                        'Please wait...',
                        style: MBTextStyles.body.copyWith(
                          color: MBColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePanel() {
    final bool hasSelectedImage =
        _originalPickedImage != null || _currentPreviewUrl.isNotEmpty;

    return MBCard(
      padding: const EdgeInsets.all(MBSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Image',
            style: MBTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.sm),
          Text(
            'Select original image, review the original preview, choose one category preset, click Resize Preview, then save.',
            style: MBTextStyles.body.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
          MBSpacing.h(MBSpacing.md),
          _buildImageActionBar(hasSelectedImage),
          MBSpacing.h(MBSpacing.md),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: MBColors.background,
              borderRadius: BorderRadius.circular(MBRadius.lg),
              border: Border.all(
                color: MBColors.border.withValues(alpha: 0.90),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(MBSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool useColumn = constraints.maxWidth < 520;

                      if (useColumn) {
                        return Column(
                          children: [
                            _buildOriginalPreviewCard(),
                            MBSpacing.h(MBSpacing.md),
                            _buildResizedPreviewCard(),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildOriginalPreviewCard()),
                          MBSpacing.w(MBSpacing.md),
                          Expanded(child: _buildResizedPreviewCard()),
                        ],
                      );
                    },
                  ),
                  MBSpacing.h(MBSpacing.md),
                  _buildResizeControls(),
                  if (_originalPickedImage != null && _preparedImage == null) ...[
                    MBSpacing.h(MBSpacing.sm),
                    Text(
                      'Resize is required before ${isEdit ? 'updating' : 'creating'} this category.',
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (_removeExistingImage &&
                      _originalPickedImage == null &&
                      _preparedImage == null) ...[
                    MBSpacing.h(MBSpacing.sm),
                    Text(
                      'Existing image has been removed. Please select and resize a new image before saving.',
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.warning,
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
    );
  }

  Widget _buildImageActionBar(bool hasSelectedImage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.md),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Wrap(
        spacing: MBSpacing.sm,
        runSpacing: MBSpacing.sm,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: _isDialogBlocked ? null : _pickOriginalImage,
            icon: const Icon(Icons.upload_rounded),
            label: Text(
              hasSelectedImage ? 'Change Image' : 'Select Image',
            ),
          ),
          OutlinedButton.icon(
            onPressed: _isDialogBlocked || !hasSelectedImage
                ? null
                : _removePreparedOrExistingImage,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Remove'),
          ),
          if (_originalPickedImage != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MBSpacing.sm,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: MBColors.primaryOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(MBRadius.md),
                border: Border.all(
                  color: MBColors.primaryOrange.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 18,
                    color: MBColors.primaryOrange,
                  ),
                  MBSpacing.w(MBSpacing.xs),
                  Text(
                    'New image selected',
                    style: MBTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: MBColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            )
          else if (_currentPreviewUrl.isNotEmpty && !_removeExistingImage)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MBSpacing.sm,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(MBRadius.md),
                border: Border.all(
                  color: MBColors.border.withValues(alpha: 0.85),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: MBColors.textSecondary,
                  ),
                  MBSpacing.w(MBSpacing.xs),
                  Text(
                    'Using saved image',
                    style: MBTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: MBColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOriginalPreviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.md),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MBSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original Preview',
              style: MBTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.sm),
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: MBColors.primaryOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(MBRadius.md),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildOriginalPreview(),
            ),
            MBSpacing.h(MBSpacing.md),
            _buildOriginalInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildResizedPreviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.md),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MBSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resized Preview',
              style: MBTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.sm),
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: MBColors.primaryOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(MBRadius.md),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildResizedPreview(),
            ),
            MBSpacing.h(MBSpacing.md),
            _buildPreparedInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginalPreview() {
    if (_originalPreviewBytes != null) {
      return Image.memory(
        _originalPreviewBytes!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      );
    }

    if (_currentPreviewUrl.isNotEmpty) {
      return Image.network(
        _currentPreviewUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              'No image found, please select an image.',
              textAlign: TextAlign.center,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
          );
        },
      );
    }

    return Center(
      child: Text(
        isEdit
            ? 'No image found, please select an image.'
            : 'Please select an image.',
        textAlign: TextAlign.center,
        style: MBTextStyles.body.copyWith(
          color: MBColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildResizedPreview() {
    if (_resizedPreviewBytes != null) {
      return Image.memory(
        _resizedPreviewBytes!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      );
    }

    return Center(
      child: Text(
        'Resized preview will appear here after clicking Resize Preview.',
        textAlign: TextAlign.center,
        style: MBTextStyles.body.copyWith(
          color: MBColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildOriginalInfoSection() {
    if (_originalPickedImage == null) {
      if (_currentPreviewUrl.isNotEmpty && !_removeExistingImage) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(MBSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MBRadius.md),
            border: Border.all(
              color: MBColors.border.withValues(alpha: 0.85),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current image information',
                style: MBTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              MBSpacing.h(MBSpacing.xs),
              _buildInfoRow(label: 'Status', value: 'Using existing image'),
              _buildInfoRow(label: 'Source', value: 'Saved category image'),
            ],
          ),
        );
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(MBSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MBRadius.md),
          border: Border.all(
            color: MBColors.border.withValues(alpha: 0.85),
          ),
        ),
        child: Text(
          'Original image information will appear here after selecting an image.',
          style: MBTextStyles.body.copyWith(
            color: MBColors.textSecondary,
          ),
        ),
      );
    }

    final original = _originalPickedImage!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.md),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Original image information',
            style: MBTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.xs),
          _buildInfoRow(label: 'Name', value: original.originalFileName),
          _buildInfoRow(
            label: 'Size',
            value: '${original.width} × ${original.height}',
          ),
          _buildInfoRow(
            label: 'File',
            value: _formatBytesFromLength(original.originalByteLength),
          ),
        ],
      ),
    );
  }

  Widget _buildResizeControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.md),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resize options',
            style: MBTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.sm),
          Text(
            'Category images are square only. Recommended size is 512 × 512.',
            style: MBTextStyles.body.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
          MBSpacing.h(MBSpacing.md),
          SegmentedButton<_CategoryImageResizeOption>(
            segments: _CategoryImageResizeOption.values
                .map(
                  (option) => ButtonSegment<_CategoryImageResizeOption>(
                value: option,
                label: Text(option.label),
                tooltip: option.note,
              ),
            )
                .toList(),
            selected: <_CategoryImageResizeOption>{_selectedResizeOption},
            onSelectionChanged:
            _originalPickedImage == null || _isDialogBlocked
                ? null
                : (selectedValues) {
              if (selectedValues.isEmpty) return;

              setState(() {
                _selectedResizeOption = selectedValues.first;
                _preparedImage = null;
              });
            },
            multiSelectionEnabled: false,
            emptySelectionAllowed: false,
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(
                  horizontal: MBSpacing.sm,
                  vertical: MBSpacing.sm,
                ),
              ),
            ),
          ),
          MBSpacing.h(MBSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(MBSpacing.sm),
            decoration: BoxDecoration(
              color: MBColors.primaryOrange.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(MBRadius.md),
              border: Border.all(
                color: MBColors.primaryOrange.withValues(alpha: 0.16),
              ),
            ),
            child: Text(
              _selectedResizeOption.note,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
          ),
          MBSpacing.h(MBSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _canResize && !_isDialogBlocked
                  ? _resizeSelectedImage
                  : null,
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Resize Preview'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparedInfoSection() {
    if (_preparedImage == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(MBSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MBRadius.md),
          border: Border.all(
            color: MBColors.border.withValues(alpha: 0.85),
          ),
        ),
        child: Text(
          'Resized image information will appear here after clicking Resize Preview.',
          style: MBTextStyles.body.copyWith(
            color: MBColors.textSecondary,
          ),
        ),
      );
    }

    final prepared = _preparedImage!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.md),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resized image information',
            style: MBTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.xs),
          _buildInfoRow(label: 'Preset', value: _selectedResizeOption.label),
          _buildInfoRow(
            label: 'Full',
            value: '${prepared.fullWidth} × ${prepared.fullHeight}',
          ),
          _buildInfoRow(
            label: 'Thumb',
            value: '${prepared.thumbWidth} × ${prepared.thumbHeight}',
          ),
          _buildInfoRow(label: 'File', value: prepared.originalFileName),
          _buildInfoRow(
            label: 'Full file',
            value: _formatBytesFromLength(prepared.fullByteLength),
          ),
          _buildInfoRow(
            label: 'Thumb file',
            value: _formatBytesFromLength(prepared.thumbByteLength),
          ),
          _buildInfoRow(
            label: 'Crop',
            value:
            prepared.requestSquareCrop ? 'Square crop applied' : 'No crop',
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() {
      _slugErrorText = null;
      _submitError = null;
      _isSaving = true;
    });

    try {
      final String slug = _slugController.text.trim();
      final int sortValue =
          int.tryParse(_sortOrderController.text.trim()) ?? -1;

      if (sortValue < 0) {
        setState(() {
          _submitError = 'Enter valid sort number.';
          _isSaving = false;
        });
        return;
      }

      final bool slugAvailable = await _isSlugAvailable(
        slug: slug,
        excludeCategoryId: widget.category?.id,
      );

      if (!slugAvailable) {
        setState(() {
          _slugErrorText =
          'This slug already exists. Change the English name to generate another slug.';
          _isSaving = false;
        });
        return;
      }

      if (_isSortDuplicate(sortValue)) {
        setState(() {
          _submitError =
          'Sort number already exists in this group. Please use another.';
          _isSaving = false;
        });
        return;
      }

      if (_mustRequirePreparedImageForSubmit && _originalPickedImage == null) {
        setState(() {
          _submitError = isEdit
              ? 'Please select a new image.'
              : 'Please select an image.';
          _isSaving = false;
        });
        return;
      }

      if (_mustRequirePreparedImageForSubmit && _preparedImage == null) {
        setState(() {
          _submitError = 'Please resize the image before submitting.';
          _isSaving = false;
        });
        return;
      }

      String finalImageUrl = widget.category?.imageUrl.trim() ?? '';
      String finalIconUrl = widget.category?.iconUrl.trim() ?? '';
      String finalImagePath = widget.category?.imagePath.trim() ?? '';
      String finalThumbPath = widget.category?.thumbPath.trim() ?? '';

      if (_removeExistingImage &&
          _preparedImage == null &&
          _originalPickedImage == null) {
        finalImageUrl = '';
        finalIconUrl = '';
        finalImagePath = '';
        finalThumbPath = '';
      }

      final MBPreparedImageSet? preparedForUpload = _preparedImage;

      if (preparedForUpload != null) {
        final MBUploadedImageSet uploaded =
        await MBImagePipelineService.instance.uploadPreparedImageSet(
          prepared: preparedForUpload,
          storageFolder: 'category_images',
          entityId: _draftEntityId,
          fileStem: 'category_main',
          customMetadata: <String, String>{
            'entityType': 'category',
            'slug': slug,
          },
        );

        finalImageUrl = uploaded.fullUrl;
        finalImagePath = uploaded.fullPath;
        finalThumbPath = uploaded.thumbPath;

        if (_useUploadedThumbAsIcon) {
          finalIconUrl = uploaded.thumbUrl;
        }
      }

      if (_iconUrlController.text.trim().isNotEmpty) {
        finalIconUrl = _iconUrlController.text.trim();
      }

      if (finalImageUrl.trim().isEmpty && finalIconUrl.trim().isEmpty) {
        setState(() {
          _submitError = isEdit
              ? 'No image found, please select an image.'
              : 'Please select an image.';
          _isSaving = false;
        });
        return;
      }

      final DateTime now = DateTime.now();
      final MBCategory? existing = widget.category;

      final MBCategory category = MBCategory(
        id: existing?.id ?? _draftEntityId,
        nameEn: _nameEnController.text.trim(),
        nameBn: _nameBnController.text.trim(),
        descriptionEn: _descriptionEnController.text.trim(),
        descriptionBn: _descriptionBnController.text.trim(),
        imageUrl: finalImageUrl,
        iconUrl: finalIconUrl,
        imagePath: finalImagePath,
        thumbPath: finalThumbPath,
        slug: slug,
        parentId: _selectedParentId,
        isFeatured: _isFeatured,
        showOnHome: _showOnHome,
        isActive: _isActive,
        sortOrder: sortValue,
        productsCount:
        int.tryParse(_productsCountController.text.trim()) ?? 0,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      if (existing == null) {
        await AdminCategoryRepository.instance.createCategory(category);
      } else {
        await AdminCategoryRepository.instance.updateCategory(category);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _submitError = e.toString();
        _isSaving = false;
      });
    }
  }
}