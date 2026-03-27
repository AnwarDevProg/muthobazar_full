
// Auth Rate Limit Storage
// -----------------------
// Persistent local storage for OTP request/verification rate limiting.

import 'package:shared_preferences/shared_preferences.dart';

class AuthRateLimitStorage {
  AuthRateLimitStorage._();

  static const String _verifyFailedAttemptsKey = 'auth_verify_failed_attempts';
  static const String _verifyLockedUntilKey = 'auth_verify_locked_until_ms';

  static const String _otp10mCountKey = 'auth_otp_10m_count';
  static const String _otp10mWindowStartKey = 'auth_otp_10m_window_start_ms';

  static const String _otp1hCountKey = 'auth_otp_1h_count';
  static const String _otp1hWindowStartKey = 'auth_otp_1h_window_start_ms';

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  // Verify OTP keys
  static Future<int> getVerifyFailedAttempts() async {
    final prefs = await _prefs();
    return prefs.getInt(_verifyFailedAttemptsKey) ?? 0;
  }

  static Future<void> setVerifyFailedAttempts(int value) async {
    final prefs = await _prefs();
    await prefs.setInt(_verifyFailedAttemptsKey, value);
  }

  static Future<int?> getVerifyLockedUntilMs() async {
    final prefs = await _prefs();
    return prefs.getInt(_verifyLockedUntilKey);
  }

  static Future<void> setVerifyLockedUntilMs(int value) async {
    final prefs = await _prefs();
    await prefs.setInt(_verifyLockedUntilKey, value);
  }

  static Future<void> clearVerifyRateLimit() async {
    final prefs = await _prefs();
    await prefs.remove(_verifyFailedAttemptsKey);
    await prefs.remove(_verifyLockedUntilKey);
  }

  // OTP request 10-minute window
  static Future<int> getOtp10mCount() async {
    final prefs = await _prefs();
    return prefs.getInt(_otp10mCountKey) ?? 0;
  }

  static Future<void> setOtp10mCount(int value) async {
    final prefs = await _prefs();
    await prefs.setInt(_otp10mCountKey, value);
  }

  static Future<int?> getOtp10mWindowStartMs() async {
    final prefs = await _prefs();
    return prefs.getInt(_otp10mWindowStartKey);
  }

  static Future<void> setOtp10mWindowStartMs(int value) async {
    final prefs = await _prefs();
    await prefs.setInt(_otp10mWindowStartKey, value);
  }

  // OTP request 1-hour window
  static Future<int> getOtp1hCount() async {
    final prefs = await _prefs();
    return prefs.getInt(_otp1hCountKey) ?? 0;
  }

  static Future<void> setOtp1hCount(int value) async {
    final prefs = await _prefs();
    await prefs.setInt(_otp1hCountKey, value);
  }

  static Future<int?> getOtp1hWindowStartMs() async {
    final prefs = await _prefs();
    return prefs.getInt(_otp1hWindowStartKey);
  }

  static Future<void> setOtp1hWindowStartMs(int value) async {
    final prefs = await _prefs();
    await prefs.setInt(_otp1hWindowStartKey, value);
  }

  static Future<void> clearOtpRequestRateLimit() async {
    final prefs = await _prefs();
    await prefs.remove(_otp10mCountKey);
    await prefs.remove(_otp10mWindowStartKey);
    await prefs.remove(_otp1hCountKey);
    await prefs.remove(_otp1hWindowStartKey);
  }

  static Future<void> clearAllAuthRateLimit() async {
    await clearVerifyRateLimit();
    await clearOtpRequestRateLimit();
  }
}











