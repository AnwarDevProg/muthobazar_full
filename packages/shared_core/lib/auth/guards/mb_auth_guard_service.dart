// Auth Guard
// ----------
// Protects routes that require authentication.

import 'package:flutter/material.dart';
import 'package:shared_core/auth/services/core_auth_service.dart';


class AuthGuard {
  static Future<bool> ensureAuthenticated(
      BuildContext context, {
        required Future<bool?> Function() onUnauthenticated,
      }) async {
    if (AuthService.isLoggedIn) {
      return true;
    }

    final result = await onUnauthenticated();

    return result ?? false;
  }
}



///HOW TO USE (in customer_app)
///await AuthGuard.ensureAuthenticated(
///context,
///onUnauthenticated: () {
///return Get.toNamed<bool>(AppRoutes.login);
///},
///);










