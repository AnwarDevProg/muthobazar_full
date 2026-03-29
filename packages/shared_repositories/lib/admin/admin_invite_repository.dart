import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import'package:shared_models/shared_models.dart';

class AdminInviteRepository {
  AdminInviteRepository._();

  static final AdminInviteRepository instance = AdminInviteRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _inviteCol =>
      _firestore.collection('admin_invites');

  CollectionReference<Map<String, dynamic>> get _permissionCol =>
      _firestore.collection('admin_permissions');

  CollectionReference<Map<String, dynamic>> get _adminCol =>
      _firestore.collection('admins');

  CollectionReference<Map<String, dynamic>> get _userCol =>
      _firestore.collection('users');

  String get currentUid => _auth.currentUser?.uid ?? '';

  Stream<List<MBAdminInvite>> watchAllInvites() {
    return _inviteCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MBAdminInvite.fromMap({
        ...doc.data(),
        'id': doc.id,
      }))
          .toList();
    });
  }

  Stream<List<MBAdminInvite>> watchPendingInvitesForUid(String uid) {
    return _inviteCol
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MBAdminInvite.fromMap({
        ...doc.data(),
        'id': doc.id,
      }))
          .toList();
    });
  }

  Future<UserModel?> findUserByPhone(String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) return null;

    QuerySnapshot<Map<String, dynamic>> snapshot = await _userCol
        .where('PhoneNumber', isEqualTo: cleaned)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      snapshot = await _userCol
          .where('phone', isEqualTo: cleaned)
          .limit(1)
          .get();
    }

    if (snapshot.docs.isEmpty) {
      snapshot = await _userCol
          .where('phoneNumber', isEqualTo: cleaned)
          .limit(1)
          .get();
    }

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data();

    return UserModel.fromMap(doc.id, data);
  }

  Future<MBAdminInvite?> getPendingInviteByUid(String uid) async {
    final snapshot = await _inviteCol
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return MBAdminInvite.fromMap({
      ...doc.data(),
      'id': doc.id,
    });
  }

  Future<MBAdminInvite> createInvite({
    required UserModel targetUser,
    required String role,
    required String invitedByUid,
    required String invitedByName,
    int validDays = 7,
  }) async {
    final existing = await getPendingInviteByUid(targetUser.id);
    if (existing != null) {
      throw Exception('A pending invite already exists for this user.');
    }

    final doc = _inviteCol.doc();
    final now = DateTime.now();

    final invite = MBAdminInvite(
      id: doc.id,
      uid: targetUser.id,
      phone: targetUser.phoneNumber.trim(),
      email: targetUser.email.trim().toLowerCase(),
      name: targetUser.fullName.trim(),
      role: role,
      status: 'pending',
      invitedBy: invitedByUid,
      invitedByName: invitedByName,
      createdAt: now,
      expiresAt: now.add(Duration(days: validDays)),
    );

    await doc.set(invite.toMap());

    return invite;
  }

  Future<void> revokeInvite(String inviteId) async {
    await _inviteCol.doc(inviteId).set(
      {
        'status': 'revoked',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> acceptInvite({
    required MBAdminInvite invite,
    required UserModel user,
  }) async {
    final batch = _firestore.batch();

    final permission = invite.role == 'super_admin'
        ? MBAdminPermission.superAdmin(
      uid: user.id,
      actorUid: invite.invitedBy,
    ).copyWith(
      updatedByUid: user.id,
    )
        : MBAdminPermission.standardAdmin(
      uid: user.id,
      actorUid: invite.invitedBy,
    ).copyWith(
      role: invite.role,
      updatedByUid: user.id,
    );

    batch.set(
      _permissionCol.doc(user.id),
      {
        ...permission.toMap(),
        'uid': user.id,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      _adminCol.doc(user.id),
      {
        'uid': user.id,
        'name': user.fullName.trim(),
        'email': user.email.trim().toLowerCase(),
        'role': invite.role,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdByUid': invite.invitedBy,
        'updatedByUid': user.id,
      },
      SetOptions(merge: true),
    );

    batch.set(
      _inviteCol.doc(invite.id),
      {
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
        'acceptedByUid': user.id,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> rejectInvite({
    required String inviteId,
    required String uid,
  }) async {
    await _inviteCol.doc(inviteId).set(
      {
        'status': 'rejected',
        'rejectedByUid': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}











