import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_models/shared_models.dart';

class SetupSuperAdminService {
  SetupSuperAdminService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> bootstrapFirstSuperAdmin({
    required String fullName,
    required String email,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No signed-in user found.');
    }

    final String uid = user.uid;
    final DateTime now = DateTime.now();

    final DocumentReference<Map<String, dynamic>> bootstrapRef =
    _firestore.collection('system').doc('bootstrap');

    final DocumentReference<Map<String, dynamic>> permissionRef =
    _firestore.collection('admin_permissions').doc(uid);

    final DocumentReference<Map<String, dynamic>> adminProfileRef =
    _firestore.collection('admins').doc(uid);

    final MBAdminPermission permission = MBAdminPermission.superAdmin(
      uid: uid,
      actorUid: uid,
    );

    await _firestore.runTransaction((transaction) async {
      final bootstrapSnap = await transaction.get(bootstrapRef);

      if (!bootstrapSnap.exists) {
        throw Exception(
          'Bootstrap document is missing. Create /system/bootstrap first.',
        );
      }

      final Map<String, dynamic> bootstrapData = bootstrapSnap.data() ?? {};

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

      transaction.set(permissionRef, permission.toMap());

      transaction.set(adminProfileRef, {
        'uid': uid,
        'name': fullName.trim(),
        'email': email.trim(),
        'role': 'super_admin',
        'isActive': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'createdByUid': uid,
        'updatedByUid': uid,
      });

      transaction.update(bootstrapRef, {
        'allowFirstSuperAdminSetup': false,
        'firstSuperAdminUid': uid,
        'bootstrapCompleted': true,
        'updatedAt': now.toIso8601String(),
      });
    });
  }
}