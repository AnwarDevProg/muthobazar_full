// MB Product Card - horizontal05
//
// Family:
// Horizontal
//
// Purpose:
// A softer editorial horizontal family variant with calmer spacing and lighter
// information pressure. This version is useful when the row should feel more
// curated and less transactional while still remaining practical.
//
// Footprint:
// Full-width card.
// Medium horizontal footprint.
// Must stay stable inside bounded preview containers and scrollable layouts.
//
// Visual Priority:
// 1. Product image
// 2. Product title
// 3. Subtitle / support line
// 4. Price block
// 5. Soft supporting metadata
//
// Best Use Cases:
// Softer home sections, curated rows, fresh produce lists, calmer lifestyle
// product blocks, and visually lighter mixed-product rows.
//
// Behavior Notes:
// - Softer and more breathable than horizontal01/02/03/04.
// - Keeps the row structure but lowers visual urgency.
// - Better for editorial or softer merchandising moments.
// - Gracefully handles missing subtitle, brand, and delivery data.
// - Avoids relying on unbounded Expanded/Flex behavior.

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../system/mb_card_config_resolver.dart';

class MBProductCardHorizontal05 extends StatelessWidget {
  const MBProductCardHorizontal05({
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildImageBlock(context, badge: badge),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildTitle(context),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: 5),
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
    final base = 13.0 * scale;
    return EdgeInsets.all(base.clamp(9.0, 22.0));
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
      case 'soft_glow':
        return const Color(0xFFFFD08A);
      case 'premium_outline':
        return const Color(0xFFD4A017);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Widget _buildImageBlock(BuildContext context, {Widget? badge}) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(resolved.media.imageCornerRadius),
      child: SizedBox(
        width: 102,
        height: 102,
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
                top: 6,
                left: 6,
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
        height: 1.25,
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context) {
    final finalPrice = product.salePrice ?? product.price;
    final originalPrice = product.price;
    final salePrice = product.salePrice;
    final hasDiscount = salePrice != null && salePrice < originalPrice;
    final currency = resolved.price.showCurrencySymbol ? '৳' : '';

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
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

  Widget? _buildMetaLine(BuildContext context) {
    final texts = <String>[];

    final brandNameEn = _textValue(product.brandNameEn);
    if (resolved.meta.showBrand && brandNameEn.isNotEmpty) {
      texts.add(brandNameEn);
    }

    final deliveryShift = _textValue(product.deliveryShift);
    if (resolved.meta.showDeliveryHint && deliveryShift.isNotEmpty) {
      texts.add(deliveryShift);
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
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
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

    final unitLabelEn = _textValue(product.unitLabelEn);
    if (resolved.meta.showUnitLabel && unitLabelEn.isNotEmpty) {
      return unitLabelEn;
    }

    return null;
  }

  String? _badgeText() {
    if (product.isFeatured) {
      return 'Featured';
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
      case 'badge_new_tag':
        return const Color(0xFF2563EB);
      case 'badge_best_seller':
        return const Color(0xFF7C3AED);
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
        size: 30,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}