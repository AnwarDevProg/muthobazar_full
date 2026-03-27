import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../../models/catalog/mb_category.dart';
import '../../controllers/admin_category_controller.dart';

class AdminCategoryFormDialog extends StatefulWidget {
  final MBCategory? category;

  const AdminCategoryFormDialog({
    super.key,
    this.category,
  });

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
  late final TextEditingController _parentIdController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _productsCountController;

  bool _isFeatured = false;
  bool _showOnHome = false;
  bool _isActive = true;

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
    _imageUrlController =
        TextEditingController(text: category?.imageUrl ?? '');
    _iconUrlController = TextEditingController(text: category?.iconUrl ?? '');
    _slugController = TextEditingController(text: category?.slug ?? '');
    _parentIdController =
        TextEditingController(text: category?.parentId ?? '');
    _sortOrderController =
        TextEditingController(text: '${category?.sortOrder ?? 0}');
    _productsCountController =
        TextEditingController(text: '${category?.productsCount ?? 0}');

    _isFeatured = category?.isFeatured ?? false;
    _showOnHome = category?.showOnHome ?? false;
    _isActive = category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameBnController.dispose();
    _descriptionEnController.dispose();
    _descriptionBnController.dispose();
    _imageUrlController.dispose();
    _iconUrlController.dispose();
    _slugController.dispose();
    _parentIdController.dispose();
    _sortOrderController.dispose();
    _productsCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdminCategoryController controller =
    Get.find<AdminCategoryController>();

    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: Container(
        width: 760,
        padding: const EdgeInsets.all(MBSpacing.xl),
        child: Obx(
              () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Category' : 'Create Category',
                style: MBTextStyles.sectionTitle,
              ),
              MBSpacing.h(MBSpacing.md),
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
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
                          children: [
                            Expanded(
                              child: MBTextField(
                                controller: _imageUrlController,
                                labelText: 'Image URL',
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
                          children: [
                            Expanded(
                              child: MBTextField(
                                controller: _slugController,
                                labelText: 'Slug',
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _parentIdController,
                                labelText: 'Parent Category ID',
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
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
              MBSpacing.h(MBSpacing.lg),
              Row(
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final AdminCategoryController controller =
    Get.find<AdminCategoryController>();

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
      slug: _slugController.text.trim(),
      parentId: _parentIdController.text.trim().isEmpty
          ? null
          : _parentIdController.text.trim(),
      isFeatured: _isFeatured,
      showOnHome: _showOnHome,
      isActive: _isActive,
      sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
      productsCount: int.tryParse(_productsCountController.text.trim()) ?? 0,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (existing == null) {
      await controller.createCategory(category);
    } else {
      await controller.updateCategory(category);
    }

    if (mounted) {
      Get.back();
    }
  }
}












