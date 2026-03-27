// Base Phone Auth Controller
// --------------------------
// Shared controller state and helpers for phone + OTP auth flows.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

abstract class BasePhoneAuthController extends ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();

  bool agreeToTerms = false;
  bool isLoading = false;
  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool otpRequestInProgress = false;
  bool verifyOtpInProgress = false;

  String? phoneErrorText;
  String? otpErrorText;
  String? generalErrorText;

  String verificationId = '';
  int? resendToken;

  bool showResendButton = false;
  int resendTimeoutSeconds = 60;

  Timer? resendTimer;
  Timer? otpTimer;

  // Verify OTP brute-force protection
  int otpFailedAttempts = 0;
  bool isOtpVerifyLocked = false;
  DateTime? otpVerifyLockedUntil;
  int otpVerifyLockRemainingSeconds = 0;
  Timer? otpVerifyLockTimer;

  // Get OTP cost protection
  bool isOtpRequestLocked = false;
  DateTime? otpRequestLockedUntil;
  int otpRequestLockRemainingSeconds = 0;
  Timer? otpRequestLockTimer;

  int otp10mRequestCount = 0;
  DateTime? otp10mWindowStart;

  int otp1hRequestCount = 0;
  DateTime? otp1hWindowStart;

  bool get isOtpFilled => otpController.text.trim().length == 6;

  bool get canSubmitOtp =>
      !isLoading && !verifyOtpInProgress && agreeToTerms && isOtpSent && isOtpFilled;

  void setLoading(bool value) {
    if (isLoading == value) return;
    isLoading = value;
    notifyListeners();
  }

  void setVerifyOtpInProgress(bool value) {
    if (verifyOtpInProgress == value) return;
    verifyOtpInProgress = value;
    notifyListeners();
  }

  bool get canVerifyOtp {
    return !isLoading &&
        !verifyOtpInProgress &&
        !isOtpVerifyLocked &&
        agreeToTerms &&
        isOtpSent &&
        isOtpFilled;
  }

  // Child controllers must define their own request validity logic.
  bool get canRequestOtp;

  String get otpButtonText {
    if (!isOtpSent) {
      return 'Get OTP';
    }

    if (showResendButton) {
      return 'Send Again';
    }

    return 'Resend OTP in (${resendTimeoutSeconds}s)';
  }

  bool get canPressOtpButton {
    if (otpRequestInProgress || isLoading) {
      return false;
    }

    if (isOtpVerified) {
      return false;
    }

    if (isOtpRequestLocked) {
      return false;
    }

    if (!isOtpSent) {
      return canRequestOtp;
    }

    return showResendButton;
  }

  int get remainingOtpAttempts {
    final int remaining = 3 - otpFailedAttempts;
    return remaining < 0 ? 0 : remaining;
  }

  String? get otpVerifyLockMessage {
    if (!isOtpVerifyLocked) return null;
    return 'Too many incorrect OTP attempts. Try again in ${_formatDuration(otpVerifyLockRemainingSeconds)}.';
  }

  String? get otpRequestLockMessage {
    if (!isOtpRequestLocked) return null;
    return 'Too many OTP requests. Please try again in ${_formatDuration(otpRequestLockRemainingSeconds)}.';
  }

  String _formatDuration(int seconds) {
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;

    if (mins > 0) {
      return '${mins}m ${secs}s';
    }
    return '${secs}s';
  }

  Future<void> initializeSecurityState() async {
    await _restoreVerifyOtpState();
    await _restoreOtpRequestState();
    notifyListeners();
  }

  void setAgreeToTerms(bool value) {
    agreeToTerms = value;
    notifyListeners();
  }

  void clearGeneralError() {
    generalErrorText = null;
    notifyListeners();
  }

  void clearOtpError() {
    otpErrorText = null;
    notifyListeners();
  }

  void clearPhoneField() {
    phoneController.clear();
    phoneErrorText = null;
    notifyListeners();
  }

  void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  void startOtpRequest() {
    otpRequestInProgress = true;
    notifyListeners();
  }

  void finishOtpRequest() {
    otpRequestInProgress = false;
    notifyListeners();
  }

  void resetOtpSessionState({
    bool clearOtpField = true,
    bool clearErrors = true,
    bool clearResendToken = false,
  }) {
    if (clearOtpField) {
      otpController.clear();
    }

    if (clearErrors) {
      otpErrorText = null;
      generalErrorText = null;
    }

    verificationId = '';
    isOtpVerified = false;
    verifyOtpInProgress = false;

    if (clearResendToken) {
      resendToken = null;
    }

    notifyListeners();
  }

  Future<void> recordOtpRequestSuccess() async {
    final DateTime now = DateTime.now();

    // 10-minute window
    if (otp10mWindowStart == null ||
        now.difference(otp10mWindowStart!).inMinutes >= 10) {
      otp10mWindowStart = now;
      otp10mRequestCount = 1;
    } else {
      otp10mRequestCount += 1;
    }

    // 1-hour window
    if (otp1hWindowStart == null ||
        now.difference(otp1hWindowStart!).inMinutes >= 60) {
      otp1hWindowStart = now;
      otp1hRequestCount = 1;
    } else {
      otp1hRequestCount += 1;
    }

    await AuthRateLimitStorage.setOtp10mCount(otp10mRequestCount);
    await AuthRateLimitStorage.setOtp10mWindowStartMs(
      otp10mWindowStart!.millisecondsSinceEpoch,
    );

    await AuthRateLimitStorage.setOtp1hCount(otp1hRequestCount);
    await AuthRateLimitStorage.setOtp1hWindowStartMs(
      otp1hWindowStart!.millisecondsSinceEpoch,
    );

    await _evaluateOtpRequestLockAfterSuccess();
    notifyListeners();
  }

  Future<void> _evaluateOtpRequestLockAfterSuccess() async {
    final DateTime now = DateTime.now();

    if (otp1hWindowStart != null &&
        now.difference(otp1hWindowStart!).inMinutes < 60 &&
        otp1hRequestCount >= 5) {
      final DateTime lockedUntil =
      otp1hWindowStart!.add(const Duration(hours: 1));
      await lockOtpRequestUntil(lockedUntil);
      return;
    }

    if (otp10mWindowStart != null &&
        now.difference(otp10mWindowStart!).inMinutes < 10 &&
        otp10mRequestCount >= 3) {
      final DateTime lockedUntil =
      otp10mWindowStart!.add(const Duration(minutes: 10));
      await lockOtpRequestUntil(lockedUntil);
    }
  }

  Future<void> lockOtpRequestUntil(DateTime lockedUntil) async {
    isOtpRequestLocked = true;
    otpRequestLockedUntil = lockedUntil;

    final int remaining =
    lockedUntil.difference(DateTime.now()).inSeconds.clamp(0, 1 << 31);
    otpRequestLockRemainingSeconds = remaining;

    otpRequestLockTimer?.cancel();
    otpRequestLockTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
          final DateTime? until = otpRequestLockedUntil;
          if (until == null) {
            timer.cancel();
            return;
          }

          final int remaining =
          until.difference(DateTime.now()).inSeconds.clamp(0, 1 << 31);

          if (remaining <= 0) {
            timer.cancel();
            await clearOtpRequestRateLimit();
          } else {
            otpRequestLockRemainingSeconds = remaining;
            notifyListeners();
          }
        });

    notifyListeners();
  }

  Future<void> clearOtpRequestRateLimit() async {
    isOtpRequestLocked = false;
    otpRequestLockedUntil = null;
    otpRequestLockRemainingSeconds = 0;
    otpRequestLockTimer?.cancel();

    otp10mRequestCount = 0;
    otp10mWindowStart = null;
    otp1hRequestCount = 0;
    otp1hWindowStart = null;

    await AuthRateLimitStorage.clearOtpRequestRateLimit();
    notifyListeners();
  }

  Future<void> recordOtpFailure() async {
    otpFailedAttempts += 1;
    await AuthRateLimitStorage.setVerifyFailedAttempts(otpFailedAttempts);

    if (otpFailedAttempts >= 3) {
      final DateTime lockedUntil =
      DateTime.now().add(const Duration(minutes: 30));
      await lockOtpVerifyUntil(lockedUntil);
      return;
    }

    notifyListeners();
  }

  Future<void> lockOtpVerifyUntil(DateTime lockedUntil) async {
    isOtpVerifyLocked = true;
    otpVerifyLockedUntil = lockedUntil;

    final int remaining =
    lockedUntil.difference(DateTime.now()).inSeconds.clamp(0, 1 << 31);
    otpVerifyLockRemainingSeconds = remaining;

    await AuthRateLimitStorage.setVerifyLockedUntilMs(
      lockedUntil.millisecondsSinceEpoch,
    );

    otpVerifyLockTimer?.cancel();
    otpVerifyLockTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
          final DateTime? until = otpVerifyLockedUntil;
          if (until == null) {
            timer.cancel();
            return;
          }

          final int remaining =
          until.difference(DateTime.now()).inSeconds.clamp(0, 1 << 31);

          if (remaining <= 0) {
            timer.cancel();
            await resetOtpFailureCount();
          } else {
            otpVerifyLockRemainingSeconds = remaining;
            notifyListeners();
          }
        });

    notifyListeners();
  }

  Future<void> resetOtpFailureCount() async {
    otpFailedAttempts = 0;
    isOtpVerifyLocked = false;
    otpVerifyLockedUntil = null;
    otpVerifyLockRemainingSeconds = 0;
    otpVerifyLockTimer?.cancel();

    await AuthRateLimitStorage.clearVerifyRateLimit();
    notifyListeners();
  }

  Future<void> resetAllOtpSecurityStorage() async {
    await resetOtpFailureCount();
    await clearOtpRequestRateLimit();
  }

  Future<void> _restoreVerifyOtpState() async {
    otpFailedAttempts = await AuthRateLimitStorage.getVerifyFailedAttempts();

    final int? lockedUntilMs = await AuthRateLimitStorage.getVerifyLockedUntilMs();
    if (lockedUntilMs == null) {
      isOtpVerifyLocked = false;
      otpVerifyLockedUntil = null;
      otpVerifyLockRemainingSeconds = 0;
      return;
    }

    final DateTime lockedUntil =
    DateTime.fromMillisecondsSinceEpoch(lockedUntilMs);

    if (lockedUntil.isAfter(DateTime.now())) {
      await lockOtpVerifyUntil(lockedUntil);
    } else {
      await resetOtpFailureCount();
    }
  }

  Future<void> _restoreOtpRequestState() async {
    otp10mRequestCount = await AuthRateLimitStorage.getOtp10mCount();
    otp1hRequestCount = await AuthRateLimitStorage.getOtp1hCount();

    final int? tenMinStartMs =
    await AuthRateLimitStorage.getOtp10mWindowStartMs();
    final int? oneHourStartMs =
    await AuthRateLimitStorage.getOtp1hWindowStartMs();

    otp10mWindowStart = tenMinStartMs != null
        ? DateTime.fromMillisecondsSinceEpoch(tenMinStartMs)
        : null;

    otp1hWindowStart = oneHourStartMs != null
        ? DateTime.fromMillisecondsSinceEpoch(oneHourStartMs)
        : null;

    final DateTime now = DateTime.now();

    if (otp10mWindowStart != null &&
        now.difference(otp10mWindowStart!).inMinutes >= 10) {
      otp10mRequestCount = 0;
      otp10mWindowStart = null;
      await AuthRateLimitStorage.setOtp10mCount(0);
    }

    if (otp1hWindowStart != null &&
        now.difference(otp1hWindowStart!).inMinutes >= 60) {
      otp1hRequestCount = 0;
      otp1hWindowStart = null;
      await AuthRateLimitStorage.setOtp1hCount(0);
    }

    if (otp1hWindowStart != null &&
        now.difference(otp1hWindowStart!).inMinutes < 60 &&
        otp1hRequestCount >= 5) {
      await lockOtpRequestUntil(otp1hWindowStart!.add(const Duration(hours: 1)));
      return;
    }

    if (otp10mWindowStart != null &&
        now.difference(otp10mWindowStart!).inMinutes < 10 &&
        otp10mRequestCount >= 3) {
      await lockOtpRequestUntil(
        otp10mWindowStart!.add(const Duration(minutes: 10)),
      );
      return;
    }

    isOtpRequestLocked = false;
    otpRequestLockedUntil = null;
    otpRequestLockRemainingSeconds = 0;
    otpRequestLockTimer?.cancel();
  }

  void resetBaseState({bool clearPhone = false}) {
    if (clearPhone) {
      phoneController.clear();
    }

    otpController.clear();
    phoneErrorText = null;
    otpErrorText = null;
    generalErrorText = null;
    isOtpSent = false;
    isOtpVerified = false;
    otpRequestInProgress = false;
    verifyOtpInProgress = false;
    verificationId = '';
    resendToken = null;
    showResendButton = false;
    resendTimeoutSeconds = 60;

    resendTimer?.cancel();
    otpTimer?.cancel();

    notifyListeners();
  }

  void startResendTimer() {
    resendTimer?.cancel();

    showResendButton = false;
    resendTimeoutSeconds = 60;
    notifyListeners();

    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimeoutSeconds > 0) {
        resendTimeoutSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        showResendButton = true;
        notifyListeners();
      }
    });
  }

  void startOtpTimer() {
    otpTimer?.cancel();

    otpTimer = Timer(const Duration(seconds: 60), () {
      if (!isOtpVerified) {
        showResendButton = true;
        notifyListeners();
      }
    });
  }

  String get maskedPhoneDisplay {
    final String raw =
    phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');

    if (raw.isEmpty) {
      return '+880';
    }

    if (raw.length < 11) {
      return '+880 $raw';
    }

    final String local = raw.startsWith('0') ? raw.substring(1) : raw;

    if (local.length < 10) {
      return '+880 $local';
    }

    final String prefix = local.substring(0, 2);
    final String suffix = local.substring(local.length - 4);

    return '+880 $prefix****$suffix';
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    otpTimer?.cancel();
    otpVerifyLockTimer?.cancel();
    otpRequestLockTimer?.cancel();
    phoneController.dispose();
    otpController.dispose();
    otpFocusNode.dispose();
    super.dispose();
  }
}

