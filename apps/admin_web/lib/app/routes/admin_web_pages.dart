import 'package:admin_web/app/bindings/admin_access_binding.dart';
import 'package:admin_web/app/bindings/admin_web_binding.dart';
import 'package:admin_web/app/bindings/brands_binding.dart';
import 'package:admin_web/app/bindings/categories_binding.dart';
import 'package:admin_web/app/bindings/dashboard_binding.dart';
import 'package:admin_web/app/bindings/products_binding.dart';
import 'package:admin_web/app/middleware/admin_auth_middleware.dart';
import 'package:admin_web/app/middleware/admin_guest_only_middleware.dart';
import 'package:admin_web/app/middleware/super_admin_only_middleware.dart';
import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/startup/admin_launch_router_page.dart';
import 'package:admin_web/features/admin_access/pages/admin_permissions_page.dart';
import 'package:admin_web/features/banners/pages/admin_banners_page.dart';
import 'package:admin_web/features/brands/pages/admin_brands_page.dart';
import 'package:admin_web/features/categories/pages/admin_categories_page.dart';
import 'package:admin_web/features/dashboard/pages/admin_dashboard_page.dart';
import 'package:admin_web/features/invites/pages/admin_invites_page.dart';
import 'package:admin_web/features/marketing/pages/admin_offers_page.dart';
import 'package:admin_web/features/marketing/pages/admin_promos_page.dart';
import 'package:admin_web/features/products/pages/admin_products_page.dart';
import 'package:admin_web/features/products/pages/admin_quarantine_products_page.dart';
import 'package:admin_web/features/setup/pages/setup_super_admin_page.dart';
import 'package:admin_web/features/users/pages/admin_users_page.dart';
import 'package:admin_web/features/auth/pages/admin_login_page.dart';
import 'package:admin_web/features/auth/pages/admin_register_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AdminWebPages {
  AdminWebPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AdminWebRoutes.launch,
      page: () => const AdminLaunchRouterPage(),
      binding: AdminWebBinding(),
    ),
    GetPage(
      name: AdminWebRoutes.login,
      page: () => const AdminLoginPage(),
      middlewares: [
        AdminGuestOnlyMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.register,
      page: () => const AdminRegisterPage(),
      middlewares: [
        AdminGuestOnlyMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.setupSuperAdmin,
      page: () => const SetupSuperAdminPage(),
      middlewares: [
        SuperAdminOnlyMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.dashboard,
      page: () => const AdminDashboardPage(),
      binding: DashboardBinding(),
      middlewares: [
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.categories,
      page: () => const AdminCategoriesPage(),
      binding: CategoriesBinding(),
      middlewares: [
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.brands,
      page: () => const AdminBrandsPage(),
      binding: BrandsBinding(),
      middlewares: [
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.banners,
      page: () => const AdminBannersPage(),
      middlewares: [
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.offers,
      page: () => const AdminOffersPage(),
      middlewares: [
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.coupons,
      page: () => const AdminPromosPage(),
      middlewares: [
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.products,
      page: () => const AdminProductsPage(),
      binding: ProductsBinding(),
      middlewares: [
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.quarantineProducts,
      page: () => const AdminQuarantineProductsPage(),
      binding: ProductsBinding(),
      middlewares: [
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.users,
      page: () => const AdminUsersPage(),
      middlewares: [
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.adminAccess,
      page: () => const AdminPermissionsPage(),
      binding: AdminAccessBinding(),
      middlewares: [
        AdminAuthMiddleware(),
      ],
    ),
    GetPage(
      name: AdminWebRoutes.invites,
      page: () => const AdminInvitesPage(),
      middlewares: [
        AdminAuthMiddleware(),
      ],
    ),
  ];
}