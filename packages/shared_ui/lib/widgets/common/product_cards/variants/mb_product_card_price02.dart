// MB Product Card - price02
//
// Family:
// Price
//
// Purpose:
// A cleaner deal-first price-family variant that still pushes discount value,
// but with a more structured retail layout than price01. This version is made
// for sections where the user should notice both savings and product clarity
// at the same time.
//
// Footprint:
// Half-width card.
// Designed for 2 cards per row in normal store grids.
// Must remain stable inside bounded preview containers and scrollable layouts.
//
// Visual Priority:
// 1. Final price
// 2. Savings panel
// 3. Product title
// 4. Old price / discount cue
// 5. Secondary meta hints
//
// Best Use Cases:
// Daily offers, grocery discounts, personal care campaigns, value-focused home
// items, and sections where deal visibility must stay strong without becoming
// as aggressive as flash-sale styling.
//
// Behavior Notes:
// - Keeps the price family footprint.
// - More structured and cleaner than price01.
// - Uses a dedicated savings panel under the main price line.
// - Gracefully handles missing sale, subtitle, brand, and stock data.
// - Avoids relying on unbounded Expanded/Flex behavior.

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../system/mb_card_config_resolver.dart';

class MBProductCardPrice02 extends StatelessWidget {
  const MBProductCardPrice02({
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
    final badge = _buildDealBadge(context);
    final savingsPanel = _buildSavingsPanel(context);
    final meta = _buildMetaLine(context);

    final body = Container(
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
                  _buildImageBlock(context, badge: badge),
                  const SizedBox(height: 10),
                  _buildPriceHeader(context),
                  if (savingsPanel != null) ...<Widget>[
                    const SizedBox(height: 8),
                    savingsPanel,
                  ],
                  const SizedBox(height: 10),
                  _buildTitle(context),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 4),
                    subtitle,
                  ],
                  if (meta != null) ...<Widget>[
                    const SizedBox(height: 8),
                    meta,
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
    final scale = resolved.surface.paddingScale <= 0
        ? 1.0
        : resolved.surface.paddingScale;
    final base = 12.0 * scale;
    return EdgeInsets.all(base.clamp(8.0, 20.0));
  }

  Color _backgroundColor() {
    switch (_normalizeToken(resolved.surface.backgroundColorToken)) {
      case 'surface_soft_orange':
        return const Color(0xFFFFFAF5);
      case 'surface_flash_tint':
        return const Color(0xFFFFFAF7);
      default:
        return Colors.white;
    }
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
      case 'deal_pulse':
        return const Color(0xFFFF7A00);
      case 'fire':
        return const Color(0xFFFF5A36);
      case 'soft_glow':
        return const Color(0xFFFFB36B);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Widget _buildImageBlock(BuildContext context, {Widget? badge}) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(resolved.media.imageCornerRadius),
      child: AspectRatio(
        aspectRatio: 1.15,
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

  Widget _buildPriceHeader(BuildContext context) {
    final finalPrice = product.salePrice ?? product.price;
    final originalPrice = product.price;
    final salePrice = product.salePrice;
    final hasDiscount = salePrice != null && salePrice < originalPrice;
    final currency = resolved.price.showCurrencySymbol ? '৳' : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Text(
            '$currency${finalPrice.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _priceColor(),
                  fontWeight: resolved.price.emphasizeFinalPrice
                      ? FontWeight.w800
                      : FontWeight.w700,
                  height: 1.0,
                ),
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
      ],
    );
  }

  Widget? _buildSavingsPanel(BuildContext context) {
    final salePrice = product.salePrice;
    if (salePrice == null || salePrice >= product.price) {
      return null;
    }

    final saved = product.price - salePrice;
    if (saved <= 0) {
      return null;
    }

    final percent = product.price > 0
        ? ((saved / product.price) * 100).round()
        : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.savings_outlined,
            size: 16,
            color: Color(0xFFE67E22),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              percent > 0
                  ? 'Save ৳${saved.toStringAsFixed(0)} • $percent% off'
                  : 'Save ৳${saved.toStringAsFixed(0)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFFE67E22),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
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

  Widget? _buildMetaLine(BuildContext context) {
    final texts = <String>[];

    final brandNameEn = _textValue(product.brandNameEn);
    if (resolved.meta.showBrand && brandNameEn.isNotEmpty) {
      texts.add(brandNameEn);
    }

    final unitLabelEn = _textValue(product.unitLabelEn);
    if (resolved.meta.showUnitLabel && unitLabelEn.isNotEmpty) {
      texts.add(unitLabelEn);
    }

    if (resolved.meta.showStockHint) {
      final qty = product.stockQty;
      if (qty > 0 && qty <= 10) {
        texts.add('Low stock');
      }
    }

    if (texts.isEmpty) {
      return null;
    }

    return Text(
      texts.join(' • '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
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
    final shortDescriptionEn = _textValue(product.shortDescriptionEn);
    if (resolved.meta.showSubtitle && shortDescriptionEn.isNotEmpty) {
      return shortDescriptionEn;
    }

    final deliveryShift = _textValue(product.deliveryShift);
    if (resolved.meta.showDeliveryHint && deliveryShift.isNotEmpty) {
      return deliveryShift;
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
