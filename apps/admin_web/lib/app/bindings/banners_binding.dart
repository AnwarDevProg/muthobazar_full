import 'package:admin_web/features/banners/controllers/admin_banner_controller.dart';
import 'package:get/get.dart';

class BannersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminBannerController>(
          () => AdminBannerController(),
    );
  }
}