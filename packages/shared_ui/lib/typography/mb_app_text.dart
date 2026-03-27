// MB App Text
// -----------
// Central typography access layer for MuthoBazar.
//
// Purpose:
// - unify responsive font sizes with theme styles
// - prevent hardcoded TextStyle usage across screens
// - provide quick access to common text styles

import 'package:flutter/material.dart';
import '../responsive/mb_text_scale.dart';

class MBAppText {
  MBAppText._();

  /// Display text (large hero text)
  static TextStyle display(BuildContext context) {
    return TextStyle(
      fontSize: MBTextScale.display(context),
      fontWeight: FontWeight.w700,
      height: MBTextScale.lineHeight(),
    );
  }

  /// Headline 1
  static TextStyle headline1(BuildContext context) {
    return TextStyle(
      fontSize: MBTextScale.headline1(context),
      fontWeight: FontWeight.w700,
      height: MBTextScale.lineHeight(),
    );
  }

  /// Headline 2
  static TextStyle headline2(BuildContext context) {
    return TextStyle(
      fontSize: MBTextScale.headline2(context),
      fontWeight: FontWeight.w600,
      height: MBTextScale.lineHeight(),
    );
  }

  /// Headline 3
  static TextStyle headline3(BuildContext context) {
    return TextStyle(
      fontSize: MBTextScale.headline3(context),
      fontWeight: FontWeight.w600,
      height: MBTextScale.lineHeight(),
    );
  }

  /// Section title
  static TextStyle sectionTitle(BuildContext context) {
    return TextStyle(
      fontSize: MBTextScale.title(context),
      fontWeight: FontWeight.w600,
      height: MBTextScale.lineHeight(),
    );
  }

  /// Body text
  static TextStyle body(BuildContext context) {
    return TextStyle(
      fontSize: MBTextScale.body(context),
      fontWeight: FontWeight.w400,
      height: MBTextScale.lineHeight(),
    );
  }

  /// Large body text
  static TextStyle bodyLarge(BuildContext context) {
    return TextStyle(
      fontSize: MBTextScale.bodyLarge(context),
      fontWeight: FontWeight.w400,
      height: MBTextScale.lineHeight(),
    );
  }

  /// Small body text
  static TextStyle bodySmall(BuildContext context) {
    return TextStyle(
      fontSize: MBTextScale.bodySmall(context),
      fontWeight: FontWeight.w400,
      height: MBTextScale.lineHeight(),
    );
  }

  /// Label text
  static TextStyle label(BuildContext context) {
    return TextStyle(
      fontSize: MBTextScale.label(context),
      fontWeight: FontWeight.w500,
      height: MBTextScale.lineHeight(),
    );
  }

  /// Button text
  static TextStyle button(BuildContext context) {
    return TextStyle(
      fontSize: MBTextScale.button(context),
      fontWeight: FontWeight.w600,
      height: MBTextScale.lineHeight(),
    );
  }

  /// Caption / helper text
  static TextStyle caption(BuildContext context) {
    return TextStyle(
      fontSize: MBTextScale.caption(context),
      fontWeight: FontWeight.w400,
      height: MBTextScale.lineHeight(),
    );
  }
}











