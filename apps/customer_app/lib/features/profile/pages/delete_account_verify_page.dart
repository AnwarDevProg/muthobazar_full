// Delete Account Verify Page
// --------------------------
// OTP verification UI aligned with login form style,
// powered by DeleteAccountVerifyController.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../controllers/delete_account_verify_controller.dart';
import '../../auth/widgets/auth_form_intro.dart';
import '../../auth/widgets/auth_get_otp_button.dart';
import '../../auth/widgets/auth_otp_section.dart';
import '../../auth/widgets/auth_resend_section.dart';
import '../../auth/widgets/phone_input_with_prefix.dart';

class DeleteAccountVerifyPage extends StatefulWidget {
  const DeleteAccountVerifyPage({super.key});

  @override
  State<DeleteAccountVerifyPage> createState() =>
      _DeleteAccountVerifyPageState();
}

class _DeleteAccountVerifyPageState extends State<DeleteAccountVerifyPage> {
  late final DeleteAccountVerifyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      DeleteAccountVerifyController(),
      tag: 'delete_account_verify',
    );
    controller.initialize();
  }

  @override
  void dispose() {
    Get.delete<DeleteAccountVerifyController>(tag: 'delete_account_verify');
    super.dispose();
  }

  void _showError(String title, String message) {
    MBNotification.error(
      title: title,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MBAppLayout(
      backgroundColor: MBColors.background,
      appBar: AppBar(
        title: Text(
          'Delete Account',
          style: MBAppText.sectionTitle(context),
        ),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final bool isBusy = controller.isLoading ||
              controller.verifyOtpInProgress ||
              controller.isDeletingAccount;

          return Stack(
            children: [
              AbsorbPointer(
                absorbing: isBusy,
                child: Padding(
                  padding: MBScreenPadding.page(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthFormIntro(
                        title: 'Verify before deleting',
                        subtitle:
                        'For security, confirm your current phone number with a one-time verification code before deleting your account.',
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
                          controller.onPhoneChanged();
                        },
                      ),

                      if (controller.generalErrorText != null) ...[
                        MBSpacing.h(MBSpacing.xs),
                        Text(
                          controller.generalErrorText!,
                          style: MBAppText.bodySmall(context).copyWith(
                            color: MBColors.error,
                          ),
                        ),
                      ],

                      MBSpacing.h(MBSpacing.md),

                      AuthGetOtpButton(
                        text: controller.otpButtonText,
                        onPressed: controller.canPressOtpButton
                            ? () async {
                          await controller.sendOtp(
                            context: context,
                            onError: _showError,
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
                          controller.onOtpChanged();

                          if (value.length == 6) {
                            Future.microtask(() {
                              if (controller.canVerifyOtp) {
                                controller.verifyOtp(
                                  onError: _showError,
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
                            color: MBColors.error,
                          ),
                        ),
                      ],

                      if (controller.otpFailedAttempts > 0 &&
                          !controller.isOtpVerifyLocked) ...[
                        MBSpacing.h(MBSpacing.xs),
                        Text(
                          'Remaining attempts: ${controller.remainingOtpAttempts}',
                          style: MBAppText.bodySmall(context).copyWith(
                            color: MBColors.error,
                          ),
                        ),
                      ],

                      if (controller.otpRequestLockMessage != null) ...[
                        MBSpacing.h(MBSpacing.xs),
                        Text(
                          controller.otpRequestLockMessage!,
                          style: MBAppText.bodySmall(context).copyWith(
                            color: MBColors.error,
                          ),
                        ),
                      ],

                      if (controller.isOtpSent) ...[
                        MBSpacing.h(MBSpacing.lg),

                        Text(
                          'This action is permanent. Once deleted, your account data cannot be recovered.',
                          style: MBAppText.bodySmall(context).copyWith(
                            color: MBColors.error,
                            height: 1.4,
                          ),
                        ),

                        MBSpacing.h(MBSpacing.lg),

                        MBPrimaryButton(
                          text: isBusy
                              ? 'Deleting...'
                              : 'Verify & Delete Account',
                          onPressed: controller.canVerifyOtp
                              ? () => controller.verifyOtp(
                            onError: _showError,
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
                            onError: _showError,
                          ),
                        ),
                      ],
                    ],
                  ),
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
        },
      ),
    );
  }
}

