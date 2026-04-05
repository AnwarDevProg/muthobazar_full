import 'package:admin_web/features/audit_logs/controllers/admin_activity_log_controller.dart';
import 'package:get/get.dart';
import 'package:shared_repositories/admin/admin_activity_log_repository.dart';


class AdminActivityLogsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminActivityLogRepository>()) {
      Get.put<AdminActivityLogRepository>(
        AdminActivityLogRepository.instance,
        permanent: true,
      );
    }

    if (!Get.isRegistered<AdminActivityLogController>()) {
      Get.lazyPut<AdminActivityLogController>(
            () => AdminActivityLogController(
          repository: Get.find<AdminActivityLogRepository>(),
        ),
      );
    }
  }
}