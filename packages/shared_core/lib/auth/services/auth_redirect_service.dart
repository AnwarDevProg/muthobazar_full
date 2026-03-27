import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_core/auth/services/core_auth_service.dart';



//final String role = (data['Role'] ?? 'customer').toString().trim().toLowerCase();

class AuthRedirectService {
  AuthRedirectService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> screenRedirect() async {
    try {
      final user = AuthService.currentUser;

      if (user == null) {
        Get.offAllNamed(AppRoutes.welcome);
        return;
      }

      await user.reload();
      final refreshedUser = AuthService.currentUser;

      if (refreshedUser == null) {
        Get.offAllNamed(AppRoutes.welcome);
        return;
      }

      final _RedirectDecision decision =
      await _resolveAuthenticatedUser(refreshedUser);

      switch (decision) {
        case _RedirectDecision.active:
          await _redirectAuthenticatedUser();
          break;

        case _RedirectDecision.blocked:
          Get.offAllNamed(AppRoutes.welcome);
          break;

        case _RedirectDecision.missingProfile:
          Get.offAllNamed(AppRoutes.welcome);
          break;
      }
    } catch (e) {
      debugPrint('AuthRedirectService.screenRedirect error: $e');
      Get.offAllNamed(AppRoutes.welcome);
    }
  }

  Future<void> _redirectAuthenticatedUser() async {
    if (!kIsWeb) {
      Get.offAllNamed(AppRoutes.shell);
      return;
    }

    if (!Get.isRegistered<AdminAccessController>()) {
      Get.offAllNamed(AppRoutes.welcome);
      return;
    }

    final AdminAccessController adminAccessController =
    Get.find<AdminAccessController>();

    int tries = 0;

    while (adminAccessController.isLoading.value && tries < 20) {
      await Future.delayed(const Duration(milliseconds: 200));
      tries++;
    }

    if (adminAccessController.canAccessAdminPanel) {
      Get.offAllNamed(AppRoutes.adminShell);
      return;
    }

    Get.offAllNamed(AppRoutes.welcome);
  }

  Future<_RedirectDecision> _resolveAuthenticatedUser(User user) async {
    try {
      final String uid = user.uid.trim();
      if (uid.isEmpty) {
        return _RedirectDecision.missingProfile;
      }

      final doc =
      await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        return _RedirectDecision.missingProfile;
      }

      final data = doc.data()!;

      final String accountStatus =
      (data['AccountStatus'] ?? 'active').toString().trim().toLowerCase();

      final String firstName =
      (data['FirstName'] ?? '').toString().trim();
      final String lastName =
      (data['LastName'] ?? '').toString().trim();
      final String phoneNumber =
      (data['PhoneNumber'] ?? '').toString().trim();

      final bool hasName = firstName.isNotEmpty || lastName.isNotEmpty;
      final bool hasPhone = phoneNumber.isNotEmpty || (user.phoneNumber ?? '').trim().isNotEmpty;

      if (accountStatus == 'blocked' ||
          accountStatus == 'inactive' ||
          accountStatus == 'disabled' ||
          accountStatus == 'suspended') {
        return _RedirectDecision.blocked;
      }

      if (!hasName && !hasPhone) {
        return _RedirectDecision.missingProfile;
      }

      return _RedirectDecision.active;
    } catch (e) {
      debugPrint('AuthRedirectService._resolveAuthenticatedUser error: $e');
      return _RedirectDecision.missingProfile;
    }
  }
}

enum _RedirectDecision {
  active,
  blocked,
  missingProfile,
}











