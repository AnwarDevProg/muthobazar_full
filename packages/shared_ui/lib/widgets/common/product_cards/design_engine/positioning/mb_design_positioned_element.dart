import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

// MuthoBazar Design Card Engine V1
// File: mb_design_positioned_element.dart
//
// Purpose:
// Reusable positioning + sizing wrapper for design-card elements.
//
// Supports:
// - slot mode: controlled named design zones
// - free mode: normalized x/y coordinates from 0.0 to 1.0
// - anchor: which point of the child sits on the coordinate
// - z: used by templates when sorting layers
// - element.size: width, height, min/max constraints, scale, rotation, opacity
//
// Coordinate behavior:
// x = 0.0 left, 0.5 center, 1.0 right
// y = 0.0 top,  0.5 center, 1.0 bottom

class MBDesignPositionedElement extends StatelessWidget {
  const MBDesignPositionedElement({
    super.key,
    required this.element,
    required this.child,
    this.fallbackSlot = 'bodyCenter',
    this.safePadding = const EdgeInsets.all(12),
    this.width,
    this.height,
  });

  final MBCardElementConfig? element;
  final Widget child;
  final String fallbackSlot;
  final EdgeInsets safePadding;

  // Template fallback size. element.size overrides these values.
  final double? width;
  final double? height;

