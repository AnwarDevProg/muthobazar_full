// MuthoBazar Home Grid Layout Tuning
// ----------------------------------
// Manual Home grid spacing values only.
//
// Card heights are no longer defined here.
// Height comes from:
// product.effectiveCardConfig.settings.layout
// -> shared_ui MBProductCardLayoutResolver variant/family defaults
// -> safe fallback.

class MBHomeGridLayoutTuning {
  const MBHomeGridLayoutTuning._();

  // Left/right margin of the Home body content.
  // HomePage currently has its own _HomeLayoutTuning copy.
  // Recommended: 8, 10, 12, 16.
  static const double bodyHorizontalPadding = 10;

  // Gap between two half-width cards in the same row.
  // Recommended: 8, 10, 12.
  static const double cardColumnGap = 10;

  // Vertical gap between product rows.
  // Recommended: 10, 12, 14.
  static const double cardRowGap = 12;

  // Gap between a product card and an adaptive filler.
  // Recommended: 4, 6, 8.
  static const double fillerTopGap = 6;

  // Higher = cards resize less, fillers are preferred more.
  static const double elasticResizePenalty = 75;

  // Higher = prefer expanding shorter card.
  // Lower = prefer shrinking taller card more.
  static const double shortCardExpandBias = 0.62;
}
