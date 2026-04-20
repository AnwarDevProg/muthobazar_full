import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/mb_colors.dart';

class MBBottomNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const MBBottomNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

class MBBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final List<MBBottomNavItem> items;
  final ValueChanged<int> onTap;

  const MBBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  }) : assert(items.length >= 2 && items.length <= 5);

  @override
  State<MBBottomNavBar> createState() => _MBBottomNavBarState();
}

class _MBBottomNavBarState extends State<MBBottomNavBar>
    with SingleTickerProviderStateMixin {
  // Manual tuning block ------------------------------------------------------
  // 1) Bottom spacing:
  static const double _slotBottomPadding = 0;
  static const double _barBodyBottomPadding = 0;

  // 2) Main sizing:
  static const double _bubbleSize = 50;
  static const double _iconSize = 23;
  static const double _labelFontSize = 11;
  static const double _labelBoxHeight = 10;

  // 3) Gaps:
  static const double _iconLabelGap = 1;
  static const double _selectedClusterGap = 3;
  static const double _selectedLabelBottomPadding = 0;

  // 4) Bar layout:
  static const double _topFloatingSpace = 20;
  static const double _barBodyHeight = 50;
  static const double _barHorizontalPadding = 6;
  static const double _barTopPadding = 11;

  // 5) Floating animation:
  static const double _selectedFloatAmplitude = 1.8;

  // 6) Bubble inner ratio from bubble size:
  static const double _innerCircleRatio = 0.76;
  static const double _selectedIconRatio = 0.54;

  // 7) Wave visibility / strength:
  static const double _waveAmplitudeFactor = 0.080;
  static const double _wavePrimaryStrokeWidth = 2.6;
  static const double _waveGlowStrokeWidth = 10;
  static const double _waveSecondaryStrokeWidth = 1.8;
  static const double _wavePrimaryOpacity = 0.92;
  static const double _waveSecondaryOpacity = 0.68;
  static const double _waveGlowOpacity = 0.34;
  // -------------------------------------------------------------------------

  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final totalHeight = _topFloatingSpace + _barBodyHeight + bottomInset;
    final slotWidth = MediaQuery.sizeOf(context).width / widget.items.length;
    final selectedItem = widget.items[widget.currentIndex];
    final innerIconCircleSize = _bubbleSize * _innerCircleRatio;
    final selectedIconSize = _bubbleSize * _selectedIconRatio;

    return SizedBox(
      width: double.infinity,
      height: totalHeight,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, _) {
          final progress = _waveController.value;
          final floatOffset =
              math.sin(progress * math.pi * 2) * _selectedFloatAmplitude;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: _barBodyHeight + bottomInset,
                  padding: EdgeInsets.only(
                    left: _barHorizontalPadding,
                    right: _barHorizontalPadding,
                    top: _barTopPadding,
                    bottom: bottomInset + _barBodyBottomPadding,
                  ),
                  decoration: BoxDecoration(
                    color: MBColors.surface,
                    border: Border(
                      top: BorderSide(
                        color: Colors.black.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MBColors.shadow.withValues(alpha: 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, -2),
                      ),
                      BoxShadow(
                        color: MBColors.shadow.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(widget.items.length, (index) {
                      final item = widget.items[index];
                      final selected = index == widget.currentIndex;

                      return Expanded(
                        child: _NavBarSlot(
                          item: item,
                          selected: selected,
                          iconSize: _iconSize,
                          labelFontSize: _labelFontSize,
                          labelBoxHeight: _labelBoxHeight,
                          iconLabelGap: _iconLabelGap,
                          slotBottomPadding: _slotBottomPadding,
                          onTap: () => widget.onTap(index),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Positioned(
                left: slotWidth * widget.currentIndex,
                width: slotWidth,
                bottom: bottomInset +
                    _barBodyBottomPadding +
                    _selectedLabelBottomPadding,
                child: Transform.translate(
                  offset: Offset(0, -floatOffset),
                  child: Center(
                    child: _FloatingSelectedItem(
                      item: selectedItem,
                      bubbleSize: _bubbleSize,
                      innerIconCircleSize: innerIconCircleSize,
                      iconSize: selectedIconSize,
                      labelFontSize: _labelFontSize,
                      labelBoxHeight: _labelBoxHeight,
                      gap: _selectedClusterGap,
                      progress: progress,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      waveAmplitudeFactor: _waveAmplitudeFactor,
                      wavePrimaryStrokeWidth: _wavePrimaryStrokeWidth,
                      waveGlowStrokeWidth: _waveGlowStrokeWidth,
                      waveSecondaryStrokeWidth: _waveSecondaryStrokeWidth,
                      wavePrimaryOpacity: _wavePrimaryOpacity,
                      waveSecondaryOpacity: _waveSecondaryOpacity,
                      waveGlowOpacity: _waveGlowOpacity,
                      onTap: () => widget.onTap(widget.currentIndex),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavBarSlot extends StatelessWidget {
  final MBBottomNavItem item;
  final bool selected;
  final double iconSize;
  final double labelFontSize;
  final double labelBoxHeight;
  final double iconLabelGap;
  final double slotBottomPadding;
  final VoidCallback onTap;

  const _NavBarSlot({
    required this.item,
    required this.selected,
    required this.iconSize,
    required this.labelFontSize,
    required this.labelBoxHeight,
    required this.iconLabelGap,
    required this.slotBottomPadding,
    required this.onTap,
  });

  double get _iconOffsetX => 0.0;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = MBColors.textPrimary.withValues(alpha: 0.82);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(bottom: slotBottomPadding),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: selected
                  ? SizedBox(
                height: iconSize + iconLabelGap + labelBoxHeight,
                width: double.infinity,
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(_iconOffsetX, 0),
                    child: Icon(
                      item.icon,
                      size: iconSize,
                      color: inactiveColor,
                    ),
                  ),
                  SizedBox(height: iconLabelGap),
                  SizedBox(
                    height: labelBoxHeight,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          height: 1,
                          fontWeight: FontWeight.w500,
                          color: inactiveColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingSelectedItem extends StatelessWidget {
  final MBBottomNavItem item;
  final double bubbleSize;
  final double innerIconCircleSize;
  final double iconSize;
  final double labelFontSize;
  final double labelBoxHeight;
  final double gap;
  final double progress;
  final Color backgroundColor;
  final double waveAmplitudeFactor;
  final double wavePrimaryStrokeWidth;
  final double waveGlowStrokeWidth;
  final double waveSecondaryStrokeWidth;
  final double wavePrimaryOpacity;
  final double waveSecondaryOpacity;
  final double waveGlowOpacity;
  final VoidCallback onTap;

  const _FloatingSelectedItem({
    required this.item,
    required this.bubbleSize,
    required this.innerIconCircleSize,
    required this.iconSize,
    required this.labelFontSize,
    required this.labelBoxHeight,
    required this.gap,
    required this.progress,
    required this.backgroundColor,
    required this.waveAmplitudeFactor,
    required this.wavePrimaryStrokeWidth,
    required this.waveGlowStrokeWidth,
    required this.waveSecondaryStrokeWidth,
    required this.wavePrimaryOpacity,
    required this.waveSecondaryOpacity,
    required this.waveGlowOpacity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = MBColors.primaryOrange;
    final selectedIcon = item.selectedIcon ?? item.icon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(bubbleSize),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: bubbleSize,
              height: bubbleSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: bubbleSize,
                    height: bubbleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MBColors.surface,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.94),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MBColors.shadow.withValues(alpha: 0.16),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: MBColors.shadow.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CustomPaint(
                        painter: _DiagonalWavePainter(
                          progress: progress,
                          waveColor: MBColors.primaryOrange.withValues(
                            alpha: wavePrimaryOpacity,
                          ),
                          glowColor: MBColors.primaryOrange.withValues(
                            alpha: waveGlowOpacity,
                          ),
                          secondaryColor: backgroundColor.withValues(
                            alpha: waveSecondaryOpacity,
                          ),
                          amplitudeFactor: waveAmplitudeFactor,
                          primaryStrokeWidth: wavePrimaryStrokeWidth,
                          glowStrokeWidth: waveGlowStrokeWidth,
                          secondaryStrokeWidth: waveSecondaryStrokeWidth,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: innerIconCircleSize,
                    height: innerIconCircleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MBColors.primaryOrange.withValues(alpha: 0.10),
                    ),
                    child: Center(
                      child: Icon(
                        selectedIcon,
                        size: iconSize,
                        color: activeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: gap),
            SizedBox(
              height: labelBoxHeight,
              child: Center(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: activeColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagonalWavePainter extends CustomPainter {
  final double progress;
  final Color waveColor;
  final Color glowColor;
  final Color secondaryColor;
  final double amplitudeFactor;
  final double primaryStrokeWidth;
  final double glowStrokeWidth;
  final double secondaryStrokeWidth;

  const _DiagonalWavePainter({
    required this.progress,
    required this.waveColor,
    required this.glowColor,
    required this.secondaryColor,
    required this.amplitudeFactor,
    required this.primaryStrokeWidth,
    required this.glowStrokeWidth,
    required this.secondaryStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowStrokeWidth
      ..strokeCap = StrokeCap.round
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = primaryStrokeWidth
      ..strokeCap = StrokeCap.round
      ..color = waveColor;

    final secondaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = secondaryStrokeWidth
      ..strokeCap = StrokeCap.round
      ..color = secondaryColor;

    final diagonalTravel = size.width * 1.8;
    final offset = -size.width * 0.9 + (diagonalTravel * progress);

    final mainPath = _buildWavePath(
      size: size,
      baseOffset: offset,
      amplitude: size.width * amplitudeFactor,
      frequency: 2.15,
    );

    final secondaryPath = _buildWavePath(
      size: size,
      baseOffset: offset - (size.width * 0.20),
      amplitude: size.width * (amplitudeFactor * 0.72),
      frequency: 2.65,
    );

    canvas.drawPath(mainPath, glowPaint);
    canvas.drawPath(mainPath, linePaint);
    canvas.drawPath(secondaryPath, secondaryPaint);

    canvas.restore();
  }

  Path _buildWavePath({
    required Size size,
    required double baseOffset,
    required double amplitude,
    required double frequency,
  }) {
    final path = Path();
    final startX = -size.width * 0.40;
    final endX = size.width * 1.40;

    for (double x = startX; x <= endX; x += 1.5) {
      final normalized = x / size.width;
      final diagonalX = x + baseOffset;
      final diagonalY =
          size.height - x - (size.height * 0.15) +
              math.sin((normalized + progress) * math.pi * frequency) *
                  amplitude;

      if (x == startX) {
        path.moveTo(diagonalX, diagonalY);
      } else {
        path.lineTo(diagonalX, diagonalY);
      }
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant _DiagonalWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveColor != waveColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.amplitudeFactor != amplitudeFactor ||
        oldDelegate.primaryStrokeWidth != primaryStrokeWidth ||
        oldDelegate.glowStrokeWidth != glowStrokeWidth ||
        oldDelegate.secondaryStrokeWidth != secondaryStrokeWidth;
  }
}
