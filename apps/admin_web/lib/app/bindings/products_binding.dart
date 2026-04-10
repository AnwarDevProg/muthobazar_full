import 'package:get/get.dart';
import 'package:shared_repositories/shared_repositories.dart';

import '../../features/products/controllers/admin_product_controller.dart';

class ProductsBinding extends Bindings {
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