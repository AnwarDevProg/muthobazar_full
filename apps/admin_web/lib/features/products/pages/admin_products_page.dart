import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:admin_web/app/routes/admin_web_routes.dart';
import '../../../models/catalog/mb_product.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import '../controllers/admin_product_controller.dart';
import 'widgets/admin_product_form_dialog.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accessController = Get.find<AdminAccessController>();
    final productController = Get.find<AdminProductController>();
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: MBColors.background,
      body: Row(
        children: [
          _SidebarProxy(
            currentRoute: AppRoutes.adminProducts,
            isSuperAdmin: accessController.isSuperAdmin,
          ),
          Expanded(
            child: Column(
              children: [
                _TopBarProxy(
                  title: 'Products',
                  onAdd: accessController.canManageProducts
                      ? () {
                    Get.dialog(
                      const AdminProductFormDialog(),
                      barrierDismissible: false,
                    );
                  }
                      : null,
                  onOpenQuarantine: accessController.canRestoreProducts
                      ? () => Get.toNamed(AppRoutes.adminQuarantineProducts)
                      : null,
                ),
                Expanded(
                  child: Obx(() {
                    if (!accessController.canManageProducts) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        child: MBCard(
                          child: Text(
                            'You do not have permission to manage products.',
                            style: MBTextStyles.body.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    if (productController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (productController.products.isEmpty) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        child: MBCard(
                          child: Text(
                            'No products found.',
                            style: MBTextStyles.body.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: productController.refreshProducts,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        itemCount: productController.products.length,
                        itemBuilder: (context, index) {
                          final product = productController.products[index];
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: MBSpacing.md),
                            child: _ProductListCard(
                              product: product,
                              canDelete: accessController.canDeleteProducts,
                              onDelete: () async {
                                await productController.moveProductToQuarantine(
                                  product: product,
                                  deletedByUid: profileController.user.value.id,
                                  deletedByName: profileController.fullName,
                                );
                              },
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

class _ProductListCard extends StatelessWidget {
  final MBProduct product;
  final bool canDelete;
  final Future<void> Function() onDelete;

  const _ProductListCard({
    required this.product,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminProductController>();

    return MBCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: MBColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
              image: product.thumbnailUrl.trim().isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(product.thumbnailUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: product.thumbnailUrl.trim().isEmpty
                ? const Icon(
              Icons.inventory_2_outlined,
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
                  product.titleEn,
                  style: MBTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (product.titleBn.trim().isNotEmpty) ...[
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    product.titleBn,
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                ],
                MBSpacing.h(MBSpacing.xxs),
                Text(
                  'Price: ${product.price}  • Stock: ${product.stockQty}',
                  style: MBTextStyles.caption,
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  'Type: ${product.productType} • '
                      '${product.isEnabled ? 'Enabled' : 'Disabled'} • '
                      'Attr: ${product.attributes.length} • '
                      'Var: ${product.variations.length} • '
                      'Options: ${product.purchaseOptions.length}',
                  style: MBTextStyles.caption,
                ),
              ],
            ),
          ),
          MBSpacing.w(MBSpacing.md),
          Column(
            children: [
              MBSecondaryButton(
                text: product.isEnabled ? 'Disable' : 'Enable',
                expand: false,
                height: 40,
                onPressed: () => controller.toggleProductEnabled(product),
              ),
              MBSpacing.h(MBSpacing.sm),
              MBSecondaryButton(
                text: 'Edit',
                expand: false,
                height: 40,
                onPressed: () {
                  Get.dialog(
                    AdminProductFormDialog(product: product),
                    barrierDismissible: false,
                  );
                },
              ),
              if (canDelete) ...[
                MBSpacing.h(MBSpacing.sm),
                MBSecondaryButton(
                  text: 'Quarantine',
                  expand: false,
                  height: 40,
                  foregroundColor: MBColors.error,
                  borderColor: MBColors.error,
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Move To Quarantine'),
                        content: Text(
                          'Move "${product.titleEn}" to quarantine?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Move'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await onDelete();
                    }
                  },
                ),
              ],
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
                label: 'Brands',
                selected: currentRoute == AppRoutes.adminBrands,
                onTap: () => Get.offNamed(AppRoutes.adminBrands),
              ),
              _ProxyTile(
                label: 'Banners',
                selected: currentRoute == AppRoutes.adminBanners,
                onTap: () => Get.offNamed(AppRoutes.adminBanners),
              ),
              _ProxyTile(
                label: 'Products',
                selected: currentRoute == AppRoutes.adminProducts,
                onTap: () => Get.offNamed(AppRoutes.adminProducts),
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
  final VoidCallback? onOpenQuarantine;

  const _TopBarProxy({
    required this.title,
    this.onAdd,
    this.onOpenQuarantine,
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
          if (onOpenQuarantine != null)
            SizedBox(
              width: 180,
              child: MBSecondaryButton(
                text: 'Quarantine',
                height: 44,
                onPressed: onOpenQuarantine,
              ),
            ),
          if (onOpenQuarantine != null) MBSpacing.w(MBSpacing.md),
          if (onAdd != null)
            SizedBox(
              width: 170,
              child: MBPrimaryButton(
                text: 'Add Product',
                height: 44,
                onPressed: onAdd,
              ),
            ),
        ],
      ),
    );
  }
}












