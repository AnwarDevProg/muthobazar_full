import 'package:get/get.dart';

import '../../features/admin_access/controllers/admin_access_controller.dart';

class AdminAccessBinding extends Bindings {
  @override
  void dependencies() {
    /// 🔥 CORE ADMIN ACCESS CONTROLLER (GLOBAL)
    Get.lazyPut<AdminAccessController>(
          () => AdminAccessController(),
      fenix: true, // ✅ auto-recreate if disposed
    );
  }
}