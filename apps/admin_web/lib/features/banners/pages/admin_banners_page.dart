import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:admin_web/app/routes/admin_web_routes.dart';
import '../../../models/home/mb_banner.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import '../controllers/admin_banner_controller.dart';
import 'widgets/admin_banner_form_dialog.dart';

class AdminBannersPage extends StatelessWidget {
  const AdminBannersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAccessController accessController =
    Get.find<AdminAccessController>();
    final AdminBannerController bannerController =
    Get.find<AdminBannerController>();

    return Scaffold(
      backgroundColor: MBColors.background,
      body: Row(
        children: [
          _SidebarProxy(
            currentRoute: AppRoutes.adminBanners,
            isSuperAdmin: accessController.isSuperAdmin,
          ),
          Expanded(
            child: Column(
              children: [
                _TopBarProxy(
                  title: 'Banners',
                  onAdd: accessController.canManageBanners
                      ? () {
                    Get.dialog(
                      const AdminBannerFormDialog(),
                      barrierDismissible: false,
                    );
                  }
                      : null,
                ),
                Expanded(
                  child: Obx(() {
                    if (!accessController.canManageBanners) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        child: MBCard(
                          child: Text(
                            'You do not have permission to manage banners.',
                            style: MBTextStyles.body.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    if (bannerController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (bannerController.banners.isEmpty) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        child: MBCard(
                          child: Text(
                            'No banners found.',
                            style: MBTextStyles.body.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: bannerController.refreshBanners,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        itemCount: bannerController.banners.length,
                        itemBuilder: (context, index) {
                          final banner = bannerController.banners[index];
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: MBSpacing.md),
                            child: _BannerListCard(
                              banner: banner,
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

class _BannerListCard extends StatelessWidget {
  final MBBanner banner;

  const _BannerListCard({
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    final AdminBannerController controller = Get.find<AdminBannerController>();

    return MBCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            height: 80,
            decoration: BoxDecoration(
              color: MBColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
              image: banner.imageUrl.trim().isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(banner.imageUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: banner.imageUrl.trim().isEmpty
                ? const Icon(
              Icons.image_outlined,
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
                  banner.titleEn.isEmpty ? 'Untitled Banner' : banner.titleEn,
                  style: MBTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (banner.titleBn.trim().isNotEmpty) ...[
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    banner.titleBn,
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                ],
                MBSpacing.h(MBSpacing.xxs),
                Text(
                  'Target: ${banner.targetType}'
                      '${banner.targetId != null && banner.targetId!.isNotEmpty ? ' • ${banner.targetId}' : ''}',
                  style: MBTextStyles.caption,
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  'Sort: ${banner.sortOrder} • ${banner.isActive ? 'Active' : 'Inactive'}',
                  style: MBTextStyles.caption,
                ),
              ],
            ),
          ),
          MBSpacing.w(MBSpacing.md),
          Column(
            children: [
              MBSecondaryButton(
                text: banner.isActive ? 'Deactivate' : 'Activate',
                expand: false,
                height: 40,
                onPressed: () => controller.toggleBannerActive(banner),
              ),
              MBSpacing.h(MBSpacing.sm),
              MBSecondaryButton(
                text: 'Edit',
                expand: false,
                height: 40,
                onPressed: () {
                  Get.dialog(
                    AdminBannerFormDialog(banner: banner),
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
                      title: const Text('Delete Banner'),
                      content: Text(
                        'Are you sure you want to delete "${banner.titleEn.isEmpty ? 'this banner' : banner.titleEn}"?',
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
                    await controller.deleteBanner(banner.id);
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
                text: 'Add Banner',
                height: 44,
                onPressed: onAdd,
              ),
            ),
        ],
      ),
    );
  }
}












