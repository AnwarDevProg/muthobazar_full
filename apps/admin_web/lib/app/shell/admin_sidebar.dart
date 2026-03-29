import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../features/admin_access/controllers/admin_access_controller.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAccessController accessController =
    Get.find<AdminAccessController>();

    final String currentRoute = Get.currentRoute;

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: MBColors.border),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(MBSpacing.lg),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: MBColors.border),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: MBGradients.primaryGradient,
                      borderRadius: BorderRadius.circular(MBRadius.lg),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: Colors.white,
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MuthoBazar',
                          style: MBTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Admin Workspace',
                          style: MBTextStyles.caption.copyWith(
                            color: MBColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(MBSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SidebarSectionLabel('Main'),
                    _AdminSidebarItem(
                      title: 'Dashboard',
                      icon: Icons.dashboard_outlined,
                      route: AdminWebRoutes.dashboard,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Profile',
                      icon: Icons.person_outline,
                      route: AdminWebRoutes.profile,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Users',
                      icon: Icons.people_alt_outlined,
                      route: AdminWebRoutes.users,
                      currentRoute: currentRoute,
                    ),

                    MBSpacing.h(MBSpacing.md),
                    const _SidebarSectionLabel('Catalog'),
                    _AdminSidebarItem(
                      title: 'Categories',
                      icon: Icons.category_outlined,
                      route: AdminWebRoutes.categories,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Brands',
                      icon: Icons.sell_outlined,
                      route: AdminWebRoutes.brands,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Products',
                      icon: Icons.inventory_2_outlined,
                      route: AdminWebRoutes.products,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Quarantine Products',
                      icon: Icons.restore_from_trash_outlined,
                      route: AdminWebRoutes.quarantineProducts,
                      currentRoute: currentRoute,
                    ),

                    MBSpacing.h(MBSpacing.md),
                    const _SidebarSectionLabel('Marketing'),
                    _AdminSidebarItem(
                      title: 'Banners',
                      icon: Icons.image_outlined,
                      route: AdminWebRoutes.banners,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Promos / Coupons',
                      icon: Icons.local_offer_outlined,
                      route: AdminWebRoutes.promos,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Offers',
                      icon: Icons.campaign_outlined,
                      route: AdminWebRoutes.offers,
                      currentRoute: currentRoute,
                    ),

                    MBSpacing.h(MBSpacing.md),
                    const _SidebarSectionLabel('Admin'),
                    if (accessController.canViewActivityLogs)
                      _AdminSidebarItem(
                        title: 'Audit Logs',
                        icon: Icons.history_rounded,
                        route: AdminWebRoutes.auditLogs,
                        currentRoute: currentRoute,
                      ),
                    if (accessController.canManageAdminInvites)
                      _AdminSidebarItem(
                        title: 'Admin Invites',
                        icon: Icons.mail_outline_rounded,
                        route: AdminWebRoutes.invites,
                        currentRoute: currentRoute,
                      ),
                    if (accessController.canManageAdminPermissions)
                      _AdminSidebarItem(
                        title: 'Admin Permissions',
                        icon: Icons.admin_panel_settings_outlined,
                        route: AdminWebRoutes.adminAccess,
                        currentRoute: currentRoute,
                      ),

                    MBSpacing.h(MBSpacing.md),
                    const _SidebarSectionLabel('Future Modules'),
                    _AdminSidebarItem(
                      title: 'Orders',
                      icon: Icons.receipt_long_outlined,
                      route: AdminWebRoutes.orders,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Inventory',
                      icon: Icons.warehouse_outlined,
                      route: AdminWebRoutes.inventory,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Finance',
                      icon: Icons.account_balance_wallet_outlined,
                      route: AdminWebRoutes.finance,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Delivery',
                      icon: Icons.local_shipping_outlined,
                      route: AdminWebRoutes.delivery,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Reports',
                      icon: Icons.bar_chart_outlined,
                      route: AdminWebRoutes.reports,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Customers',
                      icon: Icons.groups_outlined,
                      route: AdminWebRoutes.customers,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Settings',
                      icon: Icons.settings_outlined,
                      route: AdminWebRoutes.settings,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Zones',
                      icon: Icons.map_outlined,
                      route: AdminWebRoutes.zones,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Suppliers',
                      icon: Icons.store_mall_directory_outlined,
                      route: AdminWebRoutes.suppliers,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Technicians',
                      icon: Icons.engineering_outlined,
                      route: AdminWebRoutes.technicians,
                      currentRoute: currentRoute,
                    ),
                    _AdminSidebarItem(
                      title: 'Riders',
                      icon: Icons.pedal_bike_outlined,
                      route: AdminWebRoutes.riders,
                      currentRoute: currentRoute,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarSectionLabel extends StatelessWidget {
  const _SidebarSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MBSpacing.sm,
        MBSpacing.sm,
        MBSpacing.sm,
        MBSpacing.xs,
      ),
      child: Text(
        label,
        style: MBTextStyles.caption.copyWith(
          color: MBColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminSidebarItem extends StatelessWidget {
  const _AdminSidebarItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.currentRoute,
  });

  final String title;
  final IconData icon;
  final String route;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final bool selected =
        currentRoute == route || currentRoute.startsWith('$route/');

    return Padding(
      padding: const EdgeInsets.only(bottom: MBSpacing.xs),
      child: InkWell(
        borderRadius: BorderRadius.circular(MBRadius.lg),
        onTap: () {
          if (Get.currentRoute != route) {
            Get.offNamed(route);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MBSpacing.md,
            vertical: MBSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected
                ? MBColors.primaryOrange.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(MBRadius.lg),
            border: Border.all(
              color: selected
                  ? MBColors.primaryOrange.withValues(alpha: 0.25)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color:
                selected ? MBColors.primaryOrange : MBColors.textSecondary,
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: MBTextStyles.body.copyWith(
                    color:
                    selected ? MBColors.primaryOrange : MBColors.textPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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