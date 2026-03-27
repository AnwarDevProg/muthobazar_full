// OTP Input Widget
// ----------------
// Reusable OTP input using Pinput.
// Supports:
// - responsive sizing
// - clipboard OTP auto-paste
// - manual change callbacks
// - entrance highlight animation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_ui/shared_ui.dart';

class OtpInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool animateHighlight;

  const OtpInput({
    super.key,
    required this.controller,
    required this.focusNode,
    this.errorText,
    this.onChanged,
    this.animateHighlight = false,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput>
    with SingleTickerProviderStateMixin {
  bool _hasCheckedClipboardOnce = false;
  bool _otpNotificationShown = false;

  late final AnimationController _animationController;
  late final Animation<double> _glowAnimation;

  Future<void> _tryPasteOtpFromClipboard() async {
    if (_hasCheckedClipboardOnce) return;
    _hasCheckedClipboardOnce = true;

    try {
      final ClipboardData? data = await Clipboard.getData('text/plain');
      final String text = data?.text?.trim() ?? '';

      final RegExp otpRegex = RegExp(r'\b\d{6}\b');
      final Match? match = otpRegex.firstMatch(text);

      if (match != null) {
        final String otp = match.group(0)!;

        if (widget.controller.text != otp) {
          widget.controller.text = otp;
          widget.onChanged?.call(otp);

          if (!_otpNotificationShown) {
            _otpNotificationShown = true;

            MBNotification.success(
              title: 'OTP Detected',
              message: 'Verification code filled automatically',
            );
          }
        }
      }
    } catch (_) {
      // Ignore clipboard failures silently
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _glowAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus) {
        _tryPasteOtpFromClipboard();
      }
    });

    if (widget.animateHighlight) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.animateHighlight && widget.animateHighlight) {
      _animationController.forward(from: 0);
    }

    if (widget.controller.text.isEmpty) {
      _otpNotificationShown = false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double pinWidth = context.mbValue(
      mobileSmall: 40,
      mobile: 44,
      mobileLarge: 46,
      tablet: 52,
      tabletLarge: 56,
    );

    final double pinHeight = context.mbValue(
      mobileSmall: 46,
      mobile: 50,
      mobileLarge: 52,
      tablet: 58,
      tabletLarge: 62,
    );

    final double fontSize = context.mbValue(
      mobileSmall: 16,
      mobile: 17,
      mobileLarge: 18,
      tablet: 20,
      tabletLarge: 22,
    );

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final double glowStrength =
        widget.animateHighlight ? (1 - _glowAnimation.value) : 0;

        final PinTheme defaultPinTheme = PinTheme(
          width: pinWidth,
          height: pinHeight,
          textStyle: MBAppText.bodyLarge(context).copyWith(
            fontSize: fontSize,
            color: MBColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: BoxDecoration(
            color: MBColors.surface,
            borderRadius: BorderRadius.circular(MBRadius.md),
            border: Border.all(
              color: MBColors.primaryOrange.withValues(
                alpha: 0.18 + (glowStrength * 0.22),
              ),
            ),
            boxShadow: glowStrength > 0
                ? [
              BoxShadow(
                color: MBColors.primaryOrange.withValues(
                  alpha: 0.18 * glowStrength,
                ),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
        );

        final PinTheme focusedPinTheme = defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: MBColors.surface,
            borderRadius: BorderRadius.circular(MBRadius.md),
            border: Border.all(
              color: MBColors.primaryOrange,
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: MBColors.primaryOrange.withValues(alpha: 0.14),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        );

        final PinTheme submittedPinTheme = defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: MBColors.primaryOrange.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(MBRadius.md),
            border: Border.all(
              color: MBColors.primaryOrange.withValues(alpha: 0.28),
            ),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Pinput(
                controller: widget.controller,
                focusNode: widget.focusNode,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                mainAxisAlignment: MainAxisAlignment.center,
                separatorBuilder: (index) => MBSpacing.w(MBSpacing.xs),
                onChanged: (value) {
                  widget.onChanged?.call(value);

                  if (value.isEmpty) {
                    _otpNotificationShown = false;
                  }

                  if (value.length == 6 && !_otpNotificationShown) {
                    _otpNotificationShown = true;

                    MBNotification.success(
                      title: 'OTP Ready',
                      message: 'Code detected automatically',
                    );
                  }
                },
              ),
            ),
            if (widget.errorText != null) ...[
              MBSpacing.h(MBSpacing.xs),
              Text(
                widget.errorText!,
                style: MBAppText.bodySmall(context).copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}