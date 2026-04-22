// MB Product Card - horizontal01
//
// Family:
// Horizontal
//
// Purpose:
// A fast-scanning full-width row card designed for recommendation strips,
// mixed-product sections, and compact list-like store layouts.
//
// Footprint:
// Full-width card.
// Short horizontal footprint.
// Must fit comfortably inside section grids where row-style cards break the
// rhythm of 2-column cards and provide visual variety.
//
// Visual Priority:
// 1. Product image
// 2. Product title
// 3. Current price
// 4. Key supporting info
// 5. Small badge or status chip
//
// Best Use Cases:
// Mixed recommendations, recently viewed style blocks, repeat products,
// quick-scan shopping sections, cross-category suggestions.
//
// Behavior Notes:
// - Uses a left-image, right-content layout.
// - Title clamps to 2 lines.
// - Remains compact vertically.
// - Supporting info stays minimal and never crowds the layout.
// - Works safely in bounded preview containers and scrollable layouts.
// - Remains readable even with weaker product images.
// - Avoids relying on unbounded Expanded/Flex behavior.

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../system/mb_card_config_resolver.dart';

class MBProductCardHorizontal01 extends StatelessWidget {
  const MBProductCardHorizontal01({
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
    final badge = _buildPrimaryBadge(context);
    final subtitle = _buildSubtitle(context);
    final meta = _buildBottomMeta(context);

    final body = Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildImageBlock(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (badge != null) ...<Widget>[
                          badge,
                          const SizedBox(height: 8),
                        ],
                        _buildTitle(context),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: 4),
                          subtitle,
                        ],
                        const SizedBox(height: 10),
                        _buildPriceRow(context),
                        if (meta != null) ...<Widget>[
                          const SizedBox(height: 8),
                          meta,
                        ],
                        if (resolved.actions.showAddToCart ||
                            resolved.actions.showViewDetails) ...<Widget>[
                          const SizedBox(height: 10),
                          _buildActionRow(context),
                        ],
                      ],
                    ),
                  ),
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
      return body;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(resolved.surface.borderRadius),
        onTap: onTap,
        child: body,
      ),
    );
  }

  EdgeInsets _contentPadding() {
    final scale =
    resolved.surface.paddingScale <= 0 ? 1.0 : resolved.surface.paddingScale;
    final base = 12.0 * scale;
    return EdgeInsets.all(base.clamp(8.0, 20.0));
  }

  List<BoxShadow> _buildShadows() {
    final elevation = resolved.surface.elevationLevel.clamp(0.0, 6.0);
    if (elevation <= 0 && !resolved.surface.use3DEffect) {
      return const <BoxShadow>[];
    }

    return <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 10 + (elevation * 2),
        offset: Offset(0, 4 + elevation),
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
      return null;
    }

    return Border.all(
      color: _borderColor(),
      width: resolved.borderEffect.borderWidth <= 0
          ? 1
          : resolved.borderEffect.borderWidth,
    );
  }

  Color _borderColor() {
    switch (resolved.borderEffect.effectPreset.trim().toLowerCase()) {
      case 'premium_outline':
        return const Color(0xFFD4A017);
      case 'deal_pulse':
        return const Color(0xFFFF7A00);
      case 'soft_glow':
        return const Color(0xFFFFB36B);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Widget _buildImageBlock(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(resolved.media.imageCornerRadius),
      child: SizedBox(
        width: 110,
        height: 110,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _ProductImage(
              imageUrl: product.thumbnailUrl,
              fitMode: resolved.media.imageFitMode,
            ),
            if (resolved.media.imageOverlayOpacity > 0)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: resolved.media.imageOverlayOpacity.clamp(0.0, 0.85),
                  ),
                ),
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

  Widget _buildTitle(BuildContext context) {
    return Text(
      _titleText(),
      maxLines: resolved.typography.titleMaxLines,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: _titleColor(),
        fontWeight:
        resolved.typography.titleBold ? FontWeight.w700 : FontWeight.w600,
        height: 1.2,
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

  Widget _buildPriceRow(BuildContext context) {
    if (!resolved.price.showsAnyPrice) {
      return const SizedBox.shrink();
    }

    final finalPrice = product.salePrice ?? product.price;
    final originalPrice = product.price;
    final salePrice = product.salePrice;
    final hasDiscount = salePrice != null && salePrice < product.price;
    final currency = resolved.price.showCurrencySymbol ? '৳' : '';

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        if (resolved.price.showsFinalPrice)
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
        if (resolved.price.showsOriginalPrice && hasDiscount)
          Text(
            '$currency${originalPrice.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _oldPriceColor(),
              decoration: TextDecoration.lineThrough,
            ),
          ),
        if (resolved.price.showsDiscountInfo && hasDiscount)
          Text(
            _discountText(original: originalPrice, finalPrice: finalPrice),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFFE67E22),
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget? _buildBottomMeta(BuildContext context) {
    final texts = <String>[];

    final unitLabelEn = product.unitLabelEn;
    if (resolved.meta.showUnitLabel && unitLabelEn!.trim().isNotEmpty) {
      texts.add(unitLabelEn.trim());
    }

    final brandNameEn = product.brandNameEn;
    if (resolved.meta.showBrand && brandNameEn!.trim().isNotEmpty) {
      texts.add(brandNameEn.trim());
    }

    final qty = product.stockQty;
    if (resolved.meta.showStockHint && qty > 0 && qty <= 10) {
      texts.add('Low stock');
    }

    final deliveryShift = product.deliveryShift;
    if (resolved.meta.showDeliveryHint && deliveryShift.trim().isNotEmpty) {
      texts.add(deliveryShift.trim());
    }

    if (resolved.meta.showRating && product.views > 0) {
      texts.add('Popular');
    }

    if (texts.isEmpty) {
      return null;
    }

    return Text(
      texts.join(' • '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: <Widget>[
        if (resolved.actions.showAddToCart)
          Expanded(
            child: OutlinedButton(
              onPressed: onAddToCartTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add'),
            ),
          ),
        if (resolved.actions.showAddToCart && resolved.actions.showViewDetails)
          const SizedBox(width: 8),
        if (resolved.actions.showViewDetails)
          Expanded(
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Details'),
            ),
          ),
      ],
    );
  }

  Widget? _buildPrimaryBadge(BuildContext context) {
    if (!resolved.badges.showPrimaryBadge) {
      return null;
    }

    final text = _badgeText();
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
    if (product.titleEn.trim().isNotEmpty) {
      return product.titleEn.trim();
    }
    if (product.titleBn.trim().isNotEmpty) {
      return product.titleBn.trim();
    }
    if (product.slug.trim().isNotEmpty) {
      return product.slug.trim();
    }
    return 'Untitled product';
  }

  String? _subtitleText() {
    if (resolved.meta.showSubtitle && product.shortDescriptionEn.trim().isNotEmpty) {
      return product.shortDescriptionEn.trim();
    }

    final brandNameEn = product.brandNameEn;
    if (resolved.meta.showBrand && brandNameEn!.trim().isNotEmpty) {
      return brandNameEn.trim();
    }

    final unitLabelEn = product.unitLabelEn;
    if (resolved.meta.showUnitLabel && unitLabelEn!.trim().isNotEmpty) {
      return unitLabelEn.trim();
    }

    return null;
  }

  String? _badgeText() {
    if (product.isFlashSale) {
      return 'Flash';
    }
    if (product.isBestSeller) {
      return 'Best Seller';
    }
    if (product.isNewArrival) {
      return 'New';
    }
    if (product.isFeatured) {
      return 'Featured';
    }
    return null;
  }

  String _discountText({
    required double original,
    required double finalPrice,
  }) {
    final saved = (original - finalPrice).clamp(0, double.infinity);
    final percent = original <= 0 ? 0 : ((saved / original) * 100).round();
    if (percent > 0) {
      return '$percent% off';
    }
    return 'Discount';
  }

  Color _titleColor() {
    switch ((resolved.typography.titleColorToken ?? '').trim().toLowerCase()) {
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
    switch ((resolved.typography.priceColorToken ?? '').trim().toLowerCase()) {
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
    switch ((resolved.badges.primaryBadgeStyle ?? '').trim().toLowerCase()) {
      case 'badge_best_seller':
        return const Color(0xFF7C3AED);
      case 'badge_flash_sale':
        return const Color(0xFFE53935);
      case 'badge_new_tag':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFFFF7A00);
    }
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

    if (imageUrl.trim().isEmpty) {
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
    switch (fitMode.trim().toLowerCase()) {
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
        size: 30,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}