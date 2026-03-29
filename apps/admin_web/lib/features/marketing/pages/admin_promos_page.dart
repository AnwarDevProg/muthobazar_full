import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:admin_web/features/marketing/controllers/admin_promo_controller.dart';
import 'package:admin_web/features/marketing/widgets/admin_promo_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminPromosPage extends StatelessWidget {
  const AdminPromosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAccessController accessController =
    Get.find<AdminAccessController>();
    final AdminPromoController promoController =
    Get.find<AdminPromoController>();

    return AdminWebShell(
      child: Obx(() {
        if (!accessController.canManageCoupons) {
          return const _NoPromoPermissionState();
        }

        if (promoController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            const _PromosHeader(),
            Expanded(
              child: promoController.filteredPromos.isEmpty
                  ? const _EmptyPromosState()
                  : RefreshIndicator(
                onRefresh: promoController.refreshPromos,
                child: _PromosTable(
                  promos: promoController.filteredPromos,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _PromosHeader extends StatelessWidget {
  const _PromosHeader();

  @override
  Widget build(BuildContext context) {
    final AdminPromoController controller = Get.find<AdminPromoController>();

    return Container(
      padding: const EdgeInsets.all(MBSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: MBColors.border.withValues(alpha: 0.85),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Promo Code Management',
                  style: MBTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Get.dialog(
                    const AdminPromoFormDialog(),
                    barrierDismissible: false,
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Promo'),
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.md),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: controller.setSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search by code or campaign...',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: controller.statusFilter.value,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    DropdownMenuItem(value: 'expired', child: Text('Expired')),
                    DropdownMenuItem(value: 'archived', child: Text('Archived')),
                  ],
                  onChanged: (value) =>
                      controller.setStatusFilter(value ?? 'all'),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: controller.typeFilter.value,
                  decoration: const InputDecoration(
                    labelText: 'Discount Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'percent', child: Text('Percent')),
                    DropdownMenuItem(value: 'amount', child: Text('Amount')),
                  ],
                  onChanged: (value) =>
                      controller.setTypeFilter(value ?? 'all'),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              OutlinedButton(
                onPressed: controller.resetFilters,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromosTable extends StatelessWidget {
  const _PromosTable({
    required this.promos,
  });

  final List<MBPromoCode> promos;

  @override
  Widget build(BuildContext context) {
    final AdminPromoController controller = Get.find<AdminPromoController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(MBSpacing.lg),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MBRadius.lg),
          side: BorderSide(
            color: MBColors.border.withValues(alpha: 0.9),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            headingRowHeight: 56,
            dataRowMinHeight: 72,
            dataRowMaxHeight: 88,
            columns: const [
              DataColumn(label: Text('Code')),
              DataColumn(label: Text('Campaign')),
              DataColumn(label: Text('Discount')),
              DataColumn(label: Text('Usage')),
              DataColumn(label: Text('Expires')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: promos.map((promo) {
              final String statusLabel = promo.isArchived
                  ? 'Archived'
                  : promo.isExpired
                  ? 'Expired'
                  : promo.isActive
                  ? 'Active'
                  : 'Inactive';

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      promo.code,
                      style: MBTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  DataCell(Text(promo.campaignName ?? '-')),
                  DataCell(
                    Text(
                      promo.discountType == 'percent'
                          ? '${promo.discountValue}%'
                          : '${promo.discountValue}',
                    ),
                  ),
                  DataCell(
                    Text(
                      promo.usageLimit == null
                          ? '${promo.usageCount} / ∞'
                          : '${promo.usageCount} / ${promo.usageLimit}',
                    ),
                  ),
                  DataCell(
                    Text(
                      promo.expirationDate.toString().split('.').first,
                    ),
                  ),
                  DataCell(
                    _PromoStatusPill(
                      label: statusLabel,
                      active: promo.isActive &&
                          !promo.isExpired &&
                          !promo.isArchived,
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        Switch(
                          value: promo.isActive,
                          onChanged: (_) => controller.togglePromoActive(promo),
                        ),
                        IconButton(
                          tooltip: 'Edit promo',
                          onPressed: () {
                            Get.dialog(
                              AdminPromoFormDialog(promo: promo),
                              barrierDismissible: false,
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Delete promo',
                          onPressed: () async {
                            final bool? confirmed = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text('Delete Promo'),
                                content: Text(
                                  'Are you sure you want to delete "${promo.code}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Get.back(result: true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await controller.deletePromo(promo.id);
                            }
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: MBColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _PromoStatusPill extends StatelessWidget {
  const _PromoStatusPill({
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.md,
        vertical: MBSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: active
            ? MBColors.success.withValues(alpha: 0.12)
            : MBColors.textMuted.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(MBRadius.pill),
      ),
      child: Text(
        label,
        style: MBTextStyles.caption.copyWith(
          color: active ? MBColors.success : MBColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NoPromoPermissionState extends StatelessWidget {
  const _NoPromoPermissionState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(MBSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MBRadius.xl),
          boxShadow: [
            BoxShadow(
              color: MBColors.shadow.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 44,
              color: MBColors.error,
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              'Permission Required',
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.xs),
            Text(
              'You do not have permission to manage promo codes.',
              textAlign: TextAlign.center,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPromosState extends StatelessWidget {
  const _EmptyPromosState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(MBSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MBRadius.xl),
          boxShadow: [
            BoxShadow(
              color: MBColors.shadow.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 44,
              color: MBColors.primaryOrange,
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              'No Promo Codes Found',
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.xs),
            Text(
              'Create your first promo code to run campaigns and discounts.',
              textAlign: TextAlign.center,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}