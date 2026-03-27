import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/admin/mb_admin_permission.dart';

class AdminAccessRepository {
  AdminAccessRepository._();

  static final AdminAccessRepository instance = AdminAccessRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get adminPermissionsCollection =>
      _firestore.collection('admin_permissions');

  CollectionReference<Map<String, dynamic>> get adminsCollection =>
      _firestore.collection('admins');

  String get currentUid => _auth.currentUser?.uid ?? '';

  Future<MBAdminPermission?> fetchPermission(String uid) async {
    final doc = await adminPermissionsCollection.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return MBAdminPermission.fromMap(doc.data());
  }

  Stream<MBAdminPermission?> watchPermission(String uid) {
    return adminPermissionsCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return MBAdminPermission.fromMap(doc.data());
    });
  }

  Future<void> savePermission({
    required MBAdminPermission permission,
  }) async {
    await adminPermissionsCollection.doc(permission.uid).set(
      {
        ...permission.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deactivateAdminPermission({
    required String uid,
    required String actorUid,
  }) async {
    await adminPermissionsCollection.doc(uid).set(
      {
        'uid': uid,
        'isActive': false,
        'updatedByUid': actorUid,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> createAdminProfile({
    required String uid,
    required String name,
    required String email,
    required String role,
    required String createdByUid,
  }) async {
    await adminsCollection.doc(uid).set(
      {
        'uid': uid,
        'name': name,
        'email': email.trim().toLowerCase(),
        'role': role,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdByUid': createdByUid,
        'updatedByUid': createdByUid,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateAdminProfileRole({
    required String uid,
    required String role,
    required String actorUid,
  }) async {
    await adminsCollection.doc(uid).set(
      {
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedByUid': actorUid,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> setAdminProfileActiveState({
    required String uid,
    required bool isActive,
    required String actorUid,
  }) async {
    await adminsCollection.doc(uid).set(
      {
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedByUid': actorUid,
      },
      SetOptions(merge: true),
    );
  }

  Stream<List<Map<String, dynamic>>> watchAdmins() {
    return adminsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': (data['uid'] ?? doc.id).toString(),
          'name': (data['name'] ?? '').toString(),
          'email': (data['email'] ?? '').toString(),
          'role': (data['role'] ?? 'admin').toString(),
          'isActive': data['isActive'] ?? true,
          'createdAt': data['createdAt'],
          'updatedAt': data['updatedAt'],
        };
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> fetchAdminsOnce() async {
    final snapshot =
    await adminsCollection.orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': (data['uid'] ?? doc.id).toString(),
        'name': (data['name'] ?? '').toString(),
        'email': (data['email'] ?? '').toString(),
        'role': (data['role'] ?? 'admin').toString(),
        'isActive': data['isActive'] ?? true,
        'createdAt': data['createdAt'],
        'updatedAt': data['updatedAt'],
      };
    }).toList();
  }

  Future<void> updateAdminAccess({
    required String uid,
    required String name,
    required String email,
    required MBAdminPermission permission,
    required String actorUid,
  }) async {
    final WriteBatch batch = _firestore.batch();

    batch.set(
      adminPermissionsCollection.doc(uid),
      {
        ...permission.copyWith(
          uid: uid,
          updatedByUid: actorUid,
        ).toMap(),
        'uid': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      adminsCollection.doc(uid),
      {
        'uid': uid,
        'name': name,
        'email': email.trim().toLowerCase(),
        'role': permission.role,
        'isActive': permission.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedByUid': actorUid,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> deleteAdminAccess({
    required String uid,
  }) async {
    final WriteBatch batch = _firestore.batch();

    batch.delete(adminPermissionsCollection.doc(uid));
    batch.delete(adminsCollection.doc(uid));

    await batch.commit();
  }

  Future<bool> isCurrentUserSuperAdmin() async {
    final uid = currentUid;
    if (uid.isEmpty) return false;

    final permission = await fetchPermission(uid);
    if (permission == null) return false;

    return permission.isActive &&
        permission.canAccessAdminPanel &&
        permission.role == 'super_admin';
  }

  Future<bool> canCurrentUserAccessAdminPanel() async {
    final uid = currentUid;
    if (uid.isEmpty) return false;

    final permission = await fetchPermission(uid);
    if (permission == null) return false;

    return permission.isActive && permission.canAccessAdminPanel;
  }
}











