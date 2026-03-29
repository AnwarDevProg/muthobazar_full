import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_models/admin/mb_admin_activity_log.dart';

class AdminActivityLogger {
  AdminActivityLogger._();

  static Future<void> log({
    required String adminUid,
    required String adminName,
    required String adminEmail,
    required String adminRole,
    required String action,
    required String targetType,
    required String targetId,
    required String targetTitle,
    required String summary,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
  }) async {
    final log = MBAdminActivityLog(
      id: '',
      adminUid: adminUid,
      adminName: adminName,
      adminEmail: adminEmail,
      adminRole: adminRole,
      action: action,
      targetType: targetType,
      targetId: targetId,
      targetTitle: targetTitle,
      summary: summary,
      beforeData: beforeData,
      afterData: afterData,
    );
    await AdminActivityLogRepository.instance.writeLog(log);

  }
}