  static double zOf(MBCardElementConfig? element) {
    final raw = element?.position?.z;
    if (raw == null) {
      return 0;
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    if (!(element?.visible ?? true)) {
      return const SizedBox.shrink();
    }

    final position = element?.position ??
        MBCardElementPosition(
          slot: element?.slot ?? fallbackSlot,
        );

    final resolved = _resolvePoint(position, fallbackSlot);
    final size = element?.size;

    final resolvedWidth = size?.width ?? width;
    final resolvedHeight = size?.height ?? height;

    Widget content = child;

    if (resolvedWidth != null || resolvedHeight != null) {
      content = SizedBox(
        width: resolvedWidth,
        height: resolvedHeight,
        child: child,
      );
    }

    if (size?.hasConstraints ?? false) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: size?.minWidth ?? 0,
          maxWidth: size?.maxWidth ?? double.infinity,
          minHeight: size?.minHeight ?? 0,
          maxHeight: size?.maxHeight ?? double.infinity,
        ),
        child: content,
      );
    }

    final scale = size?.effectiveScale ?? 1.0;
    final rotation = size?.effectiveRotation ?? 0.0;
    final opacity = size?.effectiveOpacity ?? 1.0;

    if (scale != 1.0 || rotation != 0.0) {
      content = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ(rotation * math.pi / 180.0)
          ..scale(scale),
        child: content,
      );
    }

    if (opacity < 1.0) {
      content = Opacity(
        opacity: opacity,
        child: content,
      );
    }

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final parentWidth =
              constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
          final parentHeight =
              constraints.maxHeight.isFinite ? constraints.maxHeight : 0.0;

          final usableWidth =
              (parentWidth - safePadding.horizontal).clamp(0.0, parentWidth);
          final usableHeight =
              (parentHeight - safePadding.vertical).clamp(0.0, parentHeight);

          final left = safePadding.left + (usableWidth * resolved.x);
          final top = safePadding.top + (usableHeight * resolved.y);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: left,
                top: top,
                child: FractionalTranslation(
                  translation: _anchorTranslation(resolved.anchor),
                  child: content,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static _ResolvedPositionPoint _resolvePoint(
    MBCardElementPosition position,
    String fallbackSlot,
  ) {
    if (position.mode == MBCardElementPositionMode.free) {
      return _ResolvedPositionPoint(
        x: (position.x ?? 0.5).clamp(0.0, 1.0),
        y: (position.y ?? 0.5).clamp(0.0, 1.0),
        anchor: position.anchor ?? 'center',
      );
    }

    return _slotPoint(position.slot, fallbackSlot);
  }

  static _ResolvedPositionPoint _slotPoint(
    String slot,
    String fallbackSlot,
  ) {
    switch (slot.trim()) {
      case 'topLeft':
        return const _ResolvedPositionPoint(x: 0, y: 0, anchor: 'topLeft');
      case 'topCenter':
        return const _ResolvedPositionPoint(x: 0.5, y: 0, anchor: 'topCenter');
      case 'topRight':
        return const _ResolvedPositionPoint(x: 1, y: 0, anchor: 'topRight');
      case 'bottomLeft':
        return const _ResolvedPositionPoint(x: 0, y: 1, anchor: 'bottomLeft');
      case 'bottomCenter':
        return const _ResolvedPositionPoint(
          x: 0.5,
          y: 1,
          anchor: 'bottomCenter',
        );
      case 'bottomRight':
        return const _ResolvedPositionPoint(x: 1, y: 1, anchor: 'bottomRight');
      case 'center':
      case 'bodyCenter':
      case 'overlayCenter':
        return const _ResolvedPositionPoint(x: 0.5, y: 0.5, anchor: 'center');

      // Generic hero slots.
      case 'heroTopLeft':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.08,
          anchor: 'topLeft',
        );
      case 'heroTopCenter':
        return const _ResolvedPositionPoint(
          x: 0.5,
          y: 0.08,
          anchor: 'topCenter',
        );
      case 'heroTopRight':
        return const _ResolvedPositionPoint(
          x: 0.94,
          y: 0.08,
          anchor: 'topRight',
        );
      case 'heroCenterLeft':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.34,
          anchor: 'centerLeft',
        );
      case 'heroCenter':
        return const _ResolvedPositionPoint(
          x: 0.5,
          y: 0.42,
          anchor: 'center',
        );
      case 'heroCenterRight':
        return const _ResolvedPositionPoint(
          x: 0.94,
          y: 0.34,
          anchor: 'centerRight',
        );
      case 'heroLowerLeft':
        return const _ResolvedPositionPoint(
          x: 0.22,
          y: 0.58,
          anchor: 'center',
        );
      case 'heroLowerRight':
        return const _ResolvedPositionPoint(
          x: 0.78,
          y: 0.58,
          anchor: 'center',
        );

      // Generic body slots.
      case 'bodyTopLeft':
      case 'bodyTop':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.56,
          anchor: 'topLeft',
        );
      case 'bodyTopCenter':
        return const _ResolvedPositionPoint(
          x: 0.5,
          y: 0.56,
          anchor: 'topCenter',
        );
      case 'bodyTopRight':
        return const _ResolvedPositionPoint(
          x: 0.94,
          y: 0.56,
          anchor: 'topRight',
        );
      case 'bodyCenterLeft':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.72,
          anchor: 'centerLeft',
        );
      case 'bodyCenterRight':
        return const _ResolvedPositionPoint(
          x: 0.94,
          y: 0.72,
          anchor: 'centerRight',
        );
      case 'bodyBottomLeft':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.88,
          anchor: 'bottomLeft',
        );
      case 'bodyBottomCenter':
        return const _ResolvedPositionPoint(
          x: 0.5,
          y: 0.88,
          anchor: 'bottomCenter',
        );
      case 'bodyBottomRight':
        return const _ResolvedPositionPoint(
          x: 0.94,
          y: 0.88,
          anchor: 'bottomRight',
        );

      // Overlay slots.
      case 'overlayTopLeft':
      case 'topLeftOverlay':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.03,
          anchor: 'topLeft',
        );
      case 'overlayTopCenter':
        return const _ResolvedPositionPoint(
          x: 0.5,
          y: 0.03,
          anchor: 'topCenter',
        );
      case 'overlayTopRight':
      case 'topRightOverlay':
        return const _ResolvedPositionPoint(
          x: 0.94,
          y: 0.03,
          anchor: 'topRight',
        );
      case 'overlayBottomLeft':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.97,
          anchor: 'bottomLeft',
        );
      case 'overlayBottomCenter':
        return const _ResolvedPositionPoint(
          x: 0.5,
          y: 0.97,
          anchor: 'bottomCenter',
        );
      case 'overlayBottomRight':
        return const _ResolvedPositionPoint(
          x: 0.94,
          y: 0.97,
          anchor: 'bottomRight',
        );

      // Template-specific slots used by hero_poster_circle_diagonal_v1.
      case 'fullBackground':
      case 'heroGlow':
      case 'fullOutline':
        return const _ResolvedPositionPoint(x: 0.5, y: 0.5, anchor: 'center');
      case 'topTextStart':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.09,
          anchor: 'topLeft',
        );
      case 'belowBrand':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.16,
          anchor: 'topLeft',
        );
      case 'actionTop1':
        return const _ResolvedPositionPoint(
          x: 0.94,
          y: 0.15,
          anchor: 'topRight',
        );
      case 'actionTop2':
        return const _ResolvedPositionPoint(
          x: 0.94,
          y: 0.22,
          anchor: 'topRight',
        );
      case 'actionTop3':
        return const _ResolvedPositionPoint(
          x: 0.94,
          y: 0.29,
          anchor: 'topRight',
        );
      case 'centerHero':
      case 'aroundMedia':
        return const _ResolvedPositionPoint(
          x: 0.5,
          y: 0.47,
          anchor: 'center',
        );
      case 'mediaBottomRight':
        return const _ResolvedPositionPoint(
          x: 0.73,
          y: 0.58,
          anchor: 'center',
        );
      case 'bodyTitle':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.26,
          anchor: 'topLeft',
        );
      case 'bodySubtitle':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.36,
          anchor: 'topLeft',
        );
      case 'metaLine1':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.64,
          anchor: 'topLeft',
        );
      case 'metaLine1Right':
        return const _ResolvedPositionPoint(
          x: 0.48,
          y: 0.64,
          anchor: 'topLeft',
        );
      case 'metaLine2Left':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.70,
          anchor: 'topLeft',
        );
      case 'metaLine2Right':
        return const _ResolvedPositionPoint(
          x: 0.55,
          y: 0.70,
          anchor: 'topLeft',
        );
      case 'metaLine3Left':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.77,
          anchor: 'topLeft',
        );
      case 'metaLine3Right':
        return const _ResolvedPositionPoint(
          x: 0.46,
          y: 0.77,
          anchor: 'topLeft',
        );
      case 'priceRowStart':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.86,
          anchor: 'topLeft',
        );
      case 'priceRowMiddle':
        return const _ResolvedPositionPoint(
          x: 0.48,
          y: 0.86,
          anchor: 'topLeft',
        );
      case 'priceRowEnd':
        return const _ResolvedPositionPoint(
          x: 0.92,
          y: 0.86,
          anchor: 'topRight',
        );
      case 'priceRowBadge':
        return const _ResolvedPositionPoint(
          x: 0.5,
          y: 0.86,
          anchor: 'topCenter',
        );
      case 'bottomLeftSecondary':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.92,
          anchor: 'bottomLeft',
        );
      case 'bottomRightSecondary':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.97,
          anchor: 'bottomLeft',
        );
      case 'bottomRightMain':
        return const _ResolvedPositionPoint(
          x: 0.94,
          y: 0.97,
          anchor: 'bottomRight',
        );
      case 'footerLeft':
        return const _ResolvedPositionPoint(
          x: 0.06,
          y: 0.97,
          anchor: 'bottomLeft',
        );
      case 'footerCenter':
        return const _ResolvedPositionPoint(
          x: 0.5,
          y: 0.97,
          anchor: 'bottomCenter',
        );
      case 'footerRight':
        return const _ResolvedPositionPoint(
          x: 0.94,
          y: 0.97,
          anchor: 'bottomRight',
        );

      default:
        if (fallbackSlot != slot) {
          return _slotPoint(fallbackSlot, 'bodyCenter');
        }

        return const _ResolvedPositionPoint(x: 0.5, y: 0.5, anchor: 'center');
    }
  }

  static Offset _anchorTranslation(String anchor) {
    switch (anchor.trim()) {
      case 'topLeft':
        return Offset.zero;
      case 'topCenter':
        return const Offset(-0.5, 0);
      case 'topRight':
        return const Offset(-1, 0);
      case 'centerLeft':
        return const Offset(0, -0.5);
      case 'center':
        return const Offset(-0.5, -0.5);
      case 'centerRight':
        return const Offset(-1, -0.5);
      case 'bottomLeft':
        return const Offset(0, -1);
      case 'bottomCenter':
        return const Offset(-0.5, -1);
      case 'bottomRight':
        return const Offset(-1, -1);
      default:
        return const Offset(-0.5, -0.5);
    }
  }
}

class _ResolvedPositionPoint {
  const _ResolvedPositionPoint({
    required this.x,
    required this.y,
    required this.anchor,
  });

  final double x;
  final double y;
  final String anchor;
}
