// MB Product Card - price01
//
// Family:
// Price
//
// Purpose:
// A deal-first product card for dense 2-column store grids where price,
// discount, and savings must stand out immediately.
//
// Footprint:
// Half-width card.
// Designed for 2 cards per row in normal store grids.
// Slightly taller and stronger than compact01, but still grid-safe.
//
// Visual Priority:
// 1. Discount / deal signal
// 2. Current price
// 3. Old price / savings
// 4. Product title
// 5. Small urgency or stock hint
//
// Best Use Cases:
// Flash deals, discounted grocery items, personal care offers, essential items,
// high-conversion campaign blocks.
//
// Behavior Notes:
// - Title should clamp to 2 lines.
// - Deal badge must be stronger than compact cards.
// - Current price must feel visually dominant.
// - Old price should be visible but muted.
// - Optional urgency row may appear if useful.
// - Must work safely in bounded preview containers and scrollable layouts.
// - Must degrade cleanly when sale fields are missing.
// - Avoids relying on unbounded Expanded/Flex behavior.

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../system/mb_card_config_resolver.dart';

class MBProductCardPrice01 extends StatelessWidget {
  const MBProductCardPrice01({
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
    final urgency = _buildUrgencyRow(context);
    final badge = _buildDealBadge(context);

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildImageBlock(context, badge: badge),
                  const SizedBox(height: 10),
                  _buildTitle(context),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 4),
                    subtitle,
                  ],
                  const SizedBox(height: 10),
                  _buildPriceBlock(context),
                  if (urgency != null) ...<Widget>[
                    const SizedBox(height: 8),
                    urgency,
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
    switch (_normalizeToken(resolved.borderEffect.effectPreset)) {
      case 'deal_pulse':
        return const Color(0xFFFF7A00);
      case 'fire':
        return const Color(0xFFFF5A36);
      case 'soft_glow':
        return const Color(0xFFFFB36B);
      case 'premium_outline':
        return const Color(0xFFD4A017);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Widget _buildImageBlock(BuildContext context, {Widget? badge}) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(resolved.media.imageCornerRadius),
      child: AspectRatio(
        aspectRatio: 1.18,
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
                top: 8,
                right: 8,
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

  Widget _buildPriceBlock(BuildContext context) {
    if (!resolved.price.showsAnyPrice) {
      return const SizedBox.shrink();
    }

    final finalPrice = product.salePrice ?? product.price;
    final originalPrice = product.price;
    final salePrice = product.salePrice;
    final hasDiscount = salePrice != null && salePrice < product.price;
    final currency = resolved.price.showCurrencySymbol ? '৳' : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$currency${finalPrice.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _priceColor(),
            fontWeight: resolved.price.emphasizeFinalPrice
                ? FontWeight.w800
                : FontWeight.w700,
            height: 1.0,
          ),
        ),
        if (resolved.price.showsOriginalPrice && hasDiscount) ...<Widget>[
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  '$currency${originalPrice.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _oldPriceColor(),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              if (resolved.price.showsDiscountInfo) ...<Widget>[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _discountText(original: originalPrice, finalPrice: finalPrice),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFFE67E22),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget? _buildUrgencyRow(BuildContext context) {
    final text = _urgencyText();
    if (text == null || text.isEmpty) {
      return null;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.local_fire_department_outlined,
            size: 14,
            color: Color(0xFFE67E22),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFFE67E22),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onAddToCartTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Add to cart'),
      ),
    );
  }

  Widget? _buildDealBadge(BuildContext context) {
    if (!resolved.badges.showPrimaryBadge) {
      return null;
    }

    final text = _dealBadgeText();
    if (text == null || text.isEmpty) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _badgeBackgroundColor(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
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
    final unitLabelEn = _textValue(product.unitLabelEn);
    if (resolved.meta.showUnitLabel && unitLabelEn.isNotEmpty) {
      return unitLabelEn;
    }

    final brandNameEn = _textValue(product.brandNameEn);
    if (resolved.meta.showBrand && brandNameEn.isNotEmpty) {
      return brandNameEn;
    }

    final shortDescriptionEn = _textValue(product.shortDescriptionEn);
    if (resolved.meta.showSubtitle && shortDescriptionEn.isNotEmpty) {
      return shortDescriptionEn;
    }

    return null;
  }

  String? _dealBadgeText() {
    final sale = product.salePrice;
    if (resolved.price.showDiscountBadge &&
        sale != null &&
        sale < product.price) {
      final percent = (((product.price - sale) / product.price) * 100).round();
      if (percent > 0) {
        return '-$percent%';
      }
    }

    if (product.isFlashSale) {
      return 'Flash';
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

    final percent = original <= 0 ? 0 : ((saved / original) * 100).round();
    if (percent > 0) {
      return '$percent% off';
    }

    return 'Discount';
  }

  String? _urgencyText() {
    if (!resolved.meta.showStockHint) {
      return null;
    }

    final qty = product.stockQty;
    if (qty > 0 && qty <= 5) {
      return 'Limited stock';
    }
    if (product.isFlashSale) {
      return 'Limited time offer';
    }
    return null;
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
    switch (_normalizeToken(resolved.typography.subtitleColorToken)) {
      case 'text_subtitle_soft':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
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
      case 'badge_flash_sale':
        return const Color(0xFFE53935);
      case 'badge_hot_deal':
        return const Color(0xFFFF6A00);
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