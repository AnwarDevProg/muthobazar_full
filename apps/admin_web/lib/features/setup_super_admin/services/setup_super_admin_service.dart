import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';

class SetupSuperAdminService {
  SetupSuperAdminService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    PhoneAuthRepository? phoneRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _phoneRepository = phoneRepository ?? PhoneAuthRepository();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final PhoneAuthRepository _phoneRepository;

  Future<void> bootstrapFirstSuperAdmin({
    required String fullName,
    required String phoneNumber,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No signed-in user found.');
    }

    final String uid = user.uid;
    final String trimmedName =
    fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmedName.isEmpty) {
      throw Exception('Full name is required.');
    }

    final String phoneE164 = (user.phoneNumber ?? '').trim();
    if (phoneE164.isEmpty) {
      throw Exception('Verified phone number is missing on the current user.');
    }

    final String normalizedPhone = _phoneRepository.normalizePhoneInput(
      phoneNumber.isNotEmpty ? phoneNumber : phoneE164,
    );

    if (!_phoneRepository.isValidBangladeshMobile(normalizedPhone)) {
      throw Exception('Invalid verified phone number.');
    }

    final List<String> names = _phoneRepository.splitFullName(trimmedName);
    final MBAdminPermission permission = MBAdminPermission.superAdmin(
      uid: uid,
      actorUid: uid,
    );

    final DocumentReference<Map<String, dynamic>> bootstrapRef =
    _firestore.collection('system').doc('bootstrap');

    final DocumentReference<Map<String, dynamic>> permissionRef =
    _firestore.collection('admin_permissions').doc(uid);

    final DocumentReference<Map<String, dynamic>> adminProfileRef =
    _firestore.collection('admins').doc(uid);

    final DocumentReference<Map<String, dynamic>> userRef =
    _firestore.collection('users').doc(uid);

    final DocumentReference<Map<String, dynamic>> phoneRef =
    _firestore.collection('phone_index').doc(normalizedPhone);

    await _firestore.runTransaction((transaction) async {
      final bootstrapSnap = await transaction.get(bootstrapRef);

      if (!bootstrapSnap.exists) {
        throw Exception(
          'Bootstrap document is missing. Create /system/bootstrap first.',
        );
      }

      final Map<String, dynamic> bootstrapData =
          bootstrapSnap.data() ?? <String, dynamic>{};

      final bool allowFirstSuperAdminSetup =
          bootstrapData['allowFirstSuperAdminSetup'] == true;
      final bool bootstrapCompleted =
          bootstrapData['bootstrapCompleted'] == true;

      if (!allowFirstSuperAdminSetup || bootstrapCompleted) {
        throw Exception('First super admin setup is already closed.');
      }

      final permissionSnap = await transaction.get(permissionRef);
      final adminProfileSnap = await transaction.get(adminProfileRef);

      if (permissionSnap.exists || adminProfileSnap.exists) {
        throw Exception('This account already has bootstrap data.');
      }

      transaction.set(permissionRef, {
        ...permission.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(adminProfileRef, {
        'uid': uid,
        'name': trimmedName,
        'phoneNumber': normalizedPhone,
        'phoneNumberE164': phoneE164,
        'email': '',
        'role': 'super_admin',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdByUid': uid,
        'updatedByUid': uid,
      });

      transaction.set(
        userRef,
        {
          'Email': '',
          'FirstName': names[0],
          'LastName': names[1],
          'PhoneNumber': normalizedPhone,
          'PhoneNumberE164': phoneE164,
          'CreatedAt': FieldValue.serverTimestamp(),
          'UpdatedAt': FieldValue.serverTimestamp(),
          'Gender': '',
          'IsGuest': false,
          'Role': 'super_admin',
          'Addresses': <dynamic>[],
          'AccountStatus': 'active',
          'DOB': '',
          'DefaultAddressId': '',
          'LastLoginAt': FieldValue.serverTimestamp(),
          'ProfilePicture': '',
        },
        SetOptions(merge: true),
      );

      transaction.set(
        phoneRef,
        {
          'Uid': uid,
          'PhoneNumber': normalizedPhone,
          'PhoneNumberE164': phoneE164,
          'UpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      transaction.update(bootstrapRef, {
        'allowFirstSuperAdminSetup': false,
        'firstSuperAdminUid': uid,
        'bootstrapCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    if (user.displayName != trimmedName) {
      await user.updateDisplayName(trimmedName);
      await user.reload();
    }
  }
}