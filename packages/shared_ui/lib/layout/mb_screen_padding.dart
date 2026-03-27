// MB Screen Padding
// -----------------
// Standard padding helpers for full screens, sections, and lists.
//
// Purpose:
// - keep consistent layout padding across all pages
// - adapt padding automatically for mobile and tablet
// - avoid hardcoded EdgeInsets in screens

import 'package:flutter/widgets.dart';
import '../responsive/mb_spacing.dart';
import '../responsive/mb_responsive.dart';

class MBScreenPadding {
  MBScreenPadding._();

  /// Standard page padding
  static EdgeInsets page(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: MBSpacing.pageHorizontal(context),
      vertical: MBSpacing.pageVertical(context),
    );
  }

  /// Page padding without top (useful when header already has spacing)
  static EdgeInsets pageNoTop(BuildContext context) {
    return EdgeInsets.only(
      left: MBSpacing.pageHorizontal(context),
      right: MBSpacing.pageHorizontal(context),
      bottom: MBSpacing.pageVertical(context),
    );
  }

  /// Horizontal-only padding
  static EdgeInsets horizontal(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: MBSpacing.pageHorizontal(context),
    );
  }

  /// Vertical-only padding
  static EdgeInsets vertical(BuildContext context) {
    return EdgeInsets.symmetric(
      vertical: MBSpacing.pageVertical(context),
    );
  }

  /// Section padding (used between blocks)
  static EdgeInsets section(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: MBSpacing.pageHorizontal(context),
      vertical: MBSpacing.sectionGap(context),
    );
  }

  /// List padding (for ListView / GridView)
  static EdgeInsets list(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: MBSpacing.pageHorizontal(context),
      vertical: MBSpacing.itemGap(context),
    );
  }

  /// Card container padding
  static EdgeInsets card(BuildContext context) {
    return EdgeInsets.all(
      MBSpacing.cardPadding(context),
    );
  }

  /// Dialog padding
  static EdgeInsets dialog(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: context.mbValue(
        mobile: 20,
        mobileSmall: 16,
        mobileLarge: 22,
        tablet: 28,
        tabletLarge: 32,
      ),
      vertical: context.mbValue(
        mobile: 20,
        mobileSmall: 18,
        mobileLarge: 22,
        tablet: 26,
        tabletLarge: 30,
      ),
    );
  }

  /// Bottom sheet padding
  static EdgeInsets bottomSheet(BuildContext context) {
    return EdgeInsets.fromLTRB(
      MBSpacing.pageHorizontal(context),
      MBSpacing.sectionGap(context),
      MBSpacing.pageHorizontal(context),
      MBSpacing.pageVertical(context),
    );
  }
}











