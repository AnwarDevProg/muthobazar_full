// MB Size Tokens
// --------------
// Central size tokens for MuthoBazar UI.
//
// Purpose:
// - keep component sizing consistent across the app
// - avoid random hardcoded numbers in widgets
// - provide responsive size values for mobile and tablet
//
// Notes:
// - spacing values belong in MBSpacing
// - typography sizes belong in MBTextScale
// - this file is for component dimensions and UI element sizes

import 'package:flutter/widgets.dart';
import '../responsive/mb_responsive.dart';

class MBSizeTokens {
  MBSizeTokens._();

  // App bars / top areas

  static double appBarHeight(BuildContext context) => context.mbValue(
    mobile: 56,
    mobileSmall: 54,
    mobileLarge: 58,
    tablet: 60,
    tabletLarge: 64,
  );

  static double topSearchBarHeight(BuildContext context) => context.mbValue(
    mobile: 48,
    mobileSmall: 46,
    mobileLarge: 50,
    tablet: 52,
    tabletLarge: 54,
  );

  static double headerExpandedHeight(BuildContext context) => context.mbValue(
    mobile: 180,
    mobileSmall: 160,
    mobileLarge: 190,
    tablet: 220,
    tabletLarge: 240,
  );

  // Navigation

  static double bottomNavHeight(BuildContext context) => context.mbValue(
    mobile: 68,
    mobileSmall: 64,
    mobileLarge: 70,
    tablet: 74,
    tabletLarge: 78,
  );

  static double floatingActionButtonSize(BuildContext context) => context.mbValue(
    mobile: 56,
    mobileSmall: 52,
    mobileLarge: 58,
    tablet: 60,
    tabletLarge: 64,
  );

  // Buttons / inputs

  static double buttonHeight(BuildContext context) => context.mbValue(
    mobile: 52,
    mobileSmall: 48,
    mobileLarge: 54,
    tablet: 56,
    tabletLarge: 58,
  );

  static double compactButtonHeight(BuildContext context) => context.mbValue(
    mobile: 40,
    mobileSmall: 38,
    mobileLarge: 42,
    tablet: 44,
    tabletLarge: 46,
  );

  static double inputHeight(BuildContext context) => context.mbValue(
    mobile: 52,
    mobileSmall: 48,
    mobileLarge: 54,
    tablet: 56,
    tabletLarge: 58,
  );

  static double otpFieldSize(BuildContext context) => context.mbValue(
    mobile: 56,
    mobileSmall: 50,
    mobileLarge: 58,
    tablet: 62,
    tabletLarge: 66,
  );

  // Icons

  static double iconXs(BuildContext context) => context.mbValue(
    mobile: 12,
    mobileSmall: 12,
    mobileLarge: 13,
    tablet: 14,
    tabletLarge: 14,
  );

  static double iconSm(BuildContext context) => context.mbValue(
    mobile: 16,
    mobileSmall: 15,
    mobileLarge: 17,
    tablet: 18,
    tabletLarge: 18,
  );

  static double iconMd(BuildContext context) => context.mbValue(
    mobile: 20,
    mobileSmall: 18,
    mobileLarge: 22,
    tablet: 22,
    tabletLarge: 24,
  );

  static double iconLg(BuildContext context) => context.mbValue(
    mobile: 24,
    mobileSmall: 22,
    mobileLarge: 26,
    tablet: 28,
    tabletLarge: 30,
  );

  static double iconXl(BuildContext context) => context.mbValue(
    mobile: 32,
    mobileSmall: 28,
    mobileLarge: 34,
    tablet: 36,
    tabletLarge: 40,
  );

  // Avatars / profile images

  static double avatarSm(BuildContext context) => context.mbValue(
    mobile: 28,
    mobileSmall: 26,
    mobileLarge: 30,
    tablet: 32,
    tabletLarge: 34,
  );

  static double avatarMd(BuildContext context) => context.mbValue(
    mobile: 40,
    mobileSmall: 36,
    mobileLarge: 42,
    tablet: 46,
    tabletLarge: 50,
  );

