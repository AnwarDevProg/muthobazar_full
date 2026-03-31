import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

import '../controllers/admin_management_controller.dart';

class AdminDashboardPage extends GetView<AdminManagementController> {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DashboardPageHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth > 1400;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 1440 : 1160,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(MBSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                                () => _DashboardHeroCard(
                              greeting: controller.greetingLabel,
                              adminName: controller.adminName,
                              adminRole: controller.adminRole,
                              adminEmail: controller.adminEmail,
                              canAccessAdminPanel:
                              controller.canAccessAdminPanel,
                              isSuperAdmin: controller.isSuperAdmin,
                            ),
                          ),
                          MBSpacing.h(MBSpacing.xl),
                          const _SectionHeader(
                            title: 'Quick Overview',
                            subtitle:
                            'Important access and control information at a glance.',
                          ),
                          MBSpacing.h(MBSpacing.md),
                          _ResponsiveStatsGrid(controller: controller),
                          MBSpacing.h(MBSpacing.xl),
                          _ResponsiveMainGrid(controller: controller),
                          MBSpacing.h(MBSpacing.xl),
                          const _SectionHeader(
                            title: 'Recommended Next Actions',
                            subtitle:
                            'Suggested admin tasks based on your current access.',
                          ),
                          MBSpacing.h(MBSpacing.md),
                          _ResponsiveActionsGrid(controller: controller),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveStatsGrid extends StatelessWidget {
  const _ResponsiveStatsGrid({
    required this.controller,
  });

  final AdminManagementController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 4;

        if (constraints.maxWidth < 1100) columns = 2;
        if (constraints.maxWidth < 700) columns = 1;

        final double itemWidth =
            (constraints.maxWidth - ((columns - 1) * MBSpacing.md)) / columns;

        final items = <Widget>[
          Obx(
                () => _AdminStatCard(
              title: 'Admin Access',
              value: controller.canAccessAdminPanel ? 'Allowed' : 'Denied',
              icon: Icons.verified_user_outlined,
              accentColor: controller.canAccessAdminPanel
                  ? MBColors.success
                  : MBColors.error,
            ),
          ),
          Obx(
                () => _AdminStatCard(
              title: 'Role',
              value: controller.adminRole,
              icon: Icons.badge_outlined,
              accentColor: MBColors.primaryOrange,
            ),
          ),
          Obx(
                () => _AdminStatCard(
              title: 'Enabled Permissions',
              value: controller.enabledPermissionCount.toString(),
              icon: Icons.shield_outlined,
              accentColor: MBColors.primaryOrange,
            ),
          ),
          Obx(
                () => _AdminStatCard(
              title: 'Mode',
              value: controller.isSuperAdmin ? 'Super Admin' : 'Admin',
              icon: Icons.admin_panel_settings_outlined,
              accentColor:
              controller.isSuperAdmin ? MBColors.success : MBColors.textMuted,
            ),
          ),
        ];

        return Wrap(
          spacing: MBSpacing.md,
          runSpacing: MBSpacing.md,
          children: items
              .map(
                (item) => SizedBox(
              width: itemWidth,
              child: item,
            ),
          )
              .toList(),
        );
      },
    );
  }
}

class _ResponsiveMainGrid extends StatelessWidget {
  const _ResponsiveMainGrid({
    required this.controller,
  });

  final AdminManagementController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool stacked = constraints.maxWidth < 1000;

        if (stacked) {
          return Column(
            children: [
              _PermissionSummaryCard(controller: controller),
              MBSpacing.h(MBSpacing.lg),
              _AdminHighlightsCard(controller: controller),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _PermissionSummaryCard(controller: controller),
            ),
            MBSpacing.w(MBSpacing.lg),
            Expanded(
              flex: 2,
              child: _AdminHighlightsCard(controller: controller),
            ),
          ],
        );
      },
    );
  }
}

class _ResponsiveActionsGrid extends StatelessWidget {
  const _ResponsiveActionsGrid({
    required this.controller,
  });

  final AdminManagementController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 3;

        if (constraints.maxWidth < 1000) columns = 2;
        if (constraints.maxWidth < 600) columns = 1;

        final double itemWidth =
            (constraints.maxWidth - ((columns - 1) * MBSpacing.md)) / columns;

