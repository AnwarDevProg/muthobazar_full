import 'package:flutter/material.dart';

// MuthoBazar Design Card Engine V1
// File: mb_design_card_defaults.dart
//
// Purpose:
// Small local visual defaults for the new design renderer.
// These are intentionally independent from old cardConfig renderer code.

class MBDesignCardDefaults {
  const MBDesignCardDefaults._();

  static const Color orange = Color(0xFFFF7A00);
  static const Color orangeDark = Color(0xFFE85800);
  static const Color orangeLight = Color(0xFFFFB560);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF626262);
  static const Color textMuted = Color(0xFF8A8A8A);

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFFF9D2E),
      Color(0xFFFF6A00),
    ],
  );

  static const double radius = 20;
  static const double innerPadding = 12;

  static List<BoxShadow> get softShadow {
    return <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
  }
}
