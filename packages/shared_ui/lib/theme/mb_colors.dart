import 'package:flutter/material.dart';

class MBColors {
  MBColors._();

  // Brand oranges
  static const Color primaryOrange = Color(0xFFE87322);
  static const Color secondaryOrange = Color(0xFFFF9A3D);
  static const Color deepOrange = Color(0xFFD85A14);

  // Main aliases
  static const Color primary = primaryOrange;
  static const Color primaryLight = Color(0xFFF29A5E);
  static const Color primarySoft = Color(0xFFFFF3EA);

  // Extra aliases for admin web and newer UI blocks
  static const Color primaryOrangeLight = Color(0xFFFFE6D6);
  static const Color primaryOrangeSoft = primarySoft;
  static const Color primaryContainer = Color(0xFFFFE6D6);

  // Base surfaces
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFFAFAFC);
  static const Color card = Colors.white;
  static const Color cardSoft = Color(0xFFFCFCFD);

  // Text
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF7A7A7A);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color textHint = Color(0xFFB3B3B3);
  static const Color textOnPrimary = Colors.white;
  static const Color textInverse = Colors.white;

  // Border / divider
  static const Color border = Color(0xFFE8E8E8);
  static const Color borderLight = Color(0xFFF0F0F4);
  static const Color borderSoft = Color(0xFFF5F5F7);
  static const Color divider = Color(0xFFF0F0F0);
  static const Color outline = Color(0xFFDDDDDD);

  // States
  static const Color success = Color(0xFF22C55E);
  static const Color successSoft = Color(0xFFEAF8EF);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFFF6E5);

  static const Color error = Color(0xFFEF4444);
  static const Color errorSoft = Color(0xFFFDECEC);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoSoft = Color(0xFFEAF2FF);

  // Shadow helper
  static const Color shadow = Color(0x14000000);

  // Disabled
  static const Color disabled = Color(0xFFCBCBCB);
}