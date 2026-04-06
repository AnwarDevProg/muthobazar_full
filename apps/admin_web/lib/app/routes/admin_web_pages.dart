import 'package:admin_web/app/bindings/admin_access_binding.dart';
import 'package:admin_web/app/bindings/admin_activity_logs_binding.dart';
import 'package:admin_web/app/bindings/admin_user_binding.dart';
import 'package:admin_web/app/bindings/banners_binding.dart';
import 'package:admin_web/app/bindings/brands_binding.dart';
import 'package:admin_web/app/bindings/categories_binding.dart';
import 'package:admin_web/app/bindings/dashboard_binding.dart';
import 'package:admin_web/app/bindings/placeholder_feature_binding.dart';
import 'package:admin_web/app/bindings/products_binding.dart';
import 'package:admin_web/app/bindings/profile_binding.dart';
import 'package:admin_web/app/middleware/admin_auth_middleware.dart';
import 'package:admin_web/app/middleware/admin_guest_only_middleware.dart';
import 'package:admin_web/app/middleware/permission_guard_middleware.dart';
import 'package:admin_web/app/middleware/super_admin_only_middleware.dart';
import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/startup/admin_launch_router_page.dart';
import 'package:admin_web/app/widgets/common/admin_feature_placeholder_page.dart';
import 'package:admin_web/features/admin_access/pages/admin_permissions_page.dart';
import 'package:admin_web/features/audit_logs/pages/admin_activity_logs_page.dart';
import 'package:admin_web/features/auth/pages/admin_login_page.dart';
import 'package:admin_web/features/auth/pages/admin_register_page.dart';
import 'package:admin_web/features/banners/pages/admin_banners_page.dart';
import 'package:admin_web/features/brands/pages/admin_brands_page.dart';
import 'package:admin_web/features/categories/pages/admin_categories_page.dart';
import 'package:admin_web/features/dashboard/pages/admin_dashboard_page.dart';
import 'package:admin_web/features/marketing/pages/admin_offers_page.dart';
import 'package:admin_web/features/marketing/pages/admin_promos_page.dart';
import 'package:admin_web/features/products/pages/admin_products_page.dart';
import 'package:admin_web/features/products/pages/admin_quarantine_products_page.dart';
import 'package:admin_web/features/profile/pages/admin_profile_page.dart';
import 'package:admin_web/features/setup_super_admin/pages/setup_super_admin_page.dart';
import 'package:admin_web/features/users/pages/admin_users_page.dart';
import 'package:get/get.dart';

class AdminWebPages {
  AdminWebPages._();

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    // Startup / Auth
    GetPage(
      name: AdminWebRoutes.launch,
      page: () => const AdminLaunchRouterPage(),
    ),
    GetPage(
      name: AdminWebRoutes.login,
      page: () => const AdminLoginPage(),
      middlewares: <GetMiddleware>[
        AdminGuestOnlyMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.register,
      page: () => const AdminRegisterPage(),
      middlewares: <GetMiddleware>[
        AdminGuestOnlyMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.setupSuperAdmin,
      page: () => const SetupSuperAdminPage(),
    ),

    // Overview
    GetPage(
      name: AdminWebRoutes.dashboard,
      page: () => const AdminDashboardPage(),
      bindings: [
        DashboardBinding(),
        ProfileBinding(),
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.viewDashboard,
        ),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.profile,
      page: () => const AdminProfilePage(),
      bindings: [
        ProfileBinding(),
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.viewProfile,
        ),
      ],
    ),

    // Catalog
    GetPage(
      name: AdminWebRoutes.categories,
      page: () => const AdminCategoriesPage(),
      bindings: [
        CategoriesBinding(),
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageCategories,
        ),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.brands,
      page: () => const AdminBrandsPage(),
      bindings: [
        BrandsBinding(),
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageBrands,
        ),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.products,
      page: () => const AdminProductsPage(),
      bindings: [
        ProductsBinding(),
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageProducts,
        ),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.quarantineProducts,
      page: () => const AdminQuarantineProductsPage(),
      bindings: [
        ProductsBinding(),
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.restoreProducts,
        ),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.banners,
      page: () => const AdminBannersPage(),
      bindings: [
        BannersBinding(),
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageBanners,
        ),
      ],
    ),

