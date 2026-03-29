import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/services/admin_web_bootstrap_service.dart';
import 'package:admin_web/app/services/admin_web_session_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AdminAuthMiddleware extends GetMiddleware {
  AdminAuthMiddleware({this.priority = 0});

  @override
  final int priority;

  final AdminWebSessionService _sessionService =
  Get.find<AdminWebSessionService>();

  final AdminWebBootstrapService _bootstrapService =
  Get.find<AdminWebBootstrapService>();

  @override
  RouteSettings? redirect(String? route) {
    if (!_sessionService.isSignedIn) {
      return const RouteSettings(name: AdminWebRoutes.login);
    }

    return null;
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final bool isSignedIn = _sessionService.isSignedIn;

    if (!isSignedIn) {
      return GetNavConfig.fromRoute(AdminWebRoutes.login);
    }

    // ==========================================================
    // BOOTSTRAP-ONLY: FIRST SUPER ADMIN SETUP REDIRECT
    // ----------------------------------------------------------
    // If the system is still in first-super-admin bootstrap mode,
    // signed-in users should be sent to the setup page instead of
    // normal protected admin pages.
    //
    // Safe future removal:
    // - remove this block
    // - keep the rest of middleware unchanged
    // ==========================================================
    final bool needsSetup =
    await _bootstrapService.shouldShowSuperAdminSetup();

    if (needsSetup) {
      return GetNavConfig.fromRoute(AdminWebRoutes.setupSuperAdmin);
    }

    final bool hasAccess = await _sessionService.hasCurrentUserAdminAccess();

    if (!hasAccess) {
      await _sessionService.signOut();
      return GetNavConfig.fromRoute(AdminWebRoutes.login);
    }

    return await super.redirectDelegate(route);
  }
}