import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/services/admin_web_bootstrap_service.dart';
import 'package:admin_web/app/services/admin_web_session_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AdminAuthMiddleware extends GetMiddleware {
  AdminAuthMiddleware({int? priority}) {
    this.priority = priority ?? 1;
  }

  @override
  int? priority;

  AdminWebSessionService get _sessionService =>
      Get.find<AdminWebSessionService>();

  AdminWebBootstrapService get _bootstrapService =>
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