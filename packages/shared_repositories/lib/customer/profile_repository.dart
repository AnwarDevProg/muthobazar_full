// Profile Repository
// ------------------
// Handles profile data, profile updates, phone update flows,
// phone index sync, account deletion, and Firebase profile helpers.

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_models/customer/mb_user_profile.dart';
import 'package:shared_repositories/customer/phone_auth_repository.dart';


class ProfileRepository {
  ProfileRepository._();

  static final ProfileRepository instance = ProfileRepository._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final PhoneAuthRepository _phoneAuthRepository = PhoneAuthRepository();

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  DocumentReference<Map<String, dynamic>> userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  CollectionReference<Map<String, dynamic>> get phoneIndexCollection {
    return _firestore.collection('phone_index');
  }

  CollectionReference<Map<String, dynamic>> get phoneHistoryCollection {
    return _firestore.collection('phone_history');
  }

  bool isValidBangladeshMobile(String input) {
    return _phoneAuthRepository.isValidBangladeshMobile(input);
  }

  String normalizePhoneInput(String input) {
    return _phoneAuthRepository.normalizePhoneInput(input);
  }

  String formatPhoneForFirebase(String input) {
    return _phoneAuthRepository.formatPhoneForFirebase(input);
  }

  String mapFirebaseAuthException(FirebaseAuthException e) {
    return _phoneAuthRepository.mapFirebaseAuthException(e);
  }

  Future<void> verifyPhoneNumber({
    required String firebasePhoneNumber,
    required Duration timeout,
    required int? forceResendingToken,
    required Future<void> Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _phoneAuthRepository.verifyPhoneNumber(
      firebasePhoneNumber: firebasePhoneNumber,
      timeout: timeout,
      forceResendingToken: forceResendingToken,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Stream<UserModel> watchUser(String uid) {
    return userDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return UserModel(
          id: uid,
          firstName: '',
          lastName: '',
          email: currentFirebaseUser?.email ?? '',
          phoneNumber: normalizePhoneInput(currentFirebaseUser?.phoneNumber ?? ''),
          profilePicture: currentFirebaseUser?.photoURL ?? '',
          gender: '',
          dateOfBirth: '',
          role: 'customer',
          accountStatus: 'active',
          isGuest: false,
          defaultAddressId: '',
          addresses: const [],
        );
      }

      return UserModel.fromSnapshot(snapshot);
    });
  }

  Future<UserModel> fetchUserOnce(String uid) async {
    final snapshot = await userDoc(uid).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return UserModel(
        id: uid,
        firstName: '',
        lastName: '',
        email: currentFirebaseUser?.email ?? '',
        phoneNumber: normalizePhoneInput(currentFirebaseUser?.phoneNumber ?? ''),
        profilePicture: currentFirebaseUser?.photoURL ?? '',
        gender: '',
        dateOfBirth: '',
        role: 'customer',
        accountStatus: 'active',
        isGuest: false,
        defaultAddressId: '',
        addresses: const [],
      );
    }

