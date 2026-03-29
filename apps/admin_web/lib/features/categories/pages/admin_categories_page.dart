import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:admin_web/features/categories/controllers/admin_category_controller.dart';
import 'package:admin_web/features/categories/widgets/admin_category_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminCategoriesPage extends StatelessWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAccessController accessController =
    Get.find<AdminAccessController>();
    final AdminCategoryController categoryController =
    Get.find<AdminCategoryController>();

    return AdminWebShell(
      child: Obx(() {
        if (!accessController.canManageCategories) {
          return const _NoCategoryPermissionState();
        }

        if (categoryController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            _CategoriesHeader(
              onAdd: () {
                Get.dialog(
                  const AdminCategoryFormDialog(),
                  barrierDismissible: false,
                );
              },
            ),
            Expanded(
              child: categoryController.filteredCategories.isEmpty
                  ? const _EmptyCategoriesState()
                  : RefreshIndicator(
                onRefresh: categoryController.refreshCategories,
                child: _CategoriesTable(
                  categories: categoryController.filteredCategories,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _CategoriesHeader extends StatelessWidget {
  const _CategoriesHeader({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final AdminCategoryController controller =
    Get.find<AdminCategoryController>();

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
                  'Category Management',
                  style: MBTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Category'),
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
                        value: 'featured', child: Text('Featured')),
                    DropdownMenuItem(
                        value: 'notFeatured', child: Text('Not Featured')),
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
                        value: 'showOnHome', child: Text('Show On Home')),
                    DropdownMenuItem(
                        value: 'hideFromHome', child: Text('Hide From Home')),
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

class _CategoriesTable extends StatelessWidget {
  const _CategoriesTable({
    required this.categories,
  });

  final List<MBCategory> categories;

  @override
  Widget build(BuildContext context) {
    final AdminCategoryController controller =
    Get.find<AdminCategoryController>();

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
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Slug')),
              DataColumn(label: Text('Parent')),
              DataColumn(label: Text('Products')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Home')),
              DataColumn(label: Text('Featured')),
              DataColumn(label: Text('Sort')),
              DataColumn(label: Text('Actions')),
            ],
            rows: categories.map((category) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 340,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(MBRadius.md),
                            child: category.imageUrl.trim().isNotEmpty
                                ? Image.network(
                              category.imageUrl,
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
                                Icons.category_outlined,
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
                                  category.nameEn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: MBTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (category.nameBn.trim().isNotEmpty) ...[
                                  MBSpacing.h(MBSpacing.xxxs),
                                  Text(
                                    category.nameBn,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: MBTextStyles.caption.copyWith(
                                      color: MBColors.textSecondary,
                                    ),
                                  ),
                                ],
                                if (category.descriptionEn.trim().isNotEmpty) ...[
                                  MBSpacing.h(MBSpacing.xxxs),
                                  Text(
                                    category.descriptionEn,
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
                  DataCell(Text(category.slug.isEmpty ? '-' : category.slug)),
                  DataCell(Text(category.parentId ?? '-')),
                  DataCell(Text('${category.productsCount}')),
                  DataCell(
                    Switch(
                      value: category.isActive,
                      onChanged: (_) =>
                          controller.toggleCategoryActive(category),
                    ),
                  ),
                  DataCell(
                    _StatusPill(
                      label: category.showOnHome ? 'Shown' : 'Hidden',
                      active: category.showOnHome,
                    ),
                  ),
                  DataCell(
                    _StatusPill(
                      label: category.isFeatured ? 'Featured' : 'Normal',
                      active: category.isFeatured,
                    ),
                  ),
                  DataCell(Text('${category.sortOrder}')),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Edit category',
                          onPressed: () {
                            Get.dialog(
                              AdminCategoryFormDialog(category: category),
                              barrierDismissible: false,
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: category.isActive
                              ? 'Deactivate category'
                              : 'Activate category',
                          onPressed: () =>
                              controller.toggleCategoryActive(category),
                          icon: Icon(
                            category.isActive
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: MBColors.warning,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete category',
                          onPressed: () async {
                            final bool? confirmed = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text('Delete Category'),
                                content: Text(
                                  'Are you sure you want to delete "${category.nameEn}"?',
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
                              await controller.deleteCategory(category.id);
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

class _NoCategoryPermissionState extends StatelessWidget {
  const _NoCategoryPermissionState();

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
              'You do not have permission to manage categories.',
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

class _EmptyCategoriesState extends StatelessWidget {
  const _EmptyCategoriesState();

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
              Icons.category_outlined,
              size: 44,
              color: MBColors.primaryOrange,
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              'No Categories Found',
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.xs),
            Text(
              'Create your first category to organize products.',
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