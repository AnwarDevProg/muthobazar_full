// Firestore Auth Debug Helper
// ---------------------------
// Debug-only helper for printing auth-related Firestore documents.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreAuthDebugHelper {
  FirestoreAuthDebugHelper._();

  static const bool enabled = true;

  static Future<void> printUserAndPhoneIndex({
    required String uid,
    required String phone,
  }) async {
    if (!enabled || !kDebugMode) return;

    debugPrint('🔎 DEBUG FIRESTORE STRUCTURE');
    await printUserDoc(uid);
    await printPhoneIndex(phone);
  }

  static Future<void> printUserDoc(String uid) async {
    if (!enabled || !kDebugMode) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) {
      debugPrint('❌ USER DOC NOT FOUND for UID: $uid');
      return;
    }

    debugPrint('================ USER DOCUMENT ================');
    debugPrint('Path: users/$uid');

    final data = doc.data();
    if (data != null) {
      data.forEach((key, value) {
        debugPrint('$key : $value');
      });
    }

    debugPrint('USER JSON: ${doc.data()}');
    debugPrint('================================================');
  }

  static Future<void> printPhoneIndex(String phone) async {
    if (!enabled || !kDebugMode) return;

    final doc = await FirebaseFirestore.instance
        .collection('phone_index')
        .doc(phone)
        .get();

    if (!doc.exists) {
      debugPrint('❌ PHONE INDEX NOT FOUND for: $phone');
      return;
    }

    debugPrint('=============== PHONE INDEX DOCUMENT ===============');
    debugPrint('Path: phone_index/$phone');

    final data = doc.data();
    if (data != null) {
      data.forEach((key, value) {
        debugPrint('$key : $value');
      });
    }

    debugPrint('PHONE INDEX JSON: ${doc.data()}');
    debugPrint('====================================================');
  }
}
