import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../responsive/mb_spacing.dart';
import '../../typography/mb_app_text.dart';
import '../../../theme/mb_colors.dart';
import '../../../theme/mb_gradients.dart';
import '../../../theme/mb_radius.dart';

enum MBNotificationType {
  success,
  error,
  warning,
  info,
}

enum MBNotificationPosition {
  top,
  bottom,
}

class MBNotification {
  MBNotification._();

  static void show({
    required String title,
    required String message,
    MBNotificationType type = MBNotificationType.info,
    MBNotificationPosition position = MBNotificationPosition.top,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
    VoidCallback? onTap,
  }) {
    final context = Get.context;
    if (context == null) {
      debugPrint('MBNotification skipped: no Get.context | $title | $message');
      return;
    }

    final style = _resolveStyle(type);
    final mediaQuery = MediaQuery.of(context);

    final horizontal = MBSpacing.pageHorizontal(context);
    final topInset = mediaQuery.padding.top;
    final bottomInset = mediaQuery.padding.bottom;

    try {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      Get.rawSnackbar(
        snackPosition: position == MBNotificationPosition.top
            ? SnackPosition.TOP
            : SnackPosition.BOTTOM,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.only(
          left: horizontal,
          right: horizontal,
          top: position == MBNotificationPosition.top ? topInset + 12 : 0,
          bottom: position == MBNotificationPosition.bottom ? bottomInset + 12 : 0,
        ),
        borderRadius: MBRadius.xl,
        padding: EdgeInsets.zero,
        messageText: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: _MBNotificationCard(
            title: title,
            message: message,
            icon: icon ?? style.icon,
            accentGradient: style.gradient,
          ),
        ),
        duration: duration,
        isDismissible: true,
        animationDuration: const Duration(milliseconds: 260),
      );
    } catch (e, st) {
      debugPrint('MBNotification error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  static void success({
    required String title,
    required String message,
    MBNotificationPosition position = MBNotificationPosition.top,
    VoidCallback? onTap,
  }) {
    show(
      title: title,
      message: message,
      type: MBNotificationType.success,
      position: position,
      onTap: onTap,
    );
  }

  static void error({
    required String title,
    required String message,
    MBNotificationPosition position = MBNotificationPosition.top,
    VoidCallback? onTap,
  }) {
    show(
      title: title,
      message: message,
      type: MBNotificationType.error,
      position: position,
      onTap: onTap,
    );
  }

  static void warning({
    required String title,
    required String message,
    MBNotificationPosition position = MBNotificationPosition.top,
    VoidCallback? onTap,
  }) {
    show(
      title: title,
      message: message,
      type: MBNotificationType.warning,
      position: position,
      onTap: onTap,
    );
  }

  static void info({
    required String title,
    required String message,
    MBNotificationPosition position = MBNotificationPosition.top,
    VoidCallback? onTap,
  }) {
    show(
      title: title,
      message: message,
      type: MBNotificationType.info,
      position: position,
      onTap: onTap,
    );
  }
}

class _MBNotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Gradient accentGradient;

  const _MBNotificationCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.accentGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: MBColors.card,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: accentGradient,
              borderRadius: BorderRadius.circular(MBRadius.md),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          MBSpacing.w(MBSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MBAppText.label(context).copyWith(
                    color: MBColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  message,
                  style: MBAppText.bodySmall(context).copyWith(
                    color: MBColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

_MBNotificationStyle _resolveStyle(MBNotificationType type) {
  switch (type) {
    case MBNotificationType.success:
      return const _MBNotificationStyle(
        icon: Icons.check_circle_outline_rounded,
        gradient: LinearGradient(
          colors: [
            Color(0xFF10B981),
            Color(0xFF34D399),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    case MBNotificationType.error:
      return const _MBNotificationStyle(
        icon: Icons.error_outline_rounded,
        gradient: LinearGradient(
          colors: [
            Color(0xFFE53935),
            Color(0xFFFF6B6B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    case MBNotificationType.warning:
      return const _MBNotificationStyle(
        icon: Icons.warning_amber_rounded,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF8A00),
            Color(0xFFFFB347),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    case MBNotificationType.info:
      return const _MBNotificationStyle(
        icon: Icons.info_outline_rounded,
        gradient: MBGradients.primaryGradient,
      );
  }
}

class _MBNotificationStyle {
  final IconData icon;
  final Gradient gradient;

  const _MBNotificationStyle({
    required this.icon,
    required this.gradient,
  });
}











