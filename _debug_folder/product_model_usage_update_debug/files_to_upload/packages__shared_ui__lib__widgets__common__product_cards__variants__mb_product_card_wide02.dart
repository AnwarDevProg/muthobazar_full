// MB Product Card - wide02
//
// Family:
// Wide
//
// Purpose:
// A cleaner image-led wide family variant with a stronger product-information
// block beneath the hero image. This version is useful when the section needs
// a full-width visual anchor that still feels practical and easy to scan.
//
// Footprint:
// Full-width card.
// Medium height.
// Intended to anchor mixed section layouts without becoming a hero banner.
//
// Visual Priority:
// 1. Product image
// 2. Product title
// 3. Price block
// 4. Subtitle / support line
// 5. Compact CTA area
//
// Best Use Cases:
// Fresh foods, home essentials, curated highlights, visual store anchors,
// and mixed product sections needing one stronger row.
//
// Behavior Notes:
// - More structured than wide01.
// - Keeps the wide family full-width image-led behavior.
// - Uses a cleaner lower info area.
// - Gracefully handles missing subtitle, sale, and brand data.
// - Avoids relying on unbounded Expanded/Flex behavior.

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../system/mb_card_config_resolver.dart';

class MBProductCardWide02 extends StatelessWidget {
  const MBProductCardWide02({
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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
    final base = 14.0 * scale;
    return EdgeInsets.all(base.clamp(10.0, 24.0));
  }

  Color _backgroundColor() {
    switch (_normalizeToken(resolved.surface.backgroundColorToken)) {
      case 'surface_soft_gray':
        return const Color(0xFFF9FAFB);
      case 'surface_promo_cream':
        return const Color(0xFFFFFBF4);
      case 'surface_soft_orange':
        return const Color(0xFFFFFAF5);
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
        blurRadius: 12 + (elevation * 2),
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
      case 'premium_outline':
        return const Color(0xFFD4A017);
      case 'soft_glow':
        return const Color(0xFFFFD08A);
      case 'deal_pulse':
        return const Color(0xFFFF7A00);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Widget _buildImageBlock(BuildContext context, {Widget? badge}) {
    final image = SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 2.1,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _ProductImage(
              imageUrl: _textValue(product.thumbnailUrl),
              fitMode: _textValue(resolved.media.imageFitMode),
              cornerRadius: resolved.media.imageCornerRadius,
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

    if (!resolved.media.showImageShadow) {
      return image;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: _subtitleColor(),
        height: 1.3,
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
    final finalPrice = product.salePrice ?? product.price;
    final originalPrice = product.price;
    final salePrice = product.salePrice;
    final hasDiscount = salePrice != null && salePrice < originalPrice;
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

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Details'),
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

  String? _badgeText() {
    if (product.isFeatured) {
      return 'Featured';
    }
    if (product.isBestSeller) {
      return 'Best';
    }
    if (product.isNewArrival) {
      return 'New';
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
      case 'badge_best_seller':
        return const Color(0xFF7C3AED);
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
      child: imageUrl.isEmpty
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
        size: 36,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}