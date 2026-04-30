// MuthoBazar Advanced Product Card Design Studio
// Patch 12.1 left element drawer.
//
// Purpose:
// - Uses the data-driven V12 element catalog.
// - Shows current product-data previews in drawer items.
// - Keeps drag-only insertion: clicking a drawer item does not add anything.
// - Keeps the existing MBAdvancedElementVariant drag/drop contract.

import 'package:flutter/material.dart';

import '../models/mb_advanced_binding_resolver.dart';
import '../models/mb_advanced_element_catalog_v12.dart';
import '../models/mb_advanced_element_variant.dart';

class MBAdvancedElementDrawerPanel extends StatelessWidget {
  const MBAdvancedElementDrawerPanel({
    super.key,
    required this.productTitle,
    required this.productSubtitle,
    this.previewProduct,
    this.previewBrand,
    this.previewCategory,
    this.previewVariation,
    this.previewPurchaseOption,
    required this.onAddVariant,
    required this.onApplyCardVariant,
  });

  final String productTitle;
  final String productSubtitle;
  final dynamic previewProduct;
  final dynamic previewBrand;
  final dynamic previewCategory;
  final dynamic previewVariation;
  final dynamic previewPurchaseOption;
  final ValueChanged<MBAdvancedElementVariant> onAddVariant;
  final ValueChanged<MBAdvancedElementVariant> onApplyCardVariant;

