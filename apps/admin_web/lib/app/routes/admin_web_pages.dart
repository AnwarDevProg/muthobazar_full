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
import 'package:admin_web/app/shell/admin_shell_host_page.dart';
import 'package:admin_web/app/startup/admin_launch_router_page.dart';
import 'package:admin_web/features/auth/pages/admin_login_page.dart';
import 'package:admin_web/features/auth/pages/admin_register_page.dart';
import 'package:admin_web/features/setup_super_admin/pages/setup_super_admin_page.dart';
import 'package:get/get.dart';

class AdminWebPages {
  AdminWebPages._();

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
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

    _shellPage(
      route: AdminWebRoutes.dashboard,
      initialRoute: AdminWebRoutes.dashboard,
      bindings: <Bindings>[
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
    _shellPage(
      route: AdminWebRoutes.profile,
      initialRoute: AdminWebRoutes.profile,
      bindings: <Bindings>[
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
    _shellPage(
      route: AdminWebRoutes.categories,
      initialRoute: AdminWebRoutes.categories,
      bindings: <Bindings>[
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
    _shellPage(
      route: AdminWebRoutes.brands,
      initialRoute: AdminWebRoutes.brands,
      bindings: <Bindings>[
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
    _shellPage(
      route: AdminWebRoutes.products,
      initialRoute: AdminWebRoutes.products,
      bindings: <Bindings>[
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
    _shellPage(
      route: AdminWebRoutes.quarantineProducts,
      initialRoute: AdminWebRoutes.quarantineProducts,
      bindings: <Bindings>[
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
    _shellPage(
      route: AdminWebRoutes.banners,
      initialRoute: AdminWebRoutes.banners,
      bindings: <Bindings>[
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
    _shellPage(
      route: AdminWebRoutes.offers,
      initialRoute: AdminWebRoutes.offers,
      bindings: <Bindings>[
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageOffers,
        ),
      ],
    ),
    _shellPage(
      route: AdminWebRoutes.promos,
      initialRoute: AdminWebRoutes.promos,
      bindings: <Bindings>[
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.managePromos,
        ),
      ],
    ),
    _shellPage(
      route: AdminWebRoutes.users,
      initialRoute: AdminWebRoutes.users,
      bindings: <Bindings>[
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
    _shellPage(
      route: AdminWebRoutes.admins,
      initialRoute: AdminWebRoutes.admins,
      bindings: <Bindings>[
        PlaceholderFeatureBinding(),
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageAdmins,
        ),
      ],
    ),
    _shellPage(
      route: AdminWebRoutes.stuffs,
      initialRoute: AdminWebRoutes.stuffs,
      bindings: <Bindings>[
        PlaceholderFeatureBinding(),
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageStuffs,
        ),
      ],
    ),
    _shellPage(
      route: AdminWebRoutes.auditLogs,
      initialRoute: AdminWebRoutes.auditLogs,
      bindings: <Bindings>[
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
    _shellPage(
      route: AdminWebRoutes.adminAccess,
      initialRoute: AdminWebRoutes.adminAccess,
      bindings: <Bindings>[
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
    _shellPage(
      route: AdminWebRoutes.invites,
      initialRoute: AdminWebRoutes.invites,
      bindings: <Bindings>[
        PlaceholderFeatureBinding(),
        AdminAccessBinding(),
      ],
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
        PermissionGuardMiddleware(
          permissionKey: AdminPermissionKeys.manageAdminInvites,
        ),
      ],
    ),

    ..._placeholderPages(),
  ];

  static GetPage<dynamic> _shellPage({
    required String route,
    required String initialRoute,
    required List<Bindings> bindings,
    required List<GetMiddleware> middlewares,
  }) {
    return GetPage<dynamic>(
      name: route,
      page: () => AdminShellHostPage(initialRoute: initialRoute),
      bindings: bindings,
      middlewares: middlewares,
    );
  }

  static List<GetPage<dynamic>> _placeholderPages() {
    final List<_PlaceholderRouteConfig> configs = <_PlaceholderRouteConfig>[
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.orders,
        permissionKey: AdminPermissionKeys.manageOrders,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.manualOrders,
        permissionKey: AdminPermissionKeys.manageManualOrders,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.picking,
        permissionKey: AdminPermissionKeys.managePicking,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.packing,
        permissionKey: AdminPermissionKeys.managePacking,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.substitutions,
        permissionKey: AdminPermissionKeys.manageSubstitutions,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.refunds,
        permissionKey: AdminPermissionKeys.manageRefunds,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.returns,
        permissionKey: AdminPermissionKeys.manageReturns,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.inventory,
        permissionKey: AdminPermissionKeys.manageInventory,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.stockLedger,
        permissionKey: AdminPermissionKeys.viewStockLedger,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.purchaseReceiving,
        permissionKey: AdminPermissionKeys.managePurchaseReceiving,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.purchases,
        permissionKey: AdminPermissionKeys.managePurchases,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.suppliers,
        permissionKey: AdminPermissionKeys.manageSuppliers,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.finance,
        permissionKey: AdminPermissionKeys.manageFinance,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.expenses,
        permissionKey: AdminPermissionKeys.manageExpenses,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.dailyClosing,
        permissionKey: AdminPermissionKeys.manageDailyClosing,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.deliverySettlements,
        permissionKey: AdminPermissionKeys.manageDeliverySettlements,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.delivery,
        permissionKey: AdminPermissionKeys.manageDelivery,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.riders,
        permissionKey: AdminPermissionKeys.manageRiders,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.zones,
        permissionKey: AdminPermissionKeys.manageZones,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.slotsCapacity,
        permissionKey: AdminPermissionKeys.manageSlotsCapacity,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.deliveryComplaints,
        permissionKey: AdminPermissionKeys.manageDeliveryComplaints,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.services,
        permissionKey: AdminPermissionKeys.manageServices,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.serviceCategories,
        permissionKey: AdminPermissionKeys.manageServiceCategories,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.technicians,
        permissionKey: AdminPermissionKeys.manageTechnicians,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.serviceComplaints,
        permissionKey: AdminPermissionKeys.manageServiceComplaints,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.customers,
        permissionKey: AdminPermissionKeys.viewCustomers,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.customerSegments,
        permissionKey: AdminPermissionKeys.manageCustomerSegments,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.customerComplaints,
        permissionKey: AdminPermissionKeys.manageCustomerComplaints,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.reports,
        permissionKey: AdminPermissionKeys.viewReports,
      ),
      _PlaceholderRouteConfig(
        route: AdminWebRoutes.settings,
        permissionKey: AdminPermissionKeys.manageSettings,
      ),
    ];

    return configs
        .map(
          (config) => _shellPage(
        route: config.route,
        initialRoute: config.route,
        bindings: <Bindings>[
          PlaceholderFeatureBinding(),
          AdminAccessBinding(),
        ],
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
    required this.permissionKey,
  });

  final String route;
  final String permissionKey;
}
