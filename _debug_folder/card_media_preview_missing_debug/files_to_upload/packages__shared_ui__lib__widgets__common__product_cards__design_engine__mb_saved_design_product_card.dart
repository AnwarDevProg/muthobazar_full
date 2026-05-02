import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_models/product_cards/design/mb_card_design_models.dart';
import 'package:shared_models/shared_models.dart';

import 'mb_design_card_renderer.dart';
import 'mb_design_element_runtime_style.dart';
import 'mb_design_runtime_palette.dart';
import 'mb_saved_design_card_config_resolver.dart';

// MuthoBazar Saved Design Product Card
// ------------------------------------
// Runtime bridge for customer/home/store product lists.
//
// If product.cardDesignJson exists and can be parsed:
//   -> render with MBDesignCardRenderer
//
// Otherwise:
//   -> render the fallback card passed by the caller.
//
// Important sizing rule:
// The Card Studio exports layout values for the design preview width
// (usually around 220px). At runtime, Home/Store cells may be smaller or
// larger. So min/max height must be scaled by:
//
// runtimeWidth / savedCardWidth
//
// This prevents the saved 430px studio height from forcing a tiny FittedBox
// inside a normal two-column Home grid cell.

class MBSavedDesignProductCard extends StatelessWidget {
  const MBSavedDesignProductCard({
    super.key,
    required this.product,
    required this.fallback,
    this.onTap,
    this.onPrimaryCtaTap,
    this.onSecondaryCtaTap,
    this.fitInsideParent = true,
  });

  final MBProduct product;
  final Widget fallback;
  final VoidCallback? onTap;
  final VoidCallback? onPrimaryCtaTap;
  final VoidCallback? onSecondaryCtaTap;

  /// Use true when this card is placed inside an old fixed-height parent.
  /// Use false when the parent already calculated the saved-design height.
  final bool fitInsideParent;

  @override
  Widget build(BuildContext context) {
    final config = MBSavedDesignCardConfigResolver.resolveFromJson(
      product.cardDesignJson,
    );

    if (config == null) {
      return fallback;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final runtimeWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth
                : _SavedDesignRuntimeMetrics.fromJson(
                    product.cardDesignJson,
                    config: config,
                  ).savedCardWidth;

        final metrics = _SavedDesignRuntimeMetrics.fromJson(
          product.cardDesignJson,
          config: config,
        );

        final runtimeHeight = metrics.heightForWidth(runtimeWidth);

        final renderedCard = SizedBox(
          width: runtimeWidth,
          height: runtimeHeight,
          child: MBDesignRuntimePaletteScope(
            palette: MBDesignRuntimePalette.fromConfig(config),
            child: MBDesignElementRuntimeStyleScope(
              styles: MBDesignElementRuntimeStyles.fromConfig(config),
              child: MBDesignCardRenderer(
                product: product,
                config: config,
                onTap: onTap,
                onPrimaryCtaTap: onPrimaryCtaTap,
                onSecondaryCtaTap: onSecondaryCtaTap,
              ),
            ),
          ),
        );

        if (!fitInsideParent ||
            !constraints.maxHeight.isFinite ||
            constraints.maxHeight <= 0) {
          return renderedCard;
        }

        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            child: renderedCard,
          ),
        );
      },
    );
  }
}

class _SavedDesignRuntimeMetrics {
  const _SavedDesignRuntimeMetrics({
    required this.savedCardWidth,
    required this.aspectRatio,
    required this.minHeight,
    required this.maxHeight,
  });

  final double savedCardWidth;
  final double aspectRatio;
  final double minHeight;
  final double maxHeight;

  factory _SavedDesignRuntimeMetrics.fromJson(
    String? rawJson, {
    required MBCardDesignConfig config,
  }) {
    final layout = config.layout ??
        MBCardDesignRegistry.defaultLayoutForTemplate(
          MBCardDesignRegistry.heroPosterCircleDiagonalV1,
        );

    final layoutMap = _readLayoutMap(rawJson);

    final savedCardWidth = _readDouble(
      layoutMap['cardWidth'],
      fallback: 220,
    ).clamp(120, 420).toDouble();

    final aspectRatio = _readDouble(
      layoutMap['aspectRatio'],
      fallback: layout.aspectRatio ?? 0.56,
    ).clamp(0.35, 1.25).toDouble();

    final minHeight = _readDouble(
      layoutMap['minHeight'],
      fallback: layout.minHeight ?? 360,
    ).clamp(120, 900).toDouble();

    final maxHeight = _readDouble(
      layoutMap['maxHeight'],
      fallback: layout.maxHeight ?? 560,
    ).clamp(minHeight, 1200).toDouble();

    return _SavedDesignRuntimeMetrics(
      savedCardWidth: savedCardWidth,
      aspectRatio: aspectRatio,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  double heightForWidth(double runtimeWidth) {
    final safeWidth = runtimeWidth.clamp(80, 800).toDouble();
    final scale = (safeWidth / savedCardWidth).clamp(0.35, 2.5).toDouble();

    final rawHeight = safeWidth / aspectRatio;
    final scaledMinHeight = minHeight * scale;
    final scaledMaxHeight = maxHeight * scale;

    final safeMin = scaledMinHeight.clamp(80, 1200).toDouble();
    final safeMax = scaledMaxHeight.clamp(safeMin, 1400).toDouble();

    return rawHeight.clamp(safeMin, safeMax).toDouble();
  }

  static Map<String, dynamic> _readLayoutMap(String? rawJson) {
    final source = rawJson?.trim();
    if (source == null || source.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map) {
        return <String, dynamic>{};
      }

      final rawLayout = decoded['layout'];
      if (rawLayout is Map<String, dynamic>) {
        return Map<String, dynamic>.from(rawLayout);
      }

      if (rawLayout is Map) {
        return rawLayout.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  static double _readDouble(
    Object? value, {
    required double fallback,
  }) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
  }
}