  @override
  Widget build(BuildContext context) {
    final groups = MBAdvancedElementCatalogV12.groups();
    final previewContext = MBAdvancedPreviewContext(
      product: previewProduct ??
          <String, dynamic>{
            'titleEn': productTitle,
            'shortDescriptionEn': productSubtitle,
            'price': 120,
            'salePrice': 99,
            'thumbnailUrl': '',
          },
      brand: previewBrand,
      category: previewCategory,
      selectedVariation: previewVariation,
      selectedPurchaseOption: previewPurchaseOption,
      fallbackTitle: productTitle.trim().isEmpty ? 'Product title' : productTitle,
      fallbackSubtitle: productSubtitle.trim().isEmpty
          ? 'Fresh product detail'
          : productSubtitle,
    );

    return Container(
      width: 322,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE6E8EF)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _DrawerHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final group = groups[index];
                return _ElementGroupTile(
                  group: group,
                  previewContext: previewContext,
                  initiallyExpanded: index < 3 ||
                      group.id == 'media' ||
                      group.id == 'price',
                  onTapVariant: (_) {
                    // Patch 12.1 keeps drawer click as safe/no-op.
                    // Drag to canvas is the only way to insert a node.
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF8),
        border: Border(
          bottom: BorderSide(color: Color(0xFFFFE3D0)),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.widgets_rounded,
                color: Color(0xFFFF6500),
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Element Drawer',
                  style: TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Patch 12.1: product-aware catalog previews. Drag items to the canvas.',
            style: TextStyle(
              color: Color(0xFF747B8A),
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ElementGroupTile extends StatelessWidget {
  const _ElementGroupTile({
    required this.group,
    required this.previewContext,
    required this.initiallyExpanded,
    required this.onTapVariant,
  });

  final MBAdvancedElementGroup group;
  final MBAdvancedPreviewContext previewContext;
  final bool initiallyExpanded;
  final ValueChanged<MBAdvancedElementVariant> onTapVariant;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE9ECF3)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
            initiallyExpanded: initiallyExpanded,
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    group.title,
                    style: const TextStyle(
                      color: Color(0xFF172033),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2E8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${group.variants.length}',
                    style: const TextStyle(
                      color: Color(0xFFFF6500),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              group.subtitle,
              style: const TextStyle(
                color: Color(0xFF747B8A),
                fontSize: 10.5,
                height: 1.25,
              ),
            ),
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE6E8EF)),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final variant in group.variants)
                      _VariantBox(
                        variant: variant,
                        previewContext: previewContext,
                        onTap: () => onTapVariant(variant),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VariantBox extends StatelessWidget {
  const _VariantBox({
    required this.variant,
    required this.previewContext,
    required this.onTap,
  });

  final MBAdvancedElementVariant variant;
  final MBAdvancedPreviewContext previewContext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final box = SizedBox(
      width: 134,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: null,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E6EF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 48,
                  child: _VariantPreview(
                    variant: variant,
                    previewContext: previewContext,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  variant.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  variant.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF747B8A),
                    fontSize: 9.5,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Draggable<MBAdvancedElementVariant>(
      data: variant,
      feedback: _VariantDragFeedback(
        variant: variant,
        previewContext: previewContext,
      ),
      childWhenDragging: Opacity(opacity: 0.45, child: box),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: box,
      ),
    );
  }
}

class _VariantDragFeedback extends StatelessWidget {
  const _VariantDragFeedback({
    required this.variant,
    required this.previewContext,
  });

  final MBAdvancedElementVariant variant;
  final MBAdvancedPreviewContext previewContext;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 148,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFB074), width: 1.4),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 42,
              child: _VariantPreview(
                variant: variant,
                previewContext: previewContext,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              variant.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantPreview extends StatelessWidget {
  const _VariantPreview({
    required this.variant,
    required this.previewContext,
  });

  final MBAdvancedElementVariant variant;
  final MBAdvancedPreviewContext previewContext;

  @override
  Widget build(BuildContext context) {
    switch (variant.elementType) {
      case 'card':
        return _PreviewCardShape(variant: variant);
      case 'media':
        return _PreviewMedia(variant: variant, previewContext: previewContext);
      case 'price':
      case 'mrp':
      case 'discount':
      case 'badge':
      case 'promoBadge':
      case 'flashBadge':
      case 'timer':
      case 'rating':
      case 'stock':
      case 'delivery':
      case 'unit':
      case 'quantity':
      case 'feature':
      case 'savingText':
      case 'ribbon':
      case 'cta':
      case 'secondaryCta':
      case 'wishlist':
      case 'compare':
      case 'share':
      case 'animation':
        return _PreviewPillOrText(
          variant: variant,
          previewContext: previewContext,
        );
      case 'divider':
      case 'shape':
      case 'panel':
      case 'imageOverlay':
      case 'progress':
      case 'dots':
      case 'border':
      case 'effect':
      case 'shadow':
      case 'spacing':
        return _PreviewVisualShape(variant: variant);
      case 'title':
      case 'subtitle':
      case 'description':
      case 'brand':
      case 'category':
      default:
        return _PreviewText(
          variant: variant,
          previewContext: previewContext,
        );
    }
  }
}

class _PreviewCardShape extends StatelessWidget {
  const _PreviewCardShape({required this.variant});

  final MBAdvancedElementVariant variant;

  @override
  Widget build(BuildContext context) {
    final background = _hexColor(
      variant.cardPalettePatch['backgroundHex'],
      const Color(0xFFFF6500),
    );
    final background2 = _hexColor(
      variant.cardPalettePatch['backgroundHex2'],
      const Color(0xFFFF9A3D),
    );
    final width = _asDouble(variant.cardLayoutPatch['cardWidth'], 185) >= 300 ? 108.0 : 56.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: <Color>[background, background2]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E8EF)),
        ),
      ),
    );
  }
}

class _PreviewText extends StatelessWidget {
  const _PreviewText({required this.variant, required this.previewContext});

  final MBAdvancedElementVariant variant;
  final MBAdvancedPreviewContext previewContext;

