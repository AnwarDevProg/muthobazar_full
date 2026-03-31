class PhoneAuthEligibilityResult {
  final bool ok;
  final String normalizedPhone;
  final String app;
  final String intent;

  final bool existsInPhoneIndex;
  final bool userExists;
  final String? userUid;
  final String? userRole;

  final bool bootstrapOpen;
  final bool superAdminExists;

  final bool hasAdminProfile;
  final bool hasAdminPermission;
  final bool canAccessAdminPanel;

  final String authMode;
  final bool allowSendOtp;
  final bool showSuperAdminCreation;

  final String code;
  final String message;

  const PhoneAuthEligibilityResult({
    required this.ok,
    required this.normalizedPhone,
    required this.app,
    required this.intent,
    required this.existsInPhoneIndex,
    required this.userExists,
    required this.userUid,
    required this.userRole,
    required this.bootstrapOpen,
    required this.superAdminExists,
    required this.hasAdminProfile,
    required this.hasAdminPermission,
    required this.canAccessAdminPanel,
    required this.authMode,
    required this.allowSendOtp,
    required this.showSuperAdminCreation,
    required this.code,
    required this.message,
  });

  factory PhoneAuthEligibilityResult.fromMap(Map<String, dynamic> map) {
    return PhoneAuthEligibilityResult(
      ok: map['ok'] == true,
      normalizedPhone: (map['normalizedPhone'] ?? '').toString(),
      app: (map['app'] ?? '').toString(),
      intent: (map['intent'] ?? '').toString(),
      existsInPhoneIndex: map['existsInPhoneIndex'] == true,
      userExists: map['userExists'] == true,
      userUid: map['userUid']?.toString(),
      userRole: map['userRole']?.toString(),
      bootstrapOpen: map['bootstrapOpen'] == true,
      superAdminExists: map['superAdminExists'] == true,
      hasAdminProfile: map['hasAdminProfile'] == true,
      hasAdminPermission: map['hasAdminPermission'] == true,
      canAccessAdminPanel: map['canAccessAdminPanel'] == true,
      authMode: (map['authMode'] ?? 'blocked').toString(),
      allowSendOtp: map['allowSendOtp'] == true,
      showSuperAdminCreation: map['showSuperAdminCreation'] == true,
      code: (map['code'] ?? 'INTERNAL_ERROR').toString(),
      message: (map['message'] ?? 'Unknown response.').toString(),
    );
  }
}