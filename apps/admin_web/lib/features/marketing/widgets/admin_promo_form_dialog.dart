import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

import '../controllers/admin_promo_controller.dart';

class AdminPromoFormDialog extends StatefulWidget {
  const AdminPromoFormDialog({
    super.key,
    this.promo,
  });

  final MBPromoCode? promo;

  @override
  State<AdminPromoFormDialog> createState() => _AdminPromoFormDialogState();
}

class _AdminPromoFormDialogState extends State<AdminPromoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _discountValueController;
  late final TextEditingController _minimumOrderAmountController;
  late final TextEditingController _maximumDiscountController;
  late final TextEditingController _usageLimitController;
  late final TextEditingController _usageCountController;
  late final TextEditingController _campaignNameController;
  late final TextEditingController _expirationDateController;
  late final TextEditingController _eligibleUserIdsController;

  String _discountType = 'percent';
  bool _isActive = true;
  bool _isArchived = false;

  bool get isEdit => widget.promo != null;

  @override
  void initState() {
    super.initState();

    final promo = widget.promo;

    _codeController = TextEditingController(text: promo?.code ?? '');
    _discountValueController = TextEditingController(
      text: promo != null ? promo.discountValue.toString() : '0',
    );
    _minimumOrderAmountController = TextEditingController(
      text: promo?.minimumOrderAmount?.toString() ?? '',
    );
    _maximumDiscountController = TextEditingController(
      text: promo?.maximumDiscount?.toString() ?? '',
    );
    _usageLimitController = TextEditingController(
      text: promo?.usageLimit?.toString() ?? '',
    );
    _usageCountController = TextEditingController(
      text: promo != null ? promo.usageCount.toString() : '0',
    );
    _campaignNameController = TextEditingController(
      text: promo?.campaignName ?? '',
    );
    _expirationDateController = TextEditingController(
      text: (promo?.expirationDate ?? DateTime.now().add(const Duration(days: 7)))
          .toIso8601String(),
    );
    _eligibleUserIdsController = TextEditingController(
      text: promo?.eligibleUserIds.join(', ') ?? '',
    );

    _discountType = promo?.discountType ?? 'percent';
    _isActive = promo?.isActive ?? true;
    _isArchived = promo?.isArchived ?? false;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountValueController.dispose();
    _minimumOrderAmountController.dispose();
    _maximumDiscountController.dispose();
    _usageLimitController.dispose();
    _usageCountController.dispose();
    _campaignNameController.dispose();
    _expirationDateController.dispose();
    _eligibleUserIdsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdminPromoController controller = Get.find<AdminPromoController>();

    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 860,
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
                          isEdit ? 'Edit Promo Code' : 'Create Promo Code',
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
                                  controller: _codeController,
                                  labelText: 'Promo Code',
                                  validator: (value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return 'Enter promo code';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _discountType,
                                  decoration: const InputDecoration(
                                    labelText: 'Discount Type',
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
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _discountType = value ?? 'percent';
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
                                  controller: _discountValueController,
                                  labelText: 'Discount Value',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return 'Enter discount value';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _campaignNameController,
                                  labelText: 'Campaign Name',
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: MBTextField(
                                  controller: _minimumOrderAmountController,
                                  labelText: 'Minimum Order Amount',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _maximumDiscountController,
                                  labelText: 'Maximum Discount',
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
                                  controller: _usageLimitController,
                                  labelText: 'Usage Limit',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              MBSpacing.w(MBSpacing.md),
                              Expanded(
                                child: MBTextField(
                                  controller: _usageCountController,
                                  labelText: 'Usage Count',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          MBTextField(
                            controller: _eligibleUserIdsController,
                            labelText: 'Eligible User IDs (comma separated)',
                            maxLines: 2,
                          ),
                          MBSpacing.h(MBSpacing.md),
                          MBTextField(
                            controller: _expirationDateController,
                            labelText: 'Expiration Date (ISO8601)',
                          ),
                          MBSpacing.h(MBSpacing.md),
                          MBCard(
                            padding: const EdgeInsets.all(MBSpacing.md),
                            child: Column(
                              children: [
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
                                  title: const Text('Archived'),
                                  value: _isArchived,
                                  onChanged: (value) {
                                    setState(() {
                                      _isArchived = value;
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
                          text: isEdit ? 'Update Promo' : 'Create Promo',
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

    final AdminPromoController controller = Get.find<AdminPromoController>();
    final MBPromoCode? existing = widget.promo;
    final DateTime now = DateTime.now();

    final MBPromoCode promo = MBPromoCode(
      id: existing?.id ?? '',
      code: _codeController.text.trim(),
      discountValue: double.tryParse(_discountValueController.text.trim()) ?? 0,
      discountType: _discountType,
      minimumOrderAmount: _nullableDouble(_minimumOrderAmountController.text),
      maximumDiscount: _nullableDouble(_maximumDiscountController.text),
      usageLimit: _nullableInt(_usageLimitController.text),
      usageCount: int.tryParse(_usageCountController.text.trim()) ?? 0,
      eligibleUserIds: _splitCsv(_eligibleUserIdsController.text),
      isActive: _isActive,
      isArchived: _isArchived,
      campaignName: _emptyToNull(_campaignNameController.text),
      expirationDate:
      DateTime.tryParse(_expirationDateController.text.trim()) ??
          now.add(const Duration(days: 7)),
      createdAt: existing?.createdAt ?? now,
    );

    if (existing == null) {
      await controller.createPromo(promo);
    } else {
      await controller.updatePromo(promo);
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

  double? _nullableDouble(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }

  int? _nullableInt(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }
}