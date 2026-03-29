import 'package:admin_web/features/products/controllers/admin_product_controller.dart';
import 'package:get/get.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminProductController>(
          () => AdminProductController(),
    );
  }
}