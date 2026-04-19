import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:shared_models/admin/mb_admin_permission.dart';

class AdminSidebarGroupConfig {
  const AdminSidebarGroupConfig({
    required this.title,
    required this.routes,
    this.alwaysVisible = false,
  });

  final String title;
  final List<String> routes;
  final bool alwaysVisible;
}

class AdminSidebarItemConfig {
  const AdminSidebarItemConfig({
    required this.route,
    required this.title,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.iconFontPackage,
    this.permissionKey,
  });

  final String route;
  final String title;
  final int iconCodePoint;
  final String? iconFontFamily;
  final String? iconFontPackage;
  final String? permissionKey;
}

class AdminSidebarConfig {
  AdminSidebarConfig._();

  static const List<AdminSidebarGroupConfig> groups = [
    AdminSidebarGroupConfig(
      title: AdminSidebarGroups.overview,
      routes: [
        AdminWebRoutes.dashboard,
        AdminWebRoutes.profile,
      ],
      alwaysVisible: true,
    ),
    AdminSidebarGroupConfig(
      title: AdminSidebarGroups.catalog,
      routes: [
        AdminWebRoutes.categories,
        AdminWebRoutes.brands,
        AdminWebRoutes.products,
        AdminWebRoutes.quarantineProducts,
        AdminWebRoutes.banners,
      ],
    ),
    AdminSidebarGroupConfig(
      title: AdminSidebarGroups.marketing,
      routes: [
        AdminWebRoutes.offers,
        AdminWebRoutes.promos,
        AdminWebRoutes.homeSections,
      ],
    ),
    AdminSidebarGroupConfig(
      title: AdminSidebarGroups.administration,
      routes: [
        AdminWebRoutes.users,
        AdminWebRoutes.admins,
        AdminWebRoutes.stuffs,
        AdminWebRoutes.auditLogs,
        AdminWebRoutes.adminAccess,
        AdminWebRoutes.invites,
      ],
    ),
    AdminSidebarGroupConfig(
      title: AdminSidebarGroups.orders,
      routes: [
        AdminWebRoutes.orders,
        AdminWebRoutes.manualOrders,
        AdminWebRoutes.picking,
        AdminWebRoutes.packing,
        AdminWebRoutes.substitutions,
        AdminWebRoutes.refunds,
        AdminWebRoutes.returns,
      ],
    ),
    AdminSidebarGroupConfig(
      title: AdminSidebarGroups.inventoryProcurement,
      routes: [
        AdminWebRoutes.inventory,
        AdminWebRoutes.stockLedger,
        AdminWebRoutes.purchaseReceiving,
        AdminWebRoutes.purchases,
        AdminWebRoutes.suppliers,
      ],
    ),
    AdminSidebarGroupConfig(
      title: AdminSidebarGroups.finance,
      routes: [
        AdminWebRoutes.finance,
        AdminWebRoutes.expenses,
        AdminWebRoutes.dailyClosing,
        AdminWebRoutes.deliverySettlements,
      ],
    ),
    AdminSidebarGroupConfig(
      title: AdminSidebarGroups.delivery,
      routes: [
        AdminWebRoutes.delivery,
        AdminWebRoutes.riders,
        AdminWebRoutes.zones,
        AdminWebRoutes.slotsCapacity,
        AdminWebRoutes.deliveryComplaints,
      ],
    ),
    AdminSidebarGroupConfig(
      title: AdminSidebarGroups.services,
      routes: [
        AdminWebRoutes.services,
        AdminWebRoutes.serviceCategories,
        AdminWebRoutes.technicians,
        AdminWebRoutes.serviceComplaints,
      ],
    ),
    AdminSidebarGroupConfig(
      title: AdminSidebarGroups.customers,
      routes: [
        AdminWebRoutes.customers,
        AdminWebRoutes.customerSegments,
        AdminWebRoutes.customerComplaints,
      ],
    ),
    AdminSidebarGroupConfig(
      title: AdminSidebarGroups.reportingConfig,
      routes: [
        AdminWebRoutes.reports,
        AdminWebRoutes.settings,
      ],
    ),
  ];

  static final Map<String, List<AdminSidebarItemConfig>> _groupItemsCache = {
    for (final group in groups)
      group.title: group.routes
          .map((route) => _itemFromRoute(route))
          .whereType<AdminSidebarItemConfig>()
          .toList(),
  };

