import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class AdminActivityLogger {
  AdminActivityLogger._();

  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'asia-south1',
  );

  static Future<void> log({
    required String action,
    required String module,
    required String targetType,
    required String targetId,
    required String targetTitle,
    String status = 'success',
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _functions.httpsCallable('logAdminAction').call({
        'action': action.trim(),
        'module': module.trim(),
        'targetType': targetType.trim(),
        'targetId': targetId.trim(),
        'targetTitle': targetTitle.trim(),
        'status': status.trim(),
        'reason': reason?.trim(),
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
