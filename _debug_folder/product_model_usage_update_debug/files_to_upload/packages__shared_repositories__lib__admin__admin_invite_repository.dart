import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_models/shared_models.dart';

class AdminInviteRepository {
  AdminInviteRepository._();

  static final AdminInviteRepository instance = AdminInviteRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get invitesCollection =>
      _firestore.collection('admin_invites');

  CollectionReference<Map<String, dynamic>> get adminsCollection =>
      _firestore.collection('admins');

  CollectionReference<Map<String, dynamic>> get adminPermissionsCollection =>
      _firestore.collection('admin_permissions');

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  String get currentUid => _auth.currentUser?.uid ?? '';

  User? get currentUser => _auth.currentUser;

  // =========================================================
  // WATCH ALL INVITES
  // =========================================================

  Stream<List<MBAdminInvite>> watchAllInvites() {
    return invitesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => MBAdminInvite.fromMap(doc.data()))
          .toList(),
    );
  }

  // =========================================================
  // WATCH MY PENDING INVITES
  // =========================================================

  Stream<List<MBAdminInvite>> watchPendingInvitesForUid(String uid) {
    return invitesCollection
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => MBAdminInvite.fromMap(doc.data()))
          .where((invite) => !invite.isExpired)
          .toList(),
    );
  }

  // =========================================================
  // FIND USER BY PHONE
  // =========================================================

  Future<UserModel?> findUserByPhone(String phone) async {
    final input = phone.trim();
    if (input.isEmpty) return null;

    final query = await usersCollection
        .where('PhoneNumber', isEqualTo: input)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return UserModel.fromSnapshot(query.docs.first);
  }

  // =========================================================
  // GET ONE PENDING INVITE FOR USER
  // =========================================================

  Future<MBAdminInvite?> getPendingInviteByUid(String uid) async {
    final query = await invitesCollection
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .limit(5)
        .get();

    if (query.docs.isEmpty) return null;

    final invites = query.docs
        .map((doc) => MBAdminInvite.fromMap(doc.data()))
        .where((invite) => !invite.isExpired)
        .toList();

    if (invites.isEmpty) return null;

    invites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return invites.first;
  }

  // =========================================================
  // CREATE INVITE
  // =========================================================

  Future<MBAdminInvite> createInvite({
    required UserModel targetUser,
    required String role,
    required String invitedByUid,
    required String invitedByName,
  }) async {
    final existing = await getPendingInviteByUid(targetUser.id);
    if (existing != null) {
      throw Exception('This user already has a pending admin invite.');
    }

    final doc = invitesCollection.doc();
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: 7));

    final invite = MBAdminInvite(
      id: doc.id,
      uid: targetUser.id,
      phone: targetUser.phoneNumber.trim(),
      email: targetUser.email.trim(),
      name: targetUser.fullName.trim(),
      role: role.trim().toLowerCase(),
      status: 'pending',
      invitedBy: invitedByUid,
      invitedByName: invitedByName.trim(),
      createdAt: now,
      expiresAt: expiresAt,
    );

    await doc.set(invite.toMap());

    return invite;
  }

  // =========================================================
  // REVOKE INVITE
  // =========================================================

  Future<void> revokeInvite(String inviteId) async {
    final now = DateTime.now();

    await invitesCollection.doc(inviteId).update({
      'status': 'revoked',
      'revokedAt': now.toIso8601String(),
    });
  }

  // =========================================================
  // ACCEPT INVITE
  // =========================================================

  Future<void> acceptInvite({
    required MBAdminInvite invite,
    required UserModel user,
  }) async {
    if (invite.isExpired) {
      throw Exception('This invite has expired.');
    }

    if (!invite.isPending) {
      throw Exception('This invite is no longer pending.');
    }

    if (invite.uid.trim() != user.id.trim()) {
      throw Exception('This invite does not belong to the current user.');
    }

    final batch = _firestore.batch();
    final now = DateTime.now();

    final inviteRef = invitesCollection.doc(invite.id);
    final adminRef = adminsCollection.doc(user.id);
    final permissionRef = adminPermissionsCollection.doc(user.id);

    final permission = invite.role.trim().toLowerCase() == 'super_admin'
        ? MBAdminPermission.superAdmin(
      uid: user.id,
      actorUid: invite.invitedBy,
    )
        : MBAdminPermission.admin(
      uid: user.id,
      actorUid: invite.invitedBy,
    );

    final adminData = <String, dynamic>{
      'uid': user.id,
      'name': user.fullName.trim(),
      'email': user.email.trim(),
      'phone': user.phoneNumber.trim(),
      'role': invite.role.trim().toLowerCase(),
      'isActive': true,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'createdByUid': invite.invitedBy,
      'updatedByUid': user.id,
    };

    final acceptedInvite = invite.copyWith(
      status: 'accepted',
      acceptedAt: now,
      clearRejectedAt: true,
      clearRevokedAt: true,
    );

    batch.set(inviteRef, acceptedInvite.toMap(), SetOptions(merge: true));
    batch.set(adminRef, adminData, SetOptions(merge: true));
    batch.set(permissionRef, permission.toMap(), SetOptions(merge: true));

    await batch.commit();
  }

  // =========================================================
  // REJECT INVITE
  // =========================================================

  Future<void> rejectInvite({
    required String inviteId,
    required String uid,
  }) async {
    final inviteDoc = await invitesCollection.doc(inviteId).get();
    if (!inviteDoc.exists || inviteDoc.data() == null) {
      throw Exception('Invite not found.');
    }

    final invite = MBAdminInvite.fromMap(inviteDoc.data());

    if (invite.uid.trim() != uid.trim()) {
      throw Exception('This invite does not belong to the current user.');
    }

    if (invite.isExpired) {
      throw Exception('This invite has expired.');
    }

    if (!invite.isPending) {
      throw Exception('This invite is no longer pending.');
    }

    final now = DateTime.now();

    final rejectedInvite = invite.copyWith(
      status: 'rejected',
      rejectedAt: now,
      clearAcceptedAt: true,
      clearRevokedAt: true,
    );

    await invitesCollection.doc(inviteId).set(
      rejectedInvite.toMap(),
      SetOptions(merge: true),
    );
  }

  // =========================================================
  // OPTIONAL: EXPIRE OLD INVITES LOCALLY ON READ
  // =========================================================

  Future<void> markInviteExpiredIfNeeded(MBAdminInvite invite) async {
    if (!invite.isPending) return;
    if (!invite.isExpired) return;

    await invitesCollection.doc(invite.id).update({
      'status': 'expired',
    });
  }
}