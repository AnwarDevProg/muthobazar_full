import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../elements/mb_design_badge_element.dart';
import '../elements/mb_design_cta_element.dart';
import '../elements/mb_design_indicator_dots_element.dart';
import '../elements/mb_design_media_element.dart';
import '../elements/mb_design_price_element.dart';
import '../elements/mb_design_text_element.dart';
import '../mb_design_card_context.dart';
import '../mb_design_card_defaults.dart';
import '../positioning/mb_design_positioned_element.dart';

// MuthoBazar Design Card Engine V1
// File: hero_poster_circle_diagonal_v1.dart
//
// Purpose:
// First new design-family template.
//
// Family:
// hero_poster_circle
//
// Template:
// hero_poster_circle_diagonal_v1
//
// This version is position-aware:
// - element.position.mode == slot uses named zones
// - element.position.mode == free uses normalized x/y
// - element.position.z controls layer order

class MBHeroPosterCircleDiagonalV1 extends StatelessWidget {
  const MBHeroPosterCircleDiagonalV1({
    super.key,
    required this.contextData,
  });

  final MBDesignCardContext contextData;

  @override
  Widget build(BuildContext context) {
    final config = contextData.config;
    final layout = config.layout ??
        MBCardDesignRegistry.defaultLayoutForTemplate(
          MBCardDesignRegistry.heroPosterCircleDiagonalV1,
        );

    final aspectRatio = layout.aspectRatio ?? 0.56;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 220.0;

        final estimatedHeight = layout.preferredHeight ?? (width / aspectRatio);
        final height = estimatedHeight
            .clamp(layout.minHeight ?? 430, layout.maxHeight ?? 520)
            .toDouble();

        return GestureDetector(
          onTap: contextData.onTap,
          child: SizedBox(
            width: width,
            height: height,
            child: _HeroPosterCardBody(
              contextData: contextData,
              width: width,
              height: height,
            ),
          ),
        );
      },
    );
  }
}

class _HeroPosterCardBody extends StatelessWidget {
  const _HeroPosterCardBody({
    required this.contextData,
    required this.width,
    required this.height,
  });

  final MBDesignCardContext contextData;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final elements = _ResolvedHeroElements(contextData.config);

