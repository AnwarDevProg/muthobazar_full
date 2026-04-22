// MB Product Card - promo01
//
// Family:
// Promo
//
// Purpose:
// A campaign-sensitive product card that blends product presentation with
// promotional mood, seasonal styling, and stronger merchandising emphasis.
//
// Footprint:
// Full-width card.
// Medium to tall footprint.
// Designed to support campaign moments without replacing the actual product focus.
//
// Visual Priority:
// 1. Campaign / promo cue
// 2. Product image
// 3. Product title
// 4. Current price or offer line
// 5. CTA cue
//
// Best Use Cases:
// Eid offers, Ramadan specials, weekly campaigns, thematic promotions,
// curated category moments.
//
// Behavior Notes:
// - Promo styling may be stronger than standard product cards.
// - Product must still remain clearly visible and understandable.
// - Promotional text should stay short.
// - Title should clamp to 2 lines.
// - Must work safely in bounded preview containers and scrollable layouts.
// - Must degrade gracefully when campaign data is absent.
// - Avoids relying on unbounded Expanded/Flex behavior.

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../system/mb_card_config_resolver.dart';

class MBProductCardPromo01 extends StatelessWidget {
  const MBProductCardPromo01({
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
    final promoStrip = _buildPromoStrip(context);
    final badge = _buildPrimaryBadge(context);
    final subtitle = _buildSubtitle(context);
    final offerLine = _buildOfferLine(context);
    final meta = _buildBottomMeta(context);

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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ?promoStrip,
                _buildImageBlock(context, badge: badge),
                Padding(
                  padding: _contentPadding(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildTitle(context),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: 6),
                        subtitle,
                      ],
                      if (offerLine != null) ...<Widget>[
                        const SizedBox(height: 10),
                        offerLine,
                      ],
                      const SizedBox(height: 12),
                      _buildBottomRow(context),
                      if (meta != null) ...<Widget>[
                        const SizedBox(height: 8),
                        meta,
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (trailingOverlay != null)
              Positioned(
                top: 10,
                right: 10,
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
    final base = 15.0 * scale;
    return EdgeInsets.all(base.clamp(12.0, 26.0));
  }

  Color _backgroundColor() {
    switch ((resolved.surface.backgroundColorToken ?? '').trim().toLowerCase()) {
      case 'surface_promo_cream':
        return const Color(0xFFFFFBF4);
      case 'surface_soft_orange':
        return const Color(0xFFFFF7ED);
      case 'surface_soft_amber':
        return const Color(0xFFFFF9E8);
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
        color: Colors.black.withValues(alpha: 0.09),
        blurRadius: 14 + (elevation * 2),
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
        color: const Color(0xFFEFD7B4),
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
    switch (resolved.borderEffect.effectPreset.trim().toLowerCase()) {
      case 'premium_outline':
        return const Color(0xFFD4A017);
      case 'soft_glow':
        return const Color(0xFFFFD08A);
      case 'deal_pulse':
        return const Color(0xFFFF7A00);
      case 'festival_ribbon':
        return const Color(0xFFE67E22);
      default:
        return const Color(0xFFEFD7B4);
    }
  }

  Widget? _buildPromoStrip(BuildContext context) {
    if (!resolved.accent.showPromoStrip) {
      return null;
    }

    final text = _promoStripText();
    if (text.isEmpty) {
      return null;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            _promoPrimaryColor(),
            _promoSecondaryColor(),
          ],
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildImageBlock(BuildContext context, {Widget? badge}) {
    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 1.95,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _ProductImage(
              imageUrl: product.thumbnailUrl,
              fitMode: resolved.media.imageFitMode,
              cornerRadius: resolved.media.imageCornerRadius,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.02),
                    Colors.black.withValues(alpha: 0.22),
                  ],
                ),
              ),
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
                top: 12,
                left: 12,
                child: badge,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      _titleText(),
      maxLines: resolved.typography.titleMaxLines,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: _titleColor(),
        fontWeight:
        resolved.typography.titleBold ? FontWeight.w800 : FontWeight.w700,
        height: 1.16,
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
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: _subtitleColor(),
        height: 1.3,
      ),
    );
  }

  Widget? _buildOfferLine(BuildContext context) {
    final text = _offerText();
    if (text == null || text.isEmpty) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.local_offer_outlined,
            size: 15,
            color: Color(0xFFE67E22),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
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

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(child: _buildPriceBlock(context)),
        if (resolved.actions.showViewDetails || resolved.actions.showAddToCart)
          const SizedBox(width: 12),
        if (resolved.actions.showViewDetails || resolved.actions.showAddToCart)
          _buildActionButton(context),
      ],
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
          Text(
            '$currency${originalPrice.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _oldPriceColor(),
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildBottomMeta(BuildContext context) {
    final texts = <String>[];

    if (resolved.meta.showBrand && product.brandNameEn!.trim().isNotEmpty) {
      texts.add(product.brandNameEn!.trim());
    }

    if (resolved.meta.showUnitLabel && product.unitLabelEn!.trim().isNotEmpty) {
      texts.add(product.unitLabelEn!.trim());
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
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (resolved.actions.showAddToCart && !resolved.actions.showViewDetails) {
      return FilledButton(
        onPressed: onAddToCartTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Add'),
      );
    }

    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Shop now'),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

    if (resolved.meta.showBrand && product.brandNameEn!.trim().isNotEmpty) {
      return product.brandNameEn!.trim();
    }

    if (resolved.meta.showUnitLabel && product.unitLabelEn!.trim().isNotEmpty) {
      return product.unitLabelEn!.trim();
    }

    return null;
  }

  String _promoStripText() {
    if (product.isFlashSale) {
      return 'Flash campaign deal';
    }
    if (product.isFeatured) {
      return 'Curated promo pick';
    }
    return 'Special campaign offer';
  }

  String? _offerText() {
    final salePrice = product.salePrice;
    if (salePrice != null && salePrice < product.price) {
      final saved = product.price - salePrice;
      if (saved > 0) {
        return 'Save ৳${saved.toStringAsFixed(0)} on this offer';
      }
    }

    if (product.isFlashSale) {
      return 'Limited-time campaign item';
    }

    return 'Special merchandising highlight';
  }

  String? _badgeText() {
    if (product.isFlashSale) {
      return 'Flash';
    }
    if (product.isFeatured) {
      return 'Promo';
    }
    if (product.isNewArrival) {
      return 'New';
    }
    return null;
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
    switch ((resolved.typography.subtitleColorToken ?? '').trim().toLowerCase()) {
      case 'text_subtitle_soft':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
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
      case 'badge_flash_sale':
        return const Color(0xFFE53935);
      case 'badge_new_tag':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFFFF7A00);
    }
  }

  Color _promoPrimaryColor() {
    switch ((resolved.accent.themeDecorationPreset ?? '').trim().toLowerCase()) {
      case 'festive_warm':
        return const Color(0xFFE67E22);
      case 'flash_hot':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFFFF8A00);
    }
  }

  Color _promoSecondaryColor() {
    switch ((resolved.accent.themeDecorationPreset ?? '').trim().toLowerCase()) {
      case 'festive_warm':
        return const Color(0xFFFFA94D);
      case 'flash_hot':
        return const Color(0xFFFF7043);
      default:
        return const Color(0xFFFFB74D);
    }
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.fitMode,
    required this.cornerRadius,
  });

  final String imageUrl;
  final String fitMode;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final fit = _boxFit();

    return ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: imageUrl.trim().isEmpty
          ? _placeholder()
          : Image.network(
        imageUrl,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return _placeholder();
        },
      ),
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
        size: 36,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}
