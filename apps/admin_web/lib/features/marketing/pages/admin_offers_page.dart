import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:admin_web/features/marketing/controllers/admin_offer_controller.dart';
import 'package:admin_web/features/marketing/widgets/admin_offer_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminOffersPage extends StatelessWidget {
  const AdminOffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAccessController accessController =
    Get.find<AdminAccessController>();
    final AdminOfferController offerController =
    Get.find<AdminOfferController>();

    return AdminWebShell(
      child: Obx(() {
        if (!accessController.canManageBanners) {
          return const _NoOfferPermissionState();
        }

        if (offerController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            const _OffersHeader(),
            Expanded(
              child: offerController.filteredOffers.isEmpty
                  ? const _EmptyOffersState()
                  : RefreshIndicator(
                onRefresh: offerController.refreshOffers,
                child: _OffersTable(
                  offers: offerController.filteredOffers,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _OffersHeader extends StatelessWidget {
  const _OffersHeader();

  @override
  Widget build(BuildContext context) {
    final AdminOfferController controller = Get.find<AdminOfferController>();

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
                  'Offer Management',
                  style: MBTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Get.dialog(
                    const AdminOfferFormDialog(),
                    barrierDismissible: false,
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Offer'),
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
                    hintText: 'Search offers...',
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
                    DropdownMenuItem(
                      value: 'scheduledOut',
                      child: Text('Out of Schedule'),
                    ),
                    DropdownMenuItem(value: 'featured', child: Text('Featured')),
                    DropdownMenuItem(value: 'floating', child: Text('Floating')),
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
                    labelText: 'Offer Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'percent', child: Text('Percent')),
                    DropdownMenuItem(value: 'amount', child: Text('Amount')),
                    DropdownMenuItem(
                      value: 'free_delivery',
                      child: Text('Free Delivery'),
                    ),
                    DropdownMenuItem(value: 'bundle', child: Text('Bundle')),
                    DropdownMenuItem(value: 'custom', child: Text('Custom')),
                  ],
                  onChanged: (value) =>
                      controller.setTypeFilter(value ?? 'all'),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: controller.presentationFilter.value,
                  decoration: const InputDecoration(
                    labelText: 'Presentation',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'strip', child: Text('Strip')),
                    DropdownMenuItem(value: 'card', child: Text('Card')),
                    DropdownMenuItem(value: 'banner', child: Text('Banner')),
                    DropdownMenuItem(value: 'floating', child: Text('Floating')),
                  ],
                  onChanged: (value) =>
                      controller.setPresentationFilter(value ?? 'all'),
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

class _OffersTable extends StatelessWidget {
  const _OffersTable({
    required this.offers,
  });

  final List<MBOffer> offers;

  @override
  Widget build(BuildContext context) {
    final AdminOfferController controller = Get.find<AdminOfferController>();

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
            dataRowMinHeight: 84,
            dataRowMaxHeight: 96,
            columns: const [
              DataColumn(label: Text('Offer')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Presentation')),
              DataColumn(label: Text('Target')),
              DataColumn(label: Text('Schedule')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: offers.map((offer) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 340,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(MBRadius.md),
                            child: offer.imageUrl.trim().isNotEmpty
                                ? Image.network(
                              offer.imageUrl,
                              width: 64,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64,
                                height: 48,
                                color: MBColors.background,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                ),
                              ),
                            )
                                : Container(
                              width: 64,
                              height: 48,
                              color: MBColors.background,
                              child: const Icon(
                                Icons.local_offer_outlined,
                              ),
                            ),
                          ),
                          MBSpacing.w(MBSpacing.md),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer.titleEn.isEmpty
                                      ? 'Untitled Offer'
                                      : offer.titleEn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: MBTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (offer.subtitleEn.isNotEmpty) ...[
                                  MBSpacing.h(MBSpacing.xxxs),
                                  Text(
                                    offer.subtitleEn,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: MBTextStyles.caption.copyWith(
                                      color: MBColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text('${offer.offerType} (${offer.offerValue})')),
                  DataCell(Text(offer.presentationType)),
                  DataCell(
                    Text(
                      '${offer.targetType}${offer.targetId != null ? ' • ${offer.targetId}' : ''}',
                    ),
                  ),
                  DataCell(
                    Text(
                      '${offer.startAt?.toString().split(".").first ?? "-"}\n${offer.endAt?.toString().split(".").first ?? "-"}',
                    ),
                  ),
                  DataCell(
                    _OfferStatusPill(
                      label: offer.isAvailable ? 'Active' : 'Inactive',
                      active: offer.isAvailable,
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        Switch(
                          value: offer.isActive,
                          onChanged: (_) => controller.toggleOfferActive(offer),
                        ),
                        IconButton(
                          tooltip: 'Edit offer',
                          onPressed: () {
                            Get.dialog(
                              AdminOfferFormDialog(offer: offer),
                              barrierDismissible: false,
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Delete offer',
                          onPressed: () async {
                            final bool? confirmed = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text('Delete Offer'),
                                content: Text(
                                  'Are you sure you want to delete "${offer.titleEn.isEmpty ? 'this offer' : offer.titleEn}"?',
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
                              await controller.deleteOffer(offer.id);
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

class _OfferStatusPill extends StatelessWidget {
  const _OfferStatusPill({
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

class _NoOfferPermissionState extends StatelessWidget {
  const _NoOfferPermissionState();

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
              'You do not have permission to manage offers.',
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

class _EmptyOffersState extends StatelessWidget {
  const _EmptyOffersState();

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
              Icons.local_offer_outlined,
              size: 44,
              color: MBColors.primaryOrange,
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              'No Offers Found',
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.xs),
            Text(
              'Create your first offer to drive campaigns and promotions.',
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