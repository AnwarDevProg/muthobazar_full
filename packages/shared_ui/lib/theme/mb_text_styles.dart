import 'package:flutter/material.dart';
import 'mb_colors.dart';

class MBTextStyles {
  MBTextStyles._();

  static const String fontFamily = 'Poppins';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: MBColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: MBColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: MBColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle hero = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: MBColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: MBColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: MBColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: MBColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: MBColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: MBColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: MBColors.textSecondary,
    height: 1.35,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: MBColors.textSecondary,
    height: 1.35,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: MBColors.textOnPrimary,
    height: 1.2,
  );

  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: MBColors.primaryOrange,
    height: 1.2,
  );
}