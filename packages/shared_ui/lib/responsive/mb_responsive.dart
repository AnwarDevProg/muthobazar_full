// MB Responsive Helpers
// ---------------------
// Main utility layer for responsive decisions.
// Use this instead of writing ad-hoc MediaQuery logic repeatedly.
//
// Responsibilities:
// - width/height/safe area access
// - device classification
// - value selection by breakpoint
// - dimension scaling with safe clamping

import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'mb_breakpoints.dart';

class MBResponsive {
  MBResponsive._();

  static MediaQueryData mq(BuildContext context) => MediaQuery.of(context);

  static Size size(BuildContext context) => MediaQuery.sizeOf(context);

  static double width(BuildContext context) => size(context).width;

  static double height(BuildContext context) => size(context).height;

  static EdgeInsets viewPadding(BuildContext context) =>
      MediaQuery.viewPaddingOf(context);

  static EdgeInsets padding(BuildContext context) =>
      MediaQuery.paddingOf(context);

  static MBDeviceType deviceType(BuildContext context) =>
      MBBreakpoints.fromWidth(width(context));

  static bool isMobile(BuildContext context) =>
      MBBreakpoints.isMobile(width(context));

  static bool isTablet(BuildContext context) =>
      MBBreakpoints.isTablet(width(context));

  static double shortestSide(BuildContext context) =>
      math.min(width(context), height(context));

  static double longestSide(BuildContext context) =>
      math.max(width(context), height(context));

  static double usableWidth(BuildContext context) {
    final w = width(context);
    final pad = padding(context);
    return w - pad.left - pad.right;
  }

  static double usableHeight(BuildContext context) {
    final h = height(context);
    final pad = padding(context);
    return h - pad.top - pad.bottom;
  }

  static T value<T>(
      BuildContext context, {
        required T mobile,
        T? mobileSmall,
        T? mobileLarge,
        T? tablet,
        T? tabletLarge,
      }) {
    final type = deviceType(context);

    switch (type) {
      case MBDeviceType.mobileSmall:
        return mobileSmall ?? mobile;
      case MBDeviceType.mobile:
        return mobile;
      case MBDeviceType.mobileLarge:
        return mobileLarge ?? mobile;
      case MBDeviceType.tablet:
        return tablet ?? mobileLarge ?? mobile;
      case MBDeviceType.tabletLarge:
        return tabletLarge ?? tablet ?? mobileLarge ?? mobile;
    }
  }

  static double scaleWidth(
      BuildContext context,
      double value, {
        double minScale = 0.90,
        double maxScale = 1.18,
      }) {
    final currentWidth = width(context);
    final reference = MBBreakpoints.designReferenceWidth(currentWidth);
    final rawScale = currentWidth / reference;
    final safeScale = rawScale.clamp(minScale, maxScale);
    return value * safeScale;
  }

  static double scaleHeight(
      BuildContext context,
      double value, {
        double referenceHeight = 844,
        double minScale = 0.90,
        double maxScale = 1.10,
      }) {
    final currentHeight = height(context);
    final rawScale = currentHeight / referenceHeight;
    final safeScale = rawScale.clamp(minScale, maxScale);
    return value * safeScale;
  }

  static double scale(
      BuildContext context,
      double value, {
        double minScale = 0.90,
        double maxScale = 1.15,
      }) {
    final sw = width(context) / MBBreakpoints.designReferenceWidth(width(context));
    final sh = height(context) / 844;
    final combined = (sw + sh) / 2;
    final safeScale = combined.clamp(minScale, maxScale);
    return value * safeScale;
  }

  static double adaptive(
      BuildContext context, {
        required double min,
        required double max,
        double? minWidth,
        double? maxWidth,
      }) {
    final w = width(context);
    final start = minWidth ?? 320;
    final end = maxWidth ?? 840;

    if (w <= start) return min;
    if (w >= end) return max;

    final t = (w - start) / (end - start);
    return min + (max - min) * t;
  }
}

extension MBResponsiveContextX on BuildContext {
  MediaQueryData get mbMq => MediaQuery.of(this);

  Size get mbSize => MediaQuery.sizeOf(this);

  double get mbWidth => mbSize.width;

  double get mbHeight => mbSize.height;

  EdgeInsets get mbPadding => MediaQuery.paddingOf(this);

  EdgeInsets get mbViewPadding => MediaQuery.viewPaddingOf(this);

  double mbScale(
      double value, {
        double minScale = 0.90,
        double maxScale = 1.15,
      }) {
    return MBResponsive.scale(
      this,
      value,
      minScale: minScale,
      maxScale: maxScale,
    );
  }

  T mbValue<T>({
    required T mobile,
    T? mobileSmall,
    T? mobileLarge,
    T? tablet,
    T? tabletLarge,
  }) {
    return MBResponsive.value(
      this,
      mobile: mobile,
      mobileSmall: mobileSmall,
      mobileLarge: mobileLarge,
      tablet: tablet,
      tabletLarge: tabletLarge,
    );
  }
}