    // Marketing
    GetPage(
      name: AdminWebRoutes.offers,
      page: () => const AdminOffersPage(),
      bindings: [
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageOffers,
        ),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.promos,
      page: () => const AdminPromosPage(),
      bindings: [
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.managePromos,
        ),
      ],
    ),

    // Administration
    GetPage(
      name: AdminWebRoutes.users,
      page: () => const AdminUsersPage(),
      bindings: [
        AdminUserBinding(),
        ProfileBinding(),
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageUsers,
        ),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.admins,
      page: () => const AdminFeaturePlaceholderPage(
        title: 'Admins',
        description: 'Admins management page will be implemented next.',
      ),
      binding: PlaceholderFeatureBinding(),
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageAdmins,
        ),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.stuffs,
      page: () => const AdminFeaturePlaceholderPage(
        title: 'Stuffs',
        description: 'Stuffs management page will be implemented next.',
      ),
      binding: PlaceholderFeatureBinding(),
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageStuffs,
        ),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.auditLogs,
      page: () => const AdminActivityLogsPage(),
      bindings: [
        AdminActivityLogsBinding(),
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.viewActivityLogs,
        ),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.adminAccess,
      page: () => const AdminPermissionsPage(),
      bindings: [
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        SuperAdminOnlyMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageAdminPermissions,
        ),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.invites,
      page: () => const AdminFeaturePlaceholderPage(
        title: 'Invites',
        description: 'Admin invites page will be implemented next.',
      ),
      binding: PlaceholderFeatureBinding(),
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageAdminInvites,
        ),
      ],
    ),

    // Placeholder features
    ..._placeholderPages(),
  ];

  static List<GetPage<dynamic>> _placeholderPages() {
    final List<_PlaceholderRouteConfig> configs = <_PlaceholderRouteConfig>[
      // Orders
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.orders,
        title: 'Orders',
        permissionKey: AdminPermissionKeys.manageOrders,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.manualOrders,
        title: 'Manual Orders',
        permissionKey: AdminPermissionKeys.manageManualOrders,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.picking,
        title: 'Picking',
        permissionKey: AdminPermissionKeys.managePicking,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.packing,
        title: 'Packing',
        permissionKey: AdminPermissionKeys.managePacking,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.substitutions,
        title: 'Substitutions',
        permissionKey: AdminPermissionKeys.manageSubstitutions,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.refunds,
        title: 'Refunds',
        permissionKey: AdminPermissionKeys.manageRefunds,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.returns,
        title: 'Returns',
        permissionKey: AdminPermissionKeys.manageReturns,
      ),

      // Inventory & Procurement
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.inventory,
        title: 'Inventory',
        permissionKey: AdminPermissionKeys.manageInventory,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.stockLedger,
        title: 'Stock Ledger',
        permissionKey: AdminPermissionKeys.viewStockLedger,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.purchaseReceiving,
        title: 'Purchase Receiving',
        permissionKey: AdminPermissionKeys.managePurchaseReceiving,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.purchases,
        title: 'Purchases',
        permissionKey: AdminPermissionKeys.managePurchases,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.suppliers,
        title: 'Suppliers',
        permissionKey: AdminPermissionKeys.manageSuppliers,
      ),

      // Finance
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.finance,
        title: 'Finance',
        permissionKey: AdminPermissionKeys.manageFinance,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.expenses,
        title: 'Expenses',
        permissionKey: AdminPermissionKeys.manageExpenses,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.dailyClosing,
        title: 'Daily Closing',
        permissionKey: AdminPermissionKeys.manageDailyClosing,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.deliverySettlements,
        title: 'Delivery Settlements',
        permissionKey: AdminPermissionKeys.manageDeliverySettlements,
      ),

      // Delivery
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.delivery,
        title: 'Delivery',
        permissionKey: AdminPermissionKeys.manageDelivery,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.riders,
        title: 'Riders',
        permissionKey: AdminPermissionKeys.manageRiders,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.zones,
        title: 'Zones',
        permissionKey: AdminPermissionKeys.manageZones,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.slotsCapacity,
        title: 'Slots Capacity',
        permissionKey: AdminPermissionKeys.manageSlotsCapacity,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.deliveryComplaints,
        title: 'Delivery Complaints',
        permissionKey: AdminPermissionKeys.manageDeliveryComplaints,
      ),

      // Services
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.services,
        title: 'Services',
        permissionKey: AdminPermissionKeys.manageServices,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.serviceCategories,
        title: 'Service Categories',
        permissionKey: AdminPermissionKeys.manageServiceCategories,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.technicians,
        title: 'Technicians',
        permissionKey: AdminPermissionKeys.manageTechnicians,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.serviceComplaints,
        title: 'Service Complaints',
        permissionKey: AdminPermissionKeys.manageServiceComplaints,
      ),

      // Customers
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.customers,
        title: 'Customers',
        permissionKey: AdminPermissionKeys.viewCustomers,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.customerSegments,
        title: 'Customer Segments',
        permissionKey: AdminPermissionKeys.manageCustomerSegments,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.customerComplaints,
        title: 'Customer Complaints',
        permissionKey: AdminPermissionKeys.manageCustomerComplaints,
      ),

      // Reporting & Config
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.reports,
        title: 'Reports',
        permissionKey: AdminPermissionKeys.viewReports,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.settings,
        title: 'Settings',
        permissionKey: AdminPermissionKeys.manageSettings,
      ),
    ];

    return configs
        .map(
          (config) => GetPage(
        name: config.route,
        page: () => AdminFeaturePlaceholderPage(
          title: config.title,
          description: '${config.title} page will be implemented next.',
        ),
        binding: PlaceholderFeatureBinding(),
        middlewares: <GetMiddleware>[
          AdminAuthMiddleware(),
          PermissionGuardMiddleware(
            permissionKey: config.permissionKey,
          ),
        ],
      ),
    )
        .toList();
  }
}

class _PlaceholderRouteConfig {
  const _PlaceholderRouteConfig({
    required this.route,
    required this.title,
    required this.permissionKey,
  });

  final String route;
  final String title;
  final String permissionKey;
}