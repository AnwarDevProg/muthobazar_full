import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../auth/controllers/base_phone_auth_controller.dart';
import '../../auth/helpers/firestore_phone_update_debug_helper.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'profile_controller.dart';

class UpdatePhoneController extends BasePhoneAuthController {
  UpdatePhoneController({
    ProfileRepository? repository,
    ProfileController? profileController,
  })  : _repository = repository ?? ProfileRepository.instance,
        _profileController = profileController ?? Get.find<ProfileController>();

  final ProfileRepository _repository;
  final ProfileController _profileController;

  String _pendingRawPhone = '';

  @override
  bool get canRequestOtp =>
      !isLoading && _repository.isValidBangladeshMobile(phoneController.text);

  Future<void> initialize() async {
    agreeToTerms = true;
    phoneController.text =
        _repository.normalizePhoneInput(_profileController.phoneNumber);
    await initializeSecurityState();
    notifyListeners();
  }

  void validatePhoneNumber() {
    final bool isValid =
    _repository.isValidBangladeshMobile(phoneController.text);

    phoneErrorText = isValid ? null : 'Enter valid number like 017XXXXXXXX';
    notifyListeners();
  }

  void onPhoneChanged() {
    phoneErrorText = null;
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

    if (rawPhone == currentRawPhone) {
      phoneErrorText = 'Enter a new phone number.';
      notifyListeners();
      return;
    }

    if (otpRequestInProgress || isLoading) return;

    final bool isAvailable = await _repository.isPhoneAvailableForUpdate(
      rawPhone: rawPhone,
      currentUid: _profileController.user.value.id,
    );

    if (!isAvailable) {
      onError(
        'Phone Already Used',
        'This phone number is already registered with another account.',
      );
      return;
    }

    _pendingRawPhone = rawPhone;

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

      if (kDebugMode) {
        await FirebaseAuth.instance.setSettings(
          appVerificationDisabledForTesting: true,
        );
      }

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
          debugPrint('sendOtp verificationFailed: ${e.code} | ${e.message}');
          setLoading(false);
          finishOtpRequest();
          generalErrorText = _repository.mapFirebaseAuthException(e);
          notifyListeners();
          onError('OTP Failed', generalErrorText!);
        },
        codeSent: (String newVerificationId, int? newResendToken) async {
          debugPrint('sendOtp codeSent: $newVerificationId');
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
    } catch (e, stackTrace) {
      debugPrint('sendOtp catch error: $e');
      debugPrint('sendOtp stackTrace: $stackTrace');

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

    if (_pendingRawPhone.isEmpty) {
      onError('Missing Phone', 'Please enter phone number again.');
      return;
    }

    if (otpRequestInProgress || isLoading) return;

    startOtpRequest();
    setLoading(true);
    generalErrorText = null;
    otpErrorText = null;
    notifyListeners();

    try {
      final firebasePhone =
      _repository.formatPhoneForFirebase(_pendingRawPhone);

      if (kDebugMode) {
        await FirebaseAuth.instance.setSettings(
          appVerificationDisabledForTesting: true,
        );
      }

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
          debugPrint('resendOtp verificationFailed: ${e.code} | ${e.message}');
          setLoading(false);
          finishOtpRequest();
          generalErrorText = _repository.mapFirebaseAuthException(e);
          notifyListeners();
          onError('OTP Failed', generalErrorText!);
        },
        codeSent: (String newVerificationId, int? newResendToken) async {
          debugPrint('resendOtp codeSent: $newVerificationId');
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
    } catch (e, stackTrace) {
      debugPrint('resendOtp catch error: $e');
      debugPrint('resendOtp stackTrace: $stackTrace');

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
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: currentVerificationId,
        smsCode: otp,
      );

      debugPrint('verifyOtp credential created successfully');

      await _applyPhoneUpdate(credential);

      isOtpVerified = true;
      otpController.clear();
      verificationId = '';

      await resetAllOtpSecurityStorage();

      notifyListeners();
      Get.back();
      MBNotification.success(
        title: 'Success',
        message: 'Phone number updated successfully.',
      );
      await _profileController.refreshUserFromServer();
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint('verifyOtp FirebaseAuthException: ${e.code} | ${e.message}');
      debugPrint('verifyOtp stackTrace: $stackTrace');

      otpErrorText = _repository.mapFirebaseAuthException(e);

      if (e.code == 'code-invalid' || e.code == 'invalid-verification-code') {
        await recordOtpFailure();
      }

      onError('Verification Failed', otpErrorText!);
    } catch (e, stackTrace) {
      debugPrint('verifyOtp general error: $e');
      debugPrint('verifyOtp stackTrace: $stackTrace');

      otpErrorText = 'Failed to update phone number.';
      onError('Verification Failed', '$e');
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

      await _applyPhoneUpdate(credential);

      isOtpVerified = true;
      otpController.clear();
      verificationId = '';

      await resetAllOtpSecurityStorage();
      finishOtpRequest();

      notifyListeners();
      Get.back();
      MBNotification.success(
        title: 'Success',
        message: 'Phone number updated successfully.',
      );
      await _profileController.refreshUserFromServer();
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(
        'handleAutoVerification FirebaseAuthException: ${e.code} | ${e.message}',
      );
      debugPrint('handleAutoVerification stackTrace: $stackTrace');

      generalErrorText = _repository.mapFirebaseAuthException(e);
      finishOtpRequest();
      onError('Auto Verification Failed', generalErrorText!);
    } catch (e, stackTrace) {
      debugPrint('handleAutoVerification general error: $e');
      debugPrint('handleAutoVerification stackTrace: $stackTrace');

      finishOtpRequest();
      onError('Auto Verification Failed', '$e');
    } finally {
      setVerifyOtpInProgress(false);
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> _applyPhoneUpdate(PhoneAuthCredential credential) async {
    final currentUser = _profileController.user.value;

    final String oldRawPhone =
    _repository.normalizePhoneInput(currentUser.phoneNumber);

    await _repository.updatePhoneNumberAndIndexes(
      uid: currentUser.id,
      oldRawPhone: oldRawPhone,
      newRawPhone: _pendingRawPhone,
      credential: credential,
    );

    _profileController.applyLocalPhoneUpdate(_pendingRawPhone);

    // DEBUG PRINT
    await FirestorePhoneUpdateDebugHelper.printPhoneUpdateState(
      uid: currentUser.id,
      phone: _pendingRawPhone,
    );
  }

}


