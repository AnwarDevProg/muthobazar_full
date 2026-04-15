import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

import '../controllers/admin_offer_controller.dart';

class AdminOfferFormDialog extends StatefulWidget {
  const AdminOfferFormDialog({
    super.key,
    this.offer,
  });

  final MBOffer? offer;

  @override
  State<AdminOfferFormDialog> createState() => _AdminOfferFormDialogState();
}

class _AdminOfferFormDialogState extends State<AdminOfferFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleEnController;
  late final TextEditingController _titleBnController;
  late final TextEditingController _subtitleEnController;
  late final TextEditingController _subtitleBnController;
  late final TextEditingController _badgeTextEnController;
  late final TextEditingController _badgeTextBnController;
  late final TextEditingController _discountTextEnController;
  late final TextEditingController _discountTextBnController;
  late final TextEditingController _offerValueController;
  late final TextEditingController _productIdsController;
  late final TextEditingController _categoryIdsController;
  late final TextEditingController _brandIdsController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _mobileImageUrlController;
  late final TextEditingController _targetIdController;
  late final TextEditingController _targetRouteController;
  late final TextEditingController _externalUrlController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _floatingPriorityController;
  late final TextEditingController _startAtController;
  late final TextEditingController _endAtController;

  String _offerType = 'percent';
  String _targetType = 'none';
  String _presentationType = 'strip';

  bool _isFeatured = false;
  bool _isActive = true;
  bool _showAsFloating = false;
  bool _dismissible = true;
  bool _showOncePerAppLife = true;
  bool _randomEligible = false;

  bool get isEdit => widget.offer != null;

  @override
  void initState() {
    super.initState();

    final offer = widget.offer;

    _titleEnController = TextEditingController(text: offer?.titleEn ?? '');
    _titleBnController = TextEditingController(text: offer?.titleBn ?? '');
    _subtitleEnController = TextEditingController(text: offer?.subtitleEn ?? '');
    _subtitleBnController = TextEditingController(text: offer?.subtitleBn ?? '');
    _badgeTextEnController = TextEditingController(text: offer?.badgeTextEn ?? '');
    _badgeTextBnController = TextEditingController(text: offer?.badgeTextBn ?? '');
    _discountTextEnController =
        TextEditingController(text: offer?.discountTextEn ?? '');
    _discountTextBnController =
        TextEditingController(text: offer?.discountTextBn ?? '');
    _offerValueController = TextEditingController(
      text: offer != null ? offer.offerValue.toString() : '0',
    );
    _productIdsController = TextEditingController(
      text: offer?.productIds.join(', ') ?? '',
    );
    _categoryIdsController = TextEditingController(
      text: offer?.categoryIds.join(', ') ?? '',
    );
    _brandIdsController = TextEditingController(
      text: offer?.brandIds.join(', ') ?? '',
    );
    _imageUrlController = TextEditingController(text: offer?.imageUrl ?? '');
    _mobileImageUrlController =
        TextEditingController(text: offer?.mobileImageUrl ?? '');
    _targetIdController = TextEditingController(text: offer?.targetId ?? '');
    _targetRouteController =
        TextEditingController(text: offer?.targetRoute ?? '');
    _externalUrlController =
        TextEditingController(text: offer?.externalUrl ?? '');
    _sortOrderController = TextEditingController(
      text: offer != null ? offer.sortOrder.toString() : '0',
    );
    _floatingPriorityController = TextEditingController(
      text: offer != null ? offer.floatingPriority.toString() : '0',
    );
    _startAtController = TextEditingController(
      text: offer?.startAt?.toIso8601String() ?? '',
    );
    _endAtController = TextEditingController(
      text: offer?.endAt?.toIso8601String() ?? '',
    );

    _offerType = offer?.offerType ?? 'percent';
    _targetType = offer?.targetType ?? 'none';
    _presentationType = offer?.presentationType ?? 'strip';
    _isFeatured = offer?.isFeatured ?? false;
    _isActive = offer?.isActive ?? true;
    _showAsFloating = offer?.showAsFloating ?? false;
    _dismissible = offer?.dismissible ?? true;
    _showOncePerAppLife = offer?.showOncePerAppLife ?? true;
    _randomEligible = offer?.randomEligible ?? false;
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleBnController.dispose();
    _subtitleEnController.dispose();
    _subtitleBnController.dispose();
    _badgeTextEnController.dispose();
    _badgeTextBnController.dispose();
    _discountTextEnController.dispose();
    _discountTextBnController.dispose();
    _offerValueController.dispose();
    _productIdsController.dispose();
    _categoryIdsController.dispose();
    _brandIdsController.dispose();
    _imageUrlController.dispose();
    _mobileImageUrlController.dispose();
    _targetIdController.dispose();
    _targetRouteController.dispose();
    _externalUrlController.dispose();
    _sortOrderController.dispose();
    _floatingPriorityController.dispose();
    _startAtController.dispose();
    _endAtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdminOfferController controller = Get.find<AdminOfferController>();

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 980,
          maxHeight: 820,
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
                          isEdit ? 'Edit Offer' : 'Create Offer',
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
                                  controller: _badgeTextEnController,
                                  labelText: 'Badge Text (English)',
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _badgeTextBnController,
                                  labelText: 'Badge Text (Bangla)',
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: MBTextField(
                                  controller: _discountTextEnController,
                                  labelText: 'Discount Text (English)',
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _discountTextBnController,
                                  labelText: 'Discount Text (Bangla)',
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _offerType,
                                  decoration: const InputDecoration(
                                    labelText: 'Offer Type',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'percent',
                                      child: Text('Percent'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'amount',
                                      child: Text('Amount'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'free_delivery',
                                      child: Text('Free Delivery'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'bundle',
                                      child: Text('Bundle'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'custom',
                                      child: Text('Custom'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _offerType = value ?? 'percent';
                                    });
                                  },
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _offerValueController,
                                  labelText: 'Offer Value',
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
                                  controller: _productIdsController,
                                  labelText: 'Product IDs (comma separated)',
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _categoryIdsController,
                                  labelText: 'Category IDs (comma separated)',
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          MBTextField(
                            controller: _brandIdsController,
                            labelText: 'Brand IDs (comma separated)',
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
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _targetType,
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
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _presentationType,
                                  decoration: const InputDecoration(
                                    labelText: 'Presentation Type',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'strip',
                                      child: Text('Strip'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'card',
                                      child: Text('Card'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'banner',
                                      child: Text('Banner'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'floating',
                                      child: Text('Floating'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _presentationType = value ?? 'strip';
                                    });
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
                          MBTextField(
                            controller: _externalUrlController,
                            labelText: 'External URL',
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
                                  controller: _floatingPriorityController,
                                  labelText: 'Floating Priority',
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
                                  title: const Text('Show As Floating'),
                                  value: _showAsFloating,
                                  onChanged: (value) {
                                    setState(() {
                                      _showAsFloating = value;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                                SwitchListTile(
                                  title: const Text('Dismissible'),
                                  value: _dismissible,
                                  onChanged: (value) {
                                    setState(() {
                                      _dismissible = value;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                                SwitchListTile(
                                  title: const Text('Show Once Per App Life'),
                                  value: _showOncePerAppLife,
                                  onChanged: (value) {
                                    setState(() {
                                      _showOncePerAppLife = value;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                                SwitchListTile(
                                  title: const Text('Random Eligible'),
                                  value: _randomEligible,
                                  onChanged: (value) {
                                    setState(() {
                                      _randomEligible = value;
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
                          text: isEdit ? 'Update Offer' : 'Create Offer',
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
    final AdminOfferController controller = Get.find<AdminOfferController>();
    final MBOffer? existing = widget.offer;
    final DateTime now = DateTime.now();

    final MBOffer offer = MBOffer(
      id: existing?.id ?? '',
      titleEn: _titleEnController.text.trim(),
      titleBn: _titleBnController.text.trim(),
      subtitleEn: _subtitleEnController.text.trim(),
      subtitleBn: _subtitleBnController.text.trim(),
      badgeTextEn: _badgeTextEnController.text.trim(),
      badgeTextBn: _badgeTextBnController.text.trim(),
      discountTextEn: _discountTextEnController.text.trim(),
      discountTextBn: _discountTextBnController.text.trim(),
      offerType: _offerType,
      offerValue: double.tryParse(_offerValueController.text.trim()) ?? 0,
      productIds: _splitCsv(_productIdsController.text),
      categoryIds: _splitCsv(_categoryIdsController.text),
      brandIds: _splitCsv(_brandIdsController.text),
      imageUrl: _imageUrlController.text.trim(),
      mobileImageUrl: _mobileImageUrlController.text.trim(),
      targetType: _targetType,
      targetId: _emptyToNull(_targetIdController.text),
      targetRoute: _emptyToNull(_targetRouteController.text),
      externalUrl: _emptyToNull(_externalUrlController.text),
      isFeatured: _isFeatured,
      isActive: _isActive,
      sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
      presentationType: _presentationType,
      showAsFloating: _showAsFloating,
      dismissible: _dismissible,
      showOncePerAppLife: _showOncePerAppLife,
      randomEligible: _randomEligible,
      floatingPriority:
      int.tryParse(_floatingPriorityController.text.trim()) ?? 0,
      startAt: _nullableDate(_startAtController.text),
      endAt: _nullableDate(_endAtController.text),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (existing == null) {
      await controller.createOffer(offer);
    } else {
      await controller.updateOffer(offer);
    }

    if (mounted) {
      Get.back();
    }
  }

  List<String> _splitCsv(String raw) {
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
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