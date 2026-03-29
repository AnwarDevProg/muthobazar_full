import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:customer_app/features/profile/controllers/profile_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<ProfileController>()) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final profileController = Get.find<ProfileController>();

    if (!profileController.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }

    return null;
  }
}