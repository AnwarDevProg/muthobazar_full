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

        final String errorMessage =
        (brandController.operationError.value ?? '').trim();
        final List<MBBrand> visibleBrands =
        brandController.filteredBrands.toList(growable: false);
        final List<MBBrand> allBrands = brandController.brands.toList(
          growable: false,
        );

        return Column(
          children: [
            _BrandsHeader(
              totalCount: allBrands.length,
              visibleCount: visibleBrands.length,
              activeCount: allBrands.where((item) => item.isActive).length,
              featuredCount: allBrands.where((item) => item.isFeatured).length,
              homeShownCount: allBrands.where((item) => item.showOnHome).length,
              onAdd: () {
                brandController.clearOperationError();
                Get.dialog(
                  const AdminBrandFormDialog(),
                  barrierDismissible: false,
                );
              },
            ),
            if (errorMessage.isNotEmpty)
              _BrandOperationErrorBanner(
                message: errorMessage,
                onClose: brandController.clearOperationError,
              ),
            Expanded(
              child: visibleBrands.isEmpty
                  ? _EmptyBrandsState(
                hasAnyBrand: allBrands.isNotEmpty,
                onResetFilters: brandController.resetFilters,
              )
                  : RefreshIndicator(
                onRefresh: brandController.refreshBrands,
                child: _BrandsTable(
                  brands: visibleBrands,
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
    required this.totalCount,
    required this.visibleCount,
    required this.activeCount,
    required this.featuredCount,
    required this.homeShownCount,
    required this.onAdd,
  });

  final int totalCount;
  final int visibleCount;
  final int activeCount;
  final int featuredCount;
  final int homeShownCount;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MBSpacing.md,
            runSpacing: MBSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 520,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brand Management',
                      style: MBTextStyles.sectionTitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    MBSpacing.h(MBSpacing.xs),
                    Text(
                      'Manage brand identity, visibility, featured state, and safe admin actions.',
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: MBSpacing.md,
                runSpacing: MBSpacing.md,
                children: [
                  OutlinedButton.icon(
                    onPressed: controller.isAnyBusy
                        ? null
                        : controller.refreshBrands,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reload'),
                  ),
                  ElevatedButton.icon(
                    onPressed: controller.isAnyBusy ? null : onAdd,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Brand'),
                  ),
                ],
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.md),
          Wrap(
            spacing: MBSpacing.md,
            runSpacing: MBSpacing.md,
            children: [
              _SummaryChip(
                label: 'Total',
                value: '$totalCount',
                icon: Icons.storefront_outlined,
              ),
              _SummaryChip(
                label: 'Visible',
                value: '$visibleCount',
                icon: Icons.filter_alt_outlined,
              ),
              _SummaryChip(
                label: 'Active',
                value: '$activeCount',
                icon: Icons.verified_outlined,
              ),
              _SummaryChip(
                label: 'Featured',
                value: '$featuredCount',
                icon: Icons.star_outline_rounded,
              ),
              _SummaryChip(
                label: 'Home Shown',
                value: '$homeShownCount',
                icon: Icons.home_outlined,
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isTight = constraints.maxWidth < 1100;

              if (isTight) {
                return Column(
                  children: [
                    TextField(
                      onChanged: controller.setSearchQuery,
                      decoration: const InputDecoration(
                        hintText: 'Search by name, slug, description...',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    MBSpacing.h(MBSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: controller.statusFilter.value,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: 'active',
                                child: Text('Active'),
                              ),
                              DropdownMenuItem(
                                value: 'inactive',
                                child: Text('Inactive'),
                              ),
                            ],
                            onChanged: (value) =>
                                controller.setStatusFilter(value ?? 'all'),
                          ),
                        ),
                        MBSpacing.w(MBSpacing.md),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: controller.featuredFilter.value,
                            decoration: const InputDecoration(
                              labelText: 'Featured',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: 'featured',
                                child: Text('Featured'),
                              ),
                              DropdownMenuItem(
                                value: 'notFeatured',
                                child: Text('Not Featured'),
                              ),
                            ],
                            onChanged: (value) =>
                                controller.setFeaturedFilter(value ?? 'all'),
                          ),
                        ),
                      ],
                    ),
                    MBSpacing.h(MBSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: controller.homeFilter.value,
                            decoration: const InputDecoration(
                              labelText: 'Home Visibility',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: 'showOnHome',
                                child: Text('Show On Home'),
                              ),
                              DropdownMenuItem(
                                value: 'hideFromHome',
                                child: Text('Hide From Home'),
                              ),
                            ],
                            onChanged: (value) =>
                                controller.setHomeFilter(value ?? 'all'),
                          ),
                        ),
                        MBSpacing.w(MBSpacing.md),
                        SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: controller.resetFilters,
                            child: const Text('Reset'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Row(
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
                    child: DropdownButtonFormField<String>(
                      value: controller.statusFilter.value,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: 'inactive',
                          child: Text('Inactive'),
                        ),
                      ],
                      onChanged: (value) =>
                          controller.setStatusFilter(value ?? 'all'),
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
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
                      onChanged: (value) =>
                          controller.setFeaturedFilter(value ?? 'all'),
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
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
                      onChanged: (value) =>
                          controller.setHomeFilter(value ?? 'all'),
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: controller.resetFilters,
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.md,
        vertical: MBSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.9),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: MBColors.primaryOrange,
          ),
          MBSpacing.w(MBSpacing.sm),
          Text(
            label,
            style: MBTextStyles.caption.copyWith(
              color: MBColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          MBSpacing.w(MBSpacing.xs),
          Text(
            value,
            style: MBTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: MBColors.textPrimary,
            ),
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
    final String value = raw.trim();
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
              final String reason = reasonController.text.trim();
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
      physics: const AlwaysScrollableScrollPhysics(),
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
                              errorBuilder: (_, __, ___) => _BrandFallbackLogo(
                                name: brand.nameEn,
                              ),
                            )
                                : _BrandFallbackLogo(name: brand.nameEn),
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
                                  style: MBTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (brand.nameBn.trim().isNotEmpty) ...[
                                  MBSpacing.h(4),
                                  Text(
                                    brand.nameBn,
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
                  DataCell(
                    SelectableText(
                      brand.slug,
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.textSecondary,
                      ),
                    ),
                  ),
                  DataCell(Text('${brand.productsCount}')),
                  DataCell(
                    InkWell(
                      borderRadius: BorderRadius.circular(MBRadius.pill),
                      onTap: () async {
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
                      child: _StatusPill(
                        label: brand.isActive ? 'Active' : 'Inactive',
                        active: brand.isActive,
                      ),
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

                            final String? blockReason =
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

class _BrandFallbackLogo extends StatelessWidget {
  const _BrandFallbackLogo({
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    final String initial = name.trim().isEmpty ? 'B' : name.trim()[0].toUpperCase();

    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MBColors.primaryOrange.withValues(alpha: 0.12),
      ),
      child: Text(
        initial,
        style: MBTextStyles.body.copyWith(
          color: MBColors.primaryOrange,
          fontWeight: FontWeight.w800,
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
  const _EmptyBrandsState({
    required this.hasAnyBrand,
    required this.onResetFilters,
  });

  final bool hasAnyBrand;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    final String title = hasAnyBrand ? 'No Matching Brands' : 'No Brands Found';
    final String message = hasAnyBrand
        ? 'No brands matched the current filters. Reset filters and try again.'
        : 'Create your first brand to organize products better.';

    return Center(
      child: Container(
        width: 500,
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
              title,
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
            if (hasAnyBrand) ...[
              MBSpacing.h(MBSpacing.lg),
              OutlinedButton.icon(
                onPressed: onResetFilters,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
