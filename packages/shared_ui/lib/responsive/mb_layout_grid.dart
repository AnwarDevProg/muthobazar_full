// MB Layout Grid
// --------------
// Lightweight grid helper for cards, tiles, lists, and dashboard sections.
//
// Use cases:
// - product grids
// - category grids
// - dashboard shortcuts
// - two-column tablet arrangements
//
// This is not a replacement for all layout widgets.
// It standardizes column count, aspect ratio, and spacing decisions.

import 'package:flutter/widgets.dart';
import 'mb_breakpoints.dart';
import 'mb_responsive.dart';

class MBLayoutGridConfig {
  final int columns;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const MBLayoutGridConfig({
    required this.columns,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.childAspectRatio,
  });
}

class MBLayoutGrid {
  MBLayoutGrid._();

  static MBLayoutGridConfig products(BuildContext context) {
    return MBLayoutGridConfig(
      columns: context.mbValue(
        mobile: 2,
        mobileSmall: 2,
        mobileLarge: 2,
        tablet: 3,
        tabletLarge: 4,
      ),
      crossAxisSpacing: context.mbValue(
        mobile: 12,
        mobileSmall: 10,
        mobileLarge: 12,
        tablet: 16,
        tabletLarge: 18,
      ),
      mainAxisSpacing: context.mbValue(
        mobile: 12,
        mobileSmall: 10,
        mobileLarge: 12,
        tablet: 16,
        tabletLarge: 18,
      ),
      childAspectRatio: context.mbValue(
        mobile: 0.68,
        mobileSmall: 0.66,
        mobileLarge: 0.70,
        tablet: 0.72,
        tabletLarge: 0.76,
      ),
    );
  }

  // Dedicated helper for Home Page product grid
  // -------------------------------------------
  // Slightly taller cards than general product grids,
  // so home sections feel more balanced with title + price.
  static MBLayoutGridConfig homeProducts(BuildContext context) {
    return MBLayoutGridConfig(
      columns: context.mbValue(
        mobile: 2,
        mobileSmall: 2,
        mobileLarge: 2,
        tablet: 3,
        tabletLarge: 4,
      ),
      crossAxisSpacing: context.mbValue(
        mobile: 12,
        mobileSmall: 10,
        mobileLarge: 12,
        tablet: 16,
        tabletLarge: 18,
      ),
      mainAxisSpacing: context.mbValue(
        mobile: 12,
        mobileSmall: 10,
        mobileLarge: 12,
        tablet: 16,
        tabletLarge: 18,
      ),
      childAspectRatio: context.mbValue(
        mobile: 0.72,
        mobileSmall: 0.70,
        mobileLarge: 0.74,
        tablet: 0.76,
        tabletLarge: 0.80,
      ),
    );
  }

  static MBLayoutGridConfig categories(BuildContext context) {
    return MBLayoutGridConfig(
      columns: context.mbValue(
        mobile: 3,
        mobileSmall: 3,
        mobileLarge: 4,
        tablet: 5,
        tabletLarge: 6,
      ),
      crossAxisSpacing: context.mbValue(
        mobile: 12,
        mobileSmall: 10,
        mobileLarge: 12,
        tablet: 14,
        tabletLarge: 16,
      ),
      mainAxisSpacing: context.mbValue(
        mobile: 12,
        mobileSmall: 10,
        mobileLarge: 12,
        tablet: 14,
        tabletLarge: 16,
      ),
      childAspectRatio: context.mbValue(
        mobile: 0.84,
        mobileSmall: 0.82,
        mobileLarge: 0.88,
        tablet: 0.92,
        tabletLarge: 0.96,
      ),
    );
  }

  static MBLayoutGridConfig cards(BuildContext context) {
    return MBLayoutGridConfig(
      columns: context.mbValue(
        mobile: 1,
        mobileSmall: 1,
        mobileLarge: 1,
        tablet: 2,
        tabletLarge: 3,
      ),
      crossAxisSpacing: context.mbValue(
        mobile: 12,
        mobileSmall: 10,
        mobileLarge: 12,
        tablet: 16,
        tabletLarge: 20,
      ),
      mainAxisSpacing: context.mbValue(
        mobile: 12,
        mobileSmall: 10,
        mobileLarge: 12,
        tablet: 16,
        tabletLarge: 20,
      ),
      childAspectRatio: context.mbValue(
        mobile: 2.3,
        mobileSmall: 2.2,
        mobileLarge: 2.4,
        tablet: 1.65,
        tabletLarge: 1.5,
      ),
    );
  }

  static SliverGridDelegateWithFixedCrossAxisCount delegate({
    required MBLayoutGridConfig config,
  }) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: config.columns,
      crossAxisSpacing: config.crossAxisSpacing,
      mainAxisSpacing: config.mainAxisSpacing,
      childAspectRatio: config.childAspectRatio,
    );
  }

  static double contentWidth(BuildContext context) {
    return MBBreakpoints.contentMaxWidth(MBResponsive.width(context));
  }
}











