import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/services/admin_web_session_service.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:admin_web/features/profile/controllers/admin_profile_controller.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_services/admin/admin_activity_logger.dart';

class AdminAuthController extends BasePhoneAuthController {
  AdminAuthController({
    AdminWebPhoneAuthRepository? repository,
    AdminWebSessionService? sessionService,
    PhoneAuthEligibilityRepository? eligibilityRepository,
  })  : _repository = repository ?? AdminWebPhoneAuthRepository(),
        _sessionService =
            sessionService ?? Get.find<AdminWebSessionService>(),
        _eligibilityRepository =
            eligibilityRepository ?? PhoneAuthEligibilityRepository();

  final AdminWebPhoneAuthRepository _repository;
  final AdminWebSessionService _sessionService;
  final PhoneAuthEligibilityRepository _eligibilityRepository;

  final TextEditingController fullNameController = TextEditingController();
  String? fullNameErrorText;

  String _lastAuthMode = 'blocked';
  bool _lastShowSuperAdminCreation = false;

  @override
  bool get canRequestOtp =>
      !isLoading && _repository.isValidBangladeshMobile(phoneController.text);

  Future<void> initialize() async {
    await initializeSecurityState();
  }

  void clearFullNameError() {
    fullNameErrorText = null;
    notifyListeners();
  }

  void validatePhoneNumber() {
    final bool isValid =
    _repository.isValidBangladeshMobile(phoneController.text);

    phoneErrorText = isValid ? null : 'Enter valid number like 017XXXXXXXX';
    notifyListeners();
  }

  bool validateFullName() {
    final String value =
    fullNameController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    fullNameErrorText = value.length >= 2 ? null : 'Enter your full name';
    notifyListeners();
    return fullNameErrorText == null;
  }

