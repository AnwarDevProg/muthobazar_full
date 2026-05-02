import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

import 'mb_product_card_layout_profile.dart';

// MuthoBazar Product Card Layout Resolver
// ---------------------------------------
// Converts product.effectiveCardConfig into a parent-layout profile.
//
// Height source order:
// 1. product.effectiveCardConfig.settings.layout
// 2. MBCardLayoutSettings.variantDefaults(...)
// 3. safe variant/family fallback
//
// Important:
// Home/category/search grids should use this resolver instead of hardcoded
// Home-page card heights.
//
// Safety rule:
// Some existing products may have old/unsafe layout.aspectRatio values.
// This resolver does NOT blindly trust those values anymore.
// It clamps the calculated height using variant-safe content min/max limits.
//
// Example:
// compact02 with saved aspectRatio 0.68 and width 180 => 265 px.
// compact02 content-safe min height is higher, so final height is clamped upward.

const bool kProductCardLayoutResolveDebug = true;

class MBProductCardLayoutResolver {
  const MBProductCardLayoutResolver._();

  static MBProductCardLayoutProfile resolve({
    required MBProduct product,
    required double availableWidth,
  }) {
    final config = product.effectiveCardConfig.normalized();
    final familyId = config.familyId;
    final variantId = config.variantId;
    final isFullWidth = config.variant.isFullWidth;

    final variantDefaults = MBCardLayoutSettings.variantDefaults(
      familyId: familyId,
      variantId: variantId,
    );

    final layout = (config.settings.layout ?? const MBCardLayoutSettings())
        .mergeMissing(variantDefaults);

    final safe = _VariantSafeLayout.resolve(
      familyId: familyId,
      variantId: variantId,
      isFullWidth: isFullWidth,
      availableWidth: availableWidth,
    );

    final aspectRatio = _positive(layout.aspectRatio) ??
        _positive(layout.preferredAspectRatio) ??
        safe.aspectRatio;

    final heightFromAspectRatio = _heightFromAspectRatio(
      availableWidth: availableWidth,
      aspectRatio: aspectRatio,
      fallbackHeight: safe.preferredHeight,
    );

    final rawPreferredHeight = _positive(layout.preferredHeight) ??
        heightFromAspectRatio;

    // Main safety clamp:
    // - half-width dense cards get enough room for their actual content stack
    // - full-width cards are capped to avoid huge empty white areas
    final preferredHeight = rawPreferredHeight
        .clamp(safe.minContentHeight, safe.maxContentHeight)
        .toDouble();

    final canShrink = layout.canShrink ?? safe.canShrink;
    final canExpand = layout.canExpand ?? safe.canExpand;

    final maxShrinkPercent = _percent(layout.maxShrinkPercent) ??
        safe.maxShrinkPercent;

    final maxExpandPercent = _percent(layout.maxExpandPercent) ??
        safe.maxExpandPercent;

    final defaultMinHeight = canShrink
        ? preferredHeight * (1 - (maxShrinkPercent / 100))
        : preferredHeight;

    final defaultMaxHeight = canExpand
        ? preferredHeight * (1 + (maxExpandPercent / 100))
        : preferredHeight;

    var minHeight = _positive(layout.minHeight) ?? defaultMinHeight;
    var maxHeight = _positive(layout.maxHeight) ?? defaultMaxHeight;

    // Hard guard: min/max must also stay inside safe variant limits.
    minHeight = minHeight.clamp(safe.minContentHeight, preferredHeight)
        .toDouble();
    maxHeight = maxHeight.clamp(preferredHeight, safe.maxContentHeight)
        .toDouble();

    final profile = MBProductCardLayoutProfile(
      familyId: familyId,
      variantId: variantId,
      isFullWidth: isFullWidth,
      availableWidth: availableWidth,
      preferredHeight: preferredHeight,
      minHeight: minHeight,
      maxHeight: maxHeight,
      canShrink: canShrink,
      canExpand: canExpand,
      maxShrinkPercent: maxShrinkPercent,
      maxExpandPercent: maxExpandPercent,
      aspectRatio: aspectRatio,
    );

    _debugLayout(
      product: product,
      layout: layout,
      safe: safe,
      aspectRatio: aspectRatio,
      heightFromAspectRatio: heightFromAspectRatio,
      rawPreferredHeight: rawPreferredHeight,
      profile: profile,
    );

    return profile;
  }

  static double _heightFromAspectRatio({
    required double availableWidth,
    required double aspectRatio,
    required double fallbackHeight,
  }) {
    if (availableWidth <= 0 || aspectRatio <= 0) {
      return fallbackHeight;
    }

    return availableWidth / aspectRatio;
  }

  static double? _positive(double? value) {
    if (value == null || value <= 0) {
      return null;
    }

    return value;
  }

  static double? _percent(double? value) {
    if (value == null || value < 0) {
      return null;
    }

    return value.clamp(0, 40).toDouble();
  }

  static void _debugLayout({
    required MBProduct product,
    required MBCardLayoutSettings layout,
    required _VariantSafeLayout safe,
    required double aspectRatio,
    required double heightFromAspectRatio,
    required double rawPreferredHeight,
    required MBProductCardLayoutProfile profile,
  }) {
    if (!kProductCardLayoutResolveDebug) {
      return;
    }

    debugPrint(
      '[CARD_LAYOUT_DEBUG] '
      'title=${product.titleEn}, '
      'variant=${profile.variantId}, '
      'family=${profile.familyId}, '
      'full=${profile.isFullWidth}, '
      'width=${profile.availableWidth.toStringAsFixed(1)}, '
      'savedAspect=${layout.aspectRatio?.toStringAsFixed(3)}, '
      'usedAspect=${aspectRatio.toStringAsFixed(3)}, '
      'heightFromAspect=${heightFromAspectRatio.toStringAsFixed(1)}, '
      'rawPref=${rawPreferredHeight.toStringAsFixed(1)}, '
      'safeMin=${safe.minContentHeight.toStringAsFixed(1)}, '
      'safeMax=${safe.maxContentHeight.toStringAsFixed(1)}, '
      'resolved=${profile.preferredHeight.toStringAsFixed(1)}, '
      'min=${profile.minHeight.toStringAsFixed(1)}, '
      'max=${profile.maxHeight.toStringAsFixed(1)}',
    );
  }
}

class _VariantSafeLayout {
  const _VariantSafeLayout({
    required this.aspectRatio,
    required this.preferredHeight,
    required this.minContentHeight,
    required this.maxContentHeight,
    required this.maxShrinkPercent,
    required this.maxExpandPercent,
    required this.canShrink,
    required this.canExpand,
  });

  // Width / height.
  final double aspectRatio;
  final double preferredHeight;
  final double minContentHeight;
  final double maxContentHeight;
  final double maxShrinkPercent;
  final double maxExpandPercent;
  final bool canShrink;
  final bool canExpand;

  static _VariantSafeLayout resolve({
    required String familyId,
    required String variantId,
    required bool isFullWidth,
    required double availableWidth,
  }) {
    if (isFullWidth) {
      return _fullWidth(
        familyId: familyId,
        variantId: variantId,
        availableWidth: availableWidth,
      );
    }

    return _halfWidth(
      familyId: familyId,
      variantId: variantId,
      availableWidth: availableWidth,
    );
  }

  static _VariantSafeLayout _halfWidth({
    required String familyId,
    required String variantId,
    required double availableWidth,
  }) {
    final family = familyId.trim().toLowerCase();
    final variant = variantId.trim().toLowerCase();

    if (variant == 'compact02') {
      return _byWidth(
        aspectRatio: 0.42,
        fallbackPreferredHeight: 430,
        minContentHeight: 420,
        maxContentHeight: 520,
        maxShrinkPercent: 4,
        maxExpandPercent: 10,
        availableWidth: availableWidth,
      );
    }

    if (variant == 'compact05') {
      return _byWidth(
        aspectRatio: 0.44,
        fallbackPreferredHeight: 400,
        minContentHeight: 390,
        maxContentHeight: 500,
        maxShrinkPercent: 5,
        maxExpandPercent: 10,
        availableWidth: availableWidth,
      );
    }

    if (variant == 'compact01') {
      return _byWidth(
        aspectRatio: 0.58,
        fallbackPreferredHeight: 300,
        minContentHeight: 292,
        maxContentHeight: 370,
        maxShrinkPercent: 6,
        maxExpandPercent: 12,
        availableWidth: availableWidth,
      );
    }

    if (family == 'premium' || variant.startsWith('premium')) {
      return _byWidth(
        aspectRatio: 0.46,
        fallbackPreferredHeight: 370,
        minContentHeight: 360,
        maxContentHeight: 470,
        maxShrinkPercent: 5,
        maxExpandPercent: 10,
        availableWidth: availableWidth,
      );
    }

    if (family == 'flash_sale' || variant.startsWith('flash')) {
      return _byWidth(
        aspectRatio: 0.50,
        fallbackPreferredHeight: 350,
        minContentHeight: 335,
        maxContentHeight: 440,
        maxShrinkPercent: 6,
        maxExpandPercent: 10,
        availableWidth: availableWidth,
      );
    }

    if (family == 'price' || variant.startsWith('price')) {
      return _byWidth(
        aspectRatio: 0.50,
        fallbackPreferredHeight: 350,
        minContentHeight: 335,
        maxContentHeight: 440,
        maxShrinkPercent: 6,
        maxExpandPercent: 10,
        availableWidth: availableWidth,
      );
    }

    return _byWidth(
      aspectRatio: 0.56,
      fallbackPreferredHeight: 315,
      minContentHeight: 300,
      maxContentHeight: 410,
      maxShrinkPercent: 7,
      maxExpandPercent: 12,
      availableWidth: availableWidth,
    );
  }

  static _VariantSafeLayout _fullWidth({
    required String familyId,
    required String variantId,
    required double availableWidth,
  }) {
    final family = familyId.trim().toLowerCase();
    final variant = variantId.trim().toLowerCase();

    if (family == 'horizontal' || variant.startsWith('horizontal')) {
      return _byWidth(
        aspectRatio: 1.70,
        fallbackPreferredHeight: 220,
        minContentHeight: 170,
        maxContentHeight: 270,
        maxShrinkPercent: 5,
        maxExpandPercent: 8,
        availableWidth: availableWidth,
      );
    }

    if (family == 'wide' || variant.startsWith('wide')) {
      return _byWidth(
        aspectRatio: 1.16,
        fallbackPreferredHeight: 318,
        minContentHeight: 260,
        maxContentHeight: 368,
        maxShrinkPercent: 5,
        maxExpandPercent: 8,
        availableWidth: availableWidth,
      );
    }

    if (family == 'promo' || variant.startsWith('promo')) {
      return _byWidth(
        aspectRatio: 1.05,
        fallbackPreferredHeight: 330,
        minContentHeight: 270,
        maxContentHeight: 380,
        maxShrinkPercent: 5,
        maxExpandPercent: 8,
        availableWidth: availableWidth,
      );
    }

    if (family == 'featured' || variant.startsWith('featured')) {
      return _byWidth(
        aspectRatio: 0.95,
        fallbackPreferredHeight: 380,
        minContentHeight: 330,
        maxContentHeight: 430,
        maxShrinkPercent: 5,
        maxExpandPercent: 8,
        availableWidth: availableWidth,
      );
    }

    return _byWidth(
      aspectRatio: 1.20,
      fallbackPreferredHeight: 300,
      minContentHeight: 230,
      maxContentHeight: 340,
      maxShrinkPercent: 5,
      maxExpandPercent: 8,
      availableWidth: availableWidth,
    );
  }

  static _VariantSafeLayout _byWidth({
    required double aspectRatio,
    required double fallbackPreferredHeight,
    required double minContentHeight,
    required double maxContentHeight,
    required double maxShrinkPercent,
    required double maxExpandPercent,
    required double availableWidth,
  }) {
    final widthHeight = availableWidth > 0 && aspectRatio > 0
        ? availableWidth / aspectRatio
        : fallbackPreferredHeight;

    final preferredHeight = widthHeight
        .clamp(minContentHeight, maxContentHeight)
        .toDouble();

    return _VariantSafeLayout(
      aspectRatio: aspectRatio,
      preferredHeight: preferredHeight,
      minContentHeight: minContentHeight,
      maxContentHeight: maxContentHeight,
      maxShrinkPercent: maxShrinkPercent,
      maxExpandPercent: maxExpandPercent,
      canShrink: true,
      canExpand: true,
    );
  }
}
