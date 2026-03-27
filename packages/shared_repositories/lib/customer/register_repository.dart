import 'package:cloud_firestore/cloud_firestore.dart';

import 'phone_auth_repository.dart';

class RegisterRepository extends PhoneAuthRepository {
  RegisterRepository({
    super.auth,
    super.firestore,
  });

  Future<bool> isPhoneAlreadyRegistered(String input) async {
    final String normalized = normalizePhoneInput(input);

    final DocumentSnapshot<Map<String, dynamic>> doc = await firestore
        .collection('phone_index')
        .doc(normalized)
        .get();

    return doc.exists;
  }

  Future<void> createUserRecord({
    required String uid,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String role = 'customer',
  }) async {
    final String normalizedPhone = normalizePhoneInput(phoneNumber);
    final String phoneE164 = (auth.currentUser?.phoneNumber ?? '').trim();

    final WriteBatch batch = firestore.batch();

    final DocumentReference<Map<String, dynamic>> userRef =
    firestore.collection('users').doc(uid);

    final DocumentReference<Map<String, dynamic>> phoneRef =
    firestore.collection('phone_index').doc(normalizedPhone);

    batch.set(userRef, {
      'Email': '',
      'FirstName': firstName,
      'LastName': lastName,
      'PhoneNumber': normalizedPhone,
      'PhoneNumberE164': phoneE164,
      'CreatedAt': FieldValue.serverTimestamp(),
      'UpdatedAt': FieldValue.serverTimestamp(),
      'Gender': '',
      'IsGuest': false,
      'Role': role,
      'Addresses': [],
      'AccountStatus': 'active',
      'DOB': '',
      'DefaultAddressId': '',
      'LastLoginAt': FieldValue.serverTimestamp(),
      'ProfilePicture': '',
    });

    batch.set(phoneRef, {
      'Uid': uid,
      'PhoneNumber': normalizedPhone,
      'PhoneNumberE164': phoneE164,
      'UpdatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}