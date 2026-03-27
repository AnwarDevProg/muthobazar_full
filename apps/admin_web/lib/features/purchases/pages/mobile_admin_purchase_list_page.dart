import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/layout/mb_app_layout.dart';
import '../../../../../core/layout/mb_screen_padding.dart';
import 'package:shared_ui/shared_ui.dart';
import '../../../../../core/typography/mb_app_text.dart';
import '../controllers/mobile_admin_purchase_controller.dart';
import '../models/mobile_admin_purchase_model.dart';

class MobileAdminPurchaseListPage extends StatelessWidget {
  const MobileAdminPurchaseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MobileAdminPurchaseController controller =
    Get.find<MobileAdminPurchaseController>();

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: true,
      safeBottom: true,
      scrollable: true,
      padding: EdgeInsets.zero,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Column(
            children: [
              _PurchaseHeader(controller: controller),
              const SizedBox(
                height: 240,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PurchaseHeader(controller: controller),
            Padding(
              padding: MBScreenPadding.pageNoTop(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: _PurchaseSummaryRow(controller: controller),
                  ),
                  MBSpacing.h(MBSpacing.xs),
                  _PurchaseFilterCard(controller: controller),
                  MBSpacing.h(MBSpacing.sectionGap(context)),
                  _PurchaseTableSection(controller: controller),
                  MBSpacing.h(MBSpacing.xl),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _PurchaseHeader extends StatelessWidget {
  final MobileAdminPurchaseController controller;

  const _PurchaseHeader({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        MBSpacing.pageHorizontal(context),
        MBSpacing.pageVertical(context),
        MBSpacing.pageHorizontal(context),
        MBSpacing.xl,
      ),
      decoration: const BoxDecoration(
        gradient: MBGradients.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(MBRadius.xl),
          bottomRight: Radius.circular(MBRadius.xl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MBSpacing.h(MBSpacing.xxxs),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mobile Admin',
                      style: MBAppText.body(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                    ),
                    MBSpacing.h(MBSpacing.xxs),
                    Text(
                      'Purchase Management',
                      style: MBAppText.headline2(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    MBSpacing.h(MBSpacing.xs),
                    Text(
                      'Create, update, review and track product purchases.',
                      style: MBAppText.bodySmall(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(MBRadius.lg),
                onTap: () {
                  _openPurchaseFormSheet(
                    context: context,
                    controller: controller,
                  );
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(MBRadius.lg),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.sm),
        ],
      ),
    );
  }
}

class _PurchaseSummaryRow extends StatelessWidget {
  final MobileAdminPurchaseController controller;

  const _PurchaseSummaryRow({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: _SummaryStatCard(
              icon: Icons.receipt_long_outlined,
              label: 'Total',
              value: controller.totalCount.toString(),
            ),
          ),
          MBSpacing.w(MBSpacing.sm),
          Expanded(
            child: _SummaryStatCard(
              icon: Icons.pending_actions_outlined,
              label: 'Pending',
              value: controller.pendingCount.toString(),
            ),
          ),
          MBSpacing.w(MBSpacing.sm),
          Expanded(
            child: _SummaryStatCard(
              icon: Icons.verified_outlined,
              label: 'Completed',
              value: controller.completedCount.toString(),
            ),
          ),
        ],
      );
    });
  }
}

class _SummaryStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
      decoration: BoxDecoration(
        color: MBColors.card,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: MBColors.primaryOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(MBRadius.md),
            ),
            child: Icon(
              icon,
              color: MBColors.primaryOrange,
              size: 20,
            ),
          ),
          MBSpacing.h(MBSpacing.xs),
          Text(
            value,
            style: MBAppText.headline3(context).copyWith(
              color: MBColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.xxxs),
          Text(
            label,
            style: MBAppText.bodySmall(context).copyWith(
              color: MBColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseFilterCard extends StatelessWidget {
  final MobileAdminPurchaseController controller;

  const _PurchaseFilterCard({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return MBCard(
      child: Column(
        children: [
          TextField(
            onChanged: controller.setSearchQuery,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Search by product, seller, place, buyer, phone',
              filled: true,
              fillColor: MBColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MBRadius.md),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          MBSpacing.h(MBSpacing.md),
          Obx(() {
            return DropdownButtonFormField<String>(
              initialValue: controller.selectedStatus.value,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Status')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                controller.setStatusFilter(value ?? 'all');
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: MBColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MBRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PurchaseTableSection extends StatelessWidget {
  final MobileAdminPurchaseController controller;

  const _PurchaseTableSection({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredPurchases;

      if (items.isEmpty) {
        return MBCard(
          child: Column(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: MBColors.textMuted,
              ),
              MBSpacing.h(MBSpacing.md),
              Text(
                'No purchases found',
                style: MBAppText.label(context).copyWith(
                  color: MBColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              MBSpacing.h(MBSpacing.xxxs),
              Text(
                'Try changing filters or create a new purchase.',
                style: MBAppText.bodySmall(context).copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase List',
            style: MBAppText.headline3(context).copyWith(
              color: MBColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.xxxs),
          Text(
            'Compact mobile table-style purchase view.',
            style: MBAppText.bodySmall(context).copyWith(
              color: MBColors.textSecondary,
            ),
          ),
          MBSpacing.h(MBSpacing.blockGap(context)),
          ...items.map((purchase) {
            return Padding(
              padding: const EdgeInsets.only(bottom: MBSpacing.md),
              child: _PurchaseRowCard(
                purchase: purchase,
                controller: controller,
              ),
            );
          }),
        ],
      );
    });
  }
}

class _PurchaseRowCard extends StatelessWidget {
  final MobileAdminPurchaseModel purchase;
  final MobileAdminPurchaseController controller;

  const _PurchaseRowCard({
    required this.purchase,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return MBCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(MBRadius.lg),
        onTap: () {
          _showPurchaseDetailsSheet(
            context: context,
            purchase: purchase,
            controller: controller,
          );
        },
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: MBColors.primaryOrange.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(MBRadius.md),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: MBColors.primaryOrange,
                    size: 22,
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purchase.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MBAppText.label(context).copyWith(
                          color: MBColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      MBSpacing.h(MBSpacing.xxxs),
                      Text(
                        '${purchase.quantity} pcs  •  ৳ ${purchase.totalAmount.toStringAsFixed(2)}',
                        style: MBAppText.bodySmall(context).copyWith(
                          color: MBColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: purchase.status),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _SmallInfo(
                    label: 'Seller',
                    value: purchase.sellerName,
                  ),
                ),
                MBSpacing.w(MBSpacing.sm),
                Expanded(
                  child: _SmallInfo(
                    label: 'Place',
                    value: purchase.place,
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _SmallInfo(
                    label: 'Buyer',
                    value: purchase.purchasedBy,
                  ),
                ),
                MBSpacing.w(MBSpacing.sm),
                Expanded(
                  child: _SmallInfo(
                    label: 'Date',
                    value: _formatDate(purchase.purchaseDate),
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _ActionTileButton(
                    icon: Icons.visibility_outlined,
                    label: 'View',
                    onTap: () {
                      _showPurchaseDetailsSheet(
                        context: context,
                        purchase: purchase,
                        controller: controller,
                      );
                    },
                  ),
                ),
                MBSpacing.w(MBSpacing.sm),
                Expanded(
                  child: _ActionTileButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    onTap: () {
                      _openPurchaseFormSheet(
                        context: context,
                        controller: controller,
                        existingPurchase: purchase,
                      );
                    },
                  ),
                ),
                MBSpacing.w(MBSpacing.sm),
                Expanded(
                  child: _ActionTileButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    isDanger: true,
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('Delete Purchase'),
                            content: Text(
                              'Are you sure you want to delete "${purchase.productName}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed == true) {
                        await controller.deletePurchase(purchase.id);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallInfo extends StatelessWidget {
  final String label;
  final String value;

  const _SmallInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MBSpacing.sm),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: MBAppText.bodySmall(context).copyWith(
              color: MBColors.textSecondary,
            ),
          ),
          MBSpacing.h(MBSpacing.xxxs),
          Text(
            value.isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: MBAppText.label(context).copyWith(
              color: MBColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTileButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionTileButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isDanger ? MBColors.error : MBColors.primaryOrange;

    return InkWell(
      borderRadius: BorderRadius.circular(MBRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(MBRadius.md),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            MBSpacing.h(MBSpacing.xxxs),
            Text(
              label,
              style: MBAppText.bodySmall(context).copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(MBRadius.pill),
      ),
      child: Text(
        status.toUpperCase(),
        style: MBAppText.caption(context).copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

void _showPurchaseDetailsSheet({
  required BuildContext context,
  required MobileAdminPurchaseModel purchase,
  required MobileAdminPurchaseController controller,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Container(
        decoration: const BoxDecoration(
          color: MBColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MBRadius.xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              MBSpacing.pageHorizontal(context),
              MBSpacing.md,
              MBSpacing.pageHorizontal(context),
              MBSpacing.xl,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 54,
                      height: 5,
                      decoration: BoxDecoration(
                        color: MBColors.textMuted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  MBSpacing.h(MBSpacing.lg),
                  Text(
                    purchase.productName,
                    style: MBAppText.headline3(context).copyWith(
                      color: MBColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    'Purchase Details',
                    style: MBAppText.bodySmall(context).copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.lg),
                  MBCard(
                    child: Column(
                      children: [
                        _detailRow('Quantity', '${purchase.quantity} pcs'),
                        _divider(),
                        _detailRow(
                          'Unit Price',
                          '৳ ${purchase.unitPrice.toStringAsFixed(2)}',
                        ),
                        _divider(),
                        _detailRow(
                          'Total Amount',
                          '৳ ${purchase.totalAmount.toStringAsFixed(2)}',
                        ),
                        _divider(),
                        _detailRow('Place', purchase.place),
                        _divider(),
                        _detailRow('Seller Name', purchase.sellerName),
                        _divider(),
                        _detailRow('Seller Number', purchase.sellerNumber),
                        _divider(),
                        _detailRow('Purchased By', purchase.purchasedBy),
                        _divider(),
                        _detailRow(
                          'Purchase Date',
                          _formatDate(purchase.purchaseDate),
                        ),
                        _divider(),
                        _detailRow('Status', purchase.status),
                        _divider(),
                        _detailRow('Payment Method', purchase.paymentMethod),
                        _divider(),
                        _detailRow(
                          'Created At',
                          purchase.createdAt == null
                              ? '-'
                              : _formatDateTime(purchase.createdAt!),
                        ),
                      ],
                    ),
                  ),
                  MBSpacing.h(MBSpacing.md),
                  MBCard(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        purchase.notes.trim().isEmpty
                            ? 'No notes added.'
                            : purchase.notes,
                        style: MBAppText.body(context).copyWith(
                          color: MBColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  MBSpacing.h(MBSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _openPurchaseFormSheet(
                              context: context,
                              controller: controller,
                              existingPurchase: purchase,
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              color: MBColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: MBColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _divider() {
  return Divider(
    height: 1,
    color: MBColors.border.withValues(alpha: 0.90),
  );
}

void _openPurchaseFormSheet({
  required BuildContext context,
  required MobileAdminPurchaseController controller,
  MobileAdminPurchaseModel? existingPurchase,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return _PurchaseFormSheet(
        controller: controller,
        existingPurchase: existingPurchase,
      );
    },
  );
}

class _PurchaseFormSheet extends StatefulWidget {
  final MobileAdminPurchaseController controller;
  final MobileAdminPurchaseModel? existingPurchase;

  const _PurchaseFormSheet({
    required this.controller,
    this.existingPurchase,
  });

  @override
  State<_PurchaseFormSheet> createState() => _PurchaseFormSheetState();
}

class _PurchaseFormSheetState extends State<_PurchaseFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _productNameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _placeController;
  late final TextEditingController _sellerNameController;
  late final TextEditingController _sellerNumberController;
  late final TextEditingController _purchasedByController;
  late final TextEditingController _purchaseDateController;
  late final TextEditingController _notesController;

  late String _status;
  late String _paymentMethod;
  late DateTime _selectedPurchaseDate;

  bool get isEditMode => widget.existingPurchase != null;

  @override
  void initState() {
    super.initState();

    final purchase = widget.existingPurchase;

    _selectedPurchaseDate = purchase?.purchaseDate ?? DateTime.now();

    _productNameController = TextEditingController(
      text: purchase?.productName ?? '',
    );
    _quantityController = TextEditingController(
      text: (purchase?.quantity ?? 1).toString(),
    );
    _unitPriceController = TextEditingController(
      text: (purchase?.unitPrice ?? 0).toStringAsFixed(0),
    );
    _placeController = TextEditingController(
      text: purchase?.place ?? '',
    );
    _sellerNameController = TextEditingController(
      text: purchase?.sellerName ?? '',
    );
    _sellerNumberController = TextEditingController(
      text: purchase?.sellerNumber ?? '',
    );
    _purchasedByController = TextEditingController(
      text: purchase?.purchasedBy.isNotEmpty == true
          ? purchase!.purchasedBy
          : widget.controller.actorName,
    );
    _purchaseDateController = TextEditingController(
      text: _formatDate(_selectedPurchaseDate),
    );
    _notesController = TextEditingController(
      text: purchase?.notes ?? '',
    );

    _status = purchase?.status ?? 'completed';
    _paymentMethod = purchase?.paymentMethod ?? 'cash';
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _placeController.dispose();
    _sellerNameController.dispose();
    _sellerNumberController.dispose();
    _purchasedByController.dispose();
    _purchaseDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MBRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: MBSpacing.pageHorizontal(context),
            right: MBSpacing.pageHorizontal(context),
            top: MBSpacing.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + MBSpacing.xl,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 54,
                      height: 5,
                      decoration: BoxDecoration(
                        color: MBColors.textMuted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  MBSpacing.h(MBSpacing.lg),
                  Text(
                    isEditMode ? 'Edit Purchase' : 'Create Purchase',
                    style: MBAppText.headline3(context).copyWith(
                      color: MBColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    isEditMode
                        ? 'Update purchase information'
                        : 'Add a new product purchase',
                    style: MBAppText.bodySmall(context).copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.lg),
                  _buildField(
                    controller: _productNameController,
                    label: 'Product Name',
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Enter product name';
                      }
                      return null;
                    },
                  ),
                  MBSpacing.h(MBSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          controller: _quantityController,
                          label: 'Quantity',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final qty = int.tryParse((value ?? '').trim());
                            if (qty == null || qty <= 0) {
                              return 'Invalid qty';
                            }
                            return null;
                          },
                        ),
                      ),
                      MBSpacing.w(MBSpacing.md),
                      Expanded(
                        child: _buildField(
                          controller: _unitPriceController,
                          label: 'Unit Price',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            final price = double.tryParse((value ?? '').trim());
                            if (price == null || price < 0) {
                              return 'Invalid price';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  MBSpacing.h(MBSpacing.md),
                  _buildField(
                    controller: _placeController,
                    label: 'Place',
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Enter place';
                      }
                      return null;
                    },
                  ),
                  MBSpacing.h(MBSpacing.md),
                  _buildField(
                    controller: _sellerNameController,
                    label: 'Seller Name',
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Enter seller name';
                      }
                      return null;
                    },
                  ),
                  MBSpacing.h(MBSpacing.md),
                  _buildField(
                    controller: _sellerNumberController,
                    label: 'Seller Number',
                  ),
                  MBSpacing.h(MBSpacing.md),
                  _buildField(
                    controller: _purchasedByController,
                    label: 'Purchased By',
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Enter purchaser name';
                      }
                      return null;
                    },
                  ),
                  MBSpacing.h(MBSpacing.md),
                  InkWell(
                    borderRadius: BorderRadius.circular(MBRadius.md),
                    onTap: _pickPurchaseDate,
                    child: IgnorePointer(
                      child: _buildField(
                        controller: _purchaseDateController,
                        label: 'Purchase Date',
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ),
                  MBSpacing.h(MBSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('Completed'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelled',
                        child: Text('Cancelled'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _status = value ?? 'completed';
                      });
                    },
                    decoration: _dropdownDecoration('Status'),
                  ),
                  MBSpacing.h(MBSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _paymentMethod,
                    items: const [
                      DropdownMenuItem(
                        value: 'cash',
                        child: Text('Cash'),
                      ),
                      DropdownMenuItem(
                        value: 'bank',
                        child: Text('Bank'),
                      ),
                      DropdownMenuItem(
                        value: 'mobile_banking',
                        child: Text('Mobile Banking'),
                      ),
                      DropdownMenuItem(
                        value: 'due',
                        child: Text('Due'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value ?? 'cash';
                      });
                    },
                    decoration: _dropdownDecoration('Payment Method'),
                  ),
                  MBSpacing.h(MBSpacing.md),
                  _buildField(
                    controller: _notesController,
                    label: 'Notes',
                    maxLines: 4,
                  ),
                  MBSpacing.h(MBSpacing.lg),
                  Obx(() {
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.controller.isSaving.value
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        MBSpacing.w(MBSpacing.md),
                        Expanded(
                          child: FilledButton(
                            onPressed: widget.controller.isSaving.value
                                ? null
                                : _submit,
                            child: Text(
                              isEditMode ? 'Update' : 'Create',
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: MBColors.card,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MBRadius.md),
        borderSide: BorderSide(
          color: MBColors.border.withValues(alpha: 0.90),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MBRadius.md),
        borderSide: BorderSide(
          color: MBColors.border.withValues(alpha: 0.90),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MBRadius.md),
        borderSide: const BorderSide(
          color: MBColors.primaryOrange,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: MBColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MBRadius.md),
          borderSide: BorderSide(
            color: MBColors.border.withValues(alpha: 0.90),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MBRadius.md),
          borderSide: BorderSide(
            color: MBColors.border.withValues(alpha: 0.90),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MBRadius.md),
          borderSide: const BorderSide(
            color: MBColors.primaryOrange,
          ),
        ),
      ),
    );
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedPurchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _selectedPurchaseDate = picked;
      _purchaseDateController.text = _formatDate(picked);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final unitPrice = double.tryParse(_unitPriceController.text.trim()) ?? 0;

    final existing = widget.existingPurchase;

    final purchase = MobileAdminPurchaseModel(
      id: existing?.id ?? '',
      productName: _productNameController.text.trim(),
      quantity: quantity,
      unitPrice: unitPrice,
      place: _placeController.text.trim(),
      sellerName: _sellerNameController.text.trim(),
      sellerNumber: _sellerNumberController.text.trim(),
      purchasedBy: _purchasedByController.text.trim(),
      purchaseDate: _selectedPurchaseDate,
      status: _status,
      paymentMethod: _paymentMethod,
      notes: _notesController.text.trim(),
      createdAt: existing?.createdAt,
      updatedAt: existing?.updatedAt,
      createdByUid: existing?.createdByUid ?? widget.controller.actorUid,
      updatedByUid: widget.controller.actorUid,
    );

    if (isEditMode) {
      await widget.controller.updatePurchase(
        purchase: purchase,
      );
    } else {
      await widget.controller.createPurchase(
        purchase: purchase,
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();

  return '$day/$month/$year';
}

String _formatDateTime(DateTime value) {
  final date = _formatDate(value);
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');

  return '$date  $hour:$minute';
}

Color _statusColor(String status) {
  switch (status.trim().toLowerCase()) {
    case 'completed':
      return const Color(0xFF10B981);
    case 'pending':
      return const Color(0xFFFF8A00);
    case 'cancelled':
      return const Color(0xFFE53935);
    default:
      return MBColors.primaryOrange;
  }
}












