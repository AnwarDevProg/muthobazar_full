import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
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

  late final TextEditingController _nameEnController;
  late final TextEditingController _nameBnController;
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _descriptionBnController;
  late final TextEditingController _logoUrlController;
  late final TextEditingController _slugController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _productsCountController;

  bool _isFeatured = false;
  bool _showOnHome = false;
  bool _isActive = true;

  String? _submitError;

  bool get isEdit => widget.brand != null;

  @override
  void initState() {
    super.initState();

    final brand = widget.brand;

    _nameEnController = TextEditingController(text: brand?.nameEn ?? '');
    _nameBnController = TextEditingController(text: brand?.nameBn ?? '');
    _descriptionEnController =
        TextEditingController(text: brand?.descriptionEn ?? '');
    _descriptionBnController =
        TextEditingController(text: brand?.descriptionBn ?? '');
    _logoUrlController = TextEditingController(text: brand?.logoUrl ?? '');
    _slugController = TextEditingController(text: brand?.slug ?? '');
    _sortOrderController =
        TextEditingController(text: '${brand?.sortOrder ?? 0}');
    _productsCountController =
        TextEditingController(text: '${brand?.productsCount ?? 0}');

    _isFeatured = brand?.isFeatured ?? false;
    _showOnHome = brand?.showOnHome ?? false;
    _isActive = brand?.isActive ?? true;
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final AdminBrandController controller = Get.find<AdminBrandController>();

    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 860,
          maxHeight: 720,
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
                          isEdit ? 'Edit Brand' : 'Create Brand',
                          style: MBTextStyles.sectionTitle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : () => Get.back(),
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
                          if (_submitError != null &&
                              _submitError!.trim().isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(MBSpacing.md),
                              decoration: BoxDecoration(
                                color: MBColors.error.withValues(alpha: 0.08),
                                borderRadius:
                                BorderRadius.circular(MBRadius.lg),
                                border: Border.all(
                                  color:
                                  MBColors.error.withValues(alpha: 0.22),
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
                                      _submitError!,
                                      style: MBTextStyles.body.copyWith(
                                        color: MBColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            MBSpacing.h(MBSpacing.md),
                          ],
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
                                  onChanged: (_) {
                                    if (_submitError != null) {
                                      setState(() {
                                        _submitError = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _nameBnController,
                                  labelText: 'Name (Bangla)',
                                  onChanged: (_) {
                                    if (_submitError != null) {
                                      setState(() {
                                        _submitError = null;
                                      });
                                    }
                                  },
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
                                  onChanged: (_) {
                                    if (_submitError != null) {
                                      setState(() {
                                        _submitError = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _descriptionBnController,
                                  labelText: 'Description (Bangla)',
                                  maxLines: 3,
                                  onChanged: (_) {
                                    if (_submitError != null) {
                                      setState(() {
                                        _submitError = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: MBTextField(
                                  controller: _logoUrlController,
                                  labelText: 'Logo URL',
                                  onChanged: (_) {
                                    if (_submitError != null) {
                                      setState(() {
                                        _submitError = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _slugController,
                                  labelText: 'Slug',
                                  onChanged: (_) {
                                    if (_submitError != null) {
                                      setState(() {
                                        _submitError = null;
                                      });
                                    }
                                  },
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
                                  onChanged: (_) {
                                    if (_submitError != null) {
                                      setState(() {
                                        _submitError = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _productsCountController,
                                  labelText: 'Products Count',
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) {
                                    if (_submitError != null) {
                                      setState(() {
                                        _submitError = null;
                                      });
                                    }
                                  },
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
                                      _submitError = null;
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
                                      _submitError = null;
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
                                      _submitError = null;
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
                          onPressed: controller.isSaving.value
                              ? null
                              : () => Get.back(),
                        ),
                      ),
                      MBSpacing.w(MBSpacing.md),
                      Expanded(
                        child: MBPrimaryButton(
                          text: isEdit ? 'Update Brand' : 'Create Brand',
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

  String _readableError(Object error) {
    final raw = error.toString().trim();
    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '').trim();
    }
    return raw;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final AdminBrandController controller = Get.find<AdminBrandController>();

    setState(() {
      _submitError = null;
    });

    final now = DateTime.now();
    final existing = widget.brand;

    final brand = MBBrand(
      id: existing?.id ?? '',
      nameEn: _nameEnController.text.trim(),
      nameBn: _nameBnController.text.trim(),
      descriptionEn: _descriptionEnController.text.trim(),
      descriptionBn: _descriptionBnController.text.trim(),
      logoUrl: _logoUrlController.text.trim(),
      slug: _slugController.text.trim(),
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
        await controller.createBrand(brand);
      } else {
        await controller.updateBrand(brand);
      }

      if (mounted) {
        Get.back();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _submitError = _readableError(e);
      });
    }
  }
}
