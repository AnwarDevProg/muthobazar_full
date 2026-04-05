import 'package:flutter/widgets.dart';
import 'mb_responsive.dart';

class MBSpacing {
  MBSpacing._();

  // Base spacing scale
  static const double xxxs = 2;
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double xxxxl = 48;

  // Structural spacing
  static const double sectionBreak = 56;
  static const double heroBreak = 64;

  // Fixed aliases for desktop/web-heavy admin layouts
  static const double pageHorizontalFixed = 24;
  static const double pageVerticalFixed = 16;

  // Semantic spacing
  static double pageHorizontal(BuildContext context) => context.mbValue(
    mobile: 16,
    mobileSmall: 12,
    mobileLarge: 18,
    tablet: 24,
    tabletLarge: 32,
  );

  static double pageVertical(BuildContext context) => context.mbValue(
    mobile: 16,
    mobileSmall: 12,
    mobileLarge: 18,
    tablet: 20,
    tabletLarge: 24,
  );

  static double sectionGap(BuildContext context) => context.mbValue(
    mobile: 20,
    mobileSmall: 16,
    mobileLarge: 22,
    tablet: 24,
    tabletLarge: 28,
  );

  static double blockGap(BuildContext context) => context.mbValue(
    mobile: 16,
    mobileSmall: 12,
    mobileLarge: 18,
    tablet: 20,
    tabletLarge: 24,
  );

  static double itemGap(BuildContext context) => context.mbValue(
    mobile: 12,
    mobileSmall: 10,
    mobileLarge: 14,
    tablet: 16,
    tabletLarge: 18,
  );

  static double cardPadding(BuildContext context) => context.mbValue(
    mobile: 16,
    mobileSmall: 12,
    mobileLarge: 18,
    tablet: 20,
    tabletLarge: 24,
  );

  static double cardRadius(BuildContext context) => context.mbValue(
    mobile: 16,
    mobileSmall: 14,
    mobileLarge: 18,
    tablet: 20,
    tabletLarge: 24,
  );

  static double buttonHeight(BuildContext context) => context.mbValue(
    mobile: 52,
    mobileSmall: 48,
    mobileLarge: 54,
    tablet: 56,
    tabletLarge: 58,
  );

  static double inputHeight(BuildContext context) => context.mbValue(
    mobile: 52,
    mobileSmall: 48,
    mobileLarge: 54,
    tablet: 56,
    tabletLarge: 58,
  );

  // Admin/web helpers
  static double adminPageHorizontal(BuildContext context) =>
      context.mbValue(
        mobile: 16,
        mobileSmall: 12,
        mobileLarge: 18,
        tablet: 24,
        tabletLarge: 24,
      );

  static double adminPageVertical(BuildContext context) =>
      context.mbValue(
        mobile: 16,
        mobileSmall: 12,
        mobileLarge: 16,
        tablet: 16,
        tabletLarge: 16,
      );

  static EdgeInsets adminPagePadding(BuildContext context) =>
      EdgeInsets.symmetric(
        horizontal: adminPageHorizontal(context),
        vertical: adminPageVertical(context),
      );

  // EdgeInsets helpers
  static EdgeInsets pagePadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: pageHorizontal(context),
    vertical: pageVertical(context),
  );

  static EdgeInsets pagePaddingTopOnly(BuildContext context) => EdgeInsets.only(
    left: pageHorizontal(context),
    right: pageHorizontal(context),
    top: pageVertical(context),
  );

  static EdgeInsets pagePaddingBottomOnly(BuildContext context) =>
      EdgeInsets.only(
        left: pageHorizontal(context),
        right: pageHorizontal(context),
        bottom: pageVertical(context),
      );

  static EdgeInsets horizontalPadding(BuildContext context) =>
      EdgeInsets.symmetric(
        horizontal: pageHorizontal(context),
      );

  static EdgeInsets verticalPadding(BuildContext context) => EdgeInsets.symmetric(
    vertical: pageVertical(context),
  );

  static EdgeInsets cardInsets(BuildContext context) =>
      EdgeInsets.all(cardPadding(context));

  static EdgeInsets sectionInsets(BuildContext context) => EdgeInsets.symmetric(
    horizontal: pageHorizontal(context),
    vertical: sectionGap(context) / 2,
  );

  // SizedBox helpers
  static SizedBox h(double value) => SizedBox(height: value);
  static SizedBox w(double value) => SizedBox(width: value);
}