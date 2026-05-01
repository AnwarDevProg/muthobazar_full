import 'package:admin_web/features/products/controllers/admin_product_controller.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import 'package:shared_repositories/shared_repositories.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminProductRepository>()) {
      Get.lazyPut<AdminProductRepository>(
            () => AdminProductRepository(
          functions: FirebaseFunctions.instanceFor(region: 'asia-south1'),
        ),
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