// MB Home Gap Filler Models
// -------------------------
// A gap filler is a small adaptive widget rendered under the shorter half-width
// card when it is paired beside a taller half-width card.

enum MBHomeGapFillerKind {
  decorativeLine,
  decorativeGradient,
  deliveryChip,
  offerChip,
  categoryChip,
  promoBlock,
}

class MBHomeGapFillerDefinition {
  const MBHomeGapFillerDefinition({
    required this.id,
    required this.kind,
    required this.priority,
    required this.preferredHeight,
    required this.minHeight,
    required this.maxHeight,
    required this.label,
    this.subtitle,
    this.isTappable = false,
  });

  final String id;
  final MBHomeGapFillerKind kind;
  final int priority;
  final double preferredHeight;
  final double minHeight;
  final double maxHeight;
  final String label;
  final String? subtitle;
  final bool isTappable;

  bool canFit(double height) {
    return height >= minHeight && height <= maxHeight;
  }

  double resizePercentFor(double height) {
    if (preferredHeight <= 0) return 0;
    return ((height - preferredHeight).abs() / preferredHeight) * 100;
  }
}

class MBHomeGapFillerDecision {
  const MBHomeGapFillerDecision({
    required this.definition,
    required this.renderHeight,
    required this.score,
    required this.resizePercent,
  });

  final MBHomeGapFillerDefinition definition;
  final double renderHeight;
  final double score;
  final double resizePercent;
}
