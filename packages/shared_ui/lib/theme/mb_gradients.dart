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
}











