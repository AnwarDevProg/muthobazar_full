// Login Repository
// ----------------
// Login-specific repository behavior.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'phone_auth_repository.dart';

class LoginRepository extends PhoneAuthRepository {
  LoginRepository({
    super.auth,
    super.firestore,
  });

  Future<bool> isPhoneRegistered(String input) async {
    final String normalized = normalizePhoneInput(input);

    final DocumentSnapshot<Map<String, dynamic>> doc = await firestore
        .collection('phone_index')
        .doc(normalized)
        .get();

    return doc.exists;
  }

  Future<void> updateLoginMetadata({
    required String uid,
    required String phone,
  }) async {
    final String normalizedPhone = normalizePhoneInput(phone);
    final String phoneE164 = (auth.currentUser?.phoneNumber ?? '').trim();

    final WriteBatch batch = firestore.batch();

    final userRef = firestore.collection('users').doc(uid);
    final phoneRef = firestore.collection('phone_index').doc(normalizedPhone);

    batch.set(userRef, {
      'LastLoginAt': FieldValue.serverTimestamp(),
      'UpdatedAt': FieldValue.serverTimestamp(),
      'PhoneNumberE164': phoneE164,
    }, SetOptions(merge: true));

    batch.set(phoneRef, {
      'Uid': uid,
      'PhoneNumber': normalizedPhone,
      'PhoneNumberE164': phoneE164,
      'UpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }
}