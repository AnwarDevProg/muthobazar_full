import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:admin_web/app/routes/admin_web_routes.dart';
import '../../../models/catalog/mb_category.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import '../controllers/admin_category_controller.dart';
import 'widgets/admin_category_form_dialog.dart';

class AdminCategoriesPage extends StatelessWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAccessController accessController =
    Get.find<AdminAccessController>();
    final AdminCategoryController categoryController =
    Get.find<AdminCategoryController>();

    return Scaffold(
      backgroundColor: MBColors.background,
      body: Row(
        children: [
          _SidebarProxy(
            currentRoute: AppRoutes.adminCategories,
            isSuperAdmin: accessController.isSuperAdmin,
          ),
          Expanded(
            child: Column(
              children: [
                _TopBarProxy(
                  title: 'Categories',
                  onAdd: accessController.canManageCategories
                      ? () {
                    Get.dialog(
                      const AdminCategoryFormDialog(),
                      barrierDismissible: false,
                    );
                  }
                      : null,
                ),
                Expanded(
                  child: Obx(() {
                    if (!accessController.canManageCategories) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        child: MBCard(
                          child: Text(
                            'You do not have permission to manage categories.',
                            style: MBTextStyles.body.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    if (categoryController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (categoryController.categories.isEmpty) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        child: MBCard(
                          child: Text(
                            'No categories found.',
                            style: MBTextStyles.body.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: categoryController.refreshCategories,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        itemCount: categoryController.categories.length,
                        itemBuilder: (context, index) {
                          final category = categoryController.categories[index];
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: MBSpacing.md),
                            child: _CategoryListCard(
                              category: category,
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryListCard extends StatelessWidget {
  final MBCategory category;

  const _CategoryListCard({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final AdminCategoryController controller =
    Get.find<AdminCategoryController>();

    return MBCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: MBColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
              image: category.imageUrl.trim().isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(category.imageUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: category.imageUrl.trim().isEmpty
                ? const Icon(
              Icons.category_outlined,
              color: MBColors.primaryOrange,
            )
                : null,
          ),
          MBSpacing.w(MBSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.nameEn,
                  style: MBTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (category.nameBn.trim().isNotEmpty) ...[
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    category.nameBn,
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                ],
                MBSpacing.h(MBSpacing.xxs),
                Text(
                  'Slug: ${category.slug.isEmpty ? '-' : category.slug}',
                  style: MBTextStyles.caption,
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  'Sort: ${category.sortOrder} • '
                      '${category.isActive ? 'Active' : 'Inactive'} • '
                      '${category.isFeatured ? 'Featured' : 'Not Featured'}',
                  style: MBTextStyles.caption,
                ),
              ],
            ),
          ),
          MBSpacing.w(MBSpacing.md),
          Column(
            children: [
              MBSecondaryButton(
                text: category.isActive ? 'Deactivate' : 'Activate',
                expand: false,
                height: 40,
                onPressed: () => controller.toggleCategoryActive(category),
              ),
              MBSpacing.h(MBSpacing.sm),
              MBSecondaryButton(
                text: 'Edit',
                expand: false,
                height: 40,
                onPressed: () {
                  Get.dialog(
                    AdminCategoryFormDialog(category: category),
                    barrierDismissible: false,
                  );
                },
              ),
              MBSpacing.h(MBSpacing.sm),
              MBSecondaryButton(
                text: 'Delete',
                expand: false,
                height: 40,
                foregroundColor: MBColors.error,
                borderColor: MBColors.error,
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Category'),
                      content: Text(
                        'Are you sure you want to delete "${category.nameEn}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await controller.deleteCategory(category.id);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarProxy extends StatelessWidget {
  final String currentRoute;
  final bool isSuperAdmin;

  const _SidebarProxy({
    required this.currentRoute,
    required this.isSuperAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: MBColors.primaryOrange,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MBSpacing.md),
          child: Column(
            children: [
              _ProxyTile(
                label: 'Dashboard',
                selected: currentRoute == AppRoutes.adminDashboard ||
                    currentRoute == AppRoutes.adminShell,
                onTap: () => Get.offNamed(AppRoutes.adminShell),
              ),
              _ProxyTile(
                label: 'Categories',
                selected: currentRoute == AppRoutes.adminCategories,
                onTap: () => Get.offNamed(AppRoutes.adminCategories),
              ),
              _ProxyTile(
                label: 'Admin Invites',
                selected: currentRoute == AppRoutes.adminInvites,
                onTap: () => Get.offNamed(AppRoutes.adminInvites),
              ),
              if (isSuperAdmin)
                _ProxyTile(
                  label: 'Admin Permissions',
                  selected: currentRoute == AppRoutes.adminPermissions,
                  onTap: () => Get.offNamed(AppRoutes.adminPermissions),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProxyTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ProxyTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedTileColor: Colors.white.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        label,
        style: MBTextStyles.body.copyWith(
          color: Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _TopBarProxy extends StatelessWidget {
  final String title;
  final VoidCallback? onAdd;

  const _TopBarProxy({
    required this.title,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: MBSpacing.xl),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: MBColors.border),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: MBTextStyles.pageTitle,
          ),
          const Spacer(),
          if (onAdd != null)
            SizedBox(
              width: 160,
              child: MBPrimaryButton(
                text: 'Add Category',
                height: 44,
                onPressed: onAdd,
              ),
            ),
        ],
      ),
    );
  }
}