        final items = <Widget>[
          _ActionHintCard(
            icon: Icons.person_outline,
            title: 'Review Your Profile',
            subtitle:
            'Keep your personal info and profile picture updated for admin records.',
            onTap: () => Get.toNamed(AdminWebRoutes.profile),
          ),
          Obx(
                () => _ActionHintCard(
              icon: Icons.inventory_2_outlined,
              title: 'Manage Products',
              subtitle: controller.accessController.canManageProducts
                  ? 'Review, update, and organize product listings.'
                  : 'Product management is not enabled for this account.',
              onTap: controller.accessController.canManageProducts
                  ? () => Get.toNamed(AdminWebRoutes.products)
                  : null,
            ),
          ),
          Obx(
                () => _ActionHintCard(
              icon: Icons.category_outlined,
              title: 'Organize Catalog',
              subtitle: controller.accessController.canManageCategories ||
                  controller.accessController.canManageBrands
                  ? 'Maintain category and brand structure for a cleaner store.'
                  : 'Catalog organization permissions are currently restricted.',
              onTap: controller.accessController.canManageCategories
                  ? () => Get.toNamed(AdminWebRoutes.categories)
                  : null,
            ),
          ),
          Obx(
                () => _ActionHintCard(
              icon: Icons.campaign_outlined,
              title: 'Marketing Control',
              subtitle: controller.accessController.canManageBanners
                  ? 'Control banners, promos, and offers from one place.'
                  : 'Marketing permissions are not enabled for this account.',
              onTap: controller.accessController.canManageBanners
                  ? () => Get.toNamed(AdminWebRoutes.banners)
                  : null,
            ),
          ),
          Obx(
                () => _ActionHintCard(
              icon: Icons.people_alt_outlined,
              title: 'User Management',
              subtitle: controller.accessController.canManageUsers
                  ? 'Review customer and admin-accessible user accounts.'
                  : 'User management is not enabled for this account.',
              onTap: controller.accessController.canManageUsers
                  ? () => Get.toNamed(AdminWebRoutes.users)
                  : null,
            ),
          ),
          Obx(
                () => _ActionHintCard(
              icon: Icons.history_rounded,
              title: 'Audit Activity',
              subtitle: controller.accessController.canViewActivityLogs
                  ? 'Use activity logs to review changes and admin actions.'
                  : 'Activity log visibility is not enabled for this account.',
              onTap: controller.accessController.canViewActivityLogs
                  ? () => Get.toNamed(AdminWebRoutes.auditLogs)
                  : null,
            ),
          ),
        ];

        return Wrap(
          spacing: MBSpacing.md,
          runSpacing: MBSpacing.md,
          children: items
              .map(
                (item) => SizedBox(
              width: itemWidth,
              child: item,
            ),
          )
              .toList(),
        );
      },
    );
  }
}

class _DashboardHeroCard extends StatelessWidget {
  const _DashboardHeroCard({
    required this.greeting,
    required this.adminName,
    required this.adminRole,
    required this.adminEmail,
    required this.canAccessAdminPanel,
    required this.isSuperAdmin,
  });

  final String greeting;
  final String adminName;
  final String adminRole;
  final String adminEmail;
  final bool canAccessAdminPanel;
  final bool isSuperAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.xl),
      decoration: BoxDecoration(
        gradient: MBGradients.primaryGradient,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(MBRadius.lg),
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Colors.white,
              size: 34,
            ),
          ),
          MBSpacing.w(MBSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $adminName',
                  style: MBTextStyles.pageTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xs),
                Text(
                  canAccessAdminPanel
                      ? 'Your admin access is active and the workspace is ready.'
                      : 'Your admin access is currently restricted.',
                  style: MBTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                if (adminEmail.trim().isNotEmpty) ...[
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    adminEmail,
                    style: MBTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
                MBSpacing.h(MBSpacing.md),
                Wrap(
                  spacing: MBSpacing.sm,
                  runSpacing: MBSpacing.sm,
                  children: [
                    _HeroChip(label: 'Role: $adminRole'),
                    _HeroChip(
                      label: isSuperAdmin ? 'Super Admin' : 'Standard Admin',
                    ),
                    _HeroChip(
                      label: canAccessAdminPanel
                          ? 'Panel Access On'
                          : 'Panel Access Off',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.md,
        vertical: MBSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(MBRadius.pill),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: MBTextStyles.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MBTextStyles.sectionTitle.copyWith(
            fontWeight: FontWeight.w700,
            color: MBColors.textPrimary,
          ),
        ),
        MBSpacing.h(MBSpacing.xxxs),
        Text(
          subtitle,
          style: MBTextStyles.body.copyWith(
            color: MBColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return MBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(MBRadius.md),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 24,
            ),
          ),
          MBSpacing.h(MBSpacing.md),
          Text(
            title,
            style: MBTextStyles.caption.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
          MBSpacing.h(MBSpacing.xxs),
          Text(
            value,
            style: MBTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
              color: MBColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionSummaryCard extends StatelessWidget {
  const _PermissionSummaryCard({
    required this.controller,
  });

  final AdminManagementController controller;

  @override
  Widget build(BuildContext context) {
    return MBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permissions Summary',
            style: MBTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.sm),
          Text(
            'Detailed access rights currently enabled for this admin account.',
            style: MBTextStyles.body.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
          MBSpacing.h(MBSpacing.md),
          Obx(
                () => _PermissionRow(
              label: 'Access admin panel',
              enabled: controller.accessController.canAccessAdminPanel,
            ),
          ),
          Obx(
                () => _PermissionRow(
              label: 'Manage admins',
              enabled: controller.accessController.canManageAdmins,
            ),
          ),
          Obx(
                () => _PermissionRow(
              label: 'Manage admin invites',
              enabled: controller.accessController.canManageAdminInvites,
            ),
          ),
          Obx(
                () => _PermissionRow(
              label: 'Manage admin permissions',
              enabled: controller.accessController.canManageAdminPermissions,
            ),
          ),
          Obx(
                () => _PermissionRow(
              label: 'Manage users',
              enabled: controller.accessController.canManageUsers,
            ),
          ),
          Obx(
                () => _PermissionRow(
              label: 'Manage categories',
              enabled: controller.accessController.canManageCategories,
            ),
          ),
          Obx(
                () => _PermissionRow(
              label: 'Manage brands',
              enabled: controller.accessController.canManageBrands,
            ),
          ),
          Obx(
                () => _PermissionRow(
              label: 'Manage products',
              enabled: controller.accessController.canManageProducts,
            ),
          ),
          Obx(
                () => _PermissionRow(
              label: 'Manage banners',
              enabled: controller.accessController.canManageBanners,
            ),
          ),
          Obx(
                () => _PermissionRow(
              label: 'Delete products',
              enabled: controller.accessController.canDeleteProducts,
            ),
          ),
          Obx(
                () => _PermissionRow(
              label: 'Restore products',
              enabled: controller.accessController.canRestoreProducts,
            ),
          ),
          Obx(
                () => _PermissionRow(
              label: 'View activity logs',
              enabled: controller.accessController.canViewActivityLogs,
              isLast: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminHighlightsCard extends StatelessWidget {
  const _AdminHighlightsCard({
    required this.controller,
  });

  final AdminManagementController controller;

  @override
  Widget build(BuildContext context) {
    return MBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Highlights',
            style: MBTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.sm),
          Obx(
                () => _HighlightTile(
              title: 'Enabled Permissions',
              value: controller.enabledPermissionCount.toString(),
              icon: Icons.shield_outlined,
            ),
          ),
          MBSpacing.h(MBSpacing.sm),
          Obx(
                () => _HighlightTile(
              title: 'Role Type',
              value: controller.accessController.isSuperAdmin
                  ? 'Super Admin'
                  : 'Admin',
              icon: Icons.badge_outlined,
            ),
          ),
          MBSpacing.h(MBSpacing.sm),
          Obx(
                () => _HighlightTile(
              title: 'Catalog Control',
              value: controller.accessController.canManageProducts
                  ? 'Available'
                  : 'Restricted',
              icon: Icons.inventory_2_outlined,
            ),
          ),
          MBSpacing.h(MBSpacing.sm),
          Obx(
                () => _HighlightTile(
              title: 'Audit Visibility',
              value: controller.accessController.canViewActivityLogs
                  ? 'Enabled'
                  : 'Disabled',
              icon: Icons.history_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.md),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.90),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: MBColors.primaryOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(MBRadius.md),
            ),
            child: Icon(
              icon,
              color: MBColors.primaryOrange,
              size: 20,
            ),
          ),
          MBSpacing.w(MBSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MBTextStyles.caption.copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  value,
                  style: MBTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: MBColors.textPrimary,
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

class _ActionHintCard extends StatelessWidget {
  const _ActionHintCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MBRadius.lg),
      child: MBCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: MBColors.primaryOrange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(MBRadius.md),
              ),
              child: Icon(
                icon,
                color: MBColors.primaryOrange,
                size: 22,
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              title,
              style: MBTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: MBColors.textPrimary,
              ),
            ),
            MBSpacing.h(MBSpacing.xxs),
            Text(
              subtitle,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.label,
    required this.enabled,
    this.isLast = false,
  });

  final String label;
  final bool enabled;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: MBSpacing.md),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
          bottom: BorderSide(
            color: MBColors.border.withValues(alpha: 0.85),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textPrimary,
              ),
            ),
          ),
          Icon(
            enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: enabled ? MBColors.success : MBColors.error,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _DashboardPageHeader extends StatelessWidget {
  const _DashboardPageHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MBSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: MBColors.border),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Dashboard',
            style: MBTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            'Admin Panel / Dashboard',
            style: MBTextStyles.caption.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}