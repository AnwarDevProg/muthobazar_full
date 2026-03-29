import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/services/admin_web_bootstrap_service.dart';
import 'package:admin_web/app/services/admin_web_session_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SuperAdminOnlyMiddleware extends GetMiddleware {
  SuperAdminOnlyMiddleware({this.priority = 0});

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
    // During initial bootstrap, super-admin protected pages should
    // not open yet. Signed-in users should complete setup first.
    //
    // Safe future removal:
    // - remove this block
    // - keep remaining super-admin protection logic
    // ==========================================================
    final bool needsSetup =
    await _bootstrapService.shouldShowSuperAdminSetup();

    if (needsSetup) {
      return GetNavConfig.fromRoute(AdminWebRoutes.setupSuperAdmin);
    }

    final bool hasAdminAccess =
    await _sessionService.hasCurrentUserAdminAccess();

    if (!hasAdminAccess) {
      await _sessionService.signOut();
      return GetNavConfig.fromRoute(AdminWebRoutes.login);
    }

    final bool isSuperAdmin =
    await _sessionService.isCurrentUserSuperAdmin();

    if (!isSuperAdmin) {
      return GetNavConfig.fromRoute(AdminWebRoutes.dashboard);
    }

    return await super.redirectDelegate(route);
  }
}