    return UserModel.fromSnapshot(snapshot);
  }

  Future<void> ensurePhoneIndex({
    required String uid,
    required String rawPhone,
    String? phoneE164,
  }) async {
    final normalized = normalizePhoneInput(rawPhone);
    final resolvedPhoneE164 = (phoneE164 ?? currentFirebaseUser?.phoneNumber ?? '').trim();

    if (normalized.isEmpty) return;

    await phoneIndexCollection.doc(normalized).set({
      'Uid': uid,
      'PhoneNumber': normalized,
      'PhoneNumberE164': resolvedPhoneE164,
      'UpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> createUserDocIfMissing({
    required String uid,
    required String fullName,
    String email = '',
    String phoneNumber = '',
    String profilePicture = '',
  }) async {
    final doc = await userDoc(uid).get();
    final normalizedPhone = normalizePhoneInput(phoneNumber);
    final phoneE164 = (currentFirebaseUser?.phoneNumber ?? '').trim();

    if (doc.exists) {
      final updateData = <String, dynamic>{
        'LastLoginAt': FieldValue.serverTimestamp(),
        'UpdatedAt': FieldValue.serverTimestamp(),
      };

      if (phoneE164.isNotEmpty) {
        updateData['PhoneNumberE164'] = phoneE164;
      }

      await userDoc(uid).set(updateData, SetOptions(merge: true));

      if (normalizedPhone.isNotEmpty) {
        await ensurePhoneIndex(
          uid: uid,
          rawPhone: normalizedPhone,
          phoneE164: phoneE164,
        );
      }
      return;
    }

    final parts = UserModel.splitFullName(fullName);

    await userDoc(uid).set({
      'FirstName': parts[0],
      'LastName': parts[1],
      'Email': email,
      'PhoneNumber': normalizedPhone,
      'PhoneNumberE164': phoneE164,
      'ProfilePicture': profilePicture,
      'Gender': '',
      'DOB': '',
      'Role': 'customer',
      'AccountStatus': 'active',
      'IsGuest': false,
      'DefaultAddressId': '',
      'Addresses': <Map<String, dynamic>>[],
      'CreatedAt': FieldValue.serverTimestamp(),
      'UpdatedAt': FieldValue.serverTimestamp(),
      'LastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (normalizedPhone.isNotEmpty) {
      await ensurePhoneIndex(
        uid: uid,
        rawPhone: normalizedPhone,
        phoneE164: phoneE164,
      );
    }
  }

  Future<void> updateName({
    required String uid,
    required String fullName,
  }) async {
    final parts = UserModel.splitFullName(fullName);

    await userDoc(uid).set({
      'FirstName': parts[0],
      'LastName': parts[1],
      'UpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (_auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(fullName.trim());
    }
  }

  Future<String> uploadProfilePicture({
    required String uid,
    required File imageFile,
  }) async {
    final ref = _storage
        .ref()
        .child('profile_pictures')
        .child(uid)
        .child('profile.jpg');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      cacheControl: 'public,max-age=3600',
    );

    await ref.putFile(imageFile, metadata);

    final url = await ref.getDownloadURL();

    return '$url?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> updateProfilePicture({
    required String uid,
    required String imageUrl,
  }) async {
    await userDoc(uid).set({
      'ProfilePicture': imageUrl,
      'UpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (_auth.currentUser != null) {
      await _auth.currentUser!.updatePhotoURL(imageUrl);
    }
  }

  Future<bool> isPhoneAvailableForUpdate({
    required String rawPhone,
    required String currentUid,
  }) async {
    final normalized = normalizePhoneInput(rawPhone);
    final doc = await phoneIndexCollection.doc(normalized).get();

    if (!doc.exists) return true;

    final data = doc.data();
    final existingUid =
    (data != null ? (data['Uid'] ?? data['uid'] ?? '') : '').toString();

    return existingUid == currentUid;
  }

  Future<int> _getNextPhoneHistorySequence(String uid) async {
    final query = await phoneHistoryCollection
        .where('Uid', isEqualTo: uid)
        .orderBy('Sequence', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return 1;
    }

    final data = query.docs.first.data();
    final currentSequence = (data['Sequence'] as num?)?.toInt() ?? 0;
    return currentSequence + 1;
  }

  Future<void> updatePhoneNumberAndIndexes({
    required String uid,
    required String oldRawPhone,
    required String newRawPhone,
    required PhoneAuthCredential credential,
  }) async {
    if (_auth.currentUser == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No logged-in user found.',
      );
    }

    final oldPhone = normalizePhoneInput(oldRawPhone);
    final newPhone = normalizePhoneInput(newRawPhone);

    if (oldPhone == newPhone) return;

    final bool isAvailable = await isPhoneAvailableForUpdate(
      rawPhone: newPhone,
      currentUid: uid,
    );

    if (!isAvailable) {
      throw FirebaseAuthException(
        code: 'phone-already-in-use',
        message: 'This phone number is already registered with another account.',
      );
    }

    final int nextSequence = await _getNextPhoneHistorySequence(uid);

    await _auth.currentUser!.updatePhoneNumber(credential);

    final String phoneE164 = (_auth.currentUser?.phoneNumber ?? '').trim();

    final WriteBatch batch = _firestore.batch();

    batch.set(
      userDoc(uid),
      {
        'PhoneNumber': newPhone,
        'PhoneNumberE164': phoneE164,
        'UpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    if (oldPhone.isNotEmpty) {
      batch.delete(phoneIndexCollection.doc(oldPhone));
    }

    batch.set(
      phoneIndexCollection.doc(newPhone),
      {
        'Uid': uid,
        'PhoneNumber': newPhone,
        'PhoneNumberE164': phoneE164,
        'UpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    final historyRef = phoneHistoryCollection.doc();

    batch.set(historyRef, {
      'Uid': uid,
      'OldPhoneNumber': oldPhone,
      'NewPhoneNumber': newPhone,
      'ChangedAt': FieldValue.serverTimestamp(),
      'ChangeType': 'user_phone_update',
      'Sequence': nextSequence,
    });

    await batch.commit();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> reauthenticateWithCredential(
      PhoneAuthCredential credential,
      ) async {
    if (_auth.currentUser == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No logged-in user found.',
      );
    }

    await _auth.currentUser!.reauthenticateWithCredential(credential);
  }

  Future<void> deleteAccountCompletely({
    required String uid,
  }) async {
    if (_auth.currentUser == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No logged-in user found.',
      );
    }

    final userSnapshot = await userDoc(uid).get();
    final data = userSnapshot.data();
    final phone = normalizePhoneInput((data?['PhoneNumber'] ?? '').toString());

    final batch = _firestore.batch();

    batch.delete(userDoc(uid));

    if (phone.isNotEmpty) {
      batch.delete(phoneIndexCollection.doc(phone));
    }

    await batch.commit();
    await _auth.currentUser!.delete();
  }

  Future<void> updateProfileInfo({
    required String uid,
    required Map<String, dynamic> changedData,
  }) async {
    if (changedData.isEmpty) return;

    final payload = <String, dynamic>{
      ...changedData,
      'UpdatedAt': FieldValue.serverTimestamp(),
    };

    await userDoc(uid).set(payload, SetOptions(merge: true));
  }
}