import 'package:admin_web/features/products/controllers/admin_product_controller.dart';
import 'package:get/get.dart';
import 'package:shared_repositories/shared_repositories.dart';


// File: admin_product_binding.dart

class AdminProductBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminProductRepository>()) {
      Get.lazyPut<AdminProductRepository>(
            () => AdminProductRepository(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<AdminProductController>()) {
      Get.lazyPut<AdminProductController>(
            () => AdminProductController(
          repository: Get.find<AdminProductRepository>(),
          autoLoadOnInit: true,
          liveStreamEnabled: false,
        ),
        fenix: true,
      );
    }
  }
}