  Future<void> sendOtp({
    required BuildContext context,
    bool requireFullName = false,
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

    if (requireFullName && !validateFullName()) {
      return;
    }

    final String rawPhone =
    _repository.normalizePhoneInput(phoneController.text);

    if (!_repository.isValidBangladeshMobile(rawPhone)) {
      phoneErrorText = 'Enter valid number like 017XXXXXXXX';
      notifyListeners();
      return;
    }

    if (otpRequestInProgress || isLoading) return;

    resetOtpSessionState(
      clearOtpField: true,
      clearErrors: true,
      clearResendToken: true,
    );

    _repository.clearPendingConfirmation();
    _lastAuthMode = 'blocked';
    _lastShowSuperAdminCreation = false;

    startOtpRequest();
    setLoading(true);

    phoneErrorText = null;
    otpErrorText = null;
    generalErrorText = null;
    notifyListeners();

    try {
      final String intent = requireFullName ? 'register' : 'login';

      final result = await _eligibilityRepository.checkEligibility(
        phoneNumber: rawPhone,
        app: 'admin_web',
        intent: intent,
      );

      if (!result.allowSendOtp) {
        setLoading(false);
        finishOtpRequest();
        generalErrorText = result.message;
        notifyListeners();
        onError('Not Allowed', result.message);
        return;
      }

      // HARD GATE: login page can ONLY proceed for admin_login
      if (!requireFullName && result.authMode != 'admin_login') {
        setLoading(false);
        finishOtpRequest();
        generalErrorText = 'This phone number is not eligible for admin login.';
        notifyListeners();
        onError(
          'Login Not Allowed',
          result.message.isNotEmpty
              ? result.message
              : 'This phone number is not eligible for admin login.',
        );
        return;
      }

      // HARD GATE: register page can ONLY proceed for admin_register or bootstrap
      if (requireFullName &&
          result.authMode != 'admin_register' &&
          result.authMode != 'super_admin_bootstrap') {
        setLoading(false);
        finishOtpRequest();
        generalErrorText =
        'This phone number is not eligible for admin registration.';
        notifyListeners();
        onError(
          'Registration Not Allowed',
          result.message.isNotEmpty
              ? result.message
              : 'This phone number is not eligible for admin registration.',
        );
        return;
      }

      _lastAuthMode = result.authMode;
      _lastShowSuperAdminCreation = result.showSuperAdminCreation;

      final String firebasePhone =
      _repository.formatPhoneForFirebase(rawPhone);

      await _repository.sendOtpWeb(
        firebasePhoneNumber: firebasePhone,
      );

      verificationId = 'web_confirmation_ready';
      isOtpSent = true;
      setLoading(false);

      await recordOtpRequestSuccess();
      await resetOtpFailureCount();

      startResendTimer();
      startOtpTimer();
      finishOtpRequest();

      notifyListeners();
      otpFocusNode.requestFocus();
    } on FirebaseFunctionsException catch (e) {
      setLoading(false);
      finishOtpRequest();
      generalErrorText = e.message ?? 'Eligibility check failed.';
      notifyListeners();
      onError(
        'Eligibility Check Failed',
        '${e.message ?? 'Unknown callable error'} [${e.code}]',
      );
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      finishOtpRequest();
      generalErrorText = _repository.mapFirebaseAuthException(e);
      notifyListeners();
      onError(
        'OTP Failed',
        '${generalErrorText!} [${e.code}] ${e.message ?? ''}',
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
    bool requireFullName = false,
    required void Function(String title, String message) onError,
  }) async {
    if (!showResendButton) return;

    await sendOtp(
      context: context,
      requireFullName: requireFullName,
      onError: onError,
    );
  }

  Future<void> verifyOtp({
    required bool isRegistrationFlow,
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

    if (isRegistrationFlow && !validateFullName()) {
      return;
    }

    final String otp = otpController.text.trim();

    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      otpErrorText = 'Enter valid 6-digit OTP';
      notifyListeners();
      return;
    }

    if (!_repository.hasPendingConfirmation) {
      onError('Verification Missing', 'Please request OTP first.');
      return;
    }

    setVerifyOtpInProgress(true);
    setLoading(true);

    otpErrorText = null;
    generalErrorText = null;
    notifyListeners();

    try {
      final UserCredential userCredential =
      await _repository.confirmOtpWeb(smsCode: otp);

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('User not found');
      }

      final String rawPhone =
      _repository.normalizePhoneInput(phoneController.text);

      final String fullName =
      fullNameController.text.trim().replaceAll(RegExp(r'\s+'), ' ');

      if (fullName.isNotEmpty && user.displayName != fullName) {
        await user.updateDisplayName(fullName);
        await user.reload();
      }

      final result = await _eligibilityRepository.checkEligibility(
        phoneNumber: rawPhone,
        app: 'admin_web',
        intent: isRegistrationFlow ? 'register' : 'login',
      );

      isOtpVerified = true;
      otpController.clear();
      verificationId = '';
      _repository.clearPendingConfirmation();

      await resetAllOtpSecurityStorage();
      notifyListeners();

      if (!isRegistrationFlow) {
        // LOGIN MUST NEVER ENTER BOOTSTRAP OR REGISTER MODE
        if (result.authMode != 'admin_login') {
          await _safeSignOut();
          onError(
            'Login Not Allowed',
            result.message.isNotEmpty
                ? result.message
                : 'This phone number is not eligible for admin login.',
          );
          return;
        }

        final bool hasAccess =
        await _sessionService.hasCurrentUserAdminAccess();

        if (!hasAccess) {
          await _safeSignOut();
          onError(
            'Access Denied',
            'This phone number is not assigned to any active admin account.',
          );
          return;
        }

        MBNotification.success(
          title: 'Login successful',
          message: 'Welcome to MuthoBazar Admin.',
        );

        final session = Get.find<AdminWebSessionService>();

        await AdminActivityLogger.log(
          actorUid: user.uid,
          actorName: (user.displayName ?? fullName).trim().isEmpty
              ? 'Admin User'
              : (user.displayName ?? fullName).trim(),
          actorPhone: (user.phoneNumber ?? '').trim().isEmpty
              ? rawPhone
              : (user.phoneNumber ?? '').trim(),
          actorRole: 'admin',
          action: 'auth.login',
          module: 'auth',
          targetType: 'admin',
          targetId: user.uid,
          targetTitle: (user.displayName ?? fullName).trim(),
          metadata: {
            'loginMethod': 'phone_otp',
          },
          status: 'success',
        );

        Get.offAllNamed(AdminWebRoutes.dashboard);
        return;
      }

      // REGISTRATION FLOW ONLY
      final bool bootstrapMode =
          result.authMode == 'super_admin_bootstrap' ||
              _lastAuthMode == 'super_admin_bootstrap' ||
              _lastShowSuperAdminCreation;

      if (bootstrapMode) {
        Get.offAllNamed(AdminWebRoutes.setupSuperAdmin);
        return;
      }

      if (result.authMode != 'admin_register' &&
          _lastAuthMode != 'admin_register') {
        await _safeSignOut();
        onError(
          'Registration Not Allowed',
          result.message,
        );
        return;
      }

      await _createAdminUserRecord(
        uid: user.uid,
        fullName: fullName,
        phoneNumber: rawPhone,
        phoneE164: (user.phoneNumber ?? '').trim(),
      );

      await _safeSignOut();

      MBNotification.success(
        title: 'Registration successful',
        message:
        'Your admin account has been created. Access will be granted later by super admin or an authorized admin.',
      );

      Get.offAllNamed(AdminWebRoutes.login);
    } on FirebaseAuthException catch (e) {
      otpErrorText = _repository.mapFirebaseAuthException(e);

      if (e.code == 'code-invalid' ||
          e.code == 'invalid-verification-code') {
        await recordOtpFailure();
      }

      onError('Verification Failed', otpErrorText!);
    } catch (e) {
      otpErrorText = 'Invalid OTP. Please try again.';
      await recordOtpFailure();
      onError('Verification Failed', e.toString());
    } finally {
      setVerifyOtpInProgress(false);
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> _createAdminUserRecord({
    required String uid,
    required String fullName,
    required String phoneNumber,
    required String phoneE164,
  }) async {
    final String normalizedPhone =
    _repository.normalizePhoneInput(phoneNumber);

    final List<String> names =
    _repository.splitFullName(fullName);

    final WriteBatch batch = _repository.firestore.batch();

    final DocumentReference<Map<String, dynamic>> userRef =
    _repository.firestore.collection('users').doc(uid);

    final DocumentReference<Map<String, dynamic>> phoneRef =
    _repository.firestore.collection('phone_index').doc(normalizedPhone);

    batch.set(
      userRef,
      {
        'Email': '',
        'FirstName': names[0],
        'LastName': names[1],
        'PhoneNumber': normalizedPhone,
        'PhoneNumberE164': phoneE164,
        'CreatedAt': FieldValue.serverTimestamp(),
        'UpdatedAt': FieldValue.serverTimestamp(),
        'Gender': '',
        'IsGuest': false,
        'Role': 'admin',
        'Addresses': <dynamic>[],
        'AccountStatus': 'active',
        'DOB': '',
        'DefaultAddressId': '',
        'LastLoginAt': FieldValue.serverTimestamp(),
        'ProfilePicture': '',
      },
      SetOptions(merge: true),
    );

    batch.set(
      phoneRef,
      {
        'Uid': uid,
        'PhoneNumber': normalizedPhone,
        'PhoneNumberE164': phoneE164,
        'UpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
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