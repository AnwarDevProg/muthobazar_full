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
    final AdminAccessController accessController =
    Get.find<AdminAccessController>();
    final AdminBrandController brandController =
    Get.find<AdminBrandController>();

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
    final AdminBrandController controller = Get.find<AdminBrandController>();

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

class _BrandsTable extends StatelessWidget {
  const _BrandsTable({
    required this.brands,
  });

  final List<MBBrand> brands;

  @override
  Widget build(BuildContext context) {
    final AdminBrandController controller = Get.find<AdminBrandController>();

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
                      onChanged: (_) => controller.toggleBrandActive(brand),
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
                          onPressed: () => controller.toggleBrandActive(brand),
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
                            final bool? confirmed = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text('Delete Brand'),
                                content: Text(
                                  'Are you sure you want to delete "${brand.nameEn}"?',
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
                              await controller.deleteBrand(brand.id);
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