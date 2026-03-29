import 'package:get/get.dart';

import '../../features/brands/controllers/admin_brand_controller.dart';

class BrandsBinding extends Bindings {
  @override
  void dependencies() {
    /// 🔥 BRAND CONTROLLER
    Get.lazyPut<AdminBrandController>(
          () => AdminBrandController(),
      fenix: true,
    );
  }
}