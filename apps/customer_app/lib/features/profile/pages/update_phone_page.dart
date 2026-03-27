// Update Phone Page
// -----------------
// UI aligned with login OTP form style.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../controllers/update_phone_controller.dart';
import '../../auth/widgets/auth_form_intro.dart';
import '../../auth/widgets/auth_get_otp_button.dart';
import '../../auth/widgets/auth_otp_section.dart';
import '../../auth/widgets/auth_resend_section.dart';
import '../../auth/widgets/phone_input_with_prefix.dart';

class UpdatePhonePage extends StatefulWidget {
  const UpdatePhonePage({super.key});

  @override
  State<UpdatePhonePage> createState() => _UpdatePhonePageState();
}

class _UpdatePhonePageState extends State<UpdatePhonePage> {
  late final UpdatePhoneController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      UpdatePhoneController(),
      tag: 'profile_update_phone',
    );
    controller.initialize();
  }

  @override
  void dispose() {
    Get.delete<UpdatePhoneController>(tag: 'profile_update_phone');
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
          'Update Phone Number',
          style: MBAppText.sectionTitle(context),
        ),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final bool isBusy =
              controller.isLoading || controller.verifyOtpInProgress;

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
                        title: 'Update your phone number',
                        subtitle:
                        'Enter your new phone number to receive a one-time verification code.',
                      ),

                      MBSpacing.h(MBSpacing.xl),

                      Text(
                        'New Phone Number',
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

                        MBPrimaryButton(
                          text: isBusy ? 'Please wait...' : 'Verify & Update',
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

