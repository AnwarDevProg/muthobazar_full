import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_models/shared_models.dart';

class AdminUserRepository {
  AdminUserRepository._();

  static final AdminUserRepository instance = AdminUserRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  String get currentUid => _auth.currentUser?.uid ?? '';

  User? get currentUser => _auth.currentUser;

  // =========================================================
  // READ: ALL USERS
  // =========================================================

  Stream<List<UserModel>> watchUsers() {
    return usersCollection
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(UserModel.fromSnapshot)
          .map(UserModel.normalized)
          .toList(),
    );
  }

  Future<List<UserModel>> fetchUsersOnce() async {
    final snapshot = await usersCollection
        .orderBy('CreatedAt', descending: true)
        .get();

    return snapshot.docs
        .map(UserModel.fromSnapshot)
        .map(UserModel.normalized)
        .toList();
  }

  // =========================================================
  // READ: SINGLE USER
  // =========================================================

  Stream<UserModel?> watchUserById(String uid) {
    return usersCollection.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      return UserModel.normalized(
        UserModel.fromSnapshot(snapshot),
      );
    });
  }

  Future<UserModel?> fetchUserById(String uid) async {
    final snapshot = await usersCollection.doc(uid).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return UserModel.normalized(
      UserModel.fromSnapshot(snapshot),
    );
  }

  // =========================================================
  // UPDATE: BASIC INFO
  // =========================================================

  Future<void> updateUserBasicInfo({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
    required String role,
    required String accountStatus,
    required bool isGuest,
  }) async {
    await usersCollection.doc(uid).update({
      'FirstName': firstName.trim(),
      'LastName': lastName.trim(),
      'Email': email.trim(),
      'PhoneNumber': phoneNumber.trim(),
      'Gender': gender.trim(),
      'DOB': dateOfBirth.trim(),
      'Role': role.trim().toLowerCase(),
      'AccountStatus': accountStatus.trim().toLowerCase(),
      'IsGuest': isGuest,
      'UpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserProfilePicture({
    required String uid,
    required String profilePicture,
  }) async {
    await usersCollection.doc(uid).update({
      'ProfilePicture': profilePicture.trim(),
      'UpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================
  // UPDATE: ROLE / STATUS
  // =========================================================

  Future<void> setUserRole({
    required String uid,
    required String role,
  }) async {
    await usersCollection.doc(uid).update({
      'Role': role.trim().toLowerCase(),
      'UpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setUserStatus({
    required String uid,
    required String accountStatus,
  }) async {
    await usersCollection.doc(uid).update({
      'AccountStatus': accountStatus.trim().toLowerCase(),
      'UpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> softBlockUser({
    required String uid,
  }) async {
    await setUserStatus(
      uid: uid,
      accountStatus: 'blocked',
    );
  }

  Future<void> softDeactivateUser({
    required String uid,
  }) async {
    await setUserStatus(
      uid: uid,
      accountStatus: 'inactive',
    );
  }

  Future<void> reactivateUser({
    required String uid,
  }) async {
    await setUserStatus(
      uid: uid,
      accountStatus: 'active',
    );
  }
}