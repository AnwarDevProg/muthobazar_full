// MuthoBazar Advanced Product Card Design Studio
// Patch 1 left element drawer.
//
// Purpose:
// - Three-panel studio left side.
// - Expandable drawers: Card, Title, Subtitle, Media, Price, CTA, Badge.
// - Each drawer contains a boxed list/grid of variants.
// - Patch 1 uses click-to-add/apply only. Drag/drop is reserved for Patch 2.

import 'package:flutter/material.dart';

import '../models/mb_advanced_element_variant.dart';

class MBAdvancedElementDrawerPanel extends StatelessWidget {
  const MBAdvancedElementDrawerPanel({
    super.key,
    required this.productTitle,
    required this.productSubtitle,
    required this.onAddVariant,
    required this.onApplyCardVariant,
  });

  final String productTitle;
  final String productSubtitle;
  final ValueChanged<MBAdvancedElementVariant> onAddVariant;
  final ValueChanged<MBAdvancedElementVariant> onApplyCardVariant;

  @override
  Widget build(BuildContext context) {
    final groups = MBAdvancedElementCatalog.groups();

    return Container(
      width: 286,
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
                  productTitle: productTitle,
                  productSubtitle: productSubtitle,
                  onTapVariant: (variant) {
                    if (variant.isCardVariant) {
                      onApplyCardVariant(variant);
                    } else {
                      onAddVariant(variant);
                    }
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
            'Patch 1: expandable variant boxes. Drag/drop comes in Patch 2.',
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
    required this.productTitle,
    required this.productSubtitle,
    required this.onTapVariant,
  });

  final MBAdvancedElementGroup group;
  final String productTitle;
  final String productSubtitle;
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
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
            initiallyExpanded: group.id == 'card' || group.id == 'title',
            title: Text(
              group.title,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
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
                        productTitle: productTitle,
                        productSubtitle: productSubtitle,
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
    required this.productTitle,
    required this.productSubtitle,
    required this.onTap,
  });

  final MBAdvancedElementVariant variant;
  final String productTitle;
  final String productSubtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
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
                    productTitle: productTitle,
                    productSubtitle: productSubtitle,
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
  }
}

class _VariantPreview extends StatelessWidget {
  const _VariantPreview({
    required this.variant,
    required this.productTitle,
    required this.productSubtitle,
  });

  final MBAdvancedElementVariant variant;
  final String productTitle;
  final String productSubtitle;

  @override
  Widget build(BuildContext context) {
    switch (variant.elementType) {
      case 'card':
        return _PreviewCardShape(variant: variant);
      case 'title':
        return _PreviewTitle(variant: variant, productTitle: productTitle);
      case 'subtitle':
        return _PreviewSubtitle(
          variant: variant,
          productSubtitle: productSubtitle,
        );
      case 'media':
        return _PreviewMedia(variant: variant);
      case 'price':
        return _PreviewPrice(variant: variant);
      case 'cta':
        return _PreviewCta(variant: variant);
      case 'badge':
        return _PreviewBadge(variant: variant);
      default:
        return const SizedBox.shrink();
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: variant.id == 'card_compact_row' ? 92 : 54,
        height: variant.id == 'card_compact_row' ? 38 : 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: <Color>[background, background2]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E8EF)),
        ),
      ),
    );
  }
}

class _PreviewTitle extends StatelessWidget {
  const _PreviewTitle({required this.variant, required this.productTitle});

  final MBAdvancedElementVariant variant;
  final String productTitle;

  @override
  Widget build(BuildContext context) {
    final isChip = variant.id.contains('chip');
    final textColor = _hexColor(
      variant.defaultStyle['textColorHex'],
      const Color(0xFFFF6500),
    );
    final background = _hexColor(
      variant.defaultStyle['backgroundHex'],
      Colors.transparent,
    );
    final title = productTitle.trim().isEmpty ? 'Product title' : productTitle;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 104),
        padding: isChip
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 7)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isChip ? background : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          title,
          maxLines: isChip ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isChip ? textColor : const Color(0xFF172033),
            fontSize: isChip ? 10 : 12,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

class _PreviewSubtitle extends StatelessWidget {
  const _PreviewSubtitle({required this.variant, required this.productSubtitle});

  final MBAdvancedElementVariant variant;
  final String productSubtitle;

  @override
  Widget build(BuildContext context) {
    final isChip = variant.id.contains('chip');
    final text = productSubtitle.trim().isEmpty ? 'Fresh product detail' : productSubtitle;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: isChip ? 98 : 106,
        padding: isChip
            ? const EdgeInsets.symmetric(horizontal: 9, vertical: 6)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isChip ? const Color(0xFFFFF5EC) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          maxLines: isChip ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isChip ? const Color(0xFFB84300) : const Color(0xFF747B8A),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
      ),
    );
  }
}

class _PreviewMedia extends StatelessWidget {
  const _PreviewMedia({required this.variant});

  final MBAdvancedElementVariant variant;

  @override
  Widget build(BuildContext context) {
    final isCircle = variant.id.contains('circle');
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: isCircle ? 46 : 54,
        height: isCircle ? 46 : 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0E6),
          borderRadius: BorderRadius.circular(isCircle ? 999 : 14),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.image_rounded,
          color: Color(0xFFFF6500),
          size: 18,
        ),
      ),
    );
  }
}

class _PreviewPrice extends StatelessWidget {
  const _PreviewPrice({required this.variant});

  final MBAdvancedElementVariant variant;

  @override
  Widget build(BuildContext context) {
    final isCircle = variant.id.contains('circle');
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: isCircle ? 48 : 76,
        height: isCircle ? 48 : 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFFFD6BA)),
        ),
        child: const Text(
          '৳120',
          style: TextStyle(
            color: Color(0xFFFF6500),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PreviewCta extends StatelessWidget {
  const _PreviewCta({required this.variant});

  final MBAdvancedElementVariant variant;

  @override
  Widget build(BuildContext context) {
    final isOutline = variant.id.contains('outline');
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 70,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isOutline ? Colors.white : const Color(0xFF151922),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isOutline ? const Color(0xFFFF6500) : const Color(0xFF151922),
          ),
        ),
        child: Text(
          isOutline ? 'View' : 'Buy',
          style: TextStyle(
            color: isOutline ? const Color(0xFFFF6500) : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PreviewBadge extends StatelessWidget {
  const _PreviewBadge({required this.variant});

  final MBAdvancedElementVariant variant;

  @override
  Widget build(BuildContext context) {
    final isDark = variant.id.contains('dark');
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 68,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151922) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFFFD6BA)),
        ),
        child: Text(
          isDark ? 'SAVE' : 'HOT',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFFFF6500),
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

Color _hexColor(Object? value, Color fallback) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return fallback;
  var hex = raw.replaceAll('#', '').toUpperCase();
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return fallback;
  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) return fallback;
  return Color(parsed);
}
