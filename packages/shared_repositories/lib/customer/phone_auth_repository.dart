// Phone Auth Repository
// ---------------------
// Shared phone/OTP auth helpers for login and register flows.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthRepository {
  PhoneAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  String translateBanglaToEngNum(String input) {
    const Map<String, String> bengaliToEnglish = {
      '০': '0',
      '১': '1',
      '২': '2',
      '৩': '3',
      '৪': '4',
      '৫': '5',
      '৬': '6',
      '৭': '7',
      '৮': '8',
      '৯': '9',
    };

    final StringBuffer buffer = StringBuffer();

    for (final char in input.split('')) {
      buffer.write(bengaliToEnglish[char] ?? char);
    }

    return buffer.toString();
  }

  // Canonical DB/storage format:
  // 017XXXXXXXX
  String normalizePhoneInput(String input) {
    String value = input.trim();
    value = translateBanglaToEngNum(value);

    value = value.replaceAll(RegExp(r'[^\d+]'), '');

    if (value.startsWith('+880')) {
      value = '0${value.substring(4)}';
    } else if (value.startsWith('880')) {
      value = '0${value.substring(3)}';
    }

    return value;
  }

  bool isValidBangladeshMobile(String input) {
    final String value = normalizePhoneInput(input);
    return RegExp(r'^01[3-9]\d{8}$').hasMatch(value);
  }

  String formatPhoneForFirebase(String input) {
    final String value = normalizePhoneInput(input);

    if (!isValidBangladeshMobile(value)) {
      throw const FormatException('Invalid Bangladeshi phone number.');
    }

    final String withoutLeadingZero = value.substring(1);
    return '+880$withoutLeadingZero';
  }

  List<String> splitFullName(String fullName) {
    final String cleaned = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');

    if (cleaned.isEmpty) {
      return ['', ''];
    }

    final List<String> parts = cleaned.split(' ');

    if (parts.length == 1) {
      return [parts.first, ''];
    }

    final String firstName = parts.first;
    final String lastName = parts.sublist(1).join(' ');

    return [firstName, lastName];
  }

  Future<void> verifyPhoneNumber({
    required String firebasePhoneNumber,
    required Duration timeout,
    int? forceResendingToken,
    required Future<void> Function(PhoneAuthCredential credential)
    verificationCompleted,
    required void Function(FirebaseAuthException e) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: firebasePhoneNumber,
      timeout: timeout,
      forceResendingToken: forceResendingToken,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return _auth.signInWithCredential(credential);
  }

  String mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number. Please enter a valid number.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Try again later.';
      case 'session-expired':
        return 'OTP expired. Request a new OTP.';
      case 'code-invalid':
      case 'invalid-verification-code':
        return 'Incorrect verification code.';
      case 'invalid-verification-id':
        return 'Verification session is invalid. Please request OTP again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}
