import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/customer/mb_user_profile.dart';


class AdminUserRepository {
  AdminUserRepository._();

  static final AdminUserRepository instance = AdminUserRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  Stream<List<UserModel>> watchUsers() {
    return usersCollection
        .orderBy('UpdatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromSnapshot(doc);
      }).toList();
    });
  }

  Future<List<UserModel>> fetchUsersOnce() async {
    final snapshot = await usersCollection
        .orderBy('UpdatedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return UserModel.fromSnapshot(doc);
    }).toList();
  }

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
    await usersCollection.doc(uid).set({
      'FirstName': firstName,
      'LastName': lastName,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'Gender': gender,
      'DOB': dateOfBirth,
      'Role': role,
      'AccountStatus': accountStatus,
      'IsGuest': isGuest,
      'UpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setUserStatus({
    required String uid,
    required String accountStatus,
  }) async {
    await usersCollection.doc(uid).set({
      'AccountStatus': accountStatus,
      'UpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setUserRole({
    required String uid,
    required String role,
  }) async {
    await usersCollection.doc(uid).set({
      'Role': role,
      'UpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> softBlockUser({
    required String uid,
  }) async {
    await usersCollection.doc(uid).set({
      'AccountStatus': 'blocked',
      'UpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> softDeactivateUser({
    required String uid,
  }) async {
    await usersCollection.doc(uid).set({
      'AccountStatus': 'inactive',
      'UpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> reactivateUser({
    required String uid,
  }) async {
    await usersCollection.doc(uid).set({
      'AccountStatus': 'active',
      'UpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}











