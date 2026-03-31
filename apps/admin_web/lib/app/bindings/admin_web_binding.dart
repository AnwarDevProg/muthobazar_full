import 'package:admin_web/app/services/admin_permission_gate_service.dart';
import 'package:admin_web/app/services/admin_web_bootstrap_service.dart';
import 'package:admin_web/app/services/admin_web_session_service.dart';
import 'package:admin_web/app/shell/admin_shell_state_controller.dart';
import 'package:get/get.dart';

class AdminWebBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AdminWebSessionService>(
      AdminWebSessionService(),
      permanent: true,
    );

    Get.lazyPut<AdminWebBootstrapService>(
          () => AdminWebBootstrapService(),
      fenix: true,
    );

    Get.lazyPut<AdminPermissionGateService>(
          () => AdminPermissionGateService(),
      fenix: true,
    );

    Get.lazyPut<AdminShellStateController>(
          () => AdminShellStateController(),
      fenix: true,
    );
  }
}