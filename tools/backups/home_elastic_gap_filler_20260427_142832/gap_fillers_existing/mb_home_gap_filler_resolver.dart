import 'mb_home_gap_filler_models.dart';

// MB Home Gap Filler Resolver
// ---------------------------
// Chooses the best filler widget for a given vertical gap.

class MBHomeGapFillerResolver {
  const MBHomeGapFillerResolver._();

  static const double minimumUsefulGap = 10;

  static const List<MBHomeGapFillerDefinition> definitions =
      <MBHomeGapFillerDefinition>[
    MBHomeGapFillerDefinition(
      id: 'decorative_line',
      kind: MBHomeGapFillerKind.decorativeLine,
      priority: 90,
      preferredHeight: 14,
      minHeight: 8,
      maxHeight: 22,
      label: '',
      isTappable: false,
    ),
    MBHomeGapFillerDefinition(
      id: 'decorative_gradient',
      kind: MBHomeGapFillerKind.decorativeGradient,
      priority: 80,
      preferredHeight: 30,
      minHeight: 20,
      maxHeight: 42,
      label: '',
      isTappable: false,
    ),
    MBHomeGapFillerDefinition(
      id: 'same_day_delivery',
      kind: MBHomeGapFillerKind.deliveryChip,
      priority: 20,
      preferredHeight: 52,
      minHeight: 44,
      maxHeight: 64,
      label: 'Same day',
      subtitle: 'Fast delivery',
      isTappable: false,
    ),
    MBHomeGapFillerDefinition(
      id: 'save_more_offer',
      kind: MBHomeGapFillerKind.offerChip,
      priority: 10,
      preferredHeight: 72,
      minHeight: 58,
      maxHeight: 88,
      label: 'Save more',
      subtitle: 'Offers active',
      isTappable: false,
    ),
    MBHomeGapFillerDefinition(
      id: 'fresh_category',
      kind: MBHomeGapFillerKind.categoryChip,
      priority: 30,
      preferredHeight: 96,
      minHeight: 82,
      maxHeight: 118,
      label: 'Fresh picks',
      subtitle: 'Browse more',
      isTappable: false,
    ),
    MBHomeGapFillerDefinition(
      id: 'promo_large',
      kind: MBHomeGapFillerKind.promoBlock,
      priority: 15,
      preferredHeight: 132,
      minHeight: 110,
      maxHeight: 170,
      label: 'Today deal',
      subtitle: 'Limited-time savings',
      isTappable: false,
    ),
    MBHomeGapFillerDefinition(
      id: 'promo_x_large',
      kind: MBHomeGapFillerKind.promoBlock,
      priority: 16,
      preferredHeight: 188,
      minHeight: 160,
      maxHeight: 240,
      label: 'Special offer',
      subtitle: 'Fresh products today',
      isTappable: false,
    ),
  ];

  static MBHomeGapFillerDecision? resolve(double gapHeight) {
    if (gapHeight < minimumUsefulGap) {
      return null;
    }

    MBHomeGapFillerDecision? best;

    for (final definition in definitions) {
      if (!definition.canFit(gapHeight)) {
        continue;
      }

      final resizePercent = definition.resizePercentFor(gapHeight);
      final heightDifference = (definition.preferredHeight - gapHeight).abs();

      final score = (definition.priority * 10000) +
          (resizePercent * 100) +
          heightDifference;

      final decision = MBHomeGapFillerDecision(
        definition: definition,
        renderHeight: gapHeight,
        score: score,
        resizePercent: resizePercent,
      );

      if (best == null || decision.score < best.score) {
        best = decision;
      }
    }

    return best;
  }
}
