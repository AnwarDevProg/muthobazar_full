import 'package:flutter/foundation.dart';

// MuthoBazar Product Card Layout Profile
// --------------------------------------
// Resolved card-layout profile used by feed/grid/list layout engines.
//
// This is NOT a visual card widget.
// It only tells the parent layout how much space a card wants.
//
// Source of truth order:
// 1. product.effectiveCardConfig.settings.layout
// 2. variant/family defaults
// 3. safe system fallback
//
// The Home grid should use this instead of hardcoded per-family heights.

@immutable
class MBProductCardLayoutProfile {
  const MBProductCardLayoutProfile({
    required this.familyId,
    required this.variantId,
    required this.isFullWidth,
    required this.availableWidth,
    required this.preferredHeight,
    required this.minHeight,
    required this.maxHeight,
    required this.canShrink,
    required this.canExpand,
    required this.maxShrinkPercent,
    required this.maxExpandPercent,
    required this.aspectRatio,
  });

  final String familyId;
  final String variantId;
  final bool isFullWidth;

  final double availableWidth;
  final double preferredHeight;
  final double minHeight;
  final double maxHeight;

  final bool canShrink;
  final bool canExpand;

  final double maxShrinkPercent;
  final double maxExpandPercent;

  // Width / height ratio.
  // Example: width 170 and aspectRatio 0.68 => height 250.
  final double aspectRatio;

  double get maxShrink {
    if (!canShrink) return 0;
    return (preferredHeight - minHeight).clamp(0, double.infinity).toDouble();
  }

  double get maxExpand {
    if (!canExpand) return 0;
    return (maxHeight - preferredHeight).clamp(0, double.infinity).toDouble();
  }

  MBProductCardLayoutProfile copyWith({
    String? familyId,
    String? variantId,
    bool? isFullWidth,
    double? availableWidth,
    double? preferredHeight,
    double? minHeight,
    double? maxHeight,
    bool? canShrink,
    bool? canExpand,
    double? maxShrinkPercent,
    double? maxExpandPercent,
    double? aspectRatio,
  }) {
    return MBProductCardLayoutProfile(
      familyId: familyId ?? this.familyId,
      variantId: variantId ?? this.variantId,
      isFullWidth: isFullWidth ?? this.isFullWidth,
      availableWidth: availableWidth ?? this.availableWidth,
      preferredHeight: preferredHeight ?? this.preferredHeight,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      canShrink: canShrink ?? this.canShrink,
      canExpand: canExpand ?? this.canExpand,
      maxShrinkPercent: maxShrinkPercent ?? this.maxShrinkPercent,
      maxExpandPercent: maxExpandPercent ?? this.maxExpandPercent,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  @override
  String toString() {
    return 'MBProductCardLayoutProfile('
        'familyId: $familyId, '
        'variantId: $variantId, '
        'isFullWidth: $isFullWidth, '
        'availableWidth: $availableWidth, '
        'preferredHeight: $preferredHeight, '
        'minHeight: $minHeight, '
        'maxHeight: $maxHeight, '
        'aspectRatio: $aspectRatio'
        ')';
  }
}
