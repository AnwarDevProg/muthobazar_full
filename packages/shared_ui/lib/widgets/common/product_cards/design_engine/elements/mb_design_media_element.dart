import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../mb_design_card_defaults.dart';
import '../mb_design_element_runtime_style.dart';

// MuthoBazar Design Card Engine V1
// File: mb_design_media_element.dart
//
// Purpose:
// Media/image element with support for circular hero media and a dedicated
// transparent product cutout node.

class MBDesignMediaElement extends StatelessWidget {
  const MBDesignMediaElement({
    super.key,
    required this.imageUrl,
    this.element,
    this.runtimeStyle,
    this.size = 116,
  });

  final String imageUrl;
  final MBCardElementConfig? element;
  final MBDesignElementRuntimeStyle? runtimeStyle;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!(element?.visible ?? true)) {
      return const SizedBox.shrink();
    }

    final transparentCutout = _isTransparentCutout;
    final shape = element?.stylePreset ?? 'media_circle';
    final isCircle = shape.contains('circle');
    final radius = runtimeStyle?.borderRadius ?? (isCircle ? size : 18.0);
    final borderWidth = runtimeStyle?.ringWidth ?? runtimeStyle?.borderWidth ?? 4;

    final content = imageUrl.trim().isEmpty
        ? transparentCutout
            ? const SizedBox.shrink()
            : _placeholder()
        : Image.network(
            imageUrl,
            fit: transparentCutout ? BoxFit.contain : BoxFit.cover,
            alignment: Alignment.center,
            gaplessPlayback: true,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => transparentCutout
                ? const SizedBox.shrink()
                : _placeholder(),
          );

    if (transparentCutout) {
      return SizedBox(
        width: size,
        height: size,
        child: content,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: runtimeStyle?.backgroundColor ?? Colors.white,
        shape: isCircle && runtimeStyle?.borderRadius == null
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: isCircle && runtimeStyle?.borderRadius == null
            ? null
            : BorderRadius.circular(radius),
        boxShadow: runtimeStyle?.boxShadow() ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
        border: Border.all(
          color: runtimeStyle?.ringColor ??
              runtimeStyle?.borderColor ??
              Colors.white,
          width: borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }

  bool get _isTransparentCutout {
    final preset = (element?.stylePreset ?? '').trim().toLowerCase();
    if (preset == 'media_transparent_cutout') return true;

    final binding = (element?.binding?.source ?? '').trim();
    if (binding == 'product.resolvedCardTransparentImageUrl') return true;

    return false;
  }

  Widget _placeholder() {
    return Container(
      color: MBDesignCardDefaults.orange.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        color: MBDesignCardDefaults.orange.withValues(alpha: 0.62),
        size: 30,
      ),
    );
  }
}