  @override
  Widget build(BuildContext context) {
    final text = MBAdvancedBindingResolver.resolveText(
      previewContext,
      variant.binding,
      fallback: variant.title,
    );
    final background = _hexColor(variant.defaultStyle['backgroundHex'], Colors.transparent);
    final textColor = _hexColor(
      variant.defaultStyle['textColorHex'],
      background == Colors.transparent ? const Color(0xFF172033) : const Color(0xFFFF6500),
    );
    final isChip = background != Colors.transparent ||
        variant.id.contains('chip') ||
        variant.id.contains('badge');

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 118),
        padding: isChip
            ? const EdgeInsets.symmetric(horizontal: 9, vertical: 6)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(
            _asDouble(variant.defaultStyle['borderRadius'], 999),
          ),
        ),
        child: Text(
          text,
          maxLines: isChip ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: isChip ? 10 : 11.5,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

class _PreviewPillOrText extends StatelessWidget {
  const _PreviewPillOrText({required this.variant, required this.previewContext});

  final MBAdvancedElementVariant variant;
  final MBAdvancedPreviewContext previewContext;

  @override
  Widget build(BuildContext context) {
    final text = MBAdvancedBindingResolver.resolveText(
      previewContext,
      variant.binding,
      fallback: variant.title,
    );
    final background = _hexColor(variant.defaultStyle['backgroundHex'], Colors.transparent);
    final textColor = _hexColor(
      variant.defaultStyle['textColorHex'],
      background == Colors.transparent ? const Color(0xFFFF6500) : const Color(0xFF151922),
    );
    final isIcon = variant.elementType == 'wishlist' ||
        variant.elementType == 'compare' ||
        variant.elementType == 'share' ||
        variant.elementType == 'animation';
    final width = isIcon ? 36.0 : 82.0;
    final height = isIcon ? 36.0 : 30.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: background == Colors.transparent ? Colors.white : background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFFFD6BA)),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: isIcon ? 15 : 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PreviewMedia extends StatelessWidget {
  const _PreviewMedia({required this.variant, required this.previewContext});

  final MBAdvancedElementVariant variant;
  final MBAdvancedPreviewContext previewContext;

  @override
  Widget build(BuildContext context) {
    final imageUrl = MBAdvancedBindingResolver.resolveImageUrl(
      previewContext,
      variant.binding,
    );
    final isCircle = _asDouble(variant.defaultStyle['borderRadius'], 0) >= 500;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: isCircle ? 48 : 62,
        height: isCircle ? 48 : 42,
        padding: EdgeInsets.all(_asDouble(variant.defaultStyle['ringWidth'], 4) * 0.45),
        decoration: BoxDecoration(
          color: _hexColor(variant.defaultStyle['borderHex'], Colors.white),
          borderRadius: BorderRadius.circular(isCircle ? 999 : 14),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isCircle ? 999 : 10),
          child: imageUrl.isEmpty
              ? const _ImageFallback()
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _ImageFallback(),
                ),
        ),
      ),
    );
  }
}

class _PreviewVisualShape extends StatelessWidget {
  const _PreviewVisualShape({required this.variant});

  final MBAdvancedElementVariant variant;

  @override
  Widget build(BuildContext context) {
    final color = _hexColor(
      variant.defaultStyle['backgroundHex'],
      const Color(0xFFFF6500),
    ).withValues(
      alpha: _asDouble(variant.defaultStyle['opacity'], 0.35).clamp(0.0, 1.0),
    );

    if (variant.elementType == 'progress') {
      return Align(
        alignment: Alignment.centerLeft,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 98,
            height: 10,
            color: const Color(0xFFFFE2CC),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: _asDouble(variant.defaultStyle['progress'], 0.72),
              child: Container(color: const Color(0xFFFF6500)),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: variant.elementType == 'divider' ? 112 : 62,
        height: variant.elementType == 'divider' ? 4 : 38,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
            _asDouble(variant.defaultStyle['borderRadius'], 18),
          ),
          border: Border.all(color: const Color(0xFFFFD6BA)),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF0E6),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_rounded,
        color: Color(0xFFFF6500),
        size: 18,
      ),
    );
  }
}

Color _hexColor(Object? value, Color fallback) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty || raw == '#00000000') return fallback;

  var hex = raw.replaceAll('#', '').toUpperCase();
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return fallback;

  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) return fallback;

  return Color(parsed);
}

double _asDouble(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
}
