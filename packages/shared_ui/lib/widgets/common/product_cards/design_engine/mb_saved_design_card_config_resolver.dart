import 'dart:convert';

import 'package:shared_models/product_cards/design/mb_card_design_models.dart';
import 'package:shared_models/product_cards/design/mb_card_element_position.dart';
import 'package:shared_models/product_cards/design/mb_card_element_size.dart';

import 'mb_design_card_default_configs.dart';

// MuthoBazar Saved Design Card Config Resolver
// --------------------------------------------
// Converts saved product.cardDesignJson into MBCardDesignConfig.
//
// Palette upgrade:
// saved JSON "palette" is copied into config.metadata['palette'] so the
// runtime renderer can use product-specific colors.

class MBSavedDesignCardConfigResolver {
  const MBSavedDesignCardConfigResolver._();

  static MBCardDesignConfig? resolveFromJson(String? rawJson) {
    final source = rawJson?.trim();

    if (source == null || source.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(source);

      if (decoded is! Map) {
        return null;
      }

      return resolveFromMap(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  static MBCardDesignConfig? resolveFromMap(Map<String, dynamic> map) {
    final templateId = _readString(
      map['templateId'],
      fallback: MBCardDesignRegistry.heroPosterCircleDiagonalV1,
    );

    if (templateId != MBCardDesignRegistry.heroPosterCircleDiagonalV1) {
      return null;
    }

    final base = MBDesignCardDefaultConfigs.heroPosterCircleDiagonalV1();

    final layoutMap = _readMap(map['layout']);
    final defaultLayout = MBCardDesignRegistry.defaultLayoutForTemplate(
      MBCardDesignRegistry.heroPosterCircleDiagonalV1,
    );

    final layout = defaultLayout.copyWith(
      aspectRatio: _readDoubleOrNull(layoutMap['aspectRatio']) ??
          defaultLayout.aspectRatio,
      minHeight: _readDoubleOrNull(layoutMap['minHeight']) ??
          defaultLayout.minHeight,
      maxHeight: _readDoubleOrNull(layoutMap['maxHeight']) ??
          defaultLayout.maxHeight,
      canShrink: true,
      canExpand: true,
      maxShrinkPercent: defaultLayout.maxShrinkPercent ?? 7,
      maxExpandPercent: defaultLayout.maxExpandPercent ?? 12,
    );

    final visibleElementIds = _readStringSet(map['visibleElementIds']);
    final positionOverrides = _readPositionOverrides(
      map['positionOverrides'],
    );
    final sizeOverrides = _readSizeOverrides(
      map['sizeOverrides'],
    );
    final palette = _readMap(map['palette']);
    final elementStyles = _readMap(map['elementStyles']);

    final elements = <String, MBCardElementConfig>{};

    for (final entry in base.elements.entries) {
      final elementId = entry.key;
      final baseElement = entry.value;

      final position = positionOverrides[elementId] ??
          baseElement.position ??
          MBCardElementPosition(slot: baseElement.slot);

      final size = sizeOverrides[elementId] ?? baseElement.size;

      final isVisible = visibleElementIds.isEmpty
          ? baseElement.visible
          : visibleElementIds.contains(elementId);

      elements[elementId] = baseElement.copyWith(
        visible: isVisible,
        slot: position.slot,
        position: position,
        size: size,
      );
    }

    return base.copyWith(
      layout: layout,
      elements: elements,
      metadata: <String, Object?>{
        ...base.metadata,
        'resolvedFrom': 'product.cardDesignJson',
        'savedVersion': map['version'],
        'savedType': map['type'],
        'savedActivePresetId': map['activePresetId'],
        'savedActiveElementId': map['activeElementId'],
        if (palette.isNotEmpty) 'palette': palette,
        if (elementStyles.isNotEmpty) 'elementStyles': elementStyles,
      },
    );
  }

  static Map<String, dynamic> _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }

    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(key.toString(), val),
      );
    }

    return <String, dynamic>{};
  }

  static String _readString(
    Object? value, {
    required String fallback,
  }) {
    final normalized = value?.toString().trim();

    if (normalized == null || normalized.isEmpty) {
      return fallback;
    }

    return normalized;
  }

  static double? _readDoubleOrNull(Object? value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString().trim());
  }

  static Set<String> _readStringSet(Object? value) {
    if (value is! Iterable) {
      return <String>{};
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toSet();
  }

  static Map<String, MBCardElementPosition> _readPositionOverrides(
    Object? value,
  ) {
    final raw = _readMap(value);
    final result = <String, MBCardElementPosition>{};

    for (final entry in raw.entries) {
      final rawPosition = entry.value;

      if (rawPosition is Map) {
        result[entry.key] = MBCardElementPosition.fromMap(rawPosition);
      }
    }

    return result;
  }

  static Map<String, MBCardElementSize> _readSizeOverrides(Object? value) {
    final raw = _readMap(value);
    final result = <String, MBCardElementSize>{};

    for (final entry in raw.entries) {
      final rawSize = entry.value;

      if (rawSize is Map) {
        result[entry.key] = MBCardElementSize.fromMap(rawSize);
      }
    }

    return result;
  }
}
