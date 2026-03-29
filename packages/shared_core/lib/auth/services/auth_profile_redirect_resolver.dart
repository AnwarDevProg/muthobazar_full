import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'auth_profile_redirect_decision.dart';
import 'auth_profile_redirect_result.dart';
import 'core_auth_service.dart';

class AuthProfileRedirectResolver {
  AuthProfileRedirectResolver({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const Duration _firestoreTimeout = Duration(seconds: 8);

  Future<AuthProfileRedirectResult> resolveCurrentUser() async {
    try {
      final User? refreshedUser = await AuthService.reloadCurrentUser();

      if (refreshedUser == null) {
        return const AuthProfileRedirectResult(
          decision: AuthProfileRedirectDecision.unauthenticated,
          message: 'No authenticated Firebase user found.',
        );
      }

      return await _resolveAuthenticatedUser(refreshedUser);
    } catch (e, st) {
      debugPrint('AuthProfileRedirectResolver.resolveCurrentUser error: $e');
      debugPrint('$st');

      return const AuthProfileRedirectResult(
        decision: AuthProfileRedirectDecision.error,
        message: 'Failed to resolve authenticated user.',
      );
    }
  }

  Future<AuthProfileRedirectResult> _resolveAuthenticatedUser(User user) async {
    try {
      final String uid = user.uid.trim();
      final String authPhoneE164 = (user.phoneNumber ?? '').trim();

      if (uid.isEmpty) {
        return const AuthProfileRedirectResult(
          decision: AuthProfileRedirectDecision.missingProfile,
          message: 'Authenticated user UID is empty.',
        );
      }

      if (authPhoneE164.isEmpty) {
        return const AuthProfileRedirectResult(
          decision: AuthProfileRedirectDecision.incompleteProfile,
          message: 'Authenticated phone number is missing.',
        );
      }

      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(_firestoreTimeout);

      if (!doc.exists || doc.data() == null) {
        return const AuthProfileRedirectResult(
          decision: AuthProfileRedirectDecision.missingProfile,
          message: 'User document does not exist.',
        );
      }

      final Map<String, dynamic> data = doc.data()!;

      final String accountStatus =
      (data['AccountStatus'] ?? 'active').toString().trim().toLowerCase();

      final String firstName =
      (data['FirstName'] ?? '').toString().trim();

      final String lastName =
      (data['LastName'] ?? '').toString().trim();

      final String fullName = [firstName, lastName]
          .where((e) => e.isNotEmpty)
          .join(' ');

      final String firestorePhoneLocal =
      (data['PhoneNumber'] ?? '').toString().trim();

      final String firestorePhoneE164 =
      (data['PhoneNumberE164'] ?? '').toString().trim();

      final String role =
      (data['Role'] ?? 'customer').toString().trim().toLowerCase();

      final bool isBlocked = accountStatus == 'blocked' ||
          accountStatus == 'inactive' ||
          accountStatus == 'disabled' ||
          accountStatus == 'suspended';

      if (isBlocked) {
        return AuthProfileRedirectResult(
          decision: AuthProfileRedirectDecision.blocked,
          message: 'Account status is $accountStatus.',
        );
      }

      if (role != 'customer') {
        return AuthProfileRedirectResult(
          decision: AuthProfileRedirectDecision.blocked,
          message: 'User role "$role" is not allowed in customer app.',
        );
      }

      final bool hasFullName = fullName.isNotEmpty;
      final bool hasFirestorePhone =
          firestorePhoneLocal.isNotEmpty || firestorePhoneE164.isNotEmpty;
      final bool hasProperName =
          fullName.length >= 3 && fullName.split(' ').length >= 1;

      final bool isPhoneMatched =
          firestorePhoneE164.isNotEmpty && firestorePhoneE164 == authPhoneE164;

      if (!hasFullName) {
        return const AuthProfileRedirectResult(
          decision: AuthProfileRedirectDecision.incompleteProfile,
          message: 'User name is missing.',
        );
      }

      if (!hasProperName) {
        return const AuthProfileRedirectResult(
          decision: AuthProfileRedirectDecision.incompleteProfile,
          message: 'User name is missing.',
        );
      }

      if (!hasFirestorePhone) {
        return const AuthProfileRedirectResult(
          decision: AuthProfileRedirectDecision.incompleteProfile,
          message: 'Phone number is missing.',
        );
      }

      if (!isPhoneMatched) {
        return const AuthProfileRedirectResult(
          decision: AuthProfileRedirectDecision.incompleteProfile,
          message: 'Firestore E164 phone number does not match authenticated phone number.',
        );
      }

      return const AuthProfileRedirectResult(
        decision: AuthProfileRedirectDecision.active,
        message: 'Customer profile is active and complete.',
      );
    } on TimeoutException {
      return const AuthProfileRedirectResult(
        decision: AuthProfileRedirectDecision.error,
        message: 'User profile lookup timed out.',
      );
    } catch (e, st) {
      debugPrint('AuthProfileRedirectResolver._resolveAuthenticatedUser error: $e');
      debugPrint('$st');

      return const AuthProfileRedirectResult(
        decision: AuthProfileRedirectDecision.error,
        message: 'Unexpected error while resolving authenticated user.',
      );
    }
  }
}