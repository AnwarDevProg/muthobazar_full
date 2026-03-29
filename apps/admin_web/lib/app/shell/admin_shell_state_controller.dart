import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:get/get.dart';

class AdminShellStateController extends GetxController {
  final RxString currentRoute = AdminWebRoutes.dashboard.obs;
  final RxBool isSidebarCollapsed = false.obs;

  void setRoute(String route) {
    if (currentRoute.value == route) return;
    currentRoute.value = route;
    Get.rootDelegate.toNamed(route);
  }

  void toggleSidebar() {
    isSidebarCollapsed.value = !isSidebarCollapsed.value;
  }

  void setRouteFromNavigation(String? route) {
    if (route == null || route.isEmpty) return;
    currentRoute.value = route;
  }

  bool isActive(String route) {
    return currentRoute.value == route;
  }

  bool isProductsSectionActive() {
    return currentRoute.value == AdminWebRoutes.products ||
        currentRoute.value == AdminWebRoutes.quarantineProducts;
  }

  String get pageTitle {
    switch (currentRoute.value) {
      case AdminWebRoutes.dashboard:
        return 'Dashboard';
      case AdminWebRoutes.categories:
        return 'Categories';
      case AdminWebRoutes.brands:
        return 'Brands';
      case AdminWebRoutes.banners:
        return 'Banners';
      case AdminWebRoutes.offers:
        return 'Offers';
      case AdminWebRoutes.coupons:
        return 'Coupons';
      case AdminWebRoutes.products:
        return 'Products';
      case AdminWebRoutes.quarantineProducts:
        return 'Quarantine Products';
      case AdminWebRoutes.users:
        return 'Users';
      case AdminWebRoutes.adminAccess:
        return 'Admin Access';
      case AdminWebRoutes.invites:
        return 'Invites';
      default:
        return 'Admin Panel';
    }
  }
}