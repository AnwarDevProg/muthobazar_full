import 'package:permission_handler/permission_handler.dart';

class PermissionService {

  static Future<bool> requestNotifications() async {

    final status = await Permission.notification.request();

    return status.isGranted;
  }

}











