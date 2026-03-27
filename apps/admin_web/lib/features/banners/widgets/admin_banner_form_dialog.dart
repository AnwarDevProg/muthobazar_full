import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../../models/home/mb_banner.dart';
import '../../controllers/admin_banner_controller.dart';

class AdminBannerFormDialog extends StatefulWidget {
  final MBBanner? banner;

  const AdminBannerFormDialog({
    super.key,
    this.banner,
  });

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
  late final TextEditingController _startsAtController;
  late final TextEditingController _endsAtController;

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
    _startsAtController =
        TextEditingController(text: banner?.startsAt?.toIso8601String() ?? '');
    _endsAtController =
        TextEditingController(text: banner?.endsAt?.toIso8601String() ?? '');

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
    _startsAtController.dispose();
    _endsAtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdminBannerController controller = Get.find<AdminBannerController>();

    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: Container(
        width: 820,
        padding: const EdgeInsets.all(MBSpacing.xl),
        child: Obx(
              () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Banner' : 'Create Banner',
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
                          initialValue: _targetType,
                          decoration: const InputDecoration(
                            labelText: 'Target Type',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'none', child: Text('None')),
                            DropdownMenuItem(value: 'product', child: Text('Product')),
                            DropdownMenuItem(value: 'category', child: Text('Category')),
                            DropdownMenuItem(value: 'offer', child: Text('Offer')),
                            DropdownMenuItem(value: 'route', child: Text('Route')),
                            DropdownMenuItem(value: 'external', child: Text('External URL')),
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
                                controller: _startsAtController,
                                labelText: 'Starts At (ISO)',
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _endsAtController,
                                labelText: 'Ends At (ISO)',
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
                      text: isEdit ? 'Update Banner' : 'Create Banner',
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
    final AdminBannerController controller = Get.find<AdminBannerController>();
    final existing = widget.banner;

    final banner = MBBanner(
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
      targetId: _targetIdController.text.trim().isEmpty
          ? null
          : _targetIdController.text.trim(),
      targetRoute: _targetRouteController.text.trim().isEmpty
          ? null
          : _targetRouteController.text.trim(),
      externalUrl: _externalUrlController.text.trim().isEmpty
          ? null
          : _externalUrlController.text.trim(),
      isActive: _isActive,
      sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
      startsAt: _startsAtController.text.trim().isEmpty
          ? null
          : DateTime.tryParse(_startsAtController.text.trim()),
      endsAt: _endsAtController.text.trim().isEmpty
          ? null
          : DateTime.tryParse(_endsAtController.text.trim()),
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
}












