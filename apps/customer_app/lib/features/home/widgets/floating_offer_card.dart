import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../models/home/mb_offer.dart';
import 'package:shared_ui/shared_ui.dart';

// MB Floating Offer Card
// ----------------------
// Animated promotional overlay card for Home page.

class MBFloatingOfferCard extends StatefulWidget {
  final MBOffer offer;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const MBFloatingOfferCard({
    super.key,
    required this.offer,
    required this.onClose,
    required this.onTap,
  });

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

  double _cardHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.30;
  }

  double _cardWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.80;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onClose,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(6),
          child: const Icon(
            Icons.close,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ElectricWavePainter extends CustomPainter {
  final double progress;

  _ElectricWavePainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path();

    final startX = size.width * progress;

    path.moveTo(startX - size.width * 0.5, size.height * 0.2);

    for (double x = -size.width; x < size.width; x += 10) {
      final y = math.sin((x + startX) / 30) * 10 + size.height * 0.5;
      path.lineTo(x + startX - size.width * 0.5, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ElectricWavePainter oldDelegate) {
    return true;
  }
}