    final layers = <_HeroLayer>[
      _HeroLayer(
        element: elements.ribbon,
        fallbackSlot: 'topLeftOverlay',
        child: _SoftRibbonChip(
          text: contextData.resolveBinding(elements.ribbon),
        ),
      ),
      _HeroLayer(
        element: elements.priceBadge,
        fallbackSlot: 'topRightOverlay',
        child: _PriceBubble(
          text: contextData.finalPriceText,
        ),
      ),
      _HeroLayer(
        element: elements.brand,
        fallbackSlot: 'topTextStart',
        child: _MiniLabel(
          text: contextData.brandName.toUpperCase(),
          color: Colors.white.withValues(alpha: 0.92),
          background: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      _HeroLayer(
        element: elements.categoryChip,
        fallbackSlot: 'belowBrand',
        child: _MiniLabel(
          text: contextData.categoryName,
          color: const Color(0xFFFF7A00),
          background: Colors.white,
          borderColor: Colors.white.withValues(alpha: 0.34),
        ),
      ),
      _HeroLayer(
        element: elements.wishlistButton,
        fallbackSlot: 'actionTop1',
        child: _RoundIconButton(
          icon: Icons.favorite_border_rounded,
          onTap: contextData.onTap,
        ),
      ),
      _HeroLayer(
        element: elements.compareButton,
        fallbackSlot: 'actionTop2',
        child: _RoundIconButton(
          icon: Icons.compare_arrows_rounded,
          onTap: contextData.onTap,
        ),
      ),
      _HeroLayer(
        element: elements.shareButton,
        fallbackSlot: 'actionTop3',
        child: _RoundIconButton(
          icon: Icons.share_outlined,
          onTap: contextData.onTap,
        ),
      ),
      _HeroLayer(
        element: elements.title,
        fallbackSlot: 'bodyTitle',
        width: width * 0.68,
        child: MBDesignTextElement(
          text: contextData.title,
          element: elements.title,
          maxLines: 2,
          defaultStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            height: 1.0,
          ),
        ),
      ),
      _HeroLayer(
        element: elements.subtitle,
        fallbackSlot: 'bodySubtitle',
        width: width * 0.62,
        child: MBDesignTextElement(
          text: contextData.subtitle,
          element: elements.subtitle,
          maxLines: 3,
          defaultStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.90),
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            height: 1.18,
          ),
        ),
      ),
      _HeroLayer(
        element: elements.media,
        fallbackSlot: 'centerHero',
        width: 150,
        height: 150,
        child: _MediaCluster(
          contextData: contextData,
          elements: elements,
        ),
      ),
      _HeroLayer(
        element: elements.rating,
        fallbackSlot: 'metaLine1',
        child: _StarRating(
          rating: contextData.ratingValue,
        ),
      ),
      _HeroLayer(
        element: elements.reviewCount,
        fallbackSlot: 'metaLine1Right',
        child: Text(
          contextData.reviewCountText,
          style: TextStyle(
            color: const Color(0xFF6C6C6C).withValues(alpha: 0.90),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      _HeroLayer(
        element: elements.stockHint,
        fallbackSlot: 'metaLine2Left',
        width: width * 0.42,
        child: _SoftInfoChip(
          icon: Icons.inventory_2_outlined,
          text: contextData.stockHint,
          foreground: const Color(0xFF0B7C43),
          background: const Color(0xFFE7F7ED),
        ),
      ),
      _HeroLayer(
        element: elements.deliveryHint,
        fallbackSlot: 'metaLine2Right',
        width: width * 0.42,
        child: _SoftInfoChip(
          icon: Icons.local_shipping_outlined,
          text: contextData.deliveryHint,
          foreground: const Color(0xFF1565C0),
          background: const Color(0xFFE7F0FF),
        ),
      ),
      _HeroLayer(
        element: elements.timer,
        fallbackSlot: 'metaLine3Left',
        child: _SoftInfoChip(
          icon: Icons.timer_outlined,
          text: contextData.timerText,
          foreground: const Color(0xFFB55A00),
          background: const Color(0xFFFFF2DE),
        ),
      ),
      _HeroLayer(
        element: elements.progressBar,
        fallbackSlot: 'metaLine3Right',
        width: width * 0.48,
        child: _ProgressInfoBar(
          value: contextData.progressValue,
        ),
      ),
      _HeroLayer(
        element: elements.finalPrice,
        fallbackSlot: 'priceRowStart',
        width: width * 0.44,
        child: MBDesignPriceElement(
          finalPriceText: contextData.finalPriceText,
          originalPriceText: elements.isVisible(elements.originalPrice)
              ? contextData.originalPriceText
              : null,
          finalPriceElement: elements.finalPrice,
          originalPriceElement: elements.originalPrice,
        ),
      ),
      _HeroLayer(
        element: elements.unitLabel,
        fallbackSlot: 'priceRowEnd',
        child: Text(
          contextData.unitLabel,
          style: const TextStyle(
            color: Color(0xFF7A7A7A),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      _HeroLayer(
        element: elements.savingBadge,
        fallbackSlot: 'priceRowBadge',
        child: MBDesignBadgeElement(
          text: contextData.savingText ?? '',
          element: elements.savingBadge,
        ),
      ),
      _HeroLayer(
        element: elements.indicatorDots,
        fallbackSlot: 'bottomLeftSecondary',
        child: MBDesignIndicatorDotsElement(
          element: elements.indicatorDots,
        ),
      ),
      _HeroLayer(
        element: elements.secondaryCta,
        fallbackSlot: 'bottomRightSecondary',
        width: width * 0.30,
        child: MBDesignCtaElement(
          text: 'Buy',
          element: elements.secondaryCta,
          onTap: contextData.onSecondaryCtaTap,
        ),
      ),
      _HeroLayer(
        element: elements.primaryCta,
        fallbackSlot: 'bottomRightMain',
        width: width * 0.46,
        child: MBDesignCtaElement(
          text: 'Add',
          element: elements.primaryCta,
          onTap: contextData.onPrimaryCtaTap,
        ),
      ),
    ];

    layers.sort((a, b) {
      final az = MBDesignPositionedElement.zOf(a.element);
      final bz = MBDesignPositionedElement.zOf(b.element);
      return az.compareTo(bz);
    });

    return Container(
      decoration: BoxDecoration(
        color: MBDesignCardDefaults.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFFF8E24).withValues(alpha: 0.20),
          width: 1.15,
        ),
        boxShadow: MBDesignCardDefaults.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(
              child: _DiagonalPanelBackground(),
            ),
            for (final layer in layers) layer.build(),
          ],
        ),
      ),
    );
  }
}

class _HeroLayer {
  const _HeroLayer({
    required this.element,
    required this.fallbackSlot,
    required this.child,
    this.width,
    this.height,
  });

  final MBCardElementConfig? element;
  final String fallbackSlot;
  final Widget child;
  final double? width;
  final double? height;

  Widget build() {
    return MBDesignPositionedElement(
      element: element,
      fallbackSlot: fallbackSlot,
      width: width,
      height: height,
      child: child,
    );
  }
}

class _MediaCluster extends StatelessWidget {
  const _MediaCluster({
    required this.contextData,
    required this.elements,
  });

  final MBDesignCardContext contextData;
  final _ResolvedHeroElements elements;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (elements.isVisible(elements.imageFrame))
          Container(
            width: 146,
            height: 146,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.42),
            ),
          ),
        if (elements.isVisible(elements.imageFrame))
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFF3E3),
              border: Border.all(
                color: Colors.white,
                width: 5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
        MBDesignMediaElement(
          imageUrl: contextData.imageUrl,
          element: elements.media,
          size: 120,
        ),
        if (elements.isVisible(elements.promoBadge))
          Positioned(
            left: 6,
            bottom: 20,
            child: _SmallAccentChip(
              text: contextData.promoText,
              background: const LinearGradient(
                colors: [
                  Color(0xFFFFF0D5),
                  Color(0xFFFFE1BE),
                ],
              ),
              foreground: const Color(0xFFBE5D00),
            ),
          ),
        if (elements.isVisible(elements.imageOverlay))
          Positioned(
            right: 0,
            bottom: 14,
            child: MBDesignBadgeElement(
              text: contextData.savingText ?? '',
              element: elements.imageOverlay,
            ),
          ),
        if (elements.isVisible(elements.flashBadge))
          Positioned(
            right: 12,
            top: 14,
            child: _SmallAccentChip(
              text: contextData.flashText,
              background: const LinearGradient(
                colors: [
                  Color(0xFFFFC7C7),
                  Color(0xFFFF9D9D),
                ],
              ),
              foreground: const Color(0xFFB12A2A),
            ),
          ),
      ],
    );
  }
}

class _DiagonalPanelBackground extends StatelessWidget {
  const _DiagonalPanelBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DiagonalPanelPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _DiagonalPanelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final panelPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFA53A),
          Color(0xFFFF7400),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.70),
      );

    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.36)
      ..lineTo(size.width * 0.62, size.height * 0.44)
      ..lineTo(0, size.height * 0.56)
      ..close();

    canvas.drawPath(topPath, panelPaint);

    final accentPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14);

    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.10),
      size.width * 0.32,
      accentPaint,
    );

    final secondaryAccentPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08);

    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.22),
      size.width * 0.20,
      secondaryAccentPaint,
    );

    final lowerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFBF6),
          Color(0xFFFFF4E8),
        ],
      ).createShader(
        Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.55),
      );

    final lowerPath = Path()
      ..moveTo(0, size.height * 0.56)
      ..lineTo(size.width * 0.62, size.height * 0.44)
      ..lineTo(size.width, size.height * 0.36)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(lowerPath, lowerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SoftRibbonChip extends StatelessWidget {
  const _SoftRibbonChip({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final label = text.trim().isEmpty ? 'New' : text.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF404040),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PriceBubble extends StatelessWidget {
  const _PriceBubble({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFE1CF),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.90),
          width: 3,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF0D4C7A),
          fontSize: 14,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  const _MiniLabel({
    required this.text,
    required this.color,
    required this.background,
    this.borderColor,
  });

  final String text;
  final Color color;
  final Color background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: borderColor == null
            ? null
            : Border.all(
                color: borderColor!,
              ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 15,
        color: const Color(0xFFFF7A00),
      ),
    );

    if (onTap == null) return child;

    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }
}

class _SmallAccentChip extends StatelessWidget {
  const _SmallAccentChip({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Gradient background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          text,
          style: TextStyle(
            color: foreground,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({
    required this.rating,
  });

  final double rating;

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor().clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 5; index++)
          Icon(
            index < fullStars ? Icons.star_rounded : Icons.star_border_rounded,
            size: 15,
            color: const Color(0xFFFFB300),
          ),
      ],
    );
  }
}

class _SoftInfoChip extends StatelessWidget {
  const _SoftInfoChip({
    required this.icon,
    required this.text,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final String text;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: foreground,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressInfoBar extends StatelessWidget {
  const _ProgressInfoBar({
    required this.value,
  });

  final double value;

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sold ${(normalized * 100).round()}%',
          style: const TextStyle(
            color: Color(0xFF727272),
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: normalized,
            minHeight: 7,
            backgroundColor: const Color(0xFFFFD8BF),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFFFF7A00),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResolvedHeroElements {
  _ResolvedHeroElements(MBCardDesignConfig config)
      : defaults = MBCardDesignRegistry.defaultElementsForTemplate(
          MBCardDesignRegistry.heroPosterCircleDiagonalV1,
        ),
        overrides = config.elements;

  final Map<String, MBCardElementConfig> defaults;
  final Map<String, MBCardElementConfig> overrides;

  MBCardElementConfig? _get(String id) => overrides[id] ?? defaults[id];

  bool isVisible(MBCardElementConfig? element) => element?.visible ?? true;

  MBCardElementConfig? get ribbon => _get('ribbon');
  MBCardElementConfig? get priceBadge => _get('priceBadge');
  MBCardElementConfig? get brand => _get('brand');
  MBCardElementConfig? get categoryChip => _get('categoryChip');
  MBCardElementConfig? get wishlistButton => _get('wishlistButton');
  MBCardElementConfig? get compareButton => _get('compareButton');
  MBCardElementConfig? get shareButton => _get('shareButton');
  MBCardElementConfig? get title => _get('title');
  MBCardElementConfig? get subtitle => _get('subtitle');
  MBCardElementConfig? get media => _get('media');
  MBCardElementConfig? get imageFrame => _get('imageFrame');
  MBCardElementConfig? get imageOverlay => _get('imageOverlay');
  MBCardElementConfig? get promoBadge => _get('promoBadge');
  MBCardElementConfig? get flashBadge => _get('flashBadge');
  MBCardElementConfig? get rating => _get('rating');
  MBCardElementConfig? get reviewCount => _get('reviewCount');
  MBCardElementConfig? get stockHint => _get('stockHint');
  MBCardElementConfig? get deliveryHint => _get('deliveryHint');
  MBCardElementConfig? get timer => _get('timer');
  MBCardElementConfig? get progressBar => _get('progressBar');
  MBCardElementConfig? get finalPrice => _get('finalPrice');
  MBCardElementConfig? get originalPrice => _get('originalPrice');
  MBCardElementConfig? get unitLabel => _get('unitLabel');
  MBCardElementConfig? get savingBadge => _get('savingBadge');
  MBCardElementConfig? get secondaryCta => _get('secondaryCta');
  MBCardElementConfig? get primaryCta => _get('primaryCta');
  MBCardElementConfig? get indicatorDots => _get('indicatorDots');
}
