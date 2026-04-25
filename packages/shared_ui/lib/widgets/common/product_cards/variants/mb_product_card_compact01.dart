// MuthoBazar Product Card Design System
// File: mb_product_card_compact01.dart
// Location: packages/shared_ui/lib/widgets/common/product_cards/variants/mb_product_card_compact01.dart
//
// Family:
// Compact
//
// Variant:
// compact01
//
// Purpose:
// A colorful compact product card inspired by modern promotional retail cards.
// It is designed for dense two-column product grids while still giving the
// product a strong visual identity through a diagonal accent panel, circular
// product media, a circular price badge, bottom indicator dots, and a compact
// add-to-cart call-to-action.
//
// Footprint:
// Half-width card.
// Designed for normal customer product grids where two cards appear per row.
// The card uses a stable aspect ratio so it remains predictable in admin
// previews, StorePage preview-lab sections, and customer-facing grids.
//
// Fixed visual identity:
// - Half-width footprint.
// - Diagonal top panel.
// - Large circular media area.
// - Higher title/subtitle block.
// - Savings chip near the lower side of the circular media when sale is active.
// - Bottom-left final price with optional original price.
// - Bottom-right compact Buy CTA button.
//
// Config-driven behavior:
// This widget must keep its structure fixed, but visual treatment comes from
// the resolved card config:
// - accent.accentColorToken controls the main theme/accent color.
// - typography title/subtitle/price tokens control text colors.
// - surface.borderRadius controls rounded vs square card corners.
// - surface.elevationLevel controls shadow strength.
// - borderEffect controls simple/soft-glow/electric/wave/flame-like outer line.
// - price controls final/original/savings display.
// - actions controls CTA visibility and style/color token.
// - media controls image fit/overlay behavior.
// - meta controls subtitle visibility.
// - badges primaryBadgeStyle influences price/accent styling where applicable.
//
// Best use cases:
// Grocery products, fresh items, daily essentials, offer-led grid sections,
// lightweight campaign displays, and category browsing cards that need more
// personality than a plain product tile.
//
// Behavior notes:
// - This card intentionally uses a poster-like diagonal composition, but all
//   product values are real product data.
// - If sale is active, the bottom pricing row shows the sale/final price first.
// - If enabled by price settings, original price is displayed beside the final
//   price with line-through.
// - If enabled by price settings, the savings chip is displayed near the lower
//   side of the circular image.
// - The existing dot helpers are kept for future config refinement, but this
//   tuned layout gives the bottom-left area to pricing.
// - Uses withValues(alpha: ...) instead of withOpacity().
// - Avoids unbounded Expanded/Flex usage inside the card body.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../system/mb_card_config_resolver.dart';

class MBProductCardCompact01 extends StatelessWidget {
  const MBProductCardCompact01({
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

  static const double _designWidth = 240.0;
  static const double _designHeight = 348.0;

  @override
  Widget build(BuildContext context) {
    final radius = _radius();
    final accentColor = _accentColor();
    final borderEffect = _normalizedBorderEffect();
    final content = AspectRatio(
      aspectRatio: _cardAspectRatio(),
      child: CustomPaint(
        painter: _Compact01BorderEffectPainter(
          radius: radius,
          color: _effectColor(accentColor),
          effectPreset: borderEffect,
          intensity: _effectIntensity(),
          showBorder: resolved.borderEffect.showBorder || borderEffect != 'none',
          borderWidth: _borderWidth(),
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _surfaceColor(),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: _shadows(accentColor),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: _DiagonalAccentBackground(
                  color: accentColor,
                  radius: radius,
                  background: resolved.background,
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: _contentPadding(),
                  child: _buildCardContent(context, accentColor),
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
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, Color accentColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final imageSizeRatio = resolved.media.imageSizeRatio ?? 0.72;
        final imageTopRatio = resolved.media.imageTopRatio ?? 0.305;
        final imageSize = (width * imageSizeRatio).clamp(140.0, 168.0);
        final imageTop = height * imageTopRatio;
        final imageLeft = (width - imageSize) / 2;
        const bottomHeight = 44.0;
        final saveChipTop = imageTop + imageSize - 24;
        final saveChipLeft = (imageLeft + imageSize * 0.56).clamp(
          0.0,
          width - 92.0,
        );

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTitleBlock(context),
            ),
            Positioned(
              top: imageTop,
              left: imageLeft,
              width: imageSize,
              height: imageSize,
              child: _buildCircularMedia(context, accentColor),
            ),
            if (_hasSale && resolved.price.showSavingsText)
              Positioned(
                top: saveChipTop,
                left: saveChipLeft,
                child: _buildSaveChip(context, accentColor),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottomHeight,
              child: _buildBottomBar(context, accentColor),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitleBlock(BuildContext context) {
    final title = _titleText();
    final subtitle = _subtitleText();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Compact01AutoShrinkTitle(
          text: title.toUpperCase(),
          color: _titleColor(),
          maxLines: math.max(1, math.min(2, resolved.typography.titleMaxLines)),
          baseFontSize: resolved.typography.titleFontSize ?? 14.5,
          minFontSize: resolved.typography.titleMinFontSize,
          fontWeight: resolved.typography.titleBold
              ? FontWeight.w900
              : FontWeight.w800,
        ),
        if (subtitle != null && subtitle.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: math.max(
              1,
              math.min(2, resolved.typography.subtitleMaxLines),
            ),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _subtitleColor(),
                  fontSize: resolved.typography.subtitleFontSize ?? 11.5,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  height: resolved.typography.subtitleLineHeight ?? 1.10,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveChip(BuildContext context, Color accentColor) {
    final savings = _savingsText(
      original: product.price,
      finalPrice: _finalPrice(),
    );

    if (savings.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final chipStyle = (resolved.badges.primaryBadgeStyle ?? '').trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _priceBadgeBackground(accentColor),
        borderRadius: BorderRadius.circular(999),
        border: chipStyle.isNotEmpty
            ? Border.all(
                color: accentColor.withValues(alpha: 0.18),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          savings,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _savingTextColor(accentColor),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
        ),
      ),
    );
  }

  Widget _buildCircularMedia(BuildContext context, Color accentColor) {
    final imageUrl = product.resolvedThumbnailUrl.trim().isNotEmpty
        ? product.resolvedThumbnailUrl.trim()
        : product.thumbnailUrl.trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _mediaCircleBackground(accentColor),
        boxShadow: [
          if (resolved.media.showImageShadow)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(resolved.media.imageRingThickness ?? 8),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Compact01ProductImage(
                imageUrl: imageUrl,
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
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Color accentColor) {
    final showCta = resolved.actions.showAddToCart || resolved.actions.showBuyNow;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildBottomPriceRow(context),
        ),
        if (showCta) ...[
          const SizedBox(width: 8),
          _buildCtaButton(context, accentColor),
        ],
      ],
    );
  }

  Widget _buildBottomPriceRow(BuildContext context) {
    final finalPrice = _finalPrice();
    final originalPrice = product.price;
    final currency = resolved.price.showCurrencySymbol ? '৳' : '';
    final showOriginalPrice = _hasSale && resolved.price.showsOriginalPrice;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            '$currency${finalPrice.toStringAsFixed(0)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _priceBadgeTextColor(),
                  fontSize: resolved.typography.priceFontSize ?? 18,
                  fontWeight: resolved.price.emphasizeFinalPrice
                      ? FontWeight.w900
                      : FontWeight.w800,
                  height: 1,
                ),
          ),
        ),
        if (showOriginalPrice) ...[
          const SizedBox(width: 7),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '$currency${originalPrice.toStringAsFixed(0)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: _oldPriceColor(),
                    fontSize: resolved.typography.oldPriceFontSize ?? 12,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.lineThrough,
                    height: 1,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  // Kept intentionally for the next config-refinement pass. The tuned compact01
  // layout currently uses the bottom-left zone for pricing, but the dot builder
  // remains available when we add a dedicated showIndicatorDots setting.
  Widget _buildDots(Color accentColor) {
    const dotCount = 5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(dotCount, (index) {
        final isActive = index < 3;
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(right: index == dotCount - 1 ? 0 : 7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? accentColor
                : accentColor.withValues(alpha: 0.18),
          ),
        );
      }),
    );
  }

  Widget _buildCtaButton(BuildContext context, Color accentColor) {
    final ctaStyle = (resolved.actions.ctaStylePreset ?? '').trim().toLowerCase();
    final isOutline = ctaStyle.contains('outline');
    final background = isOutline ? Colors.white : _ctaColor(accentColor);
    final foreground = isOutline ? _ctaColor(accentColor) : Colors.white;

    return SizedBox(
      height: 34,
      width: 88,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onAddToCartTap,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: isOutline
                  ? Border.all(color: _ctaColor(accentColor), width: 1.2)
                  : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _ctaLabel(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                      height: 1,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _titleText() {
    if (product.titleEn.trim().isNotEmpty) return product.titleEn.trim();
    if (product.titleBn.trim().isNotEmpty) return product.titleBn.trim();
    if (product.slug.trim().isNotEmpty) return product.slug.trim();
    return 'Title here';
  }

  String? _subtitleText() {
    if (!resolved.meta.showSubtitle &&
        !resolved.meta.showShortDescription &&
        !resolved.meta.showBrand &&
        !resolved.meta.showUnitLabel) {
      return null;
    }

    if (resolved.meta.showShortDescription &&
        product.shortDescriptionEn.trim().isNotEmpty) {
      return product.shortDescriptionEn.trim();
    }

    if (resolved.meta.showSubtitle &&
        product.shortDescriptionEn.trim().isNotEmpty) {
      return product.shortDescriptionEn.trim();
    }

    final brand = product.brandNameEn?.trim() ?? '';
    if (resolved.meta.showBrand && brand.isNotEmpty) {
      return brand;
    }

    final unit = product.unitLabelEn?.trim() ?? '';
    if (resolved.meta.showUnitLabel && unit.isNotEmpty) {
      return unit;
    }

    return null;
  }

  bool get _hasSale {
    final salePrice = product.salePrice;
    return salePrice != null &&
        salePrice > 0 &&
        product.price > 0 &&
        salePrice < product.price;
  }

  double _finalPrice() {
    if (_hasSale) return product.salePrice!;
    return product.price;
  }

  String _savingsText({
    required double original,
    required double finalPrice,
  }) {
    final saved = (original - finalPrice).clamp(0, double.infinity);
    if (saved <= 0) return '';

    final currency = resolved.price.showCurrencySymbol ? '৳' : '';
    final percent = original > 0 ? ((saved / original) * 100).round() : 0;
    final mode = resolved.price.savingsDisplayMode.trim().toLowerCase();

    if (mode == 'both' && percent > 0) {
      return 'Save $currency${saved.toStringAsFixed(0)} / $percent%';
    }

    if (mode == 'amount' || !resolved.price.showDiscountBadge || percent <= 0) {
      return 'Save $currency${saved.toStringAsFixed(0)}';
    }

    return 'Save $percent%';
  }

  double _cardAspectRatio() {
    final configured = resolved.layout.aspectRatio;
    if (configured != null && configured > 0) {
      return configured;
    }

    return _designWidth / _designHeight;
  }

  String _ctaLabel() {
    final custom = resolved.actions.ctaText?.trim();
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }

    return 'Buy';
  }

  double _radius() {
    final radius = resolved.surface.borderRadius;
    if (radius <= 0) return 0;
    return radius.clamp(0.0, 28.0);
  }

  double _borderWidth() {
    final width = resolved.borderEffect.borderWidth;
    if (width <= 0) return 1;
    return width.clamp(1.0, 4.0);
  }

  double _effectIntensity() {
    return resolved.borderEffect.effectIntensity.clamp(0.0, 1.0);
  }

  EdgeInsets _contentPadding() {
    final scale = resolved.surface.paddingScale <= 0
        ? 1.0
        : resolved.surface.paddingScale;
    final horizontal = (18.0 * scale).clamp(12.0, 22.0);
    final vertical = (12.0 * scale).clamp(8.0, 18.0);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  List<BoxShadow> _shadows(Color accentColor) {
    final elevation = resolved.surface.elevationLevel.clamp(0.0, 6.0);
    if (elevation <= 0) return const <BoxShadow>[];

    return [
      BoxShadow(
        color: accentColor.withValues(alpha: 0.10 + (elevation * 0.01)),
        blurRadius: 16 + (elevation * 2.5),
        offset: Offset(0, 7 + elevation),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10 + elevation,
        offset: const Offset(0, 4),
      ),
    ];
  }

  String _normalizedBorderEffect() {
    final raw = resolved.borderEffect.effectPreset.trim().toLowerCase();
    if (raw.isEmpty) return 'none';
    if (raw == 'soft_glow') return 'soft_glow';
    if (raw == 'electric') return 'electric';
    if (raw == 'wave') return 'wave';
    if (raw == 'fire' || raw == 'flame') return 'flame';
    if (raw == 'simple') return 'simple';
    return raw;
  }

  Color _surfaceColor() {
    final token = (resolved.surface.backgroundColorToken ?? '').trim().toLowerCase();

    switch (token) {
      case 'surface_soft_orange':
        return const Color(0xFFFFF4E8);
      case 'surface_premium_dark':
        return const Color(0xFF111827);
      case 'surface_soft_gray':
        return const Color(0xFFF8FAFC);
      case 'surface_promo_cream':
        return const Color(0xFFFFF7ED);
      case 'surface_default_white':
      default:
        return Colors.white;
    }
  }

  Color _accentColor() {
    final token = (resolved.accent.accentColorToken ?? '').trim().toLowerCase();

    switch (token) {
      case 'accent_teal':
      case 'accent_turquoise':
      case 'accent_cyan':
        return const Color(0xFF12B9C5);
      case 'accent_pink':
      case 'accent_rose':
        return const Color(0xFFFF86A0);
      case 'accent_red_hot':
      case 'accent_flash_red':
        return const Color(0xFFFF4D4D);
      case 'accent_gold_premium':
        return const Color(0xFFD99A18);
      case 'accent_blue':
      case 'accent_navy':
        return const Color(0xFF0D5C8C);
      case 'accent_green':
        return const Color(0xFF16A34A);
      case 'accent_orange_primary':
      case 'accent_orange_soft':
      default:
        return const Color(0xFFFF9700);
    }
  }

  Color _titleColor() {
    final token = (resolved.typography.titleColorToken ?? '').trim().toLowerCase();

    switch (token) {
      case 'text_title_inverse':
        return Colors.white;
      case 'text_title_primary':
      default:
        return const Color(0xFF064E75);
    }
  }

  Color _subtitleColor() {
    final token = (resolved.typography.subtitleColorToken ?? '').trim().toLowerCase();

    switch (token) {
      case 'text_subtitle_inverse':
        return Colors.white.withValues(alpha: 0.92);
      case 'text_subtitle_muted':
      default:
        return Colors.white.withValues(alpha: 0.88);
    }
  }

  Color _priceBadgeBackground(Color accentColor) {
    final style = (resolved.badges.primaryBadgeStyle ?? '').trim().toLowerCase();

    switch (style) {
      case 'badge_flash_sale':
      case 'hot_deal':
        return const Color(0xFFFFE1D8);
      case 'badge_premium_tag':
        return const Color(0xFFFFF2CC);
      case 'badge_new_tag':
        return const Color(0xFFE0F2FE);
      default:
        return const Color(0xFFFFE4DA);
    }
  }

  Color _priceBadgeTextColor() {
    final token = (resolved.typography.priceColorToken ?? '').trim().toLowerCase();

    switch (token) {
      case 'text_price_inverse':
        return Colors.white;
      case 'text_price_primary':
      default:
        return const Color(0xFF064E75);
    }
  }

  Color _oldPriceColor() {
    final token = (resolved.typography.oldPriceColorToken ?? '').trim().toLowerCase();

    switch (token) {
      case 'text_old_price_dark':
        return const Color(0xFF374151);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _savingTextColor(Color accentColor) {
    return accentColor;
  }

  Color _mediaCircleBackground(Color accentColor) {
    return Color.lerp(Colors.white, accentColor, 0.16) ?? Colors.white;
  }

  Color _ctaColor(Color accentColor) {
    final token = (resolved.actions.ctaColorToken ?? '').trim().toLowerCase();

    switch (token) {
      case 'cta_orange':
      case 'accent_orange_primary':
        return const Color(0xFFF97316);
      case 'cta_teal':
      case 'accent_teal':
        return const Color(0xFF0EA5A8);
      case 'cta_pink':
      case 'accent_pink':
        return const Color(0xFFEC4899);
      case 'cta_red':
      case 'accent_red_hot':
        return const Color(0xFFEF4444);
      case 'cta_navy':
      default:
        return const Color(0xFF075985);
    }
  }

  Color _effectColor(Color accentColor) {
    final token = (resolved.borderEffect.borderColorToken ?? '').trim().toLowerCase();

    switch (token) {
      case 'border_flash_red':
        return const Color(0xFFEF4444);
      case 'border_premium_gold':
        return const Color(0xFFD4A017);
      case 'border_electric_blue':
        return const Color(0xFF2563EB);
      case 'border_orange_line':
        return const Color(0xFFFF7A00);
      case 'border_soft_line':
        return const Color(0xFFE5E7EB);
      default:
        return accentColor;
    }
  }
}


class _Compact01AutoShrinkTitle extends StatelessWidget {
  const _Compact01AutoShrinkTitle({
    required this.text,
    required this.color,
    required this.maxLines,
    required this.baseFontSize,
    required this.minFontSize,
    required this.fontWeight,
  });

  final String text;
  final Color color;
  final int maxLines;
  final double baseFontSize;
  final double minFontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = _bestFontSize(context, constraints.maxWidth);
        final style = Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.2,
                  height: 0.98,
                ) ??
            TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.2,
              height: 0.98,
            );

        return Text(
          text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: style,
        );
      },
    );
  }

  double _bestFontSize(BuildContext context, double maxWidth) {
    if (maxWidth <= 0) return minFontSize;

    for (double size = baseFontSize; size >= minFontSize; size -= 0.5) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: size,
            fontWeight: fontWeight,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.2,
            height: 0.98,
          ),
        ),
        maxLines: maxLines,
        textDirection: Directionality.of(context),
      )..layout(maxWidth: maxWidth);

      if (!painter.didExceedMaxLines) {
        return size;
      }
    }

    return minFontSize;
  }
}

