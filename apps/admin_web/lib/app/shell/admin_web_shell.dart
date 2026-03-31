import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/services/admin_web_session_service.dart';
import 'package:admin_web/app/shell/admin_shell_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminWebShell extends GetView<AdminShellStateController> {
  const AdminWebShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    controller.setRouteFromNavigation(Get.currentRoute);

    return Scaffold(
      backgroundColor: MBColors.background,
      body: SafeArea(
        child: Row(
          children: [
            const _AdminSidebar(),
            Expanded(
              child: Column(
                children: [
                  const _AdminTopBar(),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(
                        MBSpacing.lg,
                        0,
                        MBSpacing.lg,
                        MBSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(MBRadius.xl),
                        boxShadow: [
                          BoxShadow(
                            color: MBColors.shadow.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSidebar extends GetView<AdminShellStateController> {
  const _AdminSidebar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool collapsed = controller.isSidebarCollapsed.value;
      final double width = collapsed ? 96 : 280;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: width,
        margin: const EdgeInsets.all(MBSpacing.lg),
        decoration: BoxDecoration(
          gradient: MBGradients.primaryGradient,
          borderRadius: BorderRadius.circular(MBRadius.xl),
          boxShadow: [
            BoxShadow(
              color: MBColors.primaryOrange.withValues(alpha: 0.18),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(MBSpacing.lg),
              child: _SidebarBrand(collapsed: collapsed),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: MBSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SidebarSectionLabel(
                      label: 'Overview',
                      collapsed: collapsed,
                    ),
                    MBSpacing.h(MBSpacing.sm),
                    _SidebarItem(
                      label: 'Dashboard',
                      icon: Icons.dashboard_outlined,
                      route: AdminWebRoutes.dashboard,
                      collapsed: collapsed,
                    ),
                    MBSpacing.h(MBSpacing.md),
                    _SidebarSectionLabel(
                      label: 'Catalog',
                      collapsed: collapsed,
                    ),
                    MBSpacing.h(MBSpacing.sm),
                    _SidebarItem(
                      label: 'Categories',
                      icon: Icons.category_outlined,
                      route: AdminWebRoutes.categories,
                      collapsed: collapsed,
                    ),
                    _SidebarItem(
                      label: 'Brands',
                      icon: Icons.store_outlined,
                      route: AdminWebRoutes.brands,
                      collapsed: collapsed,
                    ),
                    _SidebarItem(
                      label: 'Banners',
                      icon: Icons.image_outlined,
                      route: AdminWebRoutes.banners,
                      collapsed: collapsed,
                    ),
                    _SidebarExpandableGroup(
                      label: 'Products',
                      icon: Icons.inventory_2_outlined,
                      collapsed: collapsed,
                      isGroupActive: controller.isProductsSectionActive(),
                      onMainTap: () =>
                          controller.setRoute(AdminWebRoutes.products),
                      children: const [
                        _SidebarSubItemConfig(
                          label: 'All Products',
                          route: AdminWebRoutes.products,
                        ),
                        _SidebarSubItemConfig(
                          label: 'Quarantine',
                          route: AdminWebRoutes.quarantineProducts,
                        ),
                      ],
                    ),
                    MBSpacing.h(MBSpacing.md),
                    _SidebarSectionLabel(
                      label: 'Marketing',
                      collapsed: collapsed,
                    ),
                    MBSpacing.h(MBSpacing.sm),
                    _SidebarItem(
                      label: 'Offers',
                      icon: Icons.local_offer_outlined,
                      route: AdminWebRoutes.offers,
                      collapsed: collapsed,
                    ),
                    _SidebarItem(
                      label: 'Coupons',
                      icon: Icons.confirmation_number_outlined,
                      route: AdminWebRoutes.promos,
                      collapsed: collapsed,
                    ),
                    MBSpacing.h(MBSpacing.md),
                    _SidebarSectionLabel(
                      label: 'Administration',
                      collapsed: collapsed,
                    ),
                    MBSpacing.h(MBSpacing.sm),
                    _SidebarItem(
                      label: 'Users',
                      icon: Icons.people_alt_outlined,
                      route: AdminWebRoutes.users,
                      collapsed: collapsed,
                    ),
                    _SidebarItem(
                      label: 'Admin Access',
                      icon: Icons.admin_panel_settings_outlined,
                      route: AdminWebRoutes.adminAccess,
                      collapsed: collapsed,
                    ),
                    _SidebarItem(
                      label: 'Invites',
                      icon: Icons.mail_outline_rounded,
                      route: AdminWebRoutes.invites,
                      collapsed: collapsed,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(MBSpacing.md),
              child: _SidebarBottomBar(collapsed: collapsed),
            ),
          ],
        ),
      );
    });
  }
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand({
    required this.collapsed,
  });

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: collapsed
          ? const Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          color: Colors.white,
          size: 28,
        ),
      )
          : Row(
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
                  'MuthoBazar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MBTextStyles.sectionTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  'Admin Web',
                  style: MBTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
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

class _SidebarSectionLabel extends StatelessWidget {
  const _SidebarSectionLabel({
    required this.label,
    required this.collapsed,
  });

  final String label;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: MBSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: MBTextStyles.caption.copyWith(
          color: Colors.white.withValues(alpha: 0.72),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SidebarItem extends GetView<AdminShellStateController> {
  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.collapsed,
  });

  final String label;
  final IconData icon;
  final String route;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isActive = controller.isActive(route);

      return Padding(
        padding: const EdgeInsets.only(bottom: MBSpacing.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => controller.setRoute(route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? MBSpacing.sm : MBSpacing.md,
              vertical: MBSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.20)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: isActive
                  ? Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              )
                  : null,
            ),
            child: collapsed
                ? Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            )
                : Row(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MBTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _SidebarExpandableGroup extends GetView<AdminShellStateController> {
  const _SidebarExpandableGroup({
    required this.label,
    required this.icon,
    required this.collapsed,
    required this.isGroupActive,
    required this.onMainTap,
    required this.children,
  });

  final String label;
  final IconData icon;
  final bool collapsed;
  final bool isGroupActive;
  final VoidCallback onMainTap;
  final List<_SidebarSubItemConfig> children;

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: MBSpacing.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onMainTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MBSpacing.sm,
              vertical: MBSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isGroupActive
                  ? Colors.white.withValues(alpha: 0.20)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    final bool expanded = isGroupActive;

    return Container(
      margin: const EdgeInsets.only(bottom: MBSpacing.sm),
      decoration: BoxDecoration(
        color: isGroupActive
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onMainTap,
            child: Container(
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
                        fontWeight: isGroupActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MBSpacing.md,
                0,
                MBSpacing.md,
                MBSpacing.sm,
              ),
              child: Column(
                children: children
                    .map(
                      (item) => _SidebarSubItem(
                    label: item.label,
                    route: item.route,
                  ),
                )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarSubItemConfig {
  const _SidebarSubItemConfig({
    required this.label,
    required this.route,
  });

  final String label;
  final String route;
}

class _SidebarSubItem extends GetView<AdminShellStateController> {
  const _SidebarSubItem({
    required this.label,
    required this.route,
  });

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isActive = controller.isActive(route);

      return Padding(
        padding: const EdgeInsets.only(top: MBSpacing.xs),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => controller.setRoute(route),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: MBSpacing.md,
              vertical: MBSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: isActive ? 1 : 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
                MBSpacing.w(MBSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: MBTextStyles.body.copyWith(
                      color: Colors.white,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _SidebarBottomBar extends GetView<AdminShellStateController> {
  const _SidebarBottomBar({
    required this.collapsed,
  });

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: controller.toggleSidebar,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: MBSpacing.md,
              vertical: MBSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: collapsed
                ? const Icon(
              Icons.keyboard_double_arrow_right_rounded,
              color: Colors.white,
              size: 20,
            )
                : Row(
              children: [
                const Icon(
                  Icons.keyboard_double_arrow_left_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                MBSpacing.w(MBSpacing.sm),
                Expanded(
                  child: Text(
                    'Collapse Sidebar',
                    style: MBTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminTopBar extends GetView<AdminShellStateController> {
  const _AdminTopBar();

  @override
  Widget build(BuildContext context) {
    final AdminWebSessionService sessionService =
    Get.find<AdminWebSessionService>();

    return Container(
      height: 92,
      margin: const EdgeInsets.fromLTRB(
        MBSpacing.lg,
        MBSpacing.lg,
        MBSpacing.lg,
        MBSpacing.lg,
      ),
      padding: const EdgeInsets.symmetric(horizontal: MBSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.pageTitle,
                    style: MBTextStyles.pageTitle.copyWith(
                      color: MBColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    'Manage your store operations with a desktop-first control panel.',
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(
            width: 280,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: MBSpacing.md),
              decoration: BoxDecoration(
                color: MBColors.background,
                borderRadius: BorderRadius.circular(MBRadius.pill),
                border: Border.all(
                  color: MBColors.border.withValues(alpha: 0.9),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: MBColors.textMuted,
                  ),
                  MBSpacing.w(MBSpacing.sm),
                  Expanded(
                    child: Text(
                      'Search modules, products, users...',
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          MBSpacing.w(MBSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MBSpacing.md,
              vertical: MBSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: MBColors.background,
              borderRadius: BorderRadius.circular(MBRadius.pill),
              border: Border.all(
                color: MBColors.border.withValues(alpha: 0.9),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    gradient: MBGradients.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                MBSpacing.w(MBSpacing.sm),
                FutureBuilder<Map<String, dynamic>?>(
                  future: sessionService.getCurrentAdminProfile(),
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    final displayName =
                    (data?['displayName'] ?? data?['name'] ?? 'Admin')
                        .toString();
                    final role =
                    (data?['role'] ?? 'admin').toString().replaceAll('_', ' ');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName,
                          style: MBTextStyles.bodyMedium.copyWith(
                            color: MBColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          role,
                          style: MBTextStyles.caption.copyWith(
                            color: MBColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                MBSpacing.w(MBSpacing.md),
                InkWell(
                  borderRadius: BorderRadius.circular(MBRadius.pill),
                  onTap: () async {
                    await sessionService.signOut();
                    Get.offAllNamed(AdminWebRoutes.login);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MBSpacing.md,
                      vertical: MBSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: MBGradients.primaryGradient,
                      borderRadius: BorderRadius.circular(MBRadius.pill),
                    ),
                    child: Text(
                      'Logout',
                      style: MBTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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