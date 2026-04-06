import 'package:get/get.dart';

class PlaceholderFeatureBinding extends Bindings {
  @override
  void dependencies() {
    // 🔥 Intentionally empty for now

    // This ensures:
    // - every route has a binding (clean architecture)
    // - easy upgrade later (just add controller here)
    // - no missing dependency crash

    // 👉 Example future upgrade:
    // Get.lazyPut(() => OrdersController());
    // Get.lazyPut(() => InventoryController());
  }
}