import 'package:flutter/material.dart';
import 'mb_colors.dart';

class MBGradients {
  MBGradients._();

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      MBColors.primaryOrange,
      MBColors.secondaryOrange,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [
      MBColors.primaryOrange,
      MBColors.secondaryOrange,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient featuredOverlayGradient = LinearGradient(
    colors: [
      Colors.black.withValues(alpha: 0.02),
      Colors.black.withValues(alpha: 0.08),
      Colors.black.withValues(alpha: 0.18),
      Colors.black.withValues(alpha: 0.55),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}