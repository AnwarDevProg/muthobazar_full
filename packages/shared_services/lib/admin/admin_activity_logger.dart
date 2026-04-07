import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class AdminActivityLogger {
  AdminActivityLogger._();

  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static Future<void> log({
    required String actorUid,
    required String actorName,
    required String actorPhone,
    required String actorRole,
    required String action,
    required String module,
    required String targetType,
    required String targetId,
    required String targetTitle,
    String status = 'success',
    String? reason,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _functions.httpsCallable('logAdminAction').call({
        'actorUid': actorUid,
        'actorName': actorName,
        'actorPhone': actorPhone,
        'actorRole': actorRole,
        'action': action,
        'module': module,
        'targetType': targetType,
        'targetId': targetId,
        'targetTitle': targetTitle,
        'status': status,
        'reason': reason,
        'beforeData': beforeData,
        'afterData': afterData,
        'metadata': metadata,
      });
    } on FirebaseFunctionsException catch (e, s) {
      debugPrint(
        'logAdminAction FirebaseFunctionsException: ${e.code} ${e.message}',
      );
      debugPrintStack(stackTrace: s);
      rethrow;
    } catch (e, s) {
      debugPrint('logAdminAction unknown error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }
}