class _DiagonalAccentBackground extends StatelessWidget {
  const _DiagonalAccentBackground({
    required this.color,
    required this.radius,
    required this.background,
  });

  final Color color;
  final double radius;
  final MBCardBackgroundSettings background;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DiagonalAccentPainter(
        color: color,
        radius: radius,
        background: background,
      ),
    );
  }
}

class _DiagonalAccentPainter extends CustomPainter {
  const _DiagonalAccentPainter({
    required this.color,
    required this.radius,
    required this.background,
  });

  final Color color;
  final double radius;
  final MBCardBackgroundSettings background;

  @override
  void paint(Canvas canvas, Size size) {
    final accentPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          Color.lerp(color, Colors.white, 0.18) ?? color,
        ],
      ).createShader(Offset.zero & size);

    final whitePaint = Paint()..color = Colors.white;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ),
      whitePaint,
    );

    final rightRatio = background.diagonalEndRatio ?? 0.38;
    final leftRatio = background.diagonalStartRatio ?? 0.58;
    final curveControlRatio = background.panelHeightRatio ?? 0.46;

    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * rightRatio)
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * curveControlRatio,
        size.width * 0.49,
        size.height * (curveControlRatio - 0.02),
      )
      ..lineTo(0, size.height * leftRatio)
      ..close();

    canvas.drawPath(topPath, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _DiagonalAccentPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius || oldDelegate.background != background;
  }
}

