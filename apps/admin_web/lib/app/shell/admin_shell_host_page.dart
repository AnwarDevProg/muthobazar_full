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
import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/shell/admin_shell_state_controller.dart';
import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:admin_web/app/widgets/common/admin_feature_placeholder_page.dart';
import 'package:admin_web/features/admin_access/pages/admin_permissions_page.dart';
import 'package:admin_web/features/audit_logs/pages/admin_activity_logs_page.dart';
import 'package:admin_web/features/banners/pages/admin_banners_page.dart';
import 'package:admin_web/features/brands/pages/admin_brands_page.dart';
import 'package:admin_web/features/categories/pages/admin_categories_page.dart';
import 'package:admin_web/features/dashboard/pages/admin_dashboard_page.dart';
import 'package:admin_web/features/marketing/pages/admin_offers_page.dart';
import 'package:admin_web/features/marketing/pages/admin_promos_page.dart';
import 'package:admin_web/features/products/pages/admin_products_page.dart';
import 'package:admin_web/features/products/pages/admin_quarantine_products_page.dart';
import 'package:admin_web/features/profile/pages/admin_profile_page.dart';
import 'package:admin_web/features/users/pages/admin_users_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminShellHostPage extends StatefulWidget {
  const AdminShellHostPage({
    super.key,
    required this.initialRoute,
  });

  final String initialRoute;

  @override
  State<AdminShellHostPage> createState() => _AdminShellHostPageState();
}

class _AdminShellHostPageState extends State<AdminShellHostPage> {
  late final AdminShellStateController _shellController;
  final Set<String> _preparedBindingKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _shellController = Get.find<AdminShellStateController>();
    _markBindingsPreparedForRoute(widget.initialRoute);
    _shellController.setRouteFromNavigation(widget.initialRoute);
  }

  @override
  void didUpdateWidget(covariant AdminShellHostPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRoute != widget.initialRoute) {
      _markBindingsPreparedForRoute(widget.initialRoute);
      _shellController.setRouteFromNavigation(widget.initialRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminShellStateController>(
      id: 'admin_content',
      builder: (controller) {
        final String route = controller.currentRoute.value.trim().isEmpty
            ? widget.initialRoute
            : controller.currentRoute.value;

        _ensureBindingsForRoute(route);

        return AdminWebShell(
          child: _buildContent(route),
        );
      },
    );
  }

  Widget _buildContent(String route) {
    switch (route) {
      case AdminWebRoutes.dashboard:
        return const AdminDashboardPage();
      case AdminWebRoutes.profile:
        return const AdminProfilePage();
      case AdminWebRoutes.categories:
        return const AdminCategoriesPage();
      case AdminWebRoutes.brands:
        return const AdminBrandsPage();
      case AdminWebRoutes.products:
        return const AdminProductsPage();
      case AdminWebRoutes.quarantineProducts:
        return const AdminQuarantineProductsPage();
      case AdminWebRoutes.banners:
        return const AdminBannersPage();
      case AdminWebRoutes.offers:
        return const AdminOffersPage();
      case AdminWebRoutes.promos:
        return const AdminPromosPage();
      case AdminWebRoutes.users:
        return const AdminUsersPage();
      case AdminWebRoutes.auditLogs:
        return const AdminActivityLogsPage();
      case AdminWebRoutes.adminAccess:
        return const AdminPermissionsPage();
      case AdminWebRoutes.admins:
        return const AdminFeaturePlaceholderPage(
          title: 'Admins',
          description: 'Admins management page will be implemented next.',
        );
      case AdminWebRoutes.stuffs:
        return const AdminFeaturePlaceholderPage(
          title: 'Stuffs',
          description: 'Stuffs management page will be implemented next.',
        );
      case AdminWebRoutes.invites:
        return const AdminFeaturePlaceholderPage(
          title: 'Invites',
          description: 'Admin invites page will be implemented next.',
        );
      default:
        final meta = AdminRouteRegistry.find(route);
        return AdminFeaturePlaceholderPage(
          title: meta?.title ?? route,
          description:
          '${meta?.title ?? route} page will be implemented next.',
        );
    }
  }

  void _markBindingsPreparedForRoute(String route) {
    for (final spec in _bindingSpecsForRoute(route)) {
      _preparedBindingKeys.add(spec.id);
    }
  }

  void _ensureBindingsForRoute(String route) {
    for (final spec in _bindingSpecsForRoute(route)) {
      if (_preparedBindingKeys.add(spec.id)) {
        spec.binding.dependencies();
      }
    }
  }

  List<_BindingSpec> _bindingSpecsForRoute(String route) {
    switch (route) {
      case AdminWebRoutes.dashboard:
        return <_BindingSpec>[
          _BindingSpec('admin_access', AdminAccessBinding()),
          _BindingSpec('dashboard', DashboardBinding()),
          _BindingSpec('profile', ProfileBinding()),
        ];
      case AdminWebRoutes.profile:
        return <_BindingSpec>[
          _BindingSpec('admin_access', AdminAccessBinding()),
          _BindingSpec('profile', ProfileBinding()),
        ];
      case AdminWebRoutes.categories:
        return <_BindingSpec>[
          _BindingSpec('admin_access', AdminAccessBinding()),
          _BindingSpec('categories', CategoriesBinding()),
        ];
      case AdminWebRoutes.brands:
        return <_BindingSpec>[
          _BindingSpec('admin_access', AdminAccessBinding()),
          _BindingSpec('brands', BrandsBinding()),
        ];
      case AdminWebRoutes.products:
      case AdminWebRoutes.quarantineProducts:
        return <_BindingSpec>[
          _BindingSpec('admin_access', AdminAccessBinding()),
          _BindingSpec('products', ProductsBinding()),
        ];
      case AdminWebRoutes.banners:
        return <_BindingSpec>[
          _BindingSpec('admin_access', AdminAccessBinding()),
          _BindingSpec('banners', BannersBinding()),
        ];
      case AdminWebRoutes.offers:
      case AdminWebRoutes.promos:
        return <_BindingSpec>[
          _BindingSpec('admin_access', AdminAccessBinding()),
        ];
      case AdminWebRoutes.users:
        return <_BindingSpec>[
          _BindingSpec('admin_access', AdminAccessBinding()),
          _BindingSpec('admin_user', AdminUserBinding()),
          _BindingSpec('profile', ProfileBinding()),
        ];
      case AdminWebRoutes.auditLogs:
        return <_BindingSpec>[
          _BindingSpec('admin_access', AdminAccessBinding()),
          _BindingSpec('admin_activity_logs', AdminActivityLogsBinding()),
        ];
      case AdminWebRoutes.adminAccess:
        return <_BindingSpec>[
          _BindingSpec('admin_access', AdminAccessBinding()),
        ];
      default:
        return <_BindingSpec>[
          _BindingSpec('admin_access', AdminAccessBinding()),
          _BindingSpec('placeholder', PlaceholderFeatureBinding()),
        ];
    }
  }
}

class _BindingSpec {
  const _BindingSpec(this.id, this.binding);

  final String id;
  final Bindings binding;
}
