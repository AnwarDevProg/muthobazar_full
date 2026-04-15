import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

import '../controllers/admin_auth_controller.dart';
import '../widgets/admin_auth_shell.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  late final AdminAuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminAuthController()..initialize();
    _controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _showError(String title, String message) {
    MBNotification.error(
      title: title,
      message: message,
    );
  }

  Future<void> _sendOtp() async {
    await _controller.sendOtp(
      context: context,
      requireFullName: false,
      onError: _showError,
    );

    if (_controller.isOtpSent) {
      MBNotification.info(
        title: 'OTP Sent',
        message: 'Verification code sent to ${_controller.maskedPhoneDisplay}',
      );
    }
  }

  Future<void> _verifyOtp() async {
    await _controller.verifyOtp(
      isRegistrationFlow: false,
      onError: _showError,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBusy =
        _controller.isLoading || _controller.verifyOtpInProgress;

    return AdminAuthShell(
      title: 'Admin Login',
      subtitle: 'Sign in with your phone number to access the admin workspace.',
      child: Stack(
        children: [
          AbsorbPointer(
            absorbing: isBusy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Number',
                  style: MBTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xs),
                TextFormField(
                  controller: _controller.phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (_) {
                    _controller.clearPhoneInputErrors();
                  },
                  onEditingComplete: _controller.validatePhoneNumber,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '017XXXXXXXX',
                    prefixText: '+88 ',
                    errorText: _controller.phoneErrorText,
                    border: const OutlineInputBorder(),
                  ),
                ),
                MBSpacing.h(MBSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed:
                    _controller.canPressOtpButton ? _sendOtp : null,
                    child: Text(_controller.otpButtonText),
                  ),
                ),
                MBSpacing.h(MBSpacing.lg),
                if (_controller.isOtpSent) ...[
                  Text(
                    'Enter OTP',
                    style: MBTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xs),
                  TextFormField(
                    controller: _controller.otpController,
                    focusNode: _controller.otpFocusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (_) {
                      _controller.clearOtpError();
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '6-digit code',
                      errorText: _controller.otpErrorText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    'Code sent to ${_controller.maskedPhoneDisplay}',
                    style: MBTextStyles.caption.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.md),
                ],
                CheckboxListTile(
                  value: _controller.agreeToTerms,
                  onChanged: (value) {
                    _controller.setAgreeToTerms(value ?? false);
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'I agree to the Terms & Conditions and Privacy Policy.',
                  ),
                ),
                if (_controller.otpVerifyLockMessage != null) ...[
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    _controller.otpVerifyLockMessage!,
                    style: MBTextStyles.caption.copyWith(
                      color: MBColors.error,
                    ),
                  ),
                ],
                if (_controller.otpFailedAttempts > 0 &&
                    !_controller.isOtpVerifyLocked) ...[
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    'Remaining attempts: ${_controller.remainingOtpAttempts}',
                    style: MBTextStyles.caption.copyWith(
                      color: MBColors.error,
                    ),
                  ),
                ],
                if (_controller.otpRequestLockMessage != null) ...[
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    _controller.otpRequestLockMessage!,
                    style: MBTextStyles.caption.copyWith(
                      color: MBColors.error,
                    ),
                  ),
                ],
                MBSpacing.h(MBSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: MBPrimaryButton(
                    text: isBusy ? 'Please wait...' : 'Login',
                    isLoading: isBusy,
                    onPressed: _controller.canVerifyOtp ? _verifyOtp : null,
                  ),
                ),
                MBSpacing.h(MBSpacing.md),
                if (_controller.isOtpSent)
                  Center(
                    child: _controller.showResendButton
                        ? TextButton(
                      onPressed: () {
                        _controller.resendOtp(
                          context: context,
                          requireFullName: false,
                          onError: _showError,
                        );
                      },
                      child: const Text('Resend OTP'),
                    )
                        : Text(
                      'Resend in ${_controller.resendTimeoutSeconds}s',
                      style: MBTextStyles.caption.copyWith(
                        color: MBColors.textSecondary,
                      ),
                    ),
                  ),
                MBSpacing.h(MBSpacing.lg),
                Center(
                  child: TextButton(
                    onPressed: () => Get.toNamed(AdminWebRoutes.register),
                    child: const Text('Need first-time setup or registration?'),
                  ),
                ),
              ],
            ),
          ),
          if (isBusy)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.25),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}