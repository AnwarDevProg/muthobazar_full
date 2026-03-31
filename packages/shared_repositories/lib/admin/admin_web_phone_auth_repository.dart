import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_repositories/customer/phone_auth_repository.dart';

class AdminWebPhoneAuthRepository extends PhoneAuthRepository {
  AdminWebPhoneAuthRepository({
    super.auth,
    super.firestore,
  });

  ConfirmationResult? _confirmationResult;

  bool get hasPendingConfirmation => _confirmationResult != null;

  void clearPendingConfirmation() {
    _confirmationResult = null;
  }

  Future<void> sendOtpWeb({
    required String firebasePhoneNumber,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError(
        'Admin web phone authentication is intended for web only.',
      );
    }

    _confirmationResult = await auth.signInWithPhoneNumber(
      firebasePhoneNumber,
    );
  }

  Future<UserCredential> confirmOtpWeb({
    required String smsCode,
  }) async {
    final ConfirmationResult? result = _confirmationResult;

    if (result == null) {
      throw FirebaseAuthException(
        code: 'missing-confirmation-result',
        message: 'Please request OTP first.',
      );
    }

    return result.confirm(smsCode.trim());
  }
}