import 'package:customer_app/app/startup/customer_auth_redirect_service.dart';
import 'package:customer_app/features/auth/helpers/firestore_auth_debug_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'base_phone_auth_controller.dart';

class RegisterController extends BasePhoneAuthController {
  RegisterController({
    RegisterRepository? repository,
    CustomerAuthRedirectService? authRedirectService,
    this.isSuperAdminRegistration = false,
    this.requestedRole = 'customer',
    this.bootstrapSuperAdmin = false,
  })  : _repository = repository ?? RegisterRepository(),
        _authRedirectService = authRedirectService ?? CustomerAuthRedirectService();

  final RegisterRepository _repository;
  final CustomerAuthRedirectService _authRedirectService;

  final bool isSuperAdminRegistration;
  final String requestedRole;
  final bool bootstrapSuperAdmin;

  final TextEditingController fullNameController = TextEditingController();

  String? fullNameErrorText;

  @override
  bool get canRequestOtp =>
      !isLoading &&
          _isFullNameValid(fullNameController.text) &&
          _repository.isValidBangladeshMobile(phoneController.text);

  Future<void> initialize() async {
    await initializeSecurityState();
  }

  void clearFullNameError() {
    fullNameErrorText = null;
    notifyListeners();
  }

  bool _isFullNameValid(String value) {
    final String name = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return name.length >= 2;
  }

  void validateFullName() {
    fullNameErrorText =
    _isFullNameValid(fullNameController.text) ? null : 'Enter your full name';
    notifyListeners();
  }

  void validatePhoneNumber() {
    final bool isValid =
    _repository.isValidBangladeshMobile(phoneController.text);

    phoneErrorText = isValid ? null : 'Enter valid number like 017XXXXXXXX';
    notifyListeners();
  }

  void resetRegisterState({bool clearInputs = false}) {
    if (clearInputs) {
      fullNameController.clear();
    }

    resetBaseState(clearPhone: clearInputs);
    fullNameErrorText = null;
    notifyListeners();
  }

  Future<void> sendOtp({
    required BuildContext context,
    required VoidCallback onAlreadyRegistered,
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

    validateFullName();

    final String rawInput = phoneController.text.trim();
    final String normalizedPhone = _repository.normalizePhoneInput(rawInput);

    if (!_isFullNameValid(fullNameController.text)) {
      return;
    }

    if (!_repository.isValidBangladeshMobile(normalizedPhone)) {
      phoneErrorText = 'Enter valid number like 017XXXXXXXX';
      notifyListeners();
      return;
    }

    if (otpRequestInProgress || isLoading) return;

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
      final bool exists =
      await _repository.isPhoneAlreadyRegistered(normalizedPhone);

      if (exists) {
        setLoading(false);
        finishOtpRequest();
        notifyListeners();
        onAlreadyRegistered();
        return;
      }

      final String firebasePhone =
      _repository.formatPhoneForFirebase(normalizedPhone);

      await _repository.verifyPhoneNumber(
        firebasePhoneNumber: firebasePhone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await handleAutoVerification(
            credential: credential,
            onAlreadyRegistered: onAlreadyRegistered,
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
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      finishOtpRequest();
      generalErrorText = _repository.mapFirebaseAuthException(e);
      notifyListeners();
      onError('OTP Failed', generalErrorText!);
    } on FormatException catch (e) {
      setLoading(false);
      finishOtpRequest();
      generalErrorText = e.message;
      notifyListeners();
      onError('Invalid Number', generalErrorText!);
    } catch (_) {
      setLoading(false);
      finishOtpRequest();
      generalErrorText = 'Failed to send OTP. Please try again.';
      notifyListeners();
      onError('Error', generalErrorText!);
    }
  }

  Future<void> resendOtp({
    required BuildContext context,
    required VoidCallback onAlreadyRegistered,
    required void Function(String title, String message) onError,
  }) async {
    if (!showResendButton) return;

    await sendOtp(
      context: context,
      onAlreadyRegistered: onAlreadyRegistered,
      onError: onError,
    );
  }

  Future<void> verifyOtp({
    required VoidCallback onSuccess,
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

      final String phone = _repository.normalizePhoneInput(phoneController.text);

      final bool alreadyExists =
      await _repository.isPhoneAlreadyRegistered(phone);

      if (alreadyExists) {
        await _safeSignOut();
        onError(
          'Already Registered',
          'This phone number is already registered. Please login instead.',
        );
        return;
      }

      final List<String> names =
      _repository.splitFullName(fullNameController.text.trim());

      await _repository.createUserRecord(
        uid: user.uid,
        firstName: names[0],
        lastName: names[1],
        phoneNumber: phone,
        role: 'customer',
      );

      isOtpVerified = true;
      verificationId = '';
      otpController.clear();

      await resetAllOtpSecurityStorage();

      await FirestoreAuthDebugHelper.printUserAndPhoneIndex(
        uid: user.uid,
        phone: phone,
      );

      notifyListeners();
      onSuccess();
    } on FirebaseAuthException catch (e) {
      otpErrorText = _repository.mapFirebaseAuthException(e);

      if (e.code == 'code-invalid' || e.code == 'invalid-verification-code') {
        await recordOtpFailure();
      }

      onError('Verification Failed', otpErrorText!);
    } catch (e) {
      onError('Verification Failed', e.toString());
    } finally {
      setVerifyOtpInProgress(false);
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> handleAutoVerification({
    required PhoneAuthCredential credential,
    required VoidCallback onAlreadyRegistered,
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

      final UserCredential result =
      await _repository.auth.signInWithCredential(credential);

      final User? user = result.user;
      if (user == null) {
        throw Exception('User not found');
      }

      final String phone = _repository.normalizePhoneInput(phoneController.text);

      final bool alreadyExists =
      await _repository.isPhoneAlreadyRegistered(phone);

      if (alreadyExists) {
        await _safeSignOut();
        finishOtpRequest();
        notifyListeners();
        onAlreadyRegistered();
        return;
      }

      final List<String> names =
      _repository.splitFullName(fullNameController.text.trim());

      await _repository.createUserRecord(
        uid: user.uid,
        firstName: names[0],
        lastName: names[1],
        phoneNumber: phone,
        role: 'customer'
      );

      isOtpVerified = true;
      verificationId = '';
      otpController.clear();
      finishOtpRequest();

      await resetAllOtpSecurityStorage();

      await FirestoreAuthDebugHelper.printUserAndPhoneIndex(
        uid: user.uid,
        phone: phone,
      );

      notifyListeners();
      await continueAfterSuccess();
    } on FirebaseAuthException catch (e) {
      generalErrorText = _repository.mapFirebaseAuthException(e);
      finishOtpRequest();
      notifyListeners();
      onError('Auto Register Failed', generalErrorText!);
    } catch (_) {
      finishOtpRequest();
      notifyListeners();
      onError('Auto Register Failed', 'Please enter OTP manually.');
    } finally {
      setVerifyOtpInProgress(false);
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> continueAfterSuccess() async {
    await resetAllOtpSecurityStorage();
    await _authRedirectService.screenRedirect();
  }

  Future<void> _safeSignOut() async {
    try {
      await _repository.auth.signOut();
    } catch (_) {}
  }

  @override
  void dispose() {
    fullNameController.dispose();
    super.dispose();
  }
}

