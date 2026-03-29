import 'package:get/get.dart';

import '../../features/profile/controllers/admin_profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminProfileController>(
          () => AdminProfileController(),
      fenix: true,
    );
  }
}