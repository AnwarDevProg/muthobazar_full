import 'package:get/get.dart';

import '../controllers/mobile_admin_purchase_controller.dart';

class MobileAdminPurchaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MobileAdminPurchaseController>(
          () => MobileAdminPurchaseController(),
    );
  }
}












