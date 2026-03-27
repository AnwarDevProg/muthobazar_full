// MB Text Scale
// -------------
// Responsive typography scale for MuthoBazar.
// Keep text readable across small phones and tablets while preserving
// brand feel and visual hierarchy.
//
// This utility returns font sizes only.
// Actual TextStyle theme integration can come later in MBAppText or theme layer.

import 'package:flutter/widgets.dart';
import 'mb_responsive.dart';

class MBTextScale {
  MBTextScale._();

  static double display(BuildContext context) => context.mbValue(
    mobile: 32,
    mobileSmall: 28,
    mobileLarge: 34,
    tablet: 38,
    tabletLarge: 42,
  );

  static double headline1(BuildContext context) => context.mbValue(
    mobile: 28,
    mobileSmall: 24,
    mobileLarge: 30,
    tablet: 32,
    tabletLarge: 36,
  );

  static double headline2(BuildContext context) => context.mbValue(
    mobile: 24,
    mobileSmall: 22,
    mobileLarge: 26,
    tablet: 28,
    tabletLarge: 30,
  );

  static double headline3(BuildContext context) => context.mbValue(
    mobile: 20,
    mobileSmall: 18,
    mobileLarge: 22,
    tablet: 24,
    tabletLarge: 26,
  );

  static double title(BuildContext context) => context.mbValue(
    mobile: 18,
    mobileSmall: 16,
    mobileLarge: 19,
    tablet: 20,
    tabletLarge: 22,
  );

  static double bodyLarge(BuildContext context) => context.mbValue(
    mobile: 16,
    mobileSmall: 15,
    mobileLarge: 17,
    tablet: 17,
    tabletLarge: 18,
  );

  static double body(BuildContext context) => context.mbValue(
    mobile: 14,
    mobileSmall: 13,
    mobileLarge: 15,
    tablet: 15,
    tabletLarge: 16,
  );

  static double bodySmall(BuildContext context) => context.mbValue(
    mobile: 12,
    mobileSmall: 11,
    mobileLarge: 13,
    tablet: 13,
    tabletLarge: 14,
  );

  static double label(BuildContext context) => context.mbValue(
    mobile: 13,
    mobileSmall: 12,
    mobileLarge: 14,
    tablet: 14,
    tabletLarge: 15,
  );

  static double button(BuildContext context) => context.mbValue(
    mobile: 15,
    mobileSmall: 14,
    mobileLarge: 16,
    tablet: 16,
    tabletLarge: 17,
  );

  static double caption(BuildContext context) => context.mbValue(
    mobile: 11,
    mobileSmall: 10,
    mobileLarge: 12,
    tablet: 12,
    tabletLarge: 13,
  );

  // For TextStyle.height
  static double lineHeight({double ratio = 1.35}) => ratio;

  static double letterSpacingTight(double fontSize) {
    if (fontSize >= 28) return -0.4;
    if (fontSize >= 20) return -0.2;
    return 0;
  }

  static double letterSpacingNormal(double fontSize) {
    if (fontSize <= 12) return 0.1;
    return 0;
  }
}











