import 'package:get/get.dart';

import '../../../app/services/admin_web_bootstrap_service.dart';

class SuperAdminBootstrapGuard {
  SuperAdminBootstrapGuard({
    AdminWebBootstrapService? bootstrapService,
  }) : _bootstrapService =
      bootstrapService ?? Get.find<AdminWebBootstrapService>();

  final AdminWebBootstrapService _bootstrapService;

  Future<bool> shouldGoToSetupPage() {
    return _bootstrapService.shouldShowSuperAdminSetup();
  }
}