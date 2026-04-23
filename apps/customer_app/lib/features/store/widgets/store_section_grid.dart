import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_card_config_resolver.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_product_card_variant_router.dart';

import 'package:customer_app/features/store/models/mb_store_card_preview_entry.dart';

class StoreSectionGrid extends StatelessWidget {
  const StoreSectionGrid({
    super.key,
    required this.entries,
    required this.productsById,
    required this.onRemoveTap,
    this.spacing = 12,
    this.featuredHeight = 320,
    this.showMetaChips = false,
  });

  final List<MBStoreCardPreviewEntry> entries;
  final Map<String, MBProduct> productsById;
  final ValueChanged<MBStoreCardPreviewEntry> onRemoveTap;
  final double spacing;
  final double featuredHeight;
  final bool showMetaChips;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEntries = List<MBStoreCardPreviewEntry>.from(entries)
      ..sort(MBStoreCardPreviewEntry.sortComparator);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final halfWidth = (maxWidth - spacing) / 2;
        final segments = _buildSegments(sortedEntries);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(
            segments.length,
                (index) {
              final segment = segments[index];

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == segments.length - 1 ? 0 : spacing,
                ),
                child: segment.fullWidthEntry != null
                    ? SizedBox(
                  width: maxWidth,
                  child: _StoreGridPreviewItem(
                    entry: segment.fullWidthEntry!,
                    product: productsById[segment.fullWidthEntry!.productId],
                    resolved: MBCardConfigResolver.resolveByVariant(
                      segment.fullWidthEntry!.variant,
                    ),
                    featuredHeight: featuredHeight,
                    onRemoveTap: () => onRemoveTap(segment.fullWidthEntry!),
                  ),
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: halfWidth,
                      child: _StorePreviewColumn(
                        entries: segment.leftEntries,
                        productsById: productsById,
                        spacing: spacing,
                        featuredHeight: featuredHeight,
                        onRemoveTap: onRemoveTap,
                      ),
                    ),
                    SizedBox(width: spacing),
                    SizedBox(
                      width: halfWidth,
                      child: _StorePreviewColumn(
                        entries: segment.rightEntries,
                        productsById: productsById,
                        spacing: spacing,
                        featuredHeight: featuredHeight,
                        onRemoveTap: onRemoveTap,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<_StoreSectionGridSegment> _buildSegments(
      List<MBStoreCardPreviewEntry> sortedEntries,
      ) {
    final segments = <_StoreSectionGridSegment>[];

    final leftEntries = <MBStoreCardPreviewEntry>[];
    final rightEntries = <MBStoreCardPreviewEntry>[];
    double leftScore = 0;
    double rightScore = 0;

    void flushHalfWidthSegment() {
      if (leftEntries.isEmpty && rightEntries.isEmpty) {
        return;
      }

      segments.add(
        _StoreSectionGridSegment.halfWidth(
          leftEntries: List<MBStoreCardPreviewEntry>.from(leftEntries),
          rightEntries: List<MBStoreCardPreviewEntry>.from(rightEntries),
        ),
      );

      leftEntries.clear();
      rightEntries.clear();
      leftScore = 0;
      rightScore = 0;
    }

    for (final entry in sortedEntries) {
      final resolved = MBCardConfigResolver.resolveByVariant(entry.variant);

      if (resolved.footprint.isFullWidth) {
        flushHalfWidthSegment();
        segments.add(_StoreSectionGridSegment.fullWidth(entry));
        continue;
      }

      final score = _heightScore(entry.variant);

      if (leftScore <= rightScore) {
        leftEntries.add(entry);
        leftScore += score;
      } else {
        rightEntries.add(entry);
        rightScore += score;
      }
    }

    flushHalfWidthSegment();

    return segments;
  }

  double _heightScore(MBCardVariant variant) {
    switch (variant.family) {
      case MBCardFamily.flashSale:
        return 1.28;
      case MBCardFamily.premium:
        return 1.16;
      case MBCardFamily.price:
        return 1.10;
      case MBCardFamily.compact:
        return 1.00;
      case MBCardFamily.horizontal:
      case MBCardFamily.wide:
      case MBCardFamily.featured:
      case MBCardFamily.promo:
        return 1.00;
      case MBCardFamily.combo:
        return 1.12;
      case MBCardFamily.variant:
        return 1.08;
      case MBCardFamily.minimal:
        return 0.92;
      case MBCardFamily.infoRich:
        return 1.22;
    }
  }
}

class _StorePreviewColumn extends StatelessWidget {
  const _StorePreviewColumn({
    required this.entries,
    required this.productsById,
    required this.spacing,
    required this.featuredHeight,
    required this.onRemoveTap,
  });

  final List<MBStoreCardPreviewEntry> entries;
  final Map<String, MBProduct> productsById;
  final double spacing;
  final double featuredHeight;
  final ValueChanged<MBStoreCardPreviewEntry> onRemoveTap;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(
        entries.length,
            (index) {
          final entry = entries[index];
          final resolved = MBCardConfigResolver.resolveByVariant(entry.variant);

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == entries.length - 1 ? 0 : spacing,
            ),
            child: _StoreGridPreviewItem(
              entry: entry,
              product: productsById[entry.productId],
              resolved: resolved,
              featuredHeight: featuredHeight,
              onRemoveTap: () => onRemoveTap(entry),
            ),
          );
        },
      ),
    );
  }
}

class _StoreGridPreviewItem extends StatelessWidget {
  const _StoreGridPreviewItem({
    required this.entry,
    required this.product,
    required this.resolved,
    required this.featuredHeight,
    required this.onRemoveTap,
  });

  final MBStoreCardPreviewEntry entry;
  final MBProduct? product;
  final MBResolvedCardConfig resolved;
  final double featuredHeight;
  final VoidCallback onRemoveTap;

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return _MissingProductCard(entry: entry);
    }

    Widget child = MBProductCardVariantRouter.build(
      context: context,
      resolved: resolved,
      product: product!,
      onTap: () {},
      onAddToCartTap: () {},
    );

    if (resolved.footprint.isFullWidth) {
      child = SizedBox(
        height: featuredHeight,
        child: child,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onRemoveTap,
      child: child,
    );
  }
}

class _MissingProductCard extends StatelessWidget {
  const _MissingProductCard({
    required this.entry,
  });

  final MBStoreCardPreviewEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Missing product',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Entry id: ${entry.id}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF92400E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreSectionGridSegment {
  const _StoreSectionGridSegment.fullWidth(this.fullWidthEntry)
      : leftEntries = const <MBStoreCardPreviewEntry>[],
        rightEntries = const <MBStoreCardPreviewEntry>[];

  const _StoreSectionGridSegment.halfWidth({
    required this.leftEntries,
    required this.rightEntries,
  }) : fullWidthEntry = null;

  final MBStoreCardPreviewEntry? fullWidthEntry;
  final List<MBStoreCardPreviewEntry> leftEntries;
  final List<MBStoreCardPreviewEntry> rightEntries;
}