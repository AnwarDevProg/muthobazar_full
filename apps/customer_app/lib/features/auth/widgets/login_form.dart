// Login Form
// ----------
// Pure UI widget for phone OTP login form.

import 'dart:ui';

import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';
import '../controllers/login_controller.dart';
import 'auth_form_intro.dart';
import 'auth_get_otp_button.dart';
import 'auth_otp_section.dart';
import 'auth_resend_section.dart';
import 'auth_switch_link.dart';
import 'auth_terms_checkbox.dart';
import 'phone_input_with_prefix.dart';

class LoginForm extends StatelessWidget {
  final LoginController controller;
  final VoidCallback onShowSignupDialog;
  final void Function(String title, String message) onShowErrorDialog;

  const LoginForm({
    super.key,
    required this.controller,
    required this.onShowSignupDialog,
    required this.onShowErrorDialog,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBusy = controller.isLoading || controller.verifyOtpInProgress;

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: isBusy,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthFormIntro(
                title: 'Login to your account',
                subtitle:
                'Enter your phone number to receive a one-time verification code.',
              ),

              MBSpacing.h(MBSpacing.xl),

              Text(
                'Phone Number',
                style: MBAppText.label(context).copyWith(
                  color: MBColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              MBSpacing.h(MBSpacing.xs),

              PhoneInputWithPrefix(
                controller: controller.phoneController,
                errorText: controller.phoneErrorText,
                onTap: controller.clearPhoneField,
                onEditingComplete: controller.validatePhoneNumber,
                onChanged: (_) {
                  controller.phoneErrorText = null;
                  controller.clearGeneralError();
                },
              ),

              MBSpacing.h(MBSpacing.md),

              AuthGetOtpButton(
                text: controller.otpButtonText,
                onPressed: controller.canPressOtpButton
                    ? () async {
                  await controller.sendOtp(
                    context: context,
                    onUnregisteredUser: onShowSignupDialog,
                    onError: onShowErrorDialog,
                  );

                  if (controller.isOtpSent) {
                    MBNotification.info(
                      title: 'OTP Sent',
                      message:
                      'Verification code sent to ${controller.maskedPhoneDisplay}',
                    );
                  }
                }
                    : null,
              ),

              MBSpacing.h(MBSpacing.lg),

              AuthOtpSection(
                controller: controller.otpController,
                focusNode: controller.otpFocusNode,
                errorText: controller.otpErrorText,
                visible: controller.isOtpSent,
                helperText: controller.isOtpSent
                    ? '6-digit code sent to ${controller.maskedPhoneDisplay}'
                    : null,
                onChanged: (value) {
                  controller.clearOtpError();

                  if (value.length == 6) {
                    Future.microtask(() {
                      if (controller.canVerifyOtp) {
                        controller.verifyOtp(
                          onError: onShowErrorDialog,
                        );
                      }
                    });
                  }
                },
              ),

              if (controller.otpVerifyLockMessage != null) ...[
                MBSpacing.h(MBSpacing.xs),
                Text(
                  controller.otpVerifyLockMessage!,
                  style: MBAppText.bodySmall(context).copyWith(
                    color: Colors.red,
                  ),
                ),
              ],

              if (controller.otpFailedAttempts > 0 &&
                  !controller.isOtpVerifyLocked) ...[
                MBSpacing.h(MBSpacing.xs),
                Text(
                  'Remaining attempts: ${controller.remainingOtpAttempts}',
                  style: MBAppText.bodySmall(context).copyWith(
                    color: Colors.red,
                  ),
                ),
              ],

              if (controller.otpRequestLockMessage != null) ...[
                MBSpacing.h(MBSpacing.xs),
                Text(
                  controller.otpRequestLockMessage!,
                  style: MBAppText.bodySmall(context).copyWith(
                    color: Colors.red,
                  ),
                ),
              ],

              MBSpacing.h(MBSpacing.lg),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Checkbox(
                      value: controller.rememberMe,
                      onChanged: (bool? value) {
                        if (value == null) return;
                        controller.toggleRememberMe(value);
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Remember me',
                        style: MBAppText.body(context),
                      ),
                    ),
                  ),
                ],
              ),

              AuthTermsCheckbox(
                value: controller.agreeToTerms,
                onChanged: controller.setAgreeToTerms,
              ),

              MBSpacing.h(MBSpacing.lg),

              MBPrimaryButton(
                text: isBusy ? 'Please wait...' : 'Login',
                onPressed: controller.canVerifyOtp
                    ? () => controller.verifyOtp(
                  onError: onShowErrorDialog,
                )
                    : null,
              ),

              MBSpacing.h(MBSpacing.md),

              AuthResendSection(
                isOtpSent: controller.isOtpSent,
                showResendButton: controller.showResendButton,
                resendTimeoutSeconds: controller.resendTimeoutSeconds,
                onResend: () => controller.resendOtp(
                  context: context,
                  onUnregisteredUser: onShowSignupDialog,
                  onError: onShowErrorDialog,
                ),
              ),

              MBSpacing.h(MBSpacing.xl),

              AuthSwitchLink(
                prefixText: "Don't have an account? ",
                actionText: 'Register',
                onTap: () {
                  Get.toNamed(AppRoutes.register);
                },
              ),
            ],
          ),
        ),

        if (isBusy)
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.25),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