  static List<AdminSidebarItemConfig> itemsForGroup(String groupTitle) {
    return _groupItemsCache[groupTitle] ?? const [];
  }

  static List<AdminSidebarGroupConfig> visibleGroups(
      MBAdminPermission? permission,
      ) {
    return groups.where((group) {
      if (group.alwaysVisible) return true;
      final items = _groupItemsCache[group.title] ?? const [];
      return items.any((item) => canAccessItem(item, permission));
    }).toList();
  }

  static bool canAccessItem(
      AdminSidebarItemConfig item,
      MBAdminPermission? permission,
      ) {
    final key = item.permissionKey;
    if (key == null || key.isEmpty) return true;
    if (permission == null) return false;

    switch (key) {
      case AdminPermissionKeys.accessAdminPanel:
        return permission.canAccessAdminPanel;

      case AdminPermissionKeys.viewDashboard:
      case AdminPermissionKeys.viewProfile:
        return permission.canAccessAdminPanel;

      case AdminPermissionKeys.manageAdmins:
        return permission.canManageAdmins;

      case AdminPermissionKeys.manageAdminInvites:
        return permission.canManageAdminInvites;

      case AdminPermissionKeys.manageAdminPermissions:
        return permission.canManageAdminPermissions;

      case AdminPermissionKeys.manageUsers:
        return permission.canManageUsers;

      case AdminPermissionKeys.manageCategories:
        return permission.canManageCategories;

      case AdminPermissionKeys.manageBrands:
        return permission.canManageBrands;

      case AdminPermissionKeys.manageProducts:
        return permission.canManageProducts;

      case AdminPermissionKeys.manageBanners:
        return permission.canManageBanners;

      case AdminPermissionKeys.manageCoupons:
        return permission.canManageCoupons;

      case AdminPermissionKeys.manageOffers:
      case AdminPermissionKeys.managePromos:
        return permission.canManageOffers;

      case AdminPermissionKeys.manageHomeSections:
        return permission.canManageHomeSections;

      case AdminPermissionKeys.deleteProducts:
        return permission.canDeleteProducts;

      case AdminPermissionKeys.restoreProducts:
        return permission.canRestoreProducts;

      case AdminPermissionKeys.viewActivityLogs:
        return permission.canViewActivityLogs;

      case AdminPermissionKeys.manageOrders:
      case AdminPermissionKeys.manageManualOrders:
      case AdminPermissionKeys.managePicking:
      case AdminPermissionKeys.managePacking:
      case AdminPermissionKeys.manageSubstitutions:
      case AdminPermissionKeys.manageRefunds:
      case AdminPermissionKeys.manageReturns:
      case AdminPermissionKeys.manageInventory:
      case AdminPermissionKeys.viewStockLedger:
      case AdminPermissionKeys.managePurchaseReceiving:
      case AdminPermissionKeys.managePurchases:
      case AdminPermissionKeys.manageSuppliers:
      case AdminPermissionKeys.manageFinance:
      case AdminPermissionKeys.manageExpenses:
      case AdminPermissionKeys.manageDailyClosing:
      case AdminPermissionKeys.manageDeliverySettlements:
      case AdminPermissionKeys.manageDelivery:
      case AdminPermissionKeys.manageRiders:
      case AdminPermissionKeys.manageZones:
      case AdminPermissionKeys.manageSlotsCapacity:
      case AdminPermissionKeys.manageDeliveryComplaints:
      case AdminPermissionKeys.manageServices:
      case AdminPermissionKeys.manageServiceCategories:
      case AdminPermissionKeys.manageTechnicians:
      case AdminPermissionKeys.manageServiceComplaints:
      case AdminPermissionKeys.viewCustomers:
      case AdminPermissionKeys.manageCustomerSegments:
      case AdminPermissionKeys.manageCustomerComplaints:
      case AdminPermissionKeys.viewReports:
      case AdminPermissionKeys.manageSettings:
        return permission.canAccessAdminPanel;

      default:
        return false;
    }
  }

  static AdminSidebarItemConfig? _itemFromRoute(String route) {
    final meta = AdminRouteRegistry.find(route);
    if (meta == null) return null;

    return AdminSidebarItemConfig(
      route: meta.route,
      title: meta.title,
      iconCodePoint: meta.icon.codePoint,
      iconFontFamily: meta.icon.fontFamily,
      iconFontPackage: meta.icon.fontPackage,
      permissionKey: meta.permissionKey,
    );
  }
}