class _Compact01ProductImage extends StatelessWidget {
  const _Compact01ProductImage({
    required this.imageUrl,
    required this.fitMode,
  });

  final String imageUrl;
  final String fitMode;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return _placeholder(context);
    }

    return Image.network(
      imageUrl,
      fit: _boxFit(),
      errorBuilder: (_, __, ___) => _placeholder(context),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder(context);
      },
    );
  }

  BoxFit _boxFit() {
    switch (fitMode.trim().toLowerCase()) {
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'cover':
      default:
        return BoxFit.cover;
    }
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 34,
      ),
    );
  }
}

class _Compact01BorderEffectPainter extends CustomPainter {
  const _Compact01BorderEffectPainter({
    required this.radius,
    required this.color,
    required this.effectPreset,
    required this.intensity,
    required this.showBorder,
    required this.borderWidth,
  });

  final double radius;
  final Color color;
  final String effectPreset;
  final double intensity;
  final bool showBorder;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (!showBorder) return;

    final rect = Offset.zero & size;
    final inset = math.max(1.0, borderWidth);
    final rounded = RRect.fromRectAndRadius(
      rect.deflate(inset / 2),
      Radius.circular(radius),
    );

    final normalized = effectPreset.trim().toLowerCase();

    if (normalized == 'soft_glow' ||
        normalized == 'electric' ||
        normalized == 'flame' ||
        normalized == 'fire') {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth + (4 * intensity.clamp(0.25, 1.0))
        ..color = color.withValues(alpha: 0.16 + (0.18 * intensity))
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          5 + (8 * intensity),
        );

