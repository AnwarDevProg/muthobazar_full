// MB Product Card - compact02
//
// Family:
// Compact
//
// Purpose:
// A denser but more structured compact-family variant for 2-column store grids.
// Compared with compact01, this version adds clearer information grouping while
// still keeping the same fast browsing behavior and half-width footprint.
//
// Footprint:
// Half-width card.
// Designed for 2 cards per row in normal store grids.
// Must remain stable inside bounded preview containers and scrollable layouts.
//
// Visual Priority:
// 1. Product image
// 2. Product title
// 3. Price block
// 4. Supporting metadata rail
// 5. Small action and badge cues
//
// Best Use Cases:
// Grocery essentials, pharmacy items, packaged foods, household items,
// and general catalog browsing where a more organized compact card is useful.
//
// Behavior Notes:
// - Keeps the compact family footprint and browsing behavior.
// - Uses a more structured content stack than compact01.
// - Badge remains small and controlled.
// - Metadata is grouped into a lightweight bottom rail.
// - Title clamps to 2 lines.
// - Must degrade gracefully when sale price, brand, subtitle, or meta values
//   are missing.
// - Avoids relying on unbounded Expanded/Flex behavior.

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../system/mb_card_config_resolver.dart';

class MBProductCardCompact02 extends StatelessWidget {
  const MBProductCardCompact02({
    super.key,
    required this.product,
    required this.resolved,
    this.onTap,
    this.onAddToCartTap,
    this.trailingOverlay,
  });

  final MBProduct product;
  final MBResolvedCardConfig resolved;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCartTap;
  final Widget? trailingOverlay;

