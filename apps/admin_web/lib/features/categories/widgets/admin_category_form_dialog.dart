import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

import '../controllers/admin_category_controller.dart';

class AdminCategoryFormDialog extends StatefulWidget {
  const AdminCategoryFormDialog({
    super.key,
    this.category,
  });

  final MBCategory? category;

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
  late final TextEditingController _imageUrlController;
  late final TextEditingController _iconUrlController;
  late final TextEditingController _slugController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _productsCountController;

  bool _isFeatured = false;
  bool _showOnHome = false;
  bool _isActive = true;
  String? _selectedParentId;
  String? _slugErrorText;

  bool get isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();

    final category = widget.category;

    _nameEnController = TextEditingController(text: category?.nameEn ?? '');
    _nameBnController = TextEditingController(text: category?.nameBn ?? '');
    _descriptionEnController =
        TextEditingController(text: category?.descriptionEn ?? '');
    _descriptionBnController =
        TextEditingController(text: category?.descriptionBn ?? '');
    _imageUrlController = TextEditingController(text: category?.imageUrl ?? '');
    _iconUrlController = TextEditingController(text: category?.iconUrl ?? '');
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
    _imageUrlController.addListener(_handleImageChanged);

    if (!isEdit && _slugController.text.trim().isEmpty) {
      _slugController.text = _generateSlug(_nameEnController.text);
    }
  }

  void _handleNameChanged() {
    if (!mounted) return;

    if (!isEdit) {
      final nextSlug = _generateSlug(_nameEnController.text);
      if (_slugController.text != nextSlug) {
        _slugController.text = nextSlug;
        _slugErrorText = null;
      }
    }

    setState(() {});
  }

  void _handleImageChanged() {
    if (!mounted) return;
    setState(() {});
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

  @override
  void dispose() {
    _nameEnController.removeListener(_handleNameChanged);
    _imageUrlController.removeListener(_handleImageChanged);

    _nameEnController.dispose();
    _nameBnController.dispose();
    _descriptionEnController.dispose();
    _descriptionBnController.dispose();
    _imageUrlController.dispose();
    _iconUrlController.dispose();
    _slugController.dispose();
    _sortOrderController.dispose();
    _productsCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCategoryController>();

    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 920,
          maxHeight: 760,
        ),
        child: Obx(
              () => AbsorbPointer(
            absorbing: controller.isSaving.value,
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
                        onPressed: () => Get.back(),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: MBTextField(
                                  controller: _descriptionEnController,
                                  labelText: 'Description (English)',
                                  maxLines: 3,
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _descriptionBnController,
                                  labelText: 'Description (Bangla)',
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MBTextField(
                                      controller: _imageUrlController,
                                      labelText: 'Image URL',
                                    ),
                                    if (_imageUrlController.text
                                        .trim()
                                        .isNotEmpty) ...[
                                      MBSpacing.h(MBSpacing.sm),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          MBRadius.md,
                                        ),
                                        child: Image.network(
                                          _imageUrlController.text.trim(),
                                          height: 100,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                height: 100,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: MBColors.background,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                    MBRadius.md,
                                                  ),
                                                  border: Border.all(
                                                    color: MBColors.border
                                                        .withValues(alpha: 0.9),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Invalid image URL',
                                                ),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _iconUrlController,
                                  labelText: 'Icon URL',
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                child: Obx(() {
                                  final parentOptions = controller.categories
                                      .where((cat) => cat.id != widget.category?.id)
                                      .toList()
                                    ..sort(
                                          (a, b) => a.nameEn
                                          .toLowerCase()
                                          .compareTo(b.nameEn.toLowerCase()),
                                    );

                                  final hasSelectedParent = _selectedParentId != null &&
                                      parentOptions.any(
                                            (cat) => cat.id == _selectedParentId,
                                      );

                                  final dropdownValue =
                                  hasSelectedParent ? _selectedParentId : null;

                                  return DropdownButtonFormField<String>(
                                    value: dropdownValue,
                                    decoration: const InputDecoration(
                                      labelText: 'Parent Category',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('None'),
                                      ),
                                      ...parentOptions.map(
                                            (cat) => DropdownMenuItem<String>(
                                          value: cat.id,
                                          child: Text(cat.nameEn),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedParentId = value;
                                      });
                                    },
                                  );
                                }),
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
                                    style: MBTextStyles.body.copyWith(
                                      color: MBColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          MBSpacing.h(MBSpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: MBTextField(
                                  controller: _sortOrderController,
                                  labelText: 'Sort Order',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _productsCountController,
                                  labelText: 'Products Count',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          MBCard(
                            padding: const EdgeInsets.all(MBSpacing.md),
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
                              ],
                            ),
                          ),
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
                          isLoading: controller.isSaving.value,
                          onPressed: () => Get.back(),
                        ),
                      ),
                      MBSpacing.w(MBSpacing.md),
                      Expanded(
                        child: MBPrimaryButton(
                          text: isEdit ? 'Update Category' : 'Create Category',
                          isLoading: controller.isSaving.value,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<AdminCategoryController>();

    final slug = _slugController.text.trim();
    final slugAvailable = await controller.isSlugAvailable(
      slug: slug,
      excludeCategoryId: widget.category?.id,
    );

    if (!slugAvailable) {
      setState(() {
        _slugErrorText = 'This slug already exists. Change the English name to generate another slug.';
      });
      return;
    }

    final now = DateTime.now();
    final existing = widget.category;

    final category = MBCategory(
      id: existing?.id ?? '',
      nameEn: _nameEnController.text.trim(),
      nameBn: _nameBnController.text.trim(),
      descriptionEn: _descriptionEnController.text.trim(),
      descriptionBn: _descriptionBnController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      iconUrl: _iconUrlController.text.trim(),
      slug: slug,
      parentId: _selectedParentId,
      isFeatured: _isFeatured,
      showOnHome: _showOnHome,
      isActive: _isActive,
      sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
      productsCount: int.tryParse(_productsCountController.text.trim()) ?? 0,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (existing == null) {
        await controller.createCategory(category);
      } else {
        await controller.updateCategory(category);
      }

      if (mounted) {
        Get.back();
      }
    } catch (_) {
      // Snackbar is already shown by controller.
    }
  }
}