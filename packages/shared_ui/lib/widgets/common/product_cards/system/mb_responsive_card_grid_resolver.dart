// File: mb_responsive_card_grid_resolver.dart
//
// MuthoBazar shared responsive product-card grid resolver
// ------------------------------------------------------
// Patch 12.5: shared responsive grid resolver for Home/Admin/Studio.
//
// Purpose:
// - Keep responsive product-card layout rules in one shared place.
// - Use the same 2/3/4-column rule across customer Home, admin previews,
//   and Studio V3 layout tools.
// - Keep V3 card design sizes as design-coordinate sizes, not fixed screen
//   widths.
// - Provide shared constants for half/full design widths and card height range.
//
// Current rule:
// - contentWidth >= 900 -> 4 columns
// - contentWidth >= 600 -> 3 columns
// - otherwise           -> 2 columns

class MBResponsiveCardGridResolver {
  const MBResponsiveCardGridResolver._();

  static const double tabletFourColumnWidth = 900.0;
  static const double tabletThreeColumnWidth = 600.0;

  static const int phoneColumnCount = 2;
  static const int smallTabletColumnCount = 3;
  static const int tabletColumnCount = 4;

  static const double halfWidthDesignPx = 192.0;
  static const double fullWidthDesignPx = 392.0;

  static const double minCardWidthPx = 160.0;
  static const double maxCardWidthPx = 420.0;

  static const double minCardHeightPx = 180.0;
  static const double maxCardHeightPx = 760.0;

  static const double phoneSpacingPx = 12.0;
  static const double tabletSpacingPx = 14.0;
  static const double largeTabletSpacingPx = 16.0;

  static int resolveColumnCount(double contentWidth) {
    if (contentWidth >= tabletFourColumnWidth) {
      return tabletColumnCount;
    }

    if (contentWidth >= tabletThreeColumnWidth) {
      return smallTabletColumnCount;
    }

    return phoneColumnCount;
  }

  static double resolveGridSpacing(double contentWidth) {
    if (contentWidth >= tabletFourColumnWidth) {
      return largeTabletSpacingPx;
    }

    if (contentWidth >= tabletThreeColumnWidth) {
      return tabletSpacingPx;
    }

    return phoneSpacingPx;
  }

  static double resolveColumnSlotWidth({
    required double contentWidth,
    required int columnCount,
    double? spacing,
  }) {
    final safeColumnCount = columnCount <= 0 ? 1 : columnCount;
    final gap = spacing ?? resolveGridSpacing(contentWidth);
    final totalGap = gap * (safeColumnCount - 1);
    final usableWidth = contentWidth - totalGap;

    if (usableWidth <= 0) return contentWidth;

    return usableWidth / safeColumnCount;
  }

  static MBResponsiveCardGridMetrics resolveMetrics(double contentWidth) {
    final columns = resolveColumnCount(contentWidth);
    final spacing = resolveGridSpacing(contentWidth);
    final slotWidth = resolveColumnSlotWidth(
      contentWidth: contentWidth,
      columnCount: columns,
      spacing: spacing,
    );

    return MBResponsiveCardGridMetrics(
      contentWidth: contentWidth,
      columnCount: columns,
      spacing: spacing,
      slotWidth: slotWidth,
    );
  }

  static bool isFullWidthDesign({
    required double cardWidth,
    String? cardLayoutType,
    String? footprint,
  }) {
    final type = (cardLayoutType ?? '').trim().toLowerCase();
    final fp = (footprint ?? '').trim().toLowerCase();

    if (fp == 'full' || fp == 'full_width' || fp == 'wide') {
      return true;
    }

    if (type.contains('full') ||
        type.contains('wide') ||
        type.contains('banner') ||
        type.contains('feature')) {
      return true;
    }

    return cardWidth >= 320.0;
  }

  static int resolveColumnSpan({
    required double contentWidth,
    required double cardWidth,
    String? cardLayoutType,
    String? footprint,
    int? requestedColumnSpan,
  }) {
    final columns = resolveColumnCount(contentWidth);

    if (requestedColumnSpan != null && requestedColumnSpan > 0) {
      return requestedColumnSpan.clamp(1, columns);
    }

    if (isFullWidthDesign(
      cardWidth: cardWidth,
      cardLayoutType: cardLayoutType,
      footprint: footprint,
    )) {
      return columns;
    }

    return 1;
  }

  static double resolveDesignAspectHeight({
    required double runtimeWidth,
    required double designWidth,
    required double designHeight,
  }) {
    if (runtimeWidth <= 0 || designWidth <= 0 || designHeight <= 0) {
      return runtimeWidth;
    }

    return runtimeWidth * (designHeight / designWidth);
  }

  static double clampCardWidth(double value) {
    return value.clamp(minCardWidthPx, maxCardWidthPx).toDouble();
  }

  static double clampCardHeight(double value) {
    return value.clamp(minCardHeightPx, maxCardHeightPx).toDouble();
  }
}

class MBResponsiveCardGridMetrics {
  const MBResponsiveCardGridMetrics({
    required this.contentWidth,
    required this.columnCount,
    required this.spacing,
    required this.slotWidth,
  });

  final double contentWidth;
  final int columnCount;
  final double spacing;
  final double slotWidth;

  double get totalGap => spacing * (columnCount - 1);

  double widthForSpan(int span) {
    final safeSpan = span.clamp(1, columnCount);
    return (slotWidth * safeSpan) + (spacing * (safeSpan - 1));
  }
}