  static double avatarLg(BuildContext context) => context.mbValue(
    mobile: 56,
    mobileSmall: 52,
    mobileLarge: 60,
    tablet: 64,
    tabletLarge: 72,
  );

  static double avatarXl(BuildContext context) => context.mbValue(
    mobile: 80,
    mobileSmall: 72,
    mobileLarge: 84,
    tablet: 92,
    tabletLarge: 100,
  );

  // Product / category visuals

  static double categoryIconBox(BuildContext context) => context.mbValue(
    mobile: 52,
    mobileSmall: 48,
    mobileLarge: 56,
    tablet: 60,
    tabletLarge: 64,
  );

  static double productCardImageHeight(BuildContext context) => context.mbValue(
    mobile: 140,
    mobileSmall: 128,
    mobileLarge: 150,
    tablet: 170,
    tabletLarge: 190,
  );

  static double bannerHeight(BuildContext context) => context.mbValue(
    mobile: 150,
    mobileSmall: 130,
    mobileLarge: 160,
    tablet: 190,
    tabletLarge: 220,
  );

  static double heroImageHeight(BuildContext context) => context.mbValue(
    mobile: 220,
    mobileSmall: 200,
    mobileLarge: 240,
    tablet: 280,
    tabletLarge: 320,
  );

  // Chips / badges / pills

  static double chipHeight(BuildContext context) => context.mbValue(
    mobile: 30,
    mobileSmall: 28,
    mobileLarge: 32,
    tablet: 34,
    tabletLarge: 36,
  );

  static double badgeHeight(BuildContext context) => context.mbValue(
    mobile: 20,
    mobileSmall: 18,
    mobileLarge: 22,
    tablet: 22,
    tabletLarge: 24,
  );

  static double badgeMinWidth(BuildContext context) => context.mbValue(
    mobile: 20,
    mobileSmall: 18,
    mobileLarge: 22,
    tablet: 22,
    tabletLarge: 24,
  );

  // Dividers / handles / indicators

  static double dividerThickness(BuildContext context) => context.mbValue(
    mobile: 1,
    mobileSmall: 1,
    mobileLarge: 1,
    tablet: 1.2,
    tabletLarge: 1.2,
  );

  static double dragHandleWidth(BuildContext context) => context.mbValue(
    mobile: 36,
    mobileSmall: 32,
    mobileLarge: 40,
    tablet: 42,
    tabletLarge: 46,
  );

  static double dragHandleHeight(BuildContext context) => context.mbValue(
    mobile: 4,
    mobileSmall: 4,
    mobileLarge: 4,
    tablet: 5,
    tabletLarge: 5,
  );

  static double pageIndicatorDot(BuildContext context) => context.mbValue(
    mobile: 8,
    mobileSmall: 7,
    mobileLarge: 8,
    tablet: 9,
    tabletLarge: 10,
  );

  static double pageIndicatorActiveWidth(BuildContext context) => context.mbValue(
    mobile: 22,
    mobileSmall: 18,
    mobileLarge: 24,
    tablet: 26,
    tabletLarge: 28,
  );

  // Loaders / dialogs / sheets

  static double loaderSize(BuildContext context) => context.mbValue(
    mobile: 20,
    mobileSmall: 18,
    mobileLarge: 22,
    tablet: 24,
    tabletLarge: 26,
  );

  static double dialogMaxWidth(BuildContext context) => context.mbValue(
    mobile: 420,
    mobileSmall: 360,
    mobileLarge: 440,
    tablet: 520,
    tabletLarge: 560,
  );

  static double bottomSheetMaxWidth(BuildContext context) => context.mbValue(
    mobile: 600,
    mobileSmall: 360,
    mobileLarge: 640,
    tablet: 720,
    tabletLarge: 840,
  );

  // Skeleton placeholders

  static double skeletonLineHeight(BuildContext context) => context.mbValue(
    mobile: 12,
    mobileSmall: 10,
    mobileLarge: 13,
    tablet: 14,
    tabletLarge: 15,
  );

  static double skeletonTitleHeight(BuildContext context) => context.mbValue(
    mobile: 18,
    mobileSmall: 16,
    mobileLarge: 19,
    tablet: 20,
    tabletLarge: 22,
  );
}











