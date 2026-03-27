import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import '../controllers/admin_product_controller.dart';

class AdminQuarantineProductsPage extends StatelessWidget {
  const AdminQuarantineProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accessController = Get.find<AdminAccessController>();
    final productController = Get.find<AdminProductController>();

    return Scaffold(
      backgroundColor: MBColors.background,
      body: Row(
        children: [
          _SidebarProxy(
            currentRoute: AppRoutes.adminQuarantineProducts,
            isSuperAdmin: accessController.isSuperAdmin,
          ),
          Expanded(
            child: Column(
              children: [
                const _TopBarProxy(title: 'Quarantine Products'),
                Expanded(
                  child: Obx(() {
                    if (!accessController.canRestoreProducts) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        child: MBCard(
                          child: Text(
                            'You do not have permission to restore products.',
                            style: MBTextStyles.body.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    if (productController.isQuarantineLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (productController.quarantineProducts.isEmpty) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        child: MBCard(
                          child: Text(
                            'No quarantine products found.',
                            style: MBTextStyles.body.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(MBSpacing.xl),
                      itemCount: productController.quarantineProducts.length,
                      itemBuilder: (context, index) {
                        final item = productController.quarantineProducts[index];
                        final productData = Map<String, dynamic>.from(
                          item['productData'] as Map<String, dynamic>? ?? const {},
                        );

                        final title =
                        (productData['titleEn'] ?? 'Untitled Product').toString();
                        final deletedAt = (item['deletedAt'] ?? '').toString();
                        final deleteAfterAt = (item['deleteAfterAt'] ?? '').toString();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: MBSpacing.md),
                          child: MBCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: MBTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      MBSpacing.h(MBSpacing.xxxs),
                                      Text(
                                        'Deleted At: $deletedAt',
                                        style: MBTextStyles.caption,
                                      ),
                                      MBSpacing.h(MBSpacing.xxxs),
                                      Text(
                                        'Auto Delete After: $deleteAfterAt',
                                        style: MBTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                MBSecondaryButton(
                                  text: 'Restore',
                                  expand: false,
                                  height: 40,
                                  onPressed: () async {
                                    await productController
                                        .restoreProduct(item['id'].toString());
                                  },
                                ),
                                MBSpacing.w(MBSpacing.sm),
                                MBSecondaryButton(
                                  text: 'Delete Permanently',
                                  expand: false,
                                  height: 40,
                                  foregroundColor: MBColors.error,
                                  borderColor: MBColors.error,
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Delete Permanently'),
                                        content: Text(
                                          'Delete "$title" permanently from quarantine?',
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
                                      await productController
                                          .hardDeleteQuarantineProduct(
                                        item['id'].toString(),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
                label: 'Products',
                selected: currentRoute == AppRoutes.adminProducts,
                onTap: () => Get.offNamed(AppRoutes.adminProducts),
              ),
              _ProxyTile(
                label: 'Quarantine',
                selected: currentRoute == AppRoutes.adminQuarantineProducts,
                onTap: () => Get.offNamed(AppRoutes.adminQuarantineProducts),
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

  const _TopBarProxy({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: MBSpacing.xl),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: MBColors.border),
        ),
      ),
      child: Text(
        title,
        style: MBTextStyles.pageTitle,
      ),
    );
  }
}












