import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_product_card_layout_resolver.dart';

// MB Home Card Layout Profile
// ---------------------------
// Compatibility wrapper for older Home code.
//
// The actual card-height source is now the shared card layout resolver:
// packages/shared_ui/lib/widgets/common/product_cards/system/
//
// Keep this wrapper only so older Home code that imports this file still works.

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

  static MBHomeCardLayoutProfile resolve(
    MBProduct product, {
    double availableWidth = 170,
  }) {
    final resolved = MBProductCardLayoutResolver.resolve(
      product: product,
      availableWidth: availableWidth,
    );

    return MBHomeCardLayoutProfile(
      familyId: resolved.familyId,
      variantId: resolved.variantId,
      preferredHeight: resolved.preferredHeight,
      minHeight: resolved.minHeight,
      maxHeight: resolved.maxHeight,
      isFullWidth: resolved.isFullWidth,
    );
  }
}