  @override
  Widget build(BuildContext context) {
    final subtitle = _buildSubtitle(context);
    final badge = _buildPrimaryBadge(context);
    final brandChip = _buildBrandChip(context);
    final metaRail = _buildMetaRail(context);

    final cardBody = Container(
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(resolved.surface.borderRadius),
        boxShadow: _buildShadows(),
        border: _buildBorder(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(resolved.surface.borderRadius),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: _contentPadding(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildImageBlock(
                    context,
                    badge: badge,
                  ),
                  const SizedBox(height: 10),
                  if (brandChip != null) ...<Widget>[
                    brandChip,
                    const SizedBox(height: 8),
                  ],
                  _buildTitle(context),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 4),
                    subtitle,
                  ],
                  const SizedBox(height: 10),
                  _buildPriceBlock(context),
                  if (metaRail != null) ...<Widget>[
                    const SizedBox(height: 10),
                    metaRail,
                  ],
                  if (resolved.actions.showAddToCart) ...<Widget>[
                    const SizedBox(height: 10),
                    _buildAddButton(context),
                  ],
                ],
              ),
            ),
            if (trailingOverlay != null)
              Positioned(
                top: 8,
                right: 8,
                child: trailingOverlay!,
              ),
          ],
        ),
      ),
    );

    if (onTap == null) {
      return cardBody;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(resolved.surface.borderRadius),
        onTap: onTap,
        child: cardBody,
      ),
    );
  }

  EdgeInsets _contentPadding() {
    final scale = resolved.surface.paddingScale <= 0
        ? 1.0
        : resolved.surface.paddingScale;
    final base = 12.0 * scale;
    return EdgeInsets.all(base.clamp(8.0, 20.0));
  }

  Color _backgroundColor() {
    switch (_normalizeToken(resolved.surface.backgroundColorToken)) {
      case 'surface_soft_gray':
        return const Color(0xFFF9FAFB);
      case 'surface_soft_orange':
        return const Color(0xFFFFFAF5);
      default:
        return Colors.white;
    }
  }

  List<BoxShadow> _buildShadows() {
    if (resolved.surface.elevationLevel <= 0 && !resolved.surface.use3DEffect) {
      return const <BoxShadow>[];
    }

    final elevation = resolved.surface.elevationLevel.clamp(0.0, 6.0);
    final blur = 10.0 + (elevation * 2.0);
    final y = 4.0 + elevation;

    return <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: blur,
        offset: Offset(0, y),
      ),
      if (resolved.surface.use3DEffect && resolved.surface.threeDDepth > 0)
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: resolved.surface.threeDDepth * 3,
          offset: Offset(0, resolved.surface.threeDDepth),
        ),
    ];
  }

  Border? _buildBorder() {
    if (!resolved.borderEffect.showBorder) {
      return Border.all(
        color: const Color(0xFFE5E7EB),
        width: 1,
      );
    }

    return Border.all(
      color: _borderColor(),
      width: resolved.borderEffect.borderWidth <= 0
          ? 1
          : resolved.borderEffect.borderWidth,
    );
  }

  Color _borderColor() {
    switch (_normalizeToken(resolved.borderEffect.effectPreset)) {
      case 'premium_outline':
        return const Color(0xFFD4A017);
      case 'deal_pulse':
        return const Color(0xFFFF7A00);
      case 'soft_glow':
        return const Color(0xFFFFB36B);
      case 'electric':
        return const Color(0xFF5B8CFF);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Widget _buildImageBlock(
      BuildContext context, {
        Widget? badge,
      }) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(resolved.media.imageCornerRadius),
      child: AspectRatio(
        aspectRatio: 1.02,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _ProductImage(
              imageUrl: _textValue(product.thumbnailUrl),
              fitMode: _textValue(resolved.media.imageFitMode),
            ),
            if (resolved.media.imageOverlayOpacity > 0)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: resolved.media.imageOverlayOpacity.clamp(0.0, 0.85),
                  ),
                ),
              ),
            if (badge != null)
              Positioned(
                left: 8,
                top: 8,
                child: badge,
              ),
          ],
        ),
      ),
    );

    if (!resolved.media.showImageShadow) {
      return image;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: image,
    );
  }

  Widget? _buildBrandChip(BuildContext context) {
    if (!resolved.meta.showBrand) {
      return null;
    }

    final brand = _textValue(product.brandNameEn);
    if (brand.isEmpty) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        brand,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF4B5563),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      _titleText(),
      maxLines: resolved.typography.titleMaxLines,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: _titleColor(),
        fontWeight:
        resolved.typography.titleBold ? FontWeight.w700 : FontWeight.w600,
        height: 1.22,
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final text = _subtitleText();
    if (text == null || text.isEmpty) {
      return null;
    }

    return Text(
      text,
      maxLines: resolved.typography.subtitleMaxLines,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: _subtitleColor(),
        height: 1.2,
      ),
    );
  }

  Widget _buildPriceBlock(BuildContext context) {
    if (!resolved.price.showsAnyPrice) {
      return const SizedBox.shrink();
    }

    final finalPrice = product.salePrice ?? product.price;
    final originalPrice = product.price;
    final salePrice = product.salePrice;
    final hasDiscount = salePrice != null && salePrice < product.price;
    final currency = resolved.price.showCurrencySymbol ? '৳' : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$currency${finalPrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _priceColor(),
                  fontWeight: resolved.price.emphasizeFinalPrice
                      ? FontWeight.w800
                      : FontWeight.w700,
                  height: 1.0,
                ),
              ),
              if (resolved.price.showsOriginalPrice && hasDiscount) ...<Widget>[
                const SizedBox(height: 3),
                Text(
                  '$currency${originalPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _oldPriceColor(),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (resolved.price.showsDiscountInfo && hasDiscount)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _discountText(
                original: originalPrice,
                finalPrice: finalPrice,
              ),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFFE67E22),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget? _buildMetaRail(BuildContext context) {
    final entries = <_MetaEntry>[];

    final unitLabel = _textValue(product.unitLabelEn);
    if (resolved.meta.showUnitLabel && unitLabel.isNotEmpty) {
      entries.add(
        _MetaEntry(
          icon: Icons.straighten,
          label: unitLabel,
        ),
      );
    }

    if (resolved.meta.showStockHint) {
      final qty = product.stockQty;
      if (qty > 0 && qty <= 10) {
        entries.add(
          const _MetaEntry(
            icon: Icons.inventory_2_outlined,
            label: 'Low stock',
          ),
        );
      }
    }

    final deliveryShift = _textValue(product.deliveryShift);
    if (resolved.meta.showDeliveryHint && deliveryShift.isNotEmpty) {
      entries.add(
        _MetaEntry(
          icon: Icons.local_shipping_outlined,
          label: deliveryShift,
        ),
      );
    }

    if (resolved.meta.showRating && product.views > 0) {
      entries.add(
        const _MetaEntry(
          icon: Icons.trending_up,
          label: 'Popular',
        ),
      );
    }

    if (entries.isEmpty) {
      return null;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: entries.map((entry) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                entry.icon,
                size: 14,
                color: const Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                entry.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onAddToCartTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Add to cart'),
      ),
    );
  }

  Widget? _buildPrimaryBadge(BuildContext context) {
    if (!resolved.badges.showPrimaryBadge) {
      return null;
    }

    final text = _primaryBadgeText();
    if (text == null || text.isEmpty) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _badgeBackgroundColor(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }

  String _titleText() {
    final titleEn = _textValue(product.titleEn);
    if (titleEn.isNotEmpty) {
      return titleEn;
    }

    final titleBn = _textValue(product.titleBn);
    if (titleBn.isNotEmpty) {
      return titleBn;
    }

    final slug = _textValue(product.slug);
    if (slug.isNotEmpty) {
      return slug;
    }

    return 'Untitled product';
  }

  String? _subtitleText() {
    final shortDescriptionEn = _textValue(product.shortDescriptionEn);
    if (resolved.meta.showSubtitle && shortDescriptionEn.isNotEmpty) {
      return shortDescriptionEn;
    }

    final brandNameEn = _textValue(product.brandNameEn);
    if (!resolved.meta.showBrand && brandNameEn.isNotEmpty) {
      return brandNameEn;
    }

    return null;
  }

  String? _primaryBadgeText() {
    final salePrice = product.salePrice;
    if (resolved.price.showDiscountBadge &&
        salePrice != null &&
        salePrice < product.price) {
      final percent = (((product.price - salePrice) / product.price) * 100).round();
      if (percent > 0) {
        return '-$percent%';
      }
    }

    if (product.isFlashSale) {
      return 'Flash';
    }
    if (product.isBestSeller) {
      return 'Best';
    }
    if (product.isNewArrival) {
      return 'New';
    }
    if (product.isFeatured) {
      return 'Hot';
    }
    return null;
  }

  String _discountText({
    required double original,
    required double finalPrice,
  }) {
    final saved = (original - finalPrice).clamp(0, double.infinity);
    if (resolved.price.showSavingsText && saved > 0) {
      return 'Save ৳${saved.toStringAsFixed(0)}';
    }

    final percent = original > 0 ? ((saved / original) * 100).round() : 0;
    if (percent > 0) {
      return '$percent% off';
    }

    return 'Deal';
  }

  Color _titleColor() {
    switch (_normalizeToken(resolved.typography.titleColorToken)) {
      case 'text_title_inverse':
        return Colors.white;
      default:
        return const Color(0xFF111827);
    }
  }

  Color _subtitleColor() {
    return const Color(0xFF6B7280);
  }

  Color _priceColor() {
    switch (_normalizeToken(resolved.typography.priceColorToken)) {
      case 'text_price_inverse':
        return Colors.white;
      default:
        return const Color(0xFF111827);
    }
  }

  Color _oldPriceColor() {
    return const Color(0xFF9CA3AF);
  }

  Color _badgeBackgroundColor() {
    switch (_normalizeToken(resolved.badges.primaryBadgeStyle)) {
      case 'badge_best_seller':
        return const Color(0xFF7C3AED);
      case 'badge_flash_sale':
        return const Color(0xFFE53935);
      case 'badge_premium_tag':
        return const Color(0xFFD4A017);
      case 'badge_new_tag':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFFFF7A00);
    }
  }

  String _normalizeToken(String? raw) {
    return _textValue(raw).toLowerCase();
  }

  String _textValue(Object? raw) {
    if (raw == null) {
      return '';
    }

    if (raw is String) {
      return raw.trim();
    }

    return raw.toString().trim();
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.fitMode,
  });

  final String imageUrl;
  final String fitMode;

  @override
  Widget build(BuildContext context) {
    final fit = _boxFit();

    if (imageUrl.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return _placeholder();
      },
    );
  }

  BoxFit _boxFit() {
    switch (fitMode.toLowerCase()) {
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      default:
        return BoxFit.cover;
    }
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF3F4F6),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 32,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}

class _MetaEntry {
  const _MetaEntry({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}