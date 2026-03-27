import 'package:get/get.dart';

import 'package:customer_app/features/cart/controllers/cart_controller.dart';
import 'package:customer_app/features/orders/controllers/order_controller.dart';
import 'package:customer_app/features/profile/controllers/profile_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ProfileController>(
      ProfileController(),
      permanent: true,
    );

    Get.lazyPut<OrderController>(
      () => OrderController(),
      fenix: true,
    );

    Get.put<CartController>(
      CartController(),
      permanent: true,
    );
  }
}


