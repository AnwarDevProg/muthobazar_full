// Delete Account Verify Controller
// --------------------------------
// Dedicated OTP verification controller for secure account deletion.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:shared_ui/shared_ui.dart';
import '../../auth/controllers/base_phone_auth_controller.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'profile_controller.dart';

class DeleteAccountVerifyController extends BasePhoneAuthController {
  DeleteAccountVerifyController({
    ProfileRepository? repository,
    ProfileController? profileController,
  })  : _repository = repository ?? ProfileRepository.instance,
        _profileController = profileController ?? Get.find<ProfileController>();

  final ProfileRepository _repository;
  final ProfileController _profileController;

  bool _isDeletingAccount = false;

  bool get isDeletingAccount => _isDeletingAccount;

  @override
  bool get canRequestOtp =>
      !_isDeletingAccount &&
          !isLoading &&
          _repository.isValidBangladeshMobile(phoneController.text);

  Future<void> initialize() async {
    agreeToTerms = true;
    phoneController.text =
        _repository.normalizePhoneInput(_profileController.phoneNumber);
    await initializeSecurityState();
    notifyListeners();
  }

  void validatePhoneNumber() {
    final String rawPhone =
    _repository.normalizePhoneInput(phoneController.text);

    if (!_repository.isValidBangladeshMobile(rawPhone)) {
      phoneErrorText = 'Enter valid number like 017XXXXXXXX';
    } else {
      final String currentRawPhone =
      _repository.normalizePhoneInput(_profileController.phoneNumber);

      phoneErrorText =
      rawPhone == currentRawPhone ? null : 'Enter your current phone number';
    }

    notifyListeners();
  }

  void onPhoneChanged() {
    phoneErrorText = null;
    otpErrorText = null;
    generalErrorText = null;
    validatePhoneNumber();
    notifyListeners();
  }

  void onOtpChanged() {
    otpErrorText = null;
    generalErrorText = null;
    notifyListeners();
  }

  Future<void> sendOtp({
    required BuildContext context,
    required void Function(String title, String message) onError,
  }) async {
    hideKeyboard(context);

    if (_profileController.isGuest || !_profileController.isLoggedIn) {
      onError('Login Required', 'Please login first.');
      return;
    }

    if (isOtpRequestLocked) {
      onError(
        'Too Many OTP Requests',
        otpRequestLockMessage ?? 'Too many OTP requests.',
      );
      return;
    }

    final String rawPhone =
    _repository.normalizePhoneInput(phoneController.text);

    if (!_repository.isValidBangladeshMobile(rawPhone)) {
      phoneErrorText = 'Enter valid number like 017XXXXXXXX';
      notifyListeners();
      return;
    }

    final String currentRawPhone =
    _repository.normalizePhoneInput(_profileController.phoneNumber);

    if (rawPhone != currentRawPhone) {
      phoneErrorText = 'Enter your current phone number';
      notifyListeners();
      return;
    }

    if (otpRequestInProgress || isLoading || _isDeletingAccount) return;

    resetOtpSessionState(
      clearOtpField: true,
      clearErrors: true,
      clearResendToken: false,
    );

    startOtpRequest();
    setLoading(true);

    phoneErrorText = null;
    otpErrorText = null;
    generalErrorText = null;
    notifyListeners();

    try {
      final String firebasePhone =
      _repository.formatPhoneForFirebase(rawPhone);

      await _repository.verifyPhoneNumber(
        firebasePhoneNumber: firebasePhone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: null,
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

      onError('Error', '$e');
    }
  }

  Future<void> resendOtp({
    required BuildContext context,
    required void Function(String title, String message) onError,
  }) async {
    if (!showResendButton) return;

    hideKeyboard(context);

    if (isOtpRequestLocked) {
      onError(
        'Too Many OTP Requests',
        otpRequestLockMessage ?? 'Too many OTP requests.',
      );
      return;
    }

    if (_profileController.isGuest || !_profileController.isLoggedIn) {
      onError('Login Required', 'Please login first.');
      return;
    }

    final String rawPhone =
    _repository.normalizePhoneInput(phoneController.text);

    if (!_repository.isValidBangladeshMobile(rawPhone)) {
      onError('Invalid Phone', 'Please enter a valid phone number.');
      return;
    }

    if (otpRequestInProgress || isLoading || _isDeletingAccount) return;

    startOtpRequest();
    setLoading(true);
    generalErrorText = null;
    otpErrorText = null;
    notifyListeners();

    try {
      final String firebasePhone =
      _repository.formatPhoneForFirebase(rawPhone);

      await _repository.verifyPhoneNumber(
        firebasePhoneNumber: firebasePhone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
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

      generalErrorText = 'Failed to resend OTP. Please try again.';
      notifyListeners();

      onError('Error', '$e');
    }
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

    if (isLoading || verifyOtpInProgress || _isDeletingAccount) return;

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

    _setDeletingAccount(true);
    setVerifyOtpInProgress(true);
    setLoading(true);

    otpErrorText = null;
    generalErrorText = null;
    notifyListeners();

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: currentVerificationId,
        smsCode: otp,
      );

      await _deleteAccountWithCredential(credential);

      isOtpVerified = true;
      otpController.clear();
      verificationId = '';

      await resetAllOtpSecurityStorage();
      finishOtpRequest();

      _profileController.applyLocalGuestState();

      notifyListeners();

      Get.offAllNamed(AppRoutes.welcome);

      MBNotification.success(
        title: 'Deleted',
        message: 'Your account has been deleted successfully.',
      );
    } on FirebaseAuthException catch (e) {
      otpErrorText = _repository.mapFirebaseAuthException(e);

      if (e.code == 'code-invalid' || e.code == 'invalid-verification-code') {
        await recordOtpFailure();
      }

      notifyListeners();
      onError('Verification Failed', otpErrorText!);
    } catch (e) {
      otpErrorText = 'Failed to delete account.';
      notifyListeners();
      onError('Verification Failed', '$e');
    } finally {
      _setDeletingAccount(false);
      setVerifyOtpInProgress(false);
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> handleAutoVerification({
    required PhoneAuthCredential credential,
    required void Function(String title, String message) onError,
  }) async {
    if (isOtpVerified || verifyOtpInProgress || _isDeletingAccount) return;

    try {
      _setDeletingAccount(true);
      setVerifyOtpInProgress(true);
      setLoading(true);
      notifyListeners();

      final String? smsCode = credential.smsCode;
      if (smsCode != null && smsCode.length == 6) {
        otpController.text = smsCode;
        notifyListeners();
      }

      await _deleteAccountWithCredential(credential);

      isOtpVerified = true;
      otpController.clear();
      verificationId = '';

      await resetAllOtpSecurityStorage();
      finishOtpRequest();

      _profileController.applyLocalGuestState();

      notifyListeners();

      Get.offAllNamed(AppRoutes.welcome);

      MBNotification.success(
        title: 'Deleted',
        message: 'Your account has been deleted successfully.',
      );
    } on FirebaseAuthException catch (e) {
      generalErrorText = _repository.mapFirebaseAuthException(e);
      finishOtpRequest();
      notifyListeners();
      onError('Auto Verification Failed', generalErrorText!);
    } catch (e) {
      finishOtpRequest();
      notifyListeners();
      onError('Auto Verification Failed', '$e');
    } finally {
      _setDeletingAccount(false);
      setVerifyOtpInProgress(false);
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> _deleteAccountWithCredential(
      PhoneAuthCredential credential,
      ) async {
    final currentUser = _profileController.user.value;

    await _repository.reauthenticateWithCredential(credential);
    await _repository.deleteAccountCompletely(uid: currentUser.id);
  }

  void _setDeletingAccount(bool value) {
    _isDeletingAccount = value;
    notifyListeners();
  }
}

