// Firestore Phone Update Debug Helper
// -----------------------------------
// Debug helper to inspect phone update related Firestore documents.
//
// Prints:
// - users/{uid}
// - phone_index/{phone}
// - latest phone_history record

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestorePhoneUpdateDebugHelper {
  FirestorePhoneUpdateDebugHelper._();

  static const bool enabled = true;

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> printPhoneUpdateState({
    required String uid,
    required String phone,
  }) async {
    if (!enabled || !kDebugMode) return;

    debugPrint('================ PHONE UPDATE DEBUG ================');

    await _printUserDoc(uid);
    await _printPhoneIndex(phone);
    await _printLatestPhoneHistory(uid);

    debugPrint('=====================================================');
  }

  static Future<void> _printUserDoc(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      debugPrint('USER DOC NOT FOUND: users/$uid');
      return;
    }

    debugPrint('USER DOC -> users/$uid');

    final data = doc.data();
    data?.forEach((key, value) {
      debugPrint('$key : $value');
    });
  }

  static Future<void> _printPhoneIndex(String phone) async {
    final doc = await _firestore.collection('phone_index').doc(phone).get();

    if (!doc.exists) {
      debugPrint('PHONE INDEX NOT FOUND: phone_index/$phone');
      return;
    }

    debugPrint('PHONE INDEX -> phone_index/$phone');

    final data = doc.data();
    data?.forEach((key, value) {
      debugPrint('$key : $value');
    });
  }

  static Future<void> _printLatestPhoneHistory(String uid) async {
    final query = await _firestore
        .collection('phone_history')
        .where('Uid', isEqualTo: uid)
        .orderBy('Sequence', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      debugPrint('NO PHONE HISTORY FOUND');
      return;
    }

    final doc = query.docs.first;

    debugPrint('LATEST PHONE HISTORY -> ${doc.id}');

    final data = doc.data();
    data.forEach((key, value) {
      debugPrint('$key : $value');
    });
  }
}
