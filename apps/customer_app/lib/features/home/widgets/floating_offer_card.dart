import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_models/marketing/mb_offer.dart';
import 'package:shared_ui/shared_ui.dart';

// MB Floating Offer Card
// ----------------------
// Animated floating promotional overlay card for Home page.
// Production-ready version for MuthoBazar.

class MBFloatingOfferCard extends StatefulWidget {
  const MBFloatingOfferCard({
    super.key,
    required this.offer,
    required this.onClose,
    required this.onTap,
  });

  final MBOffer offer;
  final VoidCallback onClose;
  final VoidCallback onTap;

  @override
  State<MBFloatingOfferCard> createState() => _MBFloatingOfferCardState();
}

class _MBFloatingOfferCardState extends State<MBFloatingOfferCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _cardWidth(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double targetWidth = screenWidth * 0.82;

    if (targetWidth < 260) return 260;
    if (targetWidth > 360) return 360;
    return targetWidth;
  }

  double _cardHeight(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double targetHeight = screenHeight * 0.28;

    if (targetHeight < 180) return 180;
    if (targetHeight > 260) return 260;
    return targetHeight;
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = _cardWidth(context);
    final double cardHeight = _cardHeight(context);

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: MBColors.primaryOrange.withValues(alpha: 0.16),
                            blurRadius: 30,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _BackgroundImage(
                              imageUrl: widget.offer.imageUrl,
                            ),

                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.10),
                                      Colors.black.withValues(alpha: 0.18),
                                      Colors.black.withValues(alpha: 0.56),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Positioned.fill(
                              child: CustomPaint(
                                painter: _ElectricWavePainter(
                                  progress: _controller.value,
                                ),
                              ),
                            ),

                            Positioned(
                              left: 16,
                              right: 16,
                              top: 16,
                              child: _TopBadgeRow(
                                offer: widget.offer,
                              ),
                            ),

                            Positioned(
                              left: 18,
                              right: 18,
                              bottom: 18,
                              child: _OfferTextContent(
                                offer: widget.offer,
                              ),
                            ),

                            Positioned(
                              right: 10,
                              top: 10,
                              child: _CloseButton(
                                onTap: widget.onClose,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return const _GradientFallback();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return const _GradientFallback();
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Stack(
          fit: StackFit.expand,
          children: const [
            _GradientFallback(),
            Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GradientFallback extends StatelessWidget {
  const _GradientFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: MBGradients.headerGradient,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -20,
            right: -12,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -24,
            left: -10,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBadgeRow extends StatelessWidget {
  const _TopBadgeRow({
    required this.offer,
  });

  final MBOffer offer;

  @override
  Widget build(BuildContext context) {
    final String badgeText = offer.badgeTextEn.trim().isNotEmpty
        ? offer.badgeTextEn.trim()
        : offer.discountTextEn.trim();

    if (badgeText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.24),
            ),
          ),
          child: Text(
            badgeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: MBTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _OfferTextContent extends StatelessWidget {
  const _OfferTextContent({
    required this.offer,
  });

  final MBOffer offer;

  @override
  Widget build(BuildContext context) {
    final String title = offer.titleEn.trim();
    final String subtitle = offer.subtitleEn.trim();
    final String ctaText = _buildCtaText(offer);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: MBTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        if (title.isNotEmpty) const SizedBox(height: 8),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: MBTextStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.94),
              height: 1.35,
            ),
          ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ctaText,
                style: MBTextStyles.caption.copyWith(
                  color: MBColors.primaryOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: MBColors.primaryOrange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _buildCtaText(MBOffer offer) {
    switch (offer.targetType) {
      case 'product':
        return 'View Product';
      case 'category':
        return 'Shop Category';
      case 'brand':
        return 'Explore Brand';
      case 'route':
        return 'Open';
      case 'external':
        return 'Learn More';
      default:
        return 'View Offer';
    }
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.42),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        padding: const EdgeInsets.all(7),
        child: const Icon(
          Icons.close_rounded,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ElectricWavePainter extends CustomPainter {
  _ElectricWavePainter({
    required this.progress,
  });

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    final Path path = Path();
    final double startX = size.width * progress;

    path.moveTo(startX - size.width * 0.7, size.height * 0.25);

    for (double x = -size.width; x < size.width * 1.4; x += 10) {
      final double y =
          math.sin((x + startX) / 28) * 8 + size.height * 0.52;
      path.lineTo(x + startX - size.width * 0.7, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ElectricWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}