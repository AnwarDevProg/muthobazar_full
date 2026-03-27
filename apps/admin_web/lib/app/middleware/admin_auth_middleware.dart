import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:admin_web/features/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';

class AdminAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<ProfileController>()) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (!Get.isRegistered<AdminAccessController>()) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final profileController = Get.find<ProfileController>();
    final adminAccessController = Get.find<AdminAccessController>();

    if (!profileController.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (!adminAccessController.canAccessAdminPanel) {
      return const RouteSettings(name: AppRoutes.welcome);
    }

    return null;
  }
}
