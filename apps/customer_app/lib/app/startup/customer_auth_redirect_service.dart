import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_core/shared_core.dart';

class CustomerAuthRedirectService {
  CustomerAuthRedirectService({
    AuthProfileRedirectResolver? resolver,
  }) : _resolver = resolver ?? AuthProfileRedirectResolver();

  final AuthProfileRedirectResolver _resolver;

  Future<void> screenRedirect() async {
    try {
      if (!AuthService.isLoggedIn) {
        debugPrint('CustomerAuthRedirectService: unauthenticated → welcome');
        Get.offAllNamed(AppRoutes.welcome);
        return;
      }

      final AuthProfileRedirectResult result =
      await _resolver.resolveCurrentUser();

      debugPrint(
        'CustomerAuthRedirectService: decision=${result.decision}, message=${result.message}',
      );

      switch (result.decision) {
        case AuthProfileRedirectDecision.unauthenticated:
          Get.offAllNamed(AppRoutes.welcome);
          break;

        case AuthProfileRedirectDecision.active:
          Get.offAllNamed(AppRoutes.shell);
          break;

        case AuthProfileRedirectDecision.blocked:
          Get.offAllNamed(AppRoutes.accountBlocked);
          break;

        case AuthProfileRedirectDecision.incompleteProfile:
        case AuthProfileRedirectDecision.missingProfile:
          Get.offAllNamed(AppRoutes.completeProfile);
          break;

        case AuthProfileRedirectDecision.error:
          Get.offAllNamed(AppRoutes.welcome);
          break;
      }
    } catch (e, st) {
      debugPrint('CustomerAuthRedirectService.screenRedirect error: $e');
      debugPrint('$st');
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}