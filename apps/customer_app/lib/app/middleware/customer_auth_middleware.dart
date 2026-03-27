import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/profile/controllers/profile_controller.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {

  @override
  int get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final ProfileController profileController = Get.find<ProfileController>();

    if (!profileController.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }

    return null;
  }
}
















