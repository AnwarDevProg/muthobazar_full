import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';


enum MBDialogType {
  info,
  warning,
  danger,
  success,
}

class MBDialogs {
  MBDialogs._();

  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    MBDialogType type = MBDialogType.info,
    IconData? icon,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        return _MBDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          type: type,
          icon: icon,
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static Future<bool> showLoginRequired(
      BuildContext context, {
        Future<void> Function()? onLoginTap,
      }) async {
    final bool? shouldLogin = await showConfirm(
      context: context,
      title: 'Login Required',
      message: 'You need to login first to use this feature.',
      confirmText: 'Login',
      cancelText: 'Cancel',
      type: MBDialogType.warning,
      icon: Icons.lock_outline_rounded,
    );

    if (shouldLogin == true) {
      if (onLoginTap != null) {
        await onLoginTap();
      }
      return true;
    }

    return false;
  }

  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    MBDialogType type = MBDialogType.info,
    IconData? icon,
  }) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Info Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        return _MBInfoDialog(
          title: title,
          message: message,
          buttonText: buttonText,
          type: type,
          icon: icon,
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _MBDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final MBDialogType type;
  final IconData? icon;

  const _MBDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.type,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(type);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MBSpacing.pageHorizontal(context),
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(MBSpacing.lg),
              decoration: BoxDecoration(
                color: MBColors.card,
                borderRadius: BorderRadius.circular(MBRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: MBColors.shadow.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: style.iconGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon ?? style.icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.md),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: MBAppText.headline3(context).copyWith(
                      color: MBColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: MBAppText.body(context).copyWith(
                      color: MBColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: MBSecondaryButton(
                          text: cancelText,
                          onPressed: () => Navigator.of(context).pop(false),
                          height: 50,
                        ),
                      ),
                      MBSpacing.w(MBSpacing.sm),
                      Expanded(
                        child: MBPrimaryButton(
                          text: confirmText,
                          onPressed: () => Navigator.of(context).pop(true),
                          height: 50,
                          gradient: style.buttonGradient,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MBInfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final MBDialogType type;
  final IconData? icon;

  const _MBInfoDialog({
    required this.title,
    required this.message,
    required this.buttonText,
    required this.type,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(type);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MBSpacing.pageHorizontal(context),
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(MBSpacing.lg),
              decoration: BoxDecoration(
                color: MBColors.card,
                borderRadius: BorderRadius.circular(MBRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: MBColors.shadow.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: style.iconGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon ?? style.icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.md),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: MBAppText.headline3(context).copyWith(
                      color: MBColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: MBAppText.body(context).copyWith(
                      color: MBColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: MBPrimaryButton(
                      text: buttonText,
                      onPressed: () => Navigator.of(context).pop(),
                      height: 50,
                      gradient: style.buttonGradient,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

_MBDialogStyle _resolveStyle(MBDialogType type) {
  switch (type) {
    case MBDialogType.warning:
      return const _MBDialogStyle(
        icon: Icons.warning_amber_rounded,
        iconGradient: LinearGradient(
          colors: [
            Color(0xFFFF8A00),
            Color(0xFFFFB347),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        buttonGradient: MBGradients.primaryGradient,
      );

    case MBDialogType.danger:
      return const _MBDialogStyle(
        icon: Icons.delete_outline_rounded,
        iconGradient: LinearGradient(
          colors: [
            Color(0xFFE53935),
            Color(0xFFFF6B6B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        buttonGradient: LinearGradient(
          colors: [
            Color(0xFFE53935),
            Color(0xFFFF6B6B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );

    case MBDialogType.success:
      return const _MBDialogStyle(
        icon: Icons.check_circle_outline_rounded,
        iconGradient: LinearGradient(
          colors: [
            Color(0xFF10B981),
            Color(0xFF34D399),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        buttonGradient: LinearGradient(
          colors: [
            Color(0xFF10B981),
            Color(0xFF34D399),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );

    case MBDialogType.info:
      return const _MBDialogStyle(
        icon: Icons.info_outline_rounded,
        iconGradient: MBGradients.primaryGradient,
        buttonGradient: MBGradients.primaryGradient,
      );
  }
}

class _MBDialogStyle {
  final IconData icon;
  final Gradient iconGradient;
  final Gradient buttonGradient;

  const _MBDialogStyle({
    required this.icon,
    required this.iconGradient,
    required this.buttonGradient,
  });
}











