import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/services/admin_web_bootstrap_service.dart';
import 'package:admin_web/app/services/admin_web_session_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AdminGuestOnlyMiddleware extends GetMiddleware {
  AdminGuestOnlyMiddleware({this.priority = 0});

  @override
  final int priority;

  final AdminWebSessionService _sessionService =
  Get.find<AdminWebSessionService>();

  final AdminWebBootstrapService _bootstrapService =
  Get.find<AdminWebBootstrapService>();

  @override
  RouteSettings? redirect(String? route) {
    // Keep sync redirect lightweight.
    // Real routing decision happens in redirectDelegate.
    return null;
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final bool isSignedIn = _sessionService.isSignedIn;

    if (!isSignedIn) {
      return await super.redirectDelegate(route);
    }

    // ==========================================================
    // BOOTSTRAP-ONLY: FIRST SUPER ADMIN SETUP REDIRECT
    // ----------------------------------------------------------
    // If bootstrap is still open and a user is already signed in,
    // do not leave them on login/register pages. Send them to the
    // one-time setup page.
    //
    // Safe future removal:
    // - remove this block
    // - leave normal guest-only behavior intact
    // ==========================================================
    final bool needsSetup =
    await _bootstrapService.shouldShowSuperAdminSetup();

    if (needsSetup) {
      return GetNavConfig.fromRoute(AdminWebRoutes.setupSuperAdmin);
    }

    final bool hasAccess = await _sessionService.hasCurrentUserAdminAccess();

    if (hasAccess) {
      return GetNavConfig.fromRoute(AdminWebRoutes.dashboard);
    }

    await _sessionService.signOut();
    return await super.redirectDelegate(route);
  }
}