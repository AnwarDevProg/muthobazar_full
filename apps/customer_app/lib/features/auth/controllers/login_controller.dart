// Login Controller
// ----------------

import 'package:customer_app/features/auth/helpers/firestore_auth_debug_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shared_core/shared_core.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'base_phone_auth_controller.dart';

class LoginController extends BasePhoneAuthController {
  LoginController({
    LoginRepository? repository,
    AuthRedirectService? authRedirectService,
  })  : _repository = repository ?? LoginRepository(),
        _authRedirectService = authRedirectService ?? AuthRedirectService();

  final LoginRepository _repository;
  final AuthRedirectService _authRedirectService;

  bool rememberMe = false;

  @override
  bool get canRequestOtp =>
      !isLoading && _repository.isValidBangladeshMobile(phoneController.text);

  Future<void> initialize() async {
    await _loadRememberMe();
    await initializeSecurityState();
  }

  Future<void> _loadRememberMe() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    rememberMe = prefs.getBool('rememberMe') ?? false;
    notifyListeners();
  }

  Future<void> toggleRememberMe(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    rememberMe = value;
    await prefs.setBool('rememberMe', value);
    notifyListeners();
  }

  void validatePhoneNumber() {
    final bool isValid =
    _repository.isValidBangladeshMobile(phoneController.text);

    phoneErrorText = isValid ? null : 'Enter valid number like 017XXXXXXXX';
    notifyListeners();
  }

  Future<void> sendOtp({
    required BuildContext context,
    bool isResend = false,
    required VoidCallback onUnregisteredUser,
    required void Function(String title, String message) onError,
  }) async {
    hideKeyboard(context);

    if (isOtpRequestLocked) {
      onError(
        'Too Many OTP Requests',
        otpRequestLockMessage ?? 'Too many OTP requests.',
      );
      return;
    }

    final String rawPhone = _repository.normalizePhoneInput(phoneController.text);

    if (!_repository.isValidBangladeshMobile(rawPhone)) {
      phoneErrorText = 'Enter valid number like 017XXXXXXXX';
      notifyListeners();
      return;
    }

    if (otpRequestInProgress || isLoading) return;

    resetOtpSessionState(
      clearOtpField: true,
      clearErrors: true,
      clearResendToken: !isResend,
    );

    startOtpRequest();
    setLoading(true);

    phoneErrorText = null;
    otpErrorText = null;
    generalErrorText = null;
    notifyListeners();

    try {
      final bool phoneExists = await _repository.isPhoneRegistered(rawPhone);

      if (!phoneExists) {
        setLoading(false);
        finishOtpRequest();
        notifyListeners();
        onUnregisteredUser();
        return;
      }

      if (isResend) {
        showResendButton = false;
      }

      final String firebasePhone = _repository.formatPhoneForFirebase(rawPhone);

      await _repository.verifyPhoneNumber(
        firebasePhoneNumber: firebasePhone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: isResend ? resendToken : null,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await handleAutoVerification(
            credential: credential,
            onError: onError,
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          setLoading(false);
          finishOtpRequest();
          generalErrorText = _repository.mapFirebaseAuthException(e);
          notifyListeners();
          onError('OTP Failed', generalErrorText!);
          debugPrint('OTP ERROR CODE: ${e.code}');
          debugPrint('OTP ERROR MESSAGE: ${e.message}');
        },
        codeSent: (String newVerificationId, int? newResendToken) async {
          verificationId = newVerificationId;
          resendToken = newResendToken;
          isOtpSent = true;
          setLoading(false);

          await recordOtpRequestSuccess();
          await resetOtpFailureCount();

          startResendTimer();
          startOtpTimer();
          finishOtpRequest();

          notifyListeners();
          otpFocusNode.requestFocus();
        },
        codeAutoRetrievalTimeout: (String newVerificationId) {
          verificationId = newVerificationId;
        },
      );
    } catch (e) {
      setLoading(false);
      finishOtpRequest();
      generalErrorText = 'Failed to send OTP. Please try again.';
      notifyListeners();

      if (kDebugMode) {
        debugPrint('SEND OTP ERROR: $e');
      }

      onError('Error', generalErrorText!);
    }
  }

  Future<void> resendOtp({
    required BuildContext context,
    required VoidCallback onUnregisteredUser,
    required void Function(String title, String message) onError,
  }) async {
    if (!showResendButton) return;

    await sendOtp(
      context: context,
      isResend: true,
      onUnregisteredUser: onUnregisteredUser,
      onError: onError,
    );
  }

  Future<void> verifyOtp({
    required void Function(String title, String message) onError,
  }) async {
    if (isOtpVerifyLocked) {
      onError(
        'Too Many Incorrect Attempts',
        otpVerifyLockMessage ?? 'Too many incorrect OTP attempts.',
      );
      return;
    }

    if (isLoading || isOtpVerified || verifyOtpInProgress) return;

    final String otp = otpController.text.trim();

    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      otpErrorText = 'Enter valid 6-digit OTP';
      notifyListeners();
      return;
    }

    final String currentVerificationId = verificationId;

    if (currentVerificationId.isEmpty) {
      onError('Verification Missing', 'Please request OTP first.');
      return;
    }

    setVerifyOtpInProgress(true);
    setLoading(true);

    otpErrorText = null;
    generalErrorText = null;
    notifyListeners();

    try {
      final UserCredential userCredential = await _repository.signInWithOtp(
        verificationId: currentVerificationId,
        smsCode: otp,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('User not found');
      }

      final String rawPhone =
      _repository.normalizePhoneInput(phoneController.text);

      final bool phoneExists = await _repository.isPhoneRegistered(rawPhone);

      if (!phoneExists) {
        await _cleanupUnexpectedAuthUser(user);
        otpErrorText = 'This number is no longer registered. Please register.';
        onError('Account Not Found', otpErrorText!);
        return;
      }

      await _repository.updateLoginMetadata(
        uid: user.uid,
        phone: rawPhone,
      );

      isOtpVerified = true;
      otpController.clear();
      verificationId = '';

      await resetAllOtpSecurityStorage();

      await FirestoreAuthDebugHelper.printUserAndPhoneIndex(
        uid: user.uid,
        phone: rawPhone,
      );

      notifyListeners();
      await _authRedirectService.screenRedirect();
    } on FirebaseAuthException catch (e) {
      otpErrorText = _repository.mapFirebaseAuthException(e);

      if (e.code == 'code-invalid' || e.code == 'invalid-verification-code') {
        await recordOtpFailure();
      }

      onError('Verification Failed', otpErrorText!);
    } catch (e) {
      otpErrorText = 'Invalid OTP. Please try again.';
      await recordOtpFailure();

      if (kDebugMode) {
        debugPrint('VERIFY OTP ERROR: $e');
      }

      onError('Verification Failed', otpErrorText!);
    } finally {
      setVerifyOtpInProgress(false);
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> handleAutoVerification({
    required PhoneAuthCredential credential,
    required void Function(String title, String message) onError,
  }) async {
    if (isOtpVerified || verifyOtpInProgress) return;

    try {
      setVerifyOtpInProgress(true);
      setLoading(true);
      notifyListeners();

      final String? smsCode = credential.smsCode;
      if (smsCode != null && smsCode.length == 6) {
        otpController.text = smsCode;
        notifyListeners();
      }

      final UserCredential userCredential =
      await _repository.auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('User not found');
      }

      final String rawPhone =
      _repository.normalizePhoneInput(phoneController.text);

      final bool phoneExists = await _repository.isPhoneRegistered(rawPhone);

      if (!phoneExists) {
        await _cleanupUnexpectedAuthUser(user);
        finishOtpRequest();
        generalErrorText =
        'This number is no longer registered. Please register first.';
        notifyListeners();
        onError('Account Not Found', generalErrorText!);
        return;
      }

      await _repository.updateLoginMetadata(
        uid: user.uid,
        phone: rawPhone,
      );

      isOtpVerified = true;
      verificationId = '';
      otpController.clear();

      await resetAllOtpSecurityStorage();
      finishOtpRequest();

      await FirestoreAuthDebugHelper.printUserAndPhoneIndex(
        uid: user.uid,
        phone: rawPhone,
      );

      notifyListeners();
      await _authRedirectService.screenRedirect();
    } on FirebaseAuthException catch (e) {
      generalErrorText = _repository.mapFirebaseAuthException(e);
      finishOtpRequest();
      onError('Auto Login Failed', generalErrorText!);
    } catch (e) {
      finishOtpRequest();

      if (kDebugMode) {
        debugPrint('AUTO VERIFY ERROR: $e');
      }

      onError('Auto Login Failed', 'Please enter OTP manually.');
    } finally {
      setVerifyOtpInProgress(false);
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> _cleanupUnexpectedAuthUser(User user) async {
    try {
      await user.delete();
    } catch (_) {
      try {
        await _repository.auth.signOut();
      } catch (_) {}
    }
  }
}


