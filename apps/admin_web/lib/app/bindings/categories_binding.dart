import 'package:get/get.dart';

import '../../features/categories/controllers/admin_category_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    /// 🔥 CATEGORY CONTROLLER
    Get.lazyPut<AdminCategoryController>(
          () => AdminCategoryController(),
      fenix: true,
    );
  }
}











