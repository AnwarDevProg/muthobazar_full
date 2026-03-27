// Register Form
// -------------
// Pure UI widget for phone OTP register form.

import 'dart:ui';

import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';
import '../controllers/register_controller.dart';
import 'auth_form_intro.dart';
import 'auth_get_otp_button.dart';
import 'auth_otp_section.dart';
import 'auth_resend_section.dart';
import 'auth_switch_link.dart';
import 'auth_terms_checkbox.dart';
import 'phone_input_with_prefix.dart';

class RegisterForm extends StatelessWidget {
  final RegisterController controller;
  final VoidCallback onAlreadyRegisteredDialog;
  final void Function(String title, String message) onShowErrorDialog;
  final VoidCallback onShowSuccessDialog;

  const RegisterForm({
    super.key,
    required this.controller,
    required this.onAlreadyRegisteredDialog,
    required this.onShowErrorDialog,
    required this.onShowSuccessDialog,
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
                title: 'Create your account',
                subtitle:
                'Enter your full name and phone number to verify and create your account.',
              ),

              MBSpacing.h(MBSpacing.xl),

              Text(
                'Full Name',
                style: MBAppText.label(context).copyWith(
                  color: MBColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              MBSpacing.h(MBSpacing.xs),

              TextField(
                controller: controller.fullNameController,
                onTap: controller.clearFullNameError,
                onChanged: (_) {
                  controller.fullNameErrorText = null;
                  controller.clearGeneralError();
                },
                onEditingComplete: controller.validateFullName,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  errorText: controller.fullNameErrorText,
                ),
              ),

              MBSpacing.h(MBSpacing.md),

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
                    onAlreadyRegistered: onAlreadyRegisteredDialog,
                    onError: onShowErrorDialog,
                  );

                  if (controller.isOtpSent) {
                    MBNotification.info(
                      title: 'OTP Sent',
                      message: 'Verification code sent to ${controller.maskedPhoneDisplay}',
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
                          onSuccess: onShowSuccessDialog,
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

              AuthTermsCheckbox(
                value: controller.agreeToTerms,
                onChanged: controller.setAgreeToTerms,
              ),

              MBSpacing.h(MBSpacing.lg),

              MBPrimaryButton(
                text: isBusy ? 'Please wait...' : 'Create Account',
                onPressed: controller.canVerifyOtp
                    ? () => controller.verifyOtp(
                  onSuccess: onShowSuccessDialog,
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
                  onAlreadyRegistered: onAlreadyRegisteredDialog,
                  onError: onShowErrorDialog,
                ),
              ),

              MBSpacing.h(MBSpacing.xl),

              AuthSwitchLink(
                prefixText: 'Already have an account? ',
                actionText: 'Login',
                onTap: () {
                  Get.toNamed(AppRoutes.login);
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