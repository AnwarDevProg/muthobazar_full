import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_card_config_resolver.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_product_card_variant_router.dart';

import '../models/mb_store_card_preview_entry.dart';

class StoreSectionGrid extends StatelessWidget {
  const StoreSectionGrid({
    super.key,
    required this.entries,
    required this.productsById,
    required this.onRemoveTap,
    this.spacing = 16,
    this.featuredHeight = 320,
    this.showMetaChips = true,
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

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: sortedEntries.map((entry) {
            final resolved = MBCardConfigResolver.resolveByVariant(entry.variant);
            final itemWidth =
            resolved.footprint.isFullWidth ? maxWidth : halfWidth;

            return SizedBox(
              width: itemWidth,
              child: _StoreGridPreviewItem(
                entry: entry,
                product: productsById[entry.productId],
                onRemoveTap: () => onRemoveTap(entry),
                showMetaChips: showMetaChips,
                resolved: resolved,
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _StoreGridPreviewItem extends StatelessWidget {
  const _StoreGridPreviewItem({
    required this.entry,
    required this.product,
    required this.onRemoveTap,
    required this.showMetaChips,
    required this.resolved,
  });

  final MBStoreCardPreviewEntry entry;
  final MBProduct? product;
  final VoidCallback onRemoveTap;
  final bool showMetaChips;
  final MBResolvedCardConfig resolved;

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return _MissingProductCard(
        entry: entry,
        onRemoveTap: onRemoveTap,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showMetaChips) ...<Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _MetaChip(label: _productLabel(product!)),
                    _MetaChip(label: entry.variantLabel),
                    _MetaChip(label: resolved.footprint.label),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemoveTap,
                tooltip: 'Remove item',
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        MBProductCardVariantRouter.build(
          context: context,
          resolved: resolved,
          product: product!,
          onTap: () {},
          onAddToCartTap: () {},
        ),
      ],
    );
  }

  String _productLabel(MBProduct product) {
    if (product.titleEn.trim().isNotEmpty) {
      return product.titleEn.trim();
    }
    if (product.titleBn.trim().isNotEmpty) {
      return product.titleBn.trim();
    }
    if (product.slug.trim().isNotEmpty) {
      return product.slug.trim();
    }

    final id = product.id.trim();
    if (id.isNotEmpty) {
      return id;
    }

    return 'Unnamed product';
  }
}

class _MissingProductCard extends StatelessWidget {
  const _MissingProductCard({
    required this.entry,
    required this.onRemoveTap,
  });

  final MBStoreCardPreviewEntry entry;
  final VoidCallback onRemoveTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _MetaChip(label: entry.productId),
                    _MetaChip(label: entry.variantLabel),
                    const _MetaChip(label: 'Product missing'),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemoveTap,
                tooltip: 'Remove item',
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This entry points to a product that is not available in the current product map.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
