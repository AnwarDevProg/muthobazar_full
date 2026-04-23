// MB Product Card - flash04
//
// Family:
// FlashSale
//
// Purpose:
// A hotter, timer-inspired flash-sale family variant that feels more urgent
// and more event-like than flash01/02/03 without requiring a real countdown.
//
// Footprint:
// Half-width card.
// Medium height.
// Designed for high-energy 2-column deal grids.
//
// Visual Priority:
// 1. Hot-sale strip
// 2. Final price
// 3. Product title
// 4. Urgency pill / stock cue
// 5. CTA
//
// Best Use Cases:
// Peak campaign windows, hot-sale collections, limited-time baskets,
// and denser sale walls.
//
// Behavior Notes:
// - Hottest variant of the first Flash batch.
// - Still data-safe without a live countdown timer.
// - Strongest urgency tone before moving into future advanced variants.
// - Gracefully handles missing sale and stock data.
// - Avoids relying on unbounded Expanded/Flex behavior.

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../system/mb_card_config_resolver.dart';

class MBProductCardFlash04 extends StatelessWidget {
  const MBProductCardFlash04({
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
    final hotStrip = _buildHotStrip(context);
    final badge = _buildPrimaryBadge(context);
    final subtitle = _buildSubtitle(context);
    final hotPill = _buildHotPill(context);

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
                if (hotStrip != null) hotStrip,
                Padding(
                  padding: _contentPadding(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildImageBlock(context, badge: badge),
                      const SizedBox(height: 10),
                      _buildPriceRow(context),
                      const SizedBox(height: 10),
                      _buildTitle(context),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: 4),
                        subtitle,
                      ],
                      if (hotPill != null) ...<Widget>[
                        const SizedBox(height: 8),
                        hotPill,
                      ],
                      if (resolved.actions.showAddToCart) ...<Widget>[
                        const SizedBox(height: 10),
                        _buildAddButton(context),
                      ],
                    ],
                  ),
                ),
              ],
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

    if (onTap == null) return body;

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

  Color _backgroundColor() {
    switch (_normalizeToken(resolved.surface.backgroundColorToken)) {
      case 'surface_flash_tint':
        return const Color(0xFFFFFAF7);
      case 'surface_soft_orange':
        return const Color(0xFFFFF7ED);
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

  Border _buildBorder() {
    if (!resolved.borderEffect.showBorder) {
      return Border.all(
        color: const Color(0xFFFFD3C4),
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
        return const Color(0xFFFF6A00);
      case 'fire':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFFFFD3C4);
    }
  }

  Widget? _buildHotStrip(BuildContext context) {
    final text = _hotStripText();
    if (text == null || text.isEmpty) return null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xFFB71C1C),
            Color(0xFFE53935),
          ],
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.local_fire_department,
            size: 15,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBlock(BuildContext context, {Widget? badge}) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(resolved.media.imageCornerRadius),
      child: AspectRatio(
        aspectRatio: 1.03,
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
                left: 8,
                child: badge,
              ),
          ],
        ),
      ),
    );

    if (!resolved.media.showImageShadow) return image;

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

  Widget _buildPriceRow(BuildContext context) {
    final finalPrice = product.salePrice ?? product.price;
    final originalPrice = product.price;
    final sale = product.salePrice;
    final hasDiscount = sale != null && sale < originalPrice;
    final currency = resolved.price.showCurrencySymbol ? '৳' : '';

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          '$currency${finalPrice.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _priceColor(),
            fontWeight: FontWeight.w800,
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

  Widget _buildTitle(BuildContext context) {
    return Text(
      _titleText(),
      maxLines: resolved.typography.titleMaxLines,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: _titleColor(),
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final text = _subtitleText();
    if (text == null || text.isEmpty) return null;

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

  Widget? _buildHotPill(BuildContext context) {
    final text = _hotPillText();
    if (text == null || text.isEmpty) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.bolt,
            size: 14,
            color: Color(0xFFE67E22),
          ),
          const SizedBox(width: 6),
          Flexible(
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

  Widget? _buildPrimaryBadge(BuildContext context) {
    if (!resolved.badges.showPrimaryBadge) return null;

    final text = _badgeText();
    if (text == null || text.isEmpty) return null;

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
    if (titleEn.isNotEmpty) return titleEn;
    final titleBn = _textValue(product.titleBn);
    if (titleBn.isNotEmpty) return titleBn;
    final slug = _textValue(product.slug);
    if (slug.isNotEmpty) return slug;
    return 'Untitled product';
  }

  String? _subtitleText() {
    final shortDescriptionEn = _textValue(product.shortDescriptionEn);
    if (resolved.meta.showSubtitle && shortDescriptionEn.isNotEmpty) {
      return shortDescriptionEn;
    }
    return null;
  }

  String? _hotStripText() {
    if (product.isFlashSale) return 'Hot sale is live now';
    return 'High-urgency deal';
  }

  String? _hotPillText() {
    final qty = product.stockQty;
    if (qty > 0 && qty <= 5) return 'Only a few left';
    if (qty > 5 && qty <= 10) return 'Selling very fast';
    if (product.isFlashSale) return 'Deal ending soon';
    return null;
  }

  String? _badgeText() {
    final sale = product.salePrice;
    if (sale != null && sale < product.price) {
      final percent = (((product.price - sale) / product.price) * 100).round();
      if (percent > 0) return '-$percent%';
    }
    if (product.isFlashSale) return 'Hot';
    return null;
  }

  Color _titleColor() => const Color(0xFF111827);
  Color _subtitleColor() => const Color(0xFF6B7280);
  Color _priceColor() => const Color(0xFF111827);
  Color _oldPriceColor() => const Color(0xFF9CA3AF);

  Color _badgeBackgroundColor() {
    switch (_normalizeToken(resolved.badges.primaryBadgeStyle)) {
      case 'badge_flash_sale':
        return const Color(0xFFE53935);
      case 'badge_hot_deal':
        return const Color(0xFFFF6A00);
      default:
        return const Color(0xFFE53935);
    }
  }

  String _normalizeToken(String? raw) => _textValue(raw).toLowerCase();

  String _textValue(Object? raw) {
    if (raw == null) return '';
    if (raw is String) return raw.trim();
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
    if (imageUrl.isEmpty) return _placeholder();

    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
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