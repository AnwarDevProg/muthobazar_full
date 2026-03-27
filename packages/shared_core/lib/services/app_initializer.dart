import 'notification_service.dart';
import 'storage_service.dart';

class AppInitializer {
  AppInitializer._();

  static Future<void> initialize() async {
    await StorageService.init();
   // await FirebaseService.init();
    await NotificationService.init();
  }
}











