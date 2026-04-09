import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:admin_web/features/brands/controllers/admin_brand_controller.dart';
import 'package:admin_web/features/brands/widgets/admin_brand_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminBrandsPage extends StatelessWidget {
  const AdminBrandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAccessController accessController = Get.find();
    final AdminBrandController brandController = Get.find();

    return AdminWebShell(
      child: Obx(() {
        if (!accessController.canManageBrands) {
          return const _NoBrandPermissionState();
        }

        if (brandController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            _BrandsHeader(
              onAdd: () {
                Get.dialog(
                  const AdminBrandFormDialog(),
                  barrierDismissible: false,
                );
              },
            ),
            if ((brandController.operationError.value ?? '').trim().isNotEmpty)
              _BrandOperationErrorBanner(
                message: brandController.operationError.value!.trim(),
                onClose: brandController.clearOperationError,
              ),
            Expanded(
              child: brandController.filteredBrands.isEmpty
                  ? const _EmptyBrandsState()
                  : RefreshIndicator(
                onRefresh: brandController.refreshBrands,
                child: _BrandsTable(
                  brands: brandController.filteredBrands,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _BrandsHeader extends StatelessWidget {
  const _BrandsHeader({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final AdminBrandController controller = Get.find();

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
                  'Brand Management',
                  style: MBTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: controller.refreshBrands,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reload'),
              ),
              MBSpacing.w(MBSpacing.md),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Brand'),
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
                    hintText: 'Search by name, slug, description...',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: DropdownButtonFormField(
                  value: controller.statusFilter.value,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (value) => controller.setStatusFilter(value ?? 'all'),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: DropdownButtonFormField(
                  value: controller.featuredFilter.value,
                  decoration: const InputDecoration(
                    labelText: 'Featured',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(
                      value: 'featured',
                      child: Text('Featured'),
                    ),
                    DropdownMenuItem(
                      value: 'notFeatured',
                      child: Text('Not Featured'),
                    ),
                  ],
                  onChanged: (value) => controller.setFeaturedFilter(value ?? 'all'),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: DropdownButtonFormField(
                  value: controller.homeFilter.value,
                  decoration: const InputDecoration(
                    labelText: 'Home Visibility',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(
                      value: 'showOnHome',
                      child: Text('Show On Home'),
                    ),
                    DropdownMenuItem(
                      value: 'hideFromHome',
                      child: Text('Hide From Home'),
                    ),
                  ],
                  onChanged: (value) => controller.setHomeFilter(value ?? 'all'),
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

class _BrandOperationErrorBanner extends StatelessWidget {
  const _BrandOperationErrorBanner({
    required this.message,
    required this.onClose,
  });

  final String message;
  final VoidCallback onClose;

  String _cleanMessage(String raw) {
    final value = raw.trim();
    if (value.startsWith('Exception: ')) {
      return value.replaceFirst('Exception: ', '').trim();
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        MBSpacing.lg,
        MBSpacing.md,
        MBSpacing.lg,
        0,
      ),
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: MBColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.error.withValues(alpha: 0.22),
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
              _cleanMessage(message),
              style: MBTextStyles.body.copyWith(
                color: MBColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          MBSpacing.w(MBSpacing.sm),
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(MBRadius.pill),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: MBColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandsTable extends StatelessWidget {
  const _BrandsTable({
    required this.brands,
  });

  final List<MBBrand> brands;

  Future<String?> _askReason({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    bool allowEmpty = true,
  }) async {
    final TextEditingController reasonController = TextEditingController();

    final String? result = await Get.dialog<String>(
      AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              MBSpacing.h(MBSpacing.md),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: allowEmpty
                      ? 'Reason (optional)'
                      : 'Reason (required)',
                  hintText: 'Enter reason here...',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (!allowEmpty && reason.isEmpty) {
                Get.snackbar(
                  'Reason Required',
                  'Please enter a reason to continue.',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              Get.back(result: reason);
            },
            child: Text(confirmText),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    reasonController.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final AdminBrandController controller = Get.find();

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
            dataRowMaxHeight: 100,
            columns: const [
              DataColumn(label: Text('Brand')),
              DataColumn(label: Text('Slug')),
              DataColumn(label: Text('Products')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Home')),
              DataColumn(label: Text('Featured')),
              DataColumn(label: Text('Sort')),
              DataColumn(label: Text('Actions')),
            ],
            rows: brands.map((brand) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 340,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(MBRadius.md),
                            child: brand.logoUrl.trim().isNotEmpty
                                ? Image.network(
                              brand.logoUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 56,
                                height: 56,
                                color: MBColors.background,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                ),
                              ),
                            )
                                : Container(
                              width: 56,
                              height: 56,
                              color: MBColors.background,
                              child: const Icon(
                                Icons.store_outlined,
                                color: MBColors.primaryOrange,
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
                                  brand.nameEn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: MBTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (brand.nameBn.trim().isNotEmpty) ...[
                                  MBSpacing.h(MBSpacing.xxxs),
                                  Text(
                                    brand.nameBn,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: MBTextStyles.caption.copyWith(
                                      color: MBColors.textSecondary,
                                    ),
                                  ),
                                ],
                                if (brand.descriptionEn.trim().isNotEmpty) ...[
                                  MBSpacing.h(MBSpacing.xxxs),
                                  Text(
                                    brand.descriptionEn,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: MBTextStyles.caption.copyWith(
                                      color: MBColors.textMuted,
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
                  DataCell(Text(brand.slug.isEmpty ? '-' : brand.slug)),
                  DataCell(Text('${brand.productsCount}')),
                  DataCell(
                    Switch(
                      value: brand.isActive,
                      onChanged: (_) async {
                        controller.clearOperationError();

                        final String actionLabel =
                        brand.isActive ? 'deactivate' : 'activate';

                        final String? reason = await _askReason(
                          context: context,
                          title: brand.isActive
                              ? 'Deactivate Brand'
                              : 'Activate Brand',
                          message:
                          'Are you sure you want to $actionLabel "${brand.nameEn}"?',
                          confirmText: brand.isActive ? 'Deactivate' : 'Activate',
                          allowEmpty: true,
                        );

                        if (reason == null) return;

                        await controller.toggleBrandActive(
                          brand,
                          reason: reason,
                        );
                      },
                    ),
                  ),
                  DataCell(
                    _StatusPill(
                      label: brand.showOnHome ? 'Shown' : 'Hidden',
                      active: brand.showOnHome,
                    ),
                  ),
                  DataCell(
                    _StatusPill(
                      label: brand.isFeatured ? 'Featured' : 'Normal',
                      active: brand.isFeatured,
                    ),
                  ),
                  DataCell(Text('${brand.sortOrder}')),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Edit brand',
                          onPressed: () {
                            controller.clearOperationError();
                            Get.dialog(
                              AdminBrandFormDialog(brand: brand),
                              barrierDismissible: false,
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: brand.isActive
                              ? 'Deactivate brand'
                              : 'Activate brand',
                          onPressed: () async {
                            controller.clearOperationError();

                            final String actionLabel =
                            brand.isActive ? 'deactivate' : 'activate';

                            final String? reason = await _askReason(
                              context: context,
                              title: brand.isActive
                                  ? 'Deactivate Brand'
                                  : 'Activate Brand',
                              message:
                              'Are you sure you want to $actionLabel "${brand.nameEn}"?',
                              confirmText:
                              brand.isActive ? 'Deactivate' : 'Activate',
                              allowEmpty: true,
                            );

                            if (reason == null) return;

                            await controller.toggleBrandActive(
                              brand,
                              reason: reason,
                            );
                          },
                          icon: Icon(
                            brand.isActive
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: MBColors.warning,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete brand',
                          onPressed: () async {
                            controller.clearOperationError();

                            final blockReason =
                            await controller.getDeleteBlockReason(
                              brandId: brand.id,
                            );

                            if (blockReason != null &&
                                blockReason.trim().isNotEmpty) {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Delete Not Allowed'),
                                  content: Text(blockReason),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            final String? reason = await _askReason(
                              context: context,
                              title: 'Delete Brand',
                              message:
                              'Are you sure you want to delete "${brand.nameEn}"?',
                              confirmText: 'Delete',
                              allowEmpty: true,
                            );

                            if (reason == null) return;

                            await controller.deleteBrand(
                              brand.id,
                              reason: reason,
                            );
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({
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

class _NoBrandPermissionState extends StatelessWidget {
  const _NoBrandPermissionState();

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
              'You do not have permission to manage brands.',
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

class _EmptyBrandsState extends StatelessWidget {
  const _EmptyBrandsState();

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
              Icons.store_outlined,
              size: 44,
              color: MBColors.primaryOrange,
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              'No Brands Found',
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.xs),
            Text(
              'Create your first brand to organize products better.',
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
