import 'package:admin_web/app/bindings/admin_access_binding.dart';
import 'package:admin_web/app/bindings/admin_user_binding.dart';
import 'package:admin_web/app/bindings/brands_binding.dart';
import 'package:admin_web/app/bindings/categories_binding.dart';
import 'package:admin_web/app/bindings/dashboard_binding.dart';
import 'package:admin_web/app/bindings/products_binding.dart';
import 'package:admin_web/app/bindings/profile_binding.dart';
import 'package:admin_web/app/middleware/admin_auth_middleware.dart';
import 'package:admin_web/app/middleware/admin_guest_only_middleware.dart';
import 'package:admin_web/app/middleware/super_admin_only_middleware.dart';
import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/startup/admin_launch_router_page.dart';
import 'package:admin_web/app/widgets/common/admin_feature_placeholder_page.dart';
import 'package:admin_web/features/admin_access/pages/admin_permissions_page.dart';
import 'package:admin_web/features/auth/pages/admin_login_page.dart';
import 'package:admin_web/features/auth/pages/admin_register_page.dart';
import 'package:admin_web/features/banners/pages/admin_banners_page.dart';
import 'package:admin_web/features/brands/pages/admin_brands_page.dart';
import 'package:admin_web/features/categories/pages/admin_categories_page.dart';
import 'package:admin_web/features/dashboard/pages/admin_dashboard_page.dart';
import 'package:admin_web/features/invites/pages/admin_invites_page.dart';
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
      ],
    ),
    GetPage(
      name: AdminWebRoutes.categories,
      page: () => const AdminCategoriesPage(),
      binding: CategoriesBinding(),
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.brands,
      page: () => const AdminBrandsPage(),
      binding: BrandsBinding(),
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.banners,
      page: () => const AdminBannersPage(),
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.promos,
      page: () => const AdminPromosPage(),
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.offers,
      page: () => const AdminOffersPage(),
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.products,
      page: () => const AdminProductsPage(),
      binding: ProductsBinding(),
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.quarantineProducts,
      page: () => const AdminQuarantineProductsPage(),
      binding: ProductsBinding(),
      middlewares: <GetMiddleware>[
        AdminAuthMiddleware(),
      ],
    ),
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
      ],
    ),
    GetPage(
      name: AdminWebRoutes.adminAccess,
      page: () => const AdminPermissionsPage(),
      binding: AdminAccessBinding(),
      middlewares: <GetMiddleware>[
        SuperAdminOnlyMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.invites,
      page: () => const AdminInvitesPage(),
      middlewares: <GetMiddleware>[
        SuperAdminOnlyMiddleware(),
      ],
    ),

    // Placeholder pages
    ..._placeholderPages(),
  ];

  static List<GetPage<dynamic>> _placeholderPages() {
    final placeholders = <MapEntry<String, String>>[
      const MapEntry(AdminWebRoutes.auditLogs, 'Audit Logs'),
      const MapEntry(AdminWebRoutes.orders, 'Orders'),
      const MapEntry(AdminWebRoutes.inventory, 'Inventory'),
      const MapEntry(AdminWebRoutes.finance, 'Finance'),
      const MapEntry(AdminWebRoutes.delivery, 'Delivery'),
      const MapEntry(AdminWebRoutes.reports, 'Reports'),
      const MapEntry(AdminWebRoutes.customers, 'Customers'),
      const MapEntry(AdminWebRoutes.settings, 'Settings'),
      const MapEntry(AdminWebRoutes.zones, 'Zones'),
      const MapEntry(AdminWebRoutes.suppliers, 'Suppliers'),
      const MapEntry(AdminWebRoutes.technicians, 'Technicians'),
      const MapEntry(AdminWebRoutes.riders, 'Riders'),
      const MapEntry(AdminWebRoutes.complaints, 'Complaints'),
      const MapEntry(AdminWebRoutes.customerSegments, 'Customer Segments'),
      const MapEntry(AdminWebRoutes.dailyClosing, 'Daily Closing'),
      const MapEntry(AdminWebRoutes.deliverySettlements, 'Delivery Settlements'),
      const MapEntry(AdminWebRoutes.expenses, 'Expenses'),
      const MapEntry(AdminWebRoutes.manualOrders, 'Manual Orders'),
      const MapEntry(AdminWebRoutes.packing, 'Packing'),
      const MapEntry(AdminWebRoutes.picking, 'Picking'),
      const MapEntry(AdminWebRoutes.purchaseReceiving, 'Purchase Receiving'),
      const MapEntry(AdminWebRoutes.purchases, 'Purchases'),
      const MapEntry(AdminWebRoutes.refunds, 'Refunds'),
      const MapEntry(AdminWebRoutes.returns, 'Returns'),
      const MapEntry(AdminWebRoutes.serviceCategories, 'Service Categories'),
      const MapEntry(AdminWebRoutes.services, 'Services'),
      const MapEntry(AdminWebRoutes.slotsCapacity, 'Slots Capacity'),
      const MapEntry(AdminWebRoutes.stockLedger, 'Stock Ledger'),
      const MapEntry(AdminWebRoutes.substitutions, 'Substitutions'),
    ];

    return placeholders
        .map(
          (e) => GetPage(
        name: e.key,
        page: () => AdminFeaturePlaceholderPage(title: e.value),
        middlewares: <GetMiddleware>[
          AdminAuthMiddleware(),
        ],
      ),
    )
        .toList();
  }
}