import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/shared_models.dart';



class AdminSetupRepository {
  AdminSetupRepository._();

  static final AdminSetupRepository instance = AdminSetupRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get adminPermissionsCollection =>
      _db.collection('admin_permissions');

  CollectionReference<Map<String, dynamic>> get adminsCollection =>
      _db.collection('admins');

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _db.collection('users');

  Future<bool> hasAnyActiveSuperAdmin() async {
    final snapshot = await adminPermissionsCollection
        .where('role', isEqualTo: 'super_admin')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> bootstrapFirstSuperAdmin({
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) async {
    final alreadyExists = await hasAnyActiveSuperAdmin();
    if (alreadyExists) {
      throw Exception('A super admin already exists.');
    }

    final permission = MBAdminPermission.superAdmin(
      uid: uid,
      actorUid: uid,
    );

    final parts = UserModel.splitFullName(name);

    final batch = _db.batch();

    batch.set(
      adminPermissionsCollection.doc(uid),
      {
        ...permission.toMap(),
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      adminsCollection.doc(uid),
      {
        'uid': uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'role': 'super_admin',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdByUid': uid,
        'updatedByUid': uid,
      },
      SetOptions(merge: true),
    );

    batch.set(
      usersCollection.doc(uid),
      {
        'FirstName': parts[0],
        'LastName': parts[1],
        'Email': email.trim(),
        'PhoneNumber': phone.trim(),
        'Role': 'super_admin',
        'AccountStatus': 'active',
        'IsGuest': false,
        'UpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}











