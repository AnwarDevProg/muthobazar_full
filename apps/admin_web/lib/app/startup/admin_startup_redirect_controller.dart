import 'package:get/get.dart';

import '../routes/admin_web_routes.dart';
import '../services/admin_web_bootstrap_service.dart';
import '../services/admin_web_session_service.dart';

enum AdminStartupDestination {
  login,
  setupSuperAdmin,
  dashboard,
}

class AdminStartupRedirectController extends GetxController {
  AdminStartupRedirectController({
    AdminWebSessionService? sessionService,
    AdminWebBootstrapService? bootstrapService,
  })  : _sessionService =
      sessionService ?? Get.find<AdminWebSessionService>(),
        _bootstrapService =
            bootstrapService ?? Get.find<AdminWebBootstrapService>();

  final AdminWebSessionService _sessionService;
  final AdminWebBootstrapService _bootstrapService;

  final RxString statusText =
      'Checking admin access and preparing the workspace.'.obs;

  @override
  void onReady() {
    super.onReady();
    _redirect();
  }

  Future<void> _redirect() async {
    try {
      final AdminStartupDestination destination =
      await _resolveDestination();

      switch (destination) {
        case AdminStartupDestination.setupSuperAdmin:
          Get.offAllNamed(AdminWebRoutes.setupSuperAdmin);
          return;
        case AdminStartupDestination.login:
          Get.offAllNamed(AdminWebRoutes.login);
          return;
        case AdminStartupDestination.dashboard:
          Get.offAllNamed(AdminWebRoutes.dashboard);
          return;
      }
    } catch (_) {
      Get.offAllNamed(AdminWebRoutes.login);
    }
  }

  Future<AdminStartupDestination> _resolveDestination() async {
    statusText.value = 'Checking bootstrap status...';

    final bool needsSetup =
    await _bootstrapService.shouldShowSuperAdminSetup();

    if (needsSetup) {
      return AdminStartupDestination.setupSuperAdmin;
    }

    statusText.value = 'Checking login session...';

    final bool isLoggedIn = _sessionService.isSignedIn;
    if (!isLoggedIn) {
      return AdminStartupDestination.login;
    }

    statusText.value = 'Checking admin permission...';

    final bool hasAdminAccess =
    await _sessionService.hasCurrentUserAdminAccess();

    if (!hasAdminAccess) {
      await _sessionService.signOut();
      return AdminStartupDestination.login;
    }

    statusText.value = 'Opening dashboard...';
    return AdminStartupDestination.dashboard;
  }
}