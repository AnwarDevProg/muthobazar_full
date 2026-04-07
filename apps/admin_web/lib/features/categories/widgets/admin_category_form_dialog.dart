import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_core/media/mb_image_pipeline_service.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';

import '../controllers/admin_category_controller.dart';

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
        return 'Balanced size for mobile and tablet category thumbnails.';
      case _CategoryImageResizeOption.large:
        return 'Larger square image for sharper catalog rendering.';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AdminCategoryController _controller;

  late final TextEditingController _nameEnController;
  late final TextEditingController _nameBnController;
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _descriptionBnController;
  late final TextEditingController _iconUrlController;
  late final TextEditingController _slugController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _productsCountController;

  final FocusNode _nameEnFocusNode = FocusNode();
  final FocusNode _slugFocusNode = FocusNode();
  final FocusNode _sortOrderFocusNode = FocusNode();

  bool _isFeatured = false;
  bool _showOnHome = false;
  bool _isActive = true;
  bool _useUploadedThumbAsIcon = true;
  bool _removeExistingImage = false;

  bool _isSaving = false;
  bool _isPickingImage = false;
  bool _isResizingImage = false;
  bool _isAutoUpdatingSlug = false;
  bool _isAutoUpdatingSort = false;

  bool _slugTouchedManually = false;
  bool _sortTouchedManually = false;

  String? _selectedParentId;
  String? _slugErrorText;
  String? _sortErrorText;
  String? _submitError;

  MBOriginalPickedImage? _originalPickedImage;
  MBPreparedImageSet? _preparedImage;
  _CategoryImageResizeOption _selectedResizeOption =
      _CategoryImageResizeOption.recommended;

  late final String _generatedId;

  bool get isEdit => widget.category != null;

  String get _draftEntityId {
    final existingId = widget.category?.id.trim() ?? '';
    if (existingId.isNotEmpty) {
      return existingId;
    }
    return _generatedId;
  }

  String get _existingPrimaryImageUrl {
    final imageUrl = widget.category?.imageUrl.trim() ?? '';
    final iconUrl = widget.category?.iconUrl.trim() ?? '';
    return imageUrl.isNotEmpty ? imageUrl : iconUrl;
  }

  bool get _hasExistingImage =>
      !_removeExistingImage &&
          ((widget.category?.imageUrl.trim().isNotEmpty ?? false) ||
              (widget.category?.iconUrl.trim().isNotEmpty ?? false));

  bool get _hasPreparedImage => _preparedImage != null;

  bool get _showResizeControls {
    if (_isResizingImage) return true;
    return _originalPickedImage != null;
  }

  bool get _canSubmit {
    if (_isSaving || _isPickingImage || _isResizingImage) return false;
    if (!_isFormBasicsValid) return false;

    if (isEdit) {
      return _hasPreparedImage || _hasExistingImage;
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

  List<MBCategory> get _availableParentCategories {
    final currentId = widget.category?.id.trim() ?? '';
    final items = widget.categories.where((item) {
      if (currentId.isEmpty) return true;
      return item.id.trim() != currentId;
    }).toList();

    items.sort((a, b) {
      final byName = a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
      if (byName != 0) return byName;
      return a.id.compareTo(b.id);
    });

    return items;
  }

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<AdminCategoryController>()
        ? Get.find<AdminCategoryController>()
        : Get.put(AdminCategoryController());

    _generatedId = FirebaseFirestore.instance.collection('categories').doc().id;

    final MBCategory? category = widget.category;

    _nameEnController = TextEditingController(text: category?.nameEn ?? '');
    _nameBnController = TextEditingController(text: category?.nameBn ?? '');
    _descriptionEnController =
        TextEditingController(text: category?.descriptionEn ?? '');
    _descriptionBnController =
        TextEditingController(text: category?.descriptionBn ?? '');
    _iconUrlController = TextEditingController(text: category?.iconUrl ?? '');

    final String initialSlug = (category?.slug.trim().isNotEmpty ?? false)
        ? category!.slug.trim()
        : _normalizeSlug(category?.nameEn ?? '');
    _slugController = TextEditingController(text: initialSlug);

    _sortOrderController = TextEditingController(
      text: (category?.sortOrder ?? 0).toString(),
    );
    _productsCountController = TextEditingController(
      text: (category?.productsCount ?? 0).toString(),
    );

    _isFeatured = category?.isFeatured ?? false;
    _showOnHome = category?.showOnHome ?? false;
    _isActive = category?.isActive ?? true;
    _selectedParentId = _normalizeParentId(category?.parentId);

    _slugTouchedManually = isEdit &&
        initialSlug.isNotEmpty &&
        initialSlug != _normalizeSlug(category?.nameEn ?? '');
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
    _iconUrlController.dispose();
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

  String? _normalizeParentId(String? value) {
    final normalized = (value ?? '').trim();
    return normalized.isEmpty ? null : normalized;
  }

  String _groupIdFromParentId(String? parentId) {
    final normalized = (parentId ?? '').trim();
    return normalized.isEmpty ? 'root' : normalized;
  }

  List<MBCategory> _categoriesInCurrentGroup() {
    final currentId = widget.category?.id.trim() ?? '';
    final groupId = _groupIdFromParentId(_selectedParentId);

    final items = widget.categories.where((item) {
      if (currentId.isNotEmpty && item.id.trim() == currentId) {
        return false;
      }
      return _groupIdFromParentId(item.parentId) == groupId;
    }).toList();

    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items;
  }

  int _firstAvailableSortOrder() {
    final used = _categoriesInCurrentGroup()
        .map((item) => item.sortOrder)
        .where((value) => value >= 0)
        .toSet()
        .toList()
      ..sort();

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

    final currentId = widget.category?.id.trim() ?? '';
    final duplicate = widget.categories.any((item) {
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
    final parsed = int.tryParse(_sortOrderController.text.trim());
    if (parsed == null) {
      return 'Enter a valid integer.';
    }

    if (parsed < 0) {
      return 'Sort order must be 0 or greater.';
    }

    final currentId = widget.category?.id.trim() ?? '';
    final groupId = _groupIdFromParentId(_selectedParentId);
    final duplicate = widget.categories.any((item) {
      if (currentId.isNotEmpty && item.id.trim() == currentId) {
        return false;
      }
      return _groupIdFromParentId(item.parentId) == groupId &&
          item.sortOrder == parsed;
    });

    if (duplicate) {
      return 'This sort order already exists in the selected group.';
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

      String finalImageUrl = widget.category?.imageUrl.trim() ?? '';
      String finalIconUrl = widget.category?.iconUrl.trim() ?? '';
      String finalImagePath = widget.category?.imagePath.trim() ?? '';
      String finalThumbPath = widget.category?.thumbPath.trim() ?? '';

      if (_removeExistingImage && _preparedImage == null) {
        finalImageUrl = '';
        finalIconUrl = '';
        finalImagePath = '';
        finalThumbPath = '';
      }

      if (_preparedImage != null) {
        final uploaded = await MBImagePipelineService.instance.uploadPreparedImageSet(
          prepared: _preparedImage!,
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
        throw Exception(
          isEdit
              ? 'Please keep the previous image or prepare a new image before updating.'
              : 'Please prepare an image before creating this category.',
        );
      }

      final now = DateTime.now();
      final existing = widget.category;

      final category = MBCategory(
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
        sortOrder: sortOrder,
        productsCount: existing?.productsCount ?? 0,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      await _controller.saveCategory(
        category: category,
        isEdit: isEdit,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
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

  Widget _buildFieldSection() {
    return Form(
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
                  focusNode: _nameEnFocusNode,
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
                  focusNode: _slugFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Slug',
                    border: const OutlineInputBorder(),
                    errorText: _slugErrorText,
                  ),
                  validator: (_) => _buildSlugError(),
                ),
              ),
              SizedBox(
                width: 320,
                child: TextFormField(
                  controller: _sortOrderController,
                  focusNode: _sortOrderFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Sort order',
                    border: const OutlineInputBorder(),
                    errorText: _sortErrorText,
                    helperText:
                    'Auto-filled from the first missing sort in this group. You can still adjust it manually.',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (_) => _buildSortError(),
                ),
              ),
              SizedBox(
                width: 320,
                child: DropdownButtonFormField<String?>(
                  value: _selectedParentId,
                  decoration: const InputDecoration(
                    labelText: 'Parent category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No parent (root)'),
                    ),
                    ..._availableParentCategories.map(
                          (item) => DropdownMenuItem<String?>(
                        value: item.id,
                        child: Text(item.nameEn),
                      ),
                    ),
                  ],
                  onChanged: _isSaving
                      ? null
                      : (value) {
                    setState(() {
                      _selectedParentId = value;
                      if (!isEdit || !_sortTouchedManually) {
                        _applySuggestedSortIfAllowed(force: true);
                      } else {
                        _sortErrorText = _buildSortError();
                      }
                    });
                  },
                ),
              ),
              SizedBox(
                width: 320,
                child: TextFormField(
                  controller: _iconUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Custom icon URL (optional)',
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
                    labelText: 'Products count',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionEnController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description (English)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionBnController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description (Bangla)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilterChip(
                label: const Text('Featured'),
                selected: _isFeatured,
                onSelected: _isSaving
                    ? null
                    : (value) {
                  setState(() {
                    _isFeatured = value;
                  });
                },
              ),
              FilterChip(
                label: const Text('Show on home'),
                selected: _showOnHome,
                onSelected: _isSaving
                    ? null
                    : (value) {
                  setState(() {
                    _showOnHome = value;
                  });
                },
              ),
              FilterChip(
                label: const Text('Active'),
                selected: _isActive,
                onSelected: _isSaving
                    ? null
                    : (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
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
        _infoRow('Image URL', widget.category?.imageUrl.trim() ?? ''),
        _infoRow('Icon URL', widget.category?.iconUrl.trim() ?? ''),
        _infoRow('Image path', widget.category?.imagePath.trim() ?? ''),
        _infoRow('Thumb path', widget.category?.thumbPath.trim() ?? ''),
      ];
    } else {
      imageBody = _emptyImageBox(
        icon: Icons.image_outlined,
        text: 'Select a main image to continue.',
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
                            : (_hasExistingImage
                            ? 'Replace image'
                            : 'Select image'),
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
                      if (_removeExistingImage) {
                        _originalPickedImage = null;
                        _preparedImage = null;
                      }
                    });
                  },
                  title: const Text('Remove previous image and require a new one'),
                ),
              ],
            ],
          ),
          if (_isPickingImage)
            Positioned.fill(
              child: _busyOverlay(label: 'Loading image...'),
            ),
        ],
      ),
    );
  }

  Widget _buildResizeImageCard() {
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

    final bool showControls = _showResizeControls &&
        (!isEdit || _originalPickedImage != null);

    return _buildCard(
      title: 'Resized image',
      subtitle: prepared != null
          ? 'Prepared image is ready for upload.'
          : 'This panel stays empty until the image is resized.',
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
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _CategoryImageResizeOption.values.map((option) {
                    return ChoiceChip(
                      label: Text(option.label),
                      selected: _selectedResizeOption == option,
                      onSelected: _isSaving || _isResizingImage
                          ? null
                          : (_) {
                        setState(() {
                          _selectedResizeOption = option;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedResizeOption.note,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isSaving || _isResizingImage
                            ? null
                            : _resizeSelectedImage,
                        icon: const Icon(Icons.auto_fix_high_rounded),
                        label: Text(
                          prepared == null ? 'Resize image' : 'Resize again',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _useUploadedThumbAsIcon,
                  onChanged: _isSaving
                      ? null
                      : (value) {
                    setState(() {
                      _useUploadedThumbAsIcon = value ?? true;
                    });
                  },
                  title: const Text('Use generated thumb as icon URL'),
                ),
              ],
            ],
          ),
          if (_isResizingImage)
            Positioned.fill(
              child: _busyOverlay(label: 'Resizing image...'),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomImageSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useColumn = constraints.maxWidth < 860;

        if (useColumn) {
          return Column(
            children: [
              _buildOriginalImageCard(),
              const SizedBox(height: 16),
              _buildResizeImageCard(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildOriginalImageCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildResizeImageCard()),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _busyOverlay({required String label}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          color: Colors.white.withValues(alpha: 0.60),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyImageBox({
    required IconData icon,
    required String text,
  }) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34, color: Colors.black45),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SelectableText.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: value.isEmpty ? '—' : value,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = isEdit ? 'Update category' : 'Create category';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1080,
          maxHeight: 940,
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldSection(),
                        const SizedBox(height: 20),
                        _buildBottomImageSection(),
                        if (_submitError != null &&
                            _submitError!.trim().isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.20),
                              ),
                            ),
                            child: Text(
                              _submitError!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _canSubmit ? _submit : null,
                        child: Text(title),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isSaving)
              Positioned.fill(
                child: _busyOverlay(
                  label: isEdit ? 'Updating category...' : 'Creating category...',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
