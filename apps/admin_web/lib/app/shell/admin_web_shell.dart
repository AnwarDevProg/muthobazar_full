import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:admin_web/features/admin_access/pages/admin_permissions_page.dart';
import 'package:admin_web/features/audit_logs/pages/admin_activity_logs_page.dart';
import 'package:admin_web/features/banners/pages/admin_banners_page.dart';
import 'package:admin_web/features/brands/pages/admin_brands_page.dart';
import 'package:admin_web/features/categories/pages/admin_categories_page.dart';
import 'package:admin_web/features/dashboard/pages/admin_dashboard_page.dart';
import 'package:admin_web/features/invites/pages/admin_invites_page.dart';
import 'package:admin_web/features/products/pages/admin_products_page.dart';
import 'package:admin_web/features/products/pages/admin_quarantine_products_page.dart';
import 'package:admin_web/features/users/pages/admin_users_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminWebShell extends StatelessWidget {
  const AdminWebShell({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAccessController adminController =
        Get.isRegistered<AdminAccessController>()
            ? Get.find<AdminAccessController>()
            : Get.put(AdminAccessController());

    return Scaffold(
      backgroundColor: MBColors.background,
      body: Obx(() {
        if (adminController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!adminController.canAccessAdminPanel) {
          return const _AdminNoAccessView();
        }

        final String currentSection =
            adminController.permission.value?.role ?? 'dashboard';

        return Row(
          children: [
            _AdminSidebar(
              currentSection: currentSection,
            ),
            const Expanded(
              child: _AdminShellContent(),
            ),
          ],
        );
      }),
    );
  }
}

class _AdminShellContent extends StatelessWidget {
  const _AdminShellContent();

  @override
  Widget build(BuildContext context) {
    return const AdminDashboardPage();
  }
}

class _AdminSidebar extends StatelessWidget {
  final String currentSection;

  const _AdminSidebar({
    required this.currentSection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        gradient: MBGradients.primaryGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MBSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AdminBrandBlock(),
              MBSpacing.h(MBSpacing.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      _SidebarStaticLabel(label: 'Overview'),
                      SizedBox(height: MBSpacing.sm),
                      _SidebarStaticTile(
                        label: 'Dashboard',
                        icon: Icons.dashboard_outlined,
                      ),
                      SizedBox(height: MBSpacing.md),
                      _SidebarStaticLabel(label: 'Management'),
                      SizedBox(height: MBSpacing.sm),
                      _SidebarStaticTile(
                        label: 'Admin Invites',
                        icon: Icons.mail_outline_rounded,
                      ),
                      _SidebarStaticTile(
                        label: 'Categories',
                        icon: Icons.category_outlined,
                      ),
                      _SidebarStaticTile(
                        label: 'Brands',
                        icon: Icons.store_outlined,
                      ),
                      _SidebarStaticTile(
                        label: 'Banners',
                        icon: Icons.image_outlined,
                      ),
                      _SidebarStaticTile(
                        label: 'Products',
                        icon: Icons.inventory_2_outlined,
                      ),
                      _SidebarStaticTile(
                        label: 'Quarantine Products',
                        icon: Icons.inventory_outlined,
                      ),
                      _SidebarStaticTile(
                        label: 'Users',
                        icon: Icons.people_alt_outlined,
                      ),
                      _SidebarStaticTile(
                        label: 'Activity Logs',
                        icon: Icons.history_rounded,
                      ),
                      SizedBox(height: MBSpacing.md),
                      _SidebarStaticLabel(label: 'Super Admin'),
                      SizedBox(height: MBSpacing.sm),
                      _SidebarStaticTile(
                        label: 'Admin Permissions',
                        icon: Icons.admin_panel_settings_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminBrandBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(MBRadius.xl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(MBRadius.lg),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          MBSpacing.w(MBSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MuthoBazar Admin',
                  style: MBTextStyles.sectionTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  'Web Control Panel',
                  style: MBTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.90),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarStaticLabel extends StatelessWidget {
  final String label;

  const _SidebarStaticLabel({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: MBSpacing.xs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: MBTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.70),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
      ),
    );
  }
}

class _SidebarStaticTile extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SidebarStaticTile({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MBSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MBSpacing.md,
            vertical: MBSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              MBSpacing.w(MBSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: MBTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminNoAccessView extends StatelessWidget {
  const _AdminNoAccessView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(MBSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: MBColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 42,
              color: MBColors.primaryOrange,
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              'No admin access',
              style: MBTextStyles.sectionTitle,
            ),
            MBSpacing.h(MBSpacing.xs),
            Text(
              'Your account does not have permission to access the admin dashboard.',
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







