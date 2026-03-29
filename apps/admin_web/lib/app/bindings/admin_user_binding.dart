import 'package:admin_web/features/users/controllers/admin_user_controller.dart';
import 'package:get/get.dart';
class AdminUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminUserController>(
          () => AdminUserController(),
    );
  }
}