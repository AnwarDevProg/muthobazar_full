import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

import '../controllers/admin_banner_controller.dart';

class AdminBannerFormDialog extends StatefulWidget {
  const AdminBannerFormDialog({
    super.key,
    this.banner,
  });

  final MBBanner? banner;

  @override
  State<AdminBannerFormDialog> createState() => _AdminBannerFormDialogState();
}

class _AdminBannerFormDialogState extends State<AdminBannerFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleEnController;
  late final TextEditingController _titleBnController;
  late final TextEditingController _subtitleEnController;
  late final TextEditingController _subtitleBnController;
  late final TextEditingController _buttonTextEnController;
  late final TextEditingController _buttonTextBnController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _mobileImageUrlController;
  late final TextEditingController _targetIdController;
  late final TextEditingController _targetRouteController;
  late final TextEditingController _externalUrlController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _startAtController;
  late final TextEditingController _endAtController;

  String _targetType = 'none';
  bool _isActive = true;

  bool get isEdit => widget.banner != null;

  @override
  void initState() {
    super.initState();

    final banner = widget.banner;

    _titleEnController = TextEditingController(text: banner?.titleEn ?? '');
    _titleBnController = TextEditingController(text: banner?.titleBn ?? '');
    _subtitleEnController =
        TextEditingController(text: banner?.subtitleEn ?? '');
    _subtitleBnController =
        TextEditingController(text: banner?.subtitleBn ?? '');
    _buttonTextEnController =
        TextEditingController(text: banner?.buttonTextEn ?? '');
    _buttonTextBnController =
        TextEditingController(text: banner?.buttonTextBn ?? '');
    _imageUrlController = TextEditingController(text: banner?.imageUrl ?? '');
    _mobileImageUrlController =
        TextEditingController(text: banner?.mobileImageUrl ?? '');
    _targetIdController = TextEditingController(text: banner?.targetId ?? '');
    _targetRouteController =
        TextEditingController(text: banner?.targetRoute ?? '');
    _externalUrlController =
        TextEditingController(text: banner?.externalUrl ?? '');
    _sortOrderController =
        TextEditingController(text: '${banner?.sortOrder ?? 0}');
    _startAtController =
        TextEditingController(text: banner?.startAt?.toIso8601String() ?? '');
    _endAtController =
        TextEditingController(text: banner?.endAt?.toIso8601String() ?? '');

    _targetType = banner?.targetType ?? 'none';
    _isActive = banner?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleBnController.dispose();
    _subtitleEnController.dispose();
    _subtitleBnController.dispose();
    _buttonTextEnController.dispose();
    _buttonTextBnController.dispose();
    _imageUrlController.dispose();
    _mobileImageUrlController.dispose();
    _targetIdController.dispose();
    _targetRouteController.dispose();
    _externalUrlController.dispose();
    _sortOrderController.dispose();
    _startAtController.dispose();
    _endAtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdminBannerController controller = Get.find<AdminBannerController>();

    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 900,
          maxHeight: 780,
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
                          isEdit ? 'Edit Banner' : 'Create Banner',
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
                            children: [
                              Expanded(
                                child: MBTextField(
                                  controller: _titleEnController,
                                  labelText: 'Title (English)',
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _titleBnController,
                                  labelText: 'Title (Bangla)',
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: MBTextField(
                                  controller: _subtitleEnController,
                                  labelText: 'Subtitle (English)',
                                  maxLines: 2,
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _subtitleBnController,
                                  labelText: 'Subtitle (Bangla)',
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: MBTextField(
                                  controller: _buttonTextEnController,
                                  labelText: 'Button Text (English)',
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _buttonTextBnController,
                                  labelText: 'Button Text (Bangla)',
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
                                  controller: _mobileImageUrlController,
                                  labelText: 'Mobile Image URL',
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          DropdownButtonFormField<String>(
                            value: _targetType,
                            decoration: const InputDecoration(
                              labelText: 'Target Type',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'none',
                                child: Text('None'),
                              ),
                              DropdownMenuItem(
                                value: 'product',
                                child: Text('Product'),
                              ),
                              DropdownMenuItem(
                                value: 'category',
                                child: Text('Category'),
                              ),
                              DropdownMenuItem(
                                value: 'brand',
                                child: Text('Brand'),
                              ),
                              DropdownMenuItem(
                                value: 'offer',
                                child: Text('Offer'),
                              ),
                              DropdownMenuItem(
                                value: 'route',
                                child: Text('Route'),
                              ),
                              DropdownMenuItem(
                                value: 'external',
                                child: Text('External URL'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _targetType = value ?? 'none';
                              });
                            },
                          ),
                          MBSpacing.h(MBSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: MBTextField(
                                  controller: _targetIdController,
                                  labelText: 'Target ID',
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _targetRouteController,
                                  labelText: 'Target Route',
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: MBTextField(
                                  controller: _externalUrlController,
                                  labelText: 'External URL',
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _sortOrderController,
                                  labelText: 'Sort Order',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: MBTextField(
                                  controller: _startAtController,
                                  labelText: 'Start At (ISO8601)',
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _endAtController,
                                  labelText: 'End At (ISO8601)',
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          SwitchListTile(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                            title: const Text('Active'),
                            contentPadding: EdgeInsets.zero,
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
                          text: isEdit ? 'Update Banner' : 'Create Banner',
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
    final AdminBannerController controller = Get.find<AdminBannerController>();
    final MBBanner? existing = widget.banner;
    final DateTime now = DateTime.now();

    final MBBanner banner = MBBanner(
      id: existing?.id ?? '',
      titleEn: _titleEnController.text.trim(),
      titleBn: _titleBnController.text.trim(),
      subtitleEn: _subtitleEnController.text.trim(),
      subtitleBn: _subtitleBnController.text.trim(),
      buttonTextEn: _buttonTextEnController.text.trim(),
      buttonTextBn: _buttonTextBnController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      mobileImageUrl: _mobileImageUrlController.text.trim(),
      targetType: _targetType,
      targetId: _emptyToNull(_targetIdController.text),
      targetRoute: _emptyToNull(_targetRouteController.text),
      externalUrl: _emptyToNull(_externalUrlController.text),
      isActive: _isActive,
      sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
      startAt: _nullableDate(_startAtController.text),
      endAt: _nullableDate(_endAtController.text),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (existing == null) {
      await controller.createBanner(banner);
    } else {
      await controller.updateBanner(banner);
    }

    if (mounted) {
      Get.back();
    }
  }

  String? _emptyToNull(String raw) {
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  DateTime? _nullableDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}