// MButhoBazar Responsive Breakpoints
// ----------------------------------
// Central breakpoint definitions for phones and tablets.
// This project is portrait-first, but layout utilities should still
// behave safely if a wider width appears.
//
// Rules:
// - Keep all breakpoint values in one place
// - UI decisions should use these constants
// - Avoid scattering hardcoded width values across widgets

import 'package:flutter/widgets.dart';

enum MBDeviceType {
  mobileSmall,
  mobile,
  mobileLarge,
  tablet,
  tabletLarge,
}

class MBBreakpoints {
  MBBreakpoints._();

  // Core widths
  static const double mobileSmallMax = 359;
  static const double mobileMax = 479;
  static const double mobileLargeMax = 599;
  static const double tabletMax = 839;
  static const double tabletLargeMax = 1199;

  // Common design widths
  static const double designWidthMobile = 390;
  static const double designWidthTablet = 800;

  static MBDeviceType fromWidth(double width) {
    if (width <= mobileSmallMax) return MBDeviceType.mobileSmall;
    if (width <= mobileMax) return MBDeviceType.mobile;
    if (width <= mobileLargeMax) return MBDeviceType.mobileLarge;
    if (width <= tabletMax) return MBDeviceType.tablet;
    return MBDeviceType.tabletLarge;
  }

  static bool isMobile(double width) => width <= mobileLargeMax;

  static bool isTablet(double width) => width > mobileLargeMax;

  static bool isSmallMobile(double width) => width <= mobileSmallMax;

  static bool isLargeMobile(double width) =>
      width > mobileMax && width <= mobileLargeMax;

  static bool isLargeTablet(double width) => width > tabletMax;

  static double designReferenceWidth(double width) {
    return isTablet(width) ? designWidthTablet : designWidthMobile;
  }

  static int columnsForWidth(double width) {
    final type = fromWidth(width);

    switch (type) {
      case MBDeviceType.mobileSmall:
      case MBDeviceType.mobile:
      case MBDeviceType.mobileLarge:
        return 4;
      case MBDeviceType.tablet:
        return 8;
      case MBDeviceType.tabletLarge:
        return 12;
    }
  }

  static double horizontalPadding(double width) {
    final type = fromWidth(width);

    switch (type) {
      case MBDeviceType.mobileSmall:
        return 12;
      case MBDeviceType.mobile:
        return 16;
      case MBDeviceType.mobileLarge:
        return 18;
      case MBDeviceType.tablet:
        return 24;
      case MBDeviceType.tabletLarge:
        return 32;
    }
  }

  static double contentMaxWidth(double width) {
    final type = fromWidth(width);

    switch (type) {
      case MBDeviceType.mobileSmall:
      case MBDeviceType.mobile:
      case MBDeviceType.mobileLarge:
        return width;
      case MBDeviceType.tablet:
        return 720;
      case MBDeviceType.tabletLarge:
        return 980;
    }
  }

  static double gutter(double width) {
    final type = fromWidth(width);

    switch (type) {
      case MBDeviceType.mobileSmall:
      case MBDeviceType.mobile:
      case MBDeviceType.mobileLarge:
        return 12;
      case MBDeviceType.tablet:
        return 16;
      case MBDeviceType.tabletLarge:
        return 20;
    }
  }
}

extension MBBreakpointContextX on BuildContext {
  MBDeviceType get mbDeviceType => MBBreakpoints.fromWidth(MediaQuery.sizeOf(this).width);

  bool get isMbMobile => MBBreakpoints.isMobile(MediaQuery.sizeOf(this).width);

  bool get isMbTablet => MBBreakpoints.isTablet(MediaQuery.sizeOf(this).width);

  bool get isMbSmallMobile =>
      MBBreakpoints.isSmallMobile(MediaQuery.sizeOf(this).width);

  bool get isMbLargeMobile =>
      MBBreakpoints.isLargeMobile(MediaQuery.sizeOf(this).width);

  bool get isMbLargeTablet =>
      MBBreakpoints.isLargeTablet(MediaQuery.sizeOf(this).width);
}