      canvas.drawRRect(rounded, glowPaint);
    }

    if (normalized == 'wave') {
      _drawWaveBorder(canvas, size);
      return;
    }

    if (normalized == 'electric') {
      _drawElectricBorder(canvas, rounded);
      return;
    }

    if (normalized == 'flame' || normalized == 'fire') {
      _drawFlameBorder(canvas, rounded);
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = color.withValues(alpha: normalized == 'none' ? 0.24 : 0.70);

    canvas.drawRRect(rounded, paint);
  }

  void _drawWaveBorder(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = color.withValues(alpha: 0.78);

    final inset = borderWidth + 1;
    final left = inset;
    final right = size.width - inset;
    final top = inset;
    final bottom = size.height - inset;
    const step = 10.0;
    final amp = 2.5 + (2.5 * intensity);

    final path = Path()..moveTo(left, top + amp);

    for (double x = left; x <= right; x += step) {
      path.lineTo(x, top + amp + math.sin(x / step) * amp);
    }
    for (double y = top; y <= bottom; y += step) {
      path.lineTo(right - amp + math.sin(y / step) * amp, y);
    }
    for (double x = right; x >= left; x -= step) {
      path.lineTo(x, bottom - amp + math.sin(x / step) * amp);
    }
    for (double y = bottom; y >= top; y -= step) {
      path.lineTo(left + amp + math.sin(y / step) * amp, y);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawElectricBorder(Canvas canvas, RRect rounded) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = color.withValues(alpha: 0.88);

    canvas.drawRRect(rounded, paint);

    final sparkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, borderWidth * 0.75)
      ..color = Colors.white.withValues(alpha: 0.80);

    final rect = rounded.outerRect.deflate(5);
    final path = Path()
      ..moveTo(rect.left + 16, rect.top)
      ..lineTo(rect.left + 28, rect.top + 7)
      ..lineTo(rect.left + 42, rect.top)
      ..moveTo(rect.right - 48, rect.bottom)
      ..lineTo(rect.right - 34, rect.bottom - 8)
      ..lineTo(rect.right - 20, rect.bottom);

    canvas.drawPath(path, sparkPaint);
  }

  void _drawFlameBorder(Canvas canvas, RRect rounded) {
    final orangePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + 1
      ..color = const Color(0xFFFF7A00).withValues(alpha: 0.76);

    final redPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, borderWidth * 0.75)
      ..color = const Color(0xFFFF3B30).withValues(alpha: 0.70);

    canvas.drawRRect(rounded, orangePaint);
    canvas.drawRRect(rounded.deflate(2), redPaint);
  }

  @override
  bool shouldRepaint(covariant _Compact01BorderEffectPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.color != color ||
        oldDelegate.effectPreset != effectPreset ||
        oldDelegate.intensity != intensity ||
        oldDelegate.showBorder != showBorder ||
        oldDelegate.borderWidth != borderWidth;
  }
}
