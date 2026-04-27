import 'package:shared_models/shared_models.dart';

// MB Home Card Layout Profile
// ---------------------------
// Temporary home-layout profile resolver for product-card variants.
//
// Purpose:
// The card system now supports multiple card families/variants with different
// visual heights. Home layout needs a safe height profile so it can:
// - pair half-width cards cleanly
// - let cards shrink/expand within safe visual limits
// - decide when a gap filler widget should be used
//
// Later this profile should move into the shared card registry/footprint model.
// For now it is intentionally local to the Home grid layout.

class MBHomeCardLayoutProfile {
  const MBHomeCardLayoutProfile({
    required this.familyId,
    required this.variantId,
    required this.preferredHeight,
    required this.minHeight,
    required this.maxHeight,
    required this.isFullWidth,
  });

  final String familyId;
  final String variantId;
  final double preferredHeight;
  final double minHeight;
  final double maxHeight;
  final bool isFullWidth;

  double get maxShrink => preferredHeight - minHeight;
  double get maxExpand => maxHeight - preferredHeight;

  static MBHomeCardLayoutProfile resolve(MBProduct product) {
    final config = product.effectiveCardConfig.normalized();
    final familyId = config.familyId;
    final variantId = config.variantId;
    final isFullWidth = config.variant.isFullWidth;

    if (isFullWidth) {
      return _fullWidthProfile(
        familyId: familyId,
        variantId: variantId,
      );
    }

    return _halfWidthProfile(
      familyId: familyId,
      variantId: variantId,
    );
  }

  static MBHomeCardLayoutProfile _halfWidthProfile({
    required String familyId,
    required String variantId,
  }) {
    if (familyId == 'premium' || variantId.startsWith('premium')) {
      return MBHomeCardLayoutProfile(
        familyId: familyId,
        variantId: variantId,
        preferredHeight: 292,
        minHeight: 265,
        maxHeight: 318,
        isFullWidth: false,
      );
    }

    if (familyId == 'flash_sale' || variantId.startsWith('flash')) {
      return MBHomeCardLayoutProfile(
        familyId: familyId,
        variantId: variantId,
        preferredHeight: 272,
        minHeight: 248,
        maxHeight: 298,
        isFullWidth: false,
      );
    }

    if (familyId == 'price' || variantId.startsWith('price')) {
      return MBHomeCardLayoutProfile(
        familyId: familyId,
        variantId: variantId,
        preferredHeight: 266,
        minHeight: 242,
        maxHeight: 292,
        isFullWidth: false,
      );
    }

    return MBHomeCardLayoutProfile(
      familyId: familyId,
      variantId: variantId,
      preferredHeight: 256,
      minHeight: 232,
      maxHeight: 282,
      isFullWidth: false,
    );
  }

  static MBHomeCardLayoutProfile _fullWidthProfile({
    required String familyId,
    required String variantId,
  }) {
    if (familyId == 'horizontal' || variantId.startsWith('horizontal')) {
      return MBHomeCardLayoutProfile(
        familyId: familyId,
        variantId: variantId,
        preferredHeight: 150,
        minHeight: 140,
        maxHeight: 168,
        isFullWidth: true,
      );
    }

    if (familyId == 'wide' || variantId.startsWith('wide')) {
      return MBHomeCardLayoutProfile(
        familyId: familyId,
        variantId: variantId,
        preferredHeight: 255,
        minHeight: 230,
        maxHeight: 286,
        isFullWidth: true,
      );
    }

    if (familyId == 'promo' || variantId.startsWith('promo')) {
      return MBHomeCardLayoutProfile(
        familyId: familyId,
        variantId: variantId,
        preferredHeight: 280,
        minHeight: 250,
        maxHeight: 310,
        isFullWidth: true,
      );
    }

    if (familyId == 'featured' || variantId.startsWith('featured')) {
      return MBHomeCardLayoutProfile(
        familyId: familyId,
        variantId: variantId,
        preferredHeight: 320,
        minHeight: 292,
        maxHeight: 350,
        isFullWidth: true,
      );
    }

    return MBHomeCardLayoutProfile(
      familyId: familyId,
      variantId: variantId,
      preferredHeight: 240,
      minHeight: 220,
      maxHeight: 270,
      isFullWidth: true,
    );
  }
}
