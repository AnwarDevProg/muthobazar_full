import 'package:get/get.dart';

import '../../features/dashboard/controllers/admin_management_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminManagementController>(
          () => AdminManagementController(),
      fenix: true,
    );
  }
}