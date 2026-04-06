import 'package:admin_web/app/services/admin_permission_gate_service.dart';
import 'package:admin_web/app/services/admin_web_bootstrap_service.dart';
import 'package:admin_web/app/services/admin_web_session_service.dart';
import 'package:admin_web/app/shell/admin_shell_state_controller.dart';
import 'package:get/get.dart';

class AdminWebBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      AdminWebSessionService(),
      permanent: true,
    );

    Get.lazyPut(
          () => AdminWebBootstrapService(),
      fenix: true,
    );

    Get.lazyPut(
          () => AdminPermissionGateService(),
      fenix: true,
    );

    if (!Get.isRegistered<AdminShellStateController>()) {
      Get.put(
        AdminShellStateController(),
        permanent: true,
      );
    }
  }
}
