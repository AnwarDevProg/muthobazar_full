import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAccessController adminController =
        Get.find<AdminAccessController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(MBSpacing.xl),
      child: Obx(() {
        final permission = adminController.permission.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardHeroCard(
              adminRole: permission?.role ?? '-',
              canAccessAdminPanel: adminController.canAccessAdminPanel,
              isSuperAdmin: adminController.isSuperAdmin,
            ),
            MBSpacing.h(MBSpacing.xl),
            _SectionHeader(
              title: 'Quick Overview',
              subtitle: 'Important access and control information at a glance.',
            ),
            MBSpacing.h(MBSpacing.md),
            Wrap(
              spacing: MBSpacing.md,
              runSpacing: MBSpacing.md,
              children: [
                _AdminStatCard(
                  title: 'Admin Access',
                  value: adminController.canAccessAdminPanel ? 'Allowed' : 'Denied',
                  icon: Icons.verified_user_outlined,
                  accentColor: adminController.canAccessAdminPanel
                      ? MBColors.success
                      : MBColors.error,
                ),
                _AdminStatCard(
                  title: 'Role',
                  value: permission?.role ?? '-',
                  icon: Icons.badge_outlined,
                  accentColor: MBColors.primaryOrange,
                ),
                _AdminStatCard(
                  title: 'Manage Admins',
                  value: adminController.canManageAdmins ? 'Yes' : 'No',
                  icon: Icons.manage_accounts_outlined,
                  accentColor: adminController.canManageAdmins
                      ? MBColors.success
                      : MBColors.textMuted,
                ),
                _AdminStatCard(
                  title: 'Manage Users',
                  value: adminController.canManageUsers ? 'Yes' : 'No',
                  icon: Icons.people_alt_outlined,
                  accentColor: adminController.canManageUsers
                      ? MBColors.success
                      : MBColors.textMuted,
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _PermissionSummaryCard(
                    adminController: adminController,
                  ),
                ),
                MBSpacing.w(MBSpacing.lg),
                Expanded(
                  flex: 2,
                  child: _AdminHighlightsCard(
                    adminController: adminController,
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.xl),
            _SectionHeader(
              title: 'Recommended Next Actions',
              subtitle: 'Suggested admin tasks based on current access.',
            ),
            MBSpacing.h(MBSpacing.md),
            Wrap(
              spacing: MBSpacing.md,
              runSpacing: MBSpacing.md,
              children: [
                _ActionHintCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Manage Products',
                  subtitle: adminController.canManageProducts
                      ? 'You can review, update, and organize product listings.'
                      : 'Product management is not enabled for this account.',
                ),
                _ActionHintCard(
                  icon: Icons.category_outlined,
                  title: 'Organize Catalog',
                  subtitle: adminController.canManageCategories ||
                          adminController.canManageBrands
                      ? 'Maintain category and brand structure for a cleaner store.'
                      : 'Catalog organization permissions are currently restricted.',
                ),
                _ActionHintCard(
                  icon: Icons.history_rounded,
                  title: 'Audit Activity',
                  subtitle: adminController.canViewActivityLogs
                      ? 'Use activity logs to review changes and admin actions.'
                      : 'Activity log visibility is not enabled for this account.',
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _DashboardHeroCard extends StatelessWidget {
  final String adminRole;
  final bool canAccessAdminPanel;
  final bool isSuperAdmin;

  const _DashboardHeroCard({
    required this.adminRole,
    required this.canAccessAdminPanel,
    required this.isSuperAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF8A00),
            Color(0xFFFF6A00),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                  'Admin Control Center',
                  style: MBTextStyles.pageTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xs),
                Text(
                  canAccessAdminPanel
                      ? 'Your admin access is active and ready to use.'
                      : 'Your admin access is currently restricted.',
                  style: MBTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                MBSpacing.h(MBSpacing.md),
                Wrap(
                  spacing: MBSpacing.sm,
                  runSpacing: MBSpacing.sm,
                  children: [
                    _HeroChip(
                      label: 'Role: ',
                    ),
                    _HeroChip(
                      label: isSuperAdmin ? 'Super Admin' : 'Standard Admin',
                    ),
                    _HeroChip(
                      label: canAccessAdminPanel ? 'Panel Access On' : 'Panel Access Off',
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
  final String label;

  const _HeroChip({
    required this.label,
  });

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
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

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
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: MBCard(
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
      ),
    );
  }
}

class _PermissionSummaryCard extends StatelessWidget {
  final AdminAccessController adminController;

  const _PermissionSummaryCard({
    required this.adminController,
  });

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
          _PermissionRow(
            label: 'Access admin panel',
            enabled: adminController.canAccessAdminPanel,
          ),
          _PermissionRow(
            label: 'Manage admins',
            enabled: adminController.canManageAdmins,
          ),
          _PermissionRow(
            label: 'Manage admin invites',
            enabled: adminController.canManageAdminInvites,
          ),
          _PermissionRow(
            label: 'Manage admin permissions',
            enabled: adminController.canManageAdminPermissions,
          ),
          _PermissionRow(
            label: 'Manage users',
            enabled: adminController.canManageUsers,
          ),
          _PermissionRow(
            label: 'Manage categories',
            enabled: adminController.canManageCategories,
          ),
          _PermissionRow(
            label: 'Manage brands',
            enabled: adminController.canManageBrands,
          ),
          _PermissionRow(
            label: 'Manage products',
            enabled: adminController.canManageProducts,
          ),
          _PermissionRow(
            label: 'Manage banners',
            enabled: adminController.canManageBanners,
          ),
          _PermissionRow(
            label: 'Delete products',
            enabled: adminController.canDeleteProducts,
          ),
          _PermissionRow(
            label: 'Restore products',
            enabled: adminController.canRestoreProducts,
          ),
          _PermissionRow(
            label: 'View activity logs',
            enabled: adminController.canViewActivityLogs,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _AdminHighlightsCard extends StatelessWidget {
  final AdminAccessController adminController;

  const _AdminHighlightsCard({
    required this.adminController,
  });

  @override
  Widget build(BuildContext context) {
    final int enabledCount = [
      adminController.canAccessAdminPanel,
      adminController.canManageAdmins,
      adminController.canManageAdminInvites,
      adminController.canManageAdminPermissions,
      adminController.canManageUsers,
      adminController.canManageCategories,
      adminController.canManageBrands,
      adminController.canManageProducts,
      adminController.canManageBanners,
      adminController.canDeleteProducts,
      adminController.canRestoreProducts,
      adminController.canViewActivityLogs,
    ].where((e) => e).length;

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
          _HighlightTile(
            title: 'Enabled Permissions',
            value: '',
            icon: Icons.shield_outlined,
          ),
          MBSpacing.h(MBSpacing.sm),
          _HighlightTile(
            title: 'Role Type',
            value: adminController.isSuperAdmin ? 'Super Admin' : 'Admin',
            icon: Icons.badge_outlined,
          ),
          MBSpacing.h(MBSpacing.sm),
          _HighlightTile(
            title: 'Catalog Control',
            value: adminController.canManageProducts ? 'Available' : 'Restricted',
            icon: Icons.inventory_2_outlined,
          ),
          MBSpacing.h(MBSpacing.sm),
          _HighlightTile(
            title: 'Audit Visibility',
            value: adminController.canViewActivityLogs ? 'Enabled' : 'Disabled',
            icon: Icons.history_rounded,
          ),
        ],
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _HighlightTile({
    required this.title,
    required this.value,
    required this.icon,
  });

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
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActionHintCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
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
  final String label;
  final bool enabled;
  final bool isLast;

  const _PermissionRow({
    required this.label,
    required this.enabled,
    this.isLast = false,
  });

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

