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
  late final AdminCategoryController _controller;

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

  bool get _hasSelectedOriginalImage => _originalPickedImage != null;

  bool get _hasPreparedImage => _preparedImage != null;

  bool get _mustRequirePreparedImageForSubmit {
    if (_hasPreparedImage) return false;
    if (_hasSelectedOriginalImage) return true;
    if (isEdit) {
      return _removeExistingImage;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<AdminCategoryController>()
        ? Get.find<AdminCategoryController>()
        : Get.put(AdminCategoryController());
    _generatedId = FirebaseFirestore.instance.collection('categories').doc().id;

    final category = widget.category;

    _nameEnController = TextEditingController(text: category?.nameEn ?? '');
    _nameBnController = TextEditingController(text: category?.nameBn ?? '');
    _descriptionEnController =
        TextEditingController(text: category?.descriptionEn ?? '');
    _descriptionBnController =
        TextEditingController(text: category?.descriptionBn ?? '');
    _iconUrlController = TextEditingController(text: category?.iconUrl ?? '');
    _slugController = TextEditingController(text: category?.slug ?? '');
    _sortOrderController =
        TextEditingController(text: (category?.sortOrder ?? 0).toString());
    _productsCountController = TextEditingController(
      text: (category?.productsCount ?? 0).toString(),
    );

    _isFeatured = category?.isFeatured ?? false;
    _showOnHome = category?.showOnHome ?? false;
    _isActive = category?.isActive ?? true;

    final parentId = category?.parentId?.trim() ?? '';
    _selectedParentId = parentId.isEmpty ? null : parentId;

    _nameEnController.addListener(_handleNameOrSlugChanged);
    _slugController.addListener(_handleSlugChanged);
    _sortOrderController.addListener(_handleSortChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateSortSuggestion();
      _validateSlug();
    });
  }

  @override
  void dispose() {
    _nameEnController.removeListener(_handleNameOrSlugChanged);
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
    super.dispose();
  }

  void _handleNameOrSlugChanged() {
    if (!mounted) return;
    setState(() {
      _submitError = null;
      _slugErrorText = null;
    });
  }

  void _handleSlugChanged() {
    if (!mounted) return;
    setState(() {
      _submitError = null;
      _slugErrorText = null;
    });
  }

  void _handleSortChanged() {
    if (!mounted) return;
    setState(() {
      _submitError = null;
      _updateSortSuggestion();
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

  String _groupIdFromParentId(String? parentId) {
    final value = (parentId ?? '').trim();
    return value.isEmpty ? 'root' : value;
  }

  int _safeParseSort(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  bool _isSortDuplicate(int sortOrder) {
    final currentId = widget.category?.id.trim() ?? '';
    final groupId = _groupIdFromParentId(_selectedParentId);

    for (final category in widget.categories) {
      final sameGroup = _groupIdFromParentId(category.parentId) == groupId;
      if (!sameGroup) continue;
      if (currentId.isNotEmpty && category.id.trim() == currentId) continue;
      if (category.sortOrder == sortOrder) return true;
    }

    return false;
  }

  void _updateSortSuggestion() {
    final sortValue = _safeParseSort(_sortOrderController.text);
    if (_isSortDuplicate(sortValue)) {
      _sortSuggestionText =
      'Sort number already exists in this group. Please use another.';
    } else {
      _sortSuggestionText = null;
    }
  }

  Future<void> _validateSlug() async {
    final slug = _normalizeSlug(_slugController.text);
    if (slug.isEmpty) {
      if (!mounted) return;
      setState(() {
        _slugErrorText = 'Slug is required.';
      });
      return;
    }

    try {
      final exists = await AdminCategoryRepository.instance.slugExists(
        slug: slug,
        excludeCategoryId: widget.category?.id,
      );

      if (!mounted) return;
      setState(() {
        _slugErrorText =
        exists ? 'This slug is already used by another category.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _slugErrorText = e.toString();
      });
    }
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
      if (picked == null) {
        setState(() {
          _isPickingImage = false;
        });
        return;
      }

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

  Future<void> _prepareSelectedImage() async {
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

  Widget _buildExistingImagePreview() {
    final imageUrl = widget.category?.imageUrl.trim() ?? '';
    final iconUrl = widget.category?.iconUrl.trim() ?? '';
    final displayUrl = imageUrl.isNotEmpty ? imageUrl : iconUrl;

    if (displayUrl.isEmpty || _removeExistingImage) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current image',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                displayUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Text('Image preview unavailable'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SelectableText('Image URL: $imageUrl'),
          const SizedBox(height: 6),
          SelectableText('Icon URL: $iconUrl'),
          const SizedBox(height: 6),
          SelectableText('Image path: ${widget.category?.imagePath ?? ''}'),
          const SizedBox(height: 6),
          SelectableText('Thumb path: ${widget.category?.thumbPath ?? ''}'),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _removeExistingImage,
                onChanged: _isSaving
                    ? null
                    : (value) {
                  setState(() {
                    _removeExistingImage = value ?? false;
                    if (_removeExistingImage) {
                      _preparedImage = null;
                      _originalPickedImage = null;
                    }
                  });
                },
              ),
              const Expanded(
                child: Text('Remove current image and upload a new one'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalImageCard() {
    final original = _originalPickedImage;
    if (original == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected original image',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.memory(
                original.originalBytes,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Name: ${original.originalFileName}'),
          const SizedBox(height: 6),
          Text('Source size: ${original.width} × ${original.height}'),
          const SizedBox(height: 6),
          Text('Bytes: ${original.originalByteLength}'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
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
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _isSaving || _isResizingImage
                  ? null
                  : _prepareSelectedImage,
              icon: _isResizingImage
                  ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.aspect_ratio_rounded),
              label: Text(_isResizingImage ? 'Resizing...' : 'Resize image'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparedImageCard() {
    final prepared = _preparedImage;
    if (prepared == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prepared image',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.memory(
                prepared.previewBytes,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Full: ${prepared.fullWidth} × ${prepared.fullHeight} • ${prepared.fullByteLength} bytes',
          ),
          const SizedBox(height: 6),
          Text(
            'Thumb: ${prepared.thumbWidth} × ${prepared.thumbHeight} • ${prepared.thumbByteLength} bytes',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _useUploadedThumbAsIcon,
                onChanged: _isSaving
                    ? null
                    : (value) {
                  setState(() {
                    _useUploadedThumbAsIcon = value ?? true;
                  });
                },
              ),
              const Expanded(
                child: Text('Use uploaded thumb URL as icon URL'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParentSelector() {
    final items = _availableParentCategories;

    return DropdownButtonFormField<String?>(
      initialValue: _selectedParentId,
      decoration: const InputDecoration(
        labelText: 'Parent category',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('No parent (root)'),
        ),
        ...items.map((item) => DropdownMenuItem<String?>(
          value: item.id,
          child: Text(item.nameEn),
        )),
      ],
      onChanged: _isSaving
          ? null
          : (value) {
        setState(() {
          _selectedParentId = value;
          _updateSortSuggestion();
        });
      },
    );
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    final currentState = _formKey.currentState;
    if (currentState == null || !currentState.validate()) {
      return;
    }

    setState(() {
      _submitError = null;
      _isSaving = true;
    });

    try {
      final slug = _normalizeSlug(_slugController.text.trim());
      if (slug.isEmpty) {
        setState(() {
          _slugErrorText = 'Slug is required.';
          _submitError = 'Please enter a valid slug.';
          _isSaving = false;
        });
        return;
      }

      await _validateSlug();
      if (!mounted) return;
      if (_slugErrorText != null && _slugErrorText!.trim().isNotEmpty) {
        setState(() {
          _submitError = _slugErrorText;
          _isSaving = false;
        });
        return;
      }

      final sortValue = _safeParseSort(_sortOrderController.text);
      if (sortValue < 0) {
        setState(() {
          _submitError = 'Sort number must be 0 or greater.';
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

      final preparedForUpload = _preparedImage;

      if (preparedForUpload != null) {
        final uploaded =
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
        sortOrder: sortValue,
        productsCount: int.tryParse(_productsCountController.text.trim()) ?? 0,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      _controller.clearOperationError();
      await _controller.saveCategory(
        category: category,
        isEdit: existing != null,
      );

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 900),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit category' : 'Create category',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
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
                            width: 420,
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
                            width: 420,
                            child: TextFormField(
                              controller: _nameBnController,
                              decoration: const InputDecoration(
                                labelText: 'Name (Bangla)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 420,
                            child: TextFormField(
                              controller: _slugController,
                              decoration: InputDecoration(
                                labelText: 'Slug',
                                border: const OutlineInputBorder(),
                                errorText: _slugErrorText,
                              ),
                              validator: (value) {
                                if (_normalizeSlug(value ?? '').isEmpty) {
                                  return 'Slug is required.';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            width: 420,
                            child: TextFormField(
                              controller: _sortOrderController,
                              decoration: InputDecoration(
                                labelText: 'Sort order',
                                border: const OutlineInputBorder(),
                                helperText: _sortSuggestionText,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                final parsed = int.tryParse((value ?? '').trim());
                                if (parsed == null) {
                                  return 'Enter a valid integer.';
                                }
                                if (parsed < 0) {
                                  return 'Sort order must be 0 or greater.';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 420, child: _buildParentSelector()),
                          SizedBox(
                            width: 420,
                            child: TextFormField(
                              controller: _iconUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Custom icon URL (optional)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 420,
                            child: TextFormField(
                              controller: _productsCountController,
                              decoration: const InputDecoration(
                                labelText: 'Products count',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionEnController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description (English)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionBnController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description (Bangla)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 24,
                        runSpacing: 8,
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
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildExistingImagePreview(),
                          _buildOriginalImageCard(),
                          _buildPreparedImageCard(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: _isSaving || _isPickingImage
                                ? null
                                : _pickOriginalImage,
                            icon: _isPickingImage
                                ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.image_outlined),
                            label: Text(
                              _isPickingImage ? 'Selecting...' : 'Select image',
                            ),
                          ),
                        ],
                      ),
                      if (_submitError != null && _submitError!.trim().isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.24),
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
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(isEdit ? 'Update category' : 'Create category'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
