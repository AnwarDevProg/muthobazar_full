import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

// Reusable admin repository error helpers for category, brand, and future
// callable-driven admin modules.
abstract final class MBAdminRepositoryErrors {
  static String firestore(FirebaseException error, {String? fallback}) {
    switch (error.code) {
      case 'permission-denied':
        return 'Permission denied while accessing admin data. Check rules or admin permissions.';
      case 'unavailable':
        return 'Firebase service is unavailable right now. Please try again.';
      case 'failed-precondition':
        return 'A Firestore precondition failed. Check indexes, rules, or referenced data.';
      case 'not-found':
        return 'Requested record was not found.';
      case 'deadline-exceeded':
        return 'The Firebase request timed out.';
      case 'cancelled':
        return 'The Firebase request was cancelled.';
      case 'already-exists':
        return 'A record with the same data already exists.';
      case 'invalid-argument':
        return 'The request contains invalid data.';
      default:
        final String? message = error.message?.trim();
        if (message != null && message.isNotEmpty) {
          return message;
        }
        return fallback ?? 'Firebase error (${error.code}) while accessing admin data.';
    }
  }

  static String callable(
    FirebaseFunctionsException error, {
    String fallback = 'Cloud Function request failed.',
  }) {
    final String? message = error.message?.trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }

    final Object? details = error.details;
    if (details is Map) {
      final Object? detailMessage = details['message'];
      final String? safeMessage = detailMessage?.toString().trim();
      if (safeMessage != null && safeMessage.isNotEmpty) {
        return safeMessage;
      }
    }

    if (details is String && details.trim().isNotEmpty) {
      return details.trim();
    }

    switch (error.code) {
      case 'permission-denied':
        return 'Permission denied while running an admin action.';
      case 'already-exists':
        return 'A record with the same data already exists.';
      case 'not-found':
        return 'Requested record was not found.';
      case 'failed-precondition':
        return 'This action cannot be completed in the current state.';
      case 'invalid-argument':
        return 'The request contains invalid data.';
      case 'unavailable':
        return 'Cloud Function service is unavailable right now. Please try again.';
      case 'deadline-exceeded':
        return 'The Cloud Function request timed out.';
      default:
        return fallback;
    }
  }

  static Exception asException(String message) => Exception(message);
}
