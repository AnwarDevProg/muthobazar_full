import 'package:admin_web/features/marketing/controllers/admin_home_section_controller.dart';
import 'package:get/get.dart';

class AdminHomeSectionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminHomeSectionController>()) {
      Get.lazyPut<AdminHomeSectionController>(
            () => AdminHomeSectionController(),
        fenix: true,
      );
    }
  }
}
