import 'package:flutter/material.dart';
import 'package:shared_models/product_cards/design/mb_card_design_models.dart';

// MuthoBazar Design Runtime Palette
// ---------------------------------
// Runtime color palette for the new free-design product-card renderer.
//
// Source:
// - config.metadata['palette']
// - saved product.cardDesignJson['palette'] via saved resolver
//
// Stored format is intentionally hex-string based so the admin studio can
// freely tune colors without waiting for token registration.

class MBDesignRuntimePalette {
  const MBDesignRuntimePalette({
    required this.presetId,
    required this.panelStart,
    required this.panelEnd,
    required this.surfaceStart,
    required this.surfaceEnd,
    required this.cardBorder,
    required this.titleText,
    required this.subtitleText,
    required this.priceText,
    required this.originalPriceText,
    required this.mutedText,
    required this.buttonStart,
    required this.buttonEnd,
    required this.buttonText,
    required this.badgeBackground,
    required this.badgeText,
    required this.priceBubbleBackground,
    required this.priceBubbleText,
    required this.deliveryChipBackground,
    required this.deliveryChipText,
    required this.timerChipBackground,
    required this.timerChipText,
    required this.stockChipBackground,
    required this.stockChipText,
    required this.ratingStar,
    required this.progressBackground,
    required this.progressValue,
  });

  final String presetId;

  final Color panelStart;
  final Color panelEnd;

  final Color surfaceStart;
  final Color surfaceEnd;
  final Color cardBorder;

  final Color titleText;
  final Color subtitleText;
  final Color priceText;
  final Color originalPriceText;
  final Color mutedText;

  final Color buttonStart;
  final Color buttonEnd;
  final Color buttonText;

  final Color badgeBackground;
  final Color badgeText;

  final Color priceBubbleBackground;
  final Color priceBubbleText;

  final Color deliveryChipBackground;
  final Color deliveryChipText;

  final Color timerChipBackground;
  final Color timerChipText;

  final Color stockChipBackground;
  final Color stockChipText;

  final Color ratingStar;
  final Color progressBackground;
  final Color progressValue;

  static const List<String> presetIds = <String>[
    'orange_fresh',
    'green_grocery',
    'blue_tech',
    'pink_beauty',
    'dark_premium',
    'minimal_white',
  ];

  static String presetLabel(String presetId) {
    switch (presetId) {
      case 'green_grocery':
        return 'Green Grocery';
      case 'blue_tech':
        return 'Blue Tech';
      case 'pink_beauty':
        return 'Pink Beauty';
      case 'dark_premium':
        return 'Dark Premium';
      case 'minimal_white':
        return 'Minimal White';
      case 'orange_fresh':
      default:
        return 'Orange Fresh';
    }
  }

  static const List<String> editableHexKeys = <String>[
    'panelStartHex',
    'panelEndHex',
    'surfaceStartHex',
    'surfaceEndHex',
    'cardBorderHex',
    'titleTextHex',
    'subtitleTextHex',
    'priceTextHex',
    'originalPriceTextHex',
    'mutedTextHex',
    'buttonStartHex',
    'buttonEndHex',
    'buttonTextHex',
    'badgeBackgroundHex',
    'badgeTextHex',
    'priceBubbleBackgroundHex',
    'priceBubbleTextHex',
    'deliveryChipBackgroundHex',
    'deliveryChipTextHex',
    'timerChipBackgroundHex',
    'timerChipTextHex',
    'stockChipBackgroundHex',
    'stockChipTextHex',
    'ratingStarHex',
    'progressBackgroundHex',
    'progressValueHex',
  ];

  static String fieldLabel(String key) {
    switch (key) {
      case 'panelStartHex':
        return 'Top panel start';
      case 'panelEndHex':
        return 'Top panel end';
      case 'surfaceStartHex':
        return 'Lower surface start';
      case 'surfaceEndHex':
        return 'Lower surface end';
      case 'cardBorderHex':
        return 'Card border';
      case 'titleTextHex':
        return 'Title text';
      case 'subtitleTextHex':
        return 'Subtitle text';
      case 'priceTextHex':
        return 'Price text';
      case 'originalPriceTextHex':
        return 'Original price text';
      case 'mutedTextHex':
        return 'Muted text';
      case 'buttonStartHex':
        return 'Button start';
      case 'buttonEndHex':
        return 'Button end';
      case 'buttonTextHex':
        return 'Button text';
      case 'badgeBackgroundHex':
        return 'Badge background';
      case 'badgeTextHex':
        return 'Badge text';
      case 'priceBubbleBackgroundHex':
        return 'Price bubble background';
      case 'priceBubbleTextHex':
        return 'Price bubble text';
      case 'deliveryChipBackgroundHex':
        return 'Delivery chip background';
      case 'deliveryChipTextHex':
        return 'Delivery chip text';
      case 'timerChipBackgroundHex':
        return 'Timer chip background';
      case 'timerChipTextHex':
        return 'Timer chip text';
      case 'stockChipBackgroundHex':
        return 'Stock chip background';
      case 'stockChipTextHex':
        return 'Stock chip text';
      case 'ratingStarHex':
        return 'Rating star';
      case 'progressBackgroundHex':
        return 'Progress background';
      case 'progressValueHex':
        return 'Progress value';
      default:
        return key;
    }
  }

  factory MBDesignRuntimePalette.fromConfig(MBCardDesignConfig config) {
    final raw = config.metadata['palette'];
    if (raw is Map) {
      return MBDesignRuntimePalette.fromMap(raw);
    }

    return MBDesignRuntimePalette.fromMap(const <String, Object?>{
      'presetId': 'orange_fresh',
    });
  }

  factory MBDesignRuntimePalette.fromMap(Map map) {
    final normalized = normalizePaletteMap(map);
    final presetId = normalized['presetId'] ?? 'orange_fresh';

    Color read(String key) {
      return colorFromHex(
        normalized[key],
        fallback: colorFromHex(
          presetHexMap(presetId)[key],
          fallback: Colors.orange,
        ),
      );
    }

    return MBDesignRuntimePalette(
      presetId: presetId,
      panelStart: read('panelStartHex'),
      panelEnd: read('panelEndHex'),
      surfaceStart: read('surfaceStartHex'),
      surfaceEnd: read('surfaceEndHex'),
      cardBorder: read('cardBorderHex'),
      titleText: read('titleTextHex'),
      subtitleText: read('subtitleTextHex'),
      priceText: read('priceTextHex'),
      originalPriceText: read('originalPriceTextHex'),
      mutedText: read('mutedTextHex'),
      buttonStart: read('buttonStartHex'),
      buttonEnd: read('buttonEndHex'),
      buttonText: read('buttonTextHex'),
      badgeBackground: read('badgeBackgroundHex'),
      badgeText: read('badgeTextHex'),
      priceBubbleBackground: read('priceBubbleBackgroundHex'),
      priceBubbleText: read('priceBubbleTextHex'),
      deliveryChipBackground: read('deliveryChipBackgroundHex'),
      deliveryChipText: read('deliveryChipTextHex'),
      timerChipBackground: read('timerChipBackgroundHex'),
      timerChipText: read('timerChipTextHex'),
      stockChipBackground: read('stockChipBackgroundHex'),
      stockChipText: read('stockChipTextHex'),
      ratingStar: read('ratingStarHex'),
      progressBackground: read('progressBackgroundHex'),
      progressValue: read('progressValueHex'),
    );
  }

  LinearGradient get panelGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        panelStart,
        panelEnd,
      ],
    );
  }

  LinearGradient get surfaceGradient {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        surfaceStart,
        surfaceEnd,
      ],
    );
  }

  LinearGradient get buttonGradient {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        buttonStart,
        buttonEnd,
      ],
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'presetId': presetId,
      'panelStartHex': hexFromColor(panelStart),
      'panelEndHex': hexFromColor(panelEnd),
      'surfaceStartHex': hexFromColor(surfaceStart),
      'surfaceEndHex': hexFromColor(surfaceEnd),
      'cardBorderHex': hexFromColor(cardBorder),
      'titleTextHex': hexFromColor(titleText),
      'subtitleTextHex': hexFromColor(subtitleText),
      'priceTextHex': hexFromColor(priceText),
      'originalPriceTextHex': hexFromColor(originalPriceText),
      'mutedTextHex': hexFromColor(mutedText),
      'buttonStartHex': hexFromColor(buttonStart),
      'buttonEndHex': hexFromColor(buttonEnd),
      'buttonTextHex': hexFromColor(buttonText),
      'badgeBackgroundHex': hexFromColor(badgeBackground),
      'badgeTextHex': hexFromColor(badgeText),
      'priceBubbleBackgroundHex': hexFromColor(priceBubbleBackground),
      'priceBubbleTextHex': hexFromColor(priceBubbleText),
      'deliveryChipBackgroundHex': hexFromColor(deliveryChipBackground),
      'deliveryChipTextHex': hexFromColor(deliveryChipText),
      'timerChipBackgroundHex': hexFromColor(timerChipBackground),
      'timerChipTextHex': hexFromColor(timerChipText),
      'stockChipBackgroundHex': hexFromColor(stockChipBackground),
      'stockChipTextHex': hexFromColor(stockChipText),
      'ratingStarHex': hexFromColor(ratingStar),
      'progressBackgroundHex': hexFromColor(progressBackground),
      'progressValueHex': hexFromColor(progressValue),
    };
  }

  static Map<String, String> normalizePaletteMap(Map? raw) {
    final presetId = _readString(raw?['presetId'], fallback: 'orange_fresh');
    final result = Map<String, String>.from(presetHexMap(presetId));
    result['presetId'] = presetId;

    if (raw == null) {
      return result;
    }

    for (final key in editableHexKeys) {
      final value = _readString(raw[key], fallback: '');
      if (isValidHex(value)) {
        result[key] = normalizeHex(value);
      }
    }

    return result;
  }

  static Map<String, String> presetHexMap(String presetId) {
    switch (presetId) {
      case 'green_grocery':
        return <String, String>{
          ..._orangeFresh,
          'presetId': 'green_grocery',
          'panelStartHex': '#42C66B',
          'panelEndHex': '#129A44',
          'surfaceStartHex': '#FAFFF8',
          'surfaceEndHex': '#EFFFF0',
          'cardBorderHex': '#22A652',
          'titleTextHex': '#FFFFFF',
          'subtitleTextHex': '#EFFFF2',
          'priceTextHex': '#075E2D',
          'buttonStartHex': '#2AC45D',
          'buttonEndHex': '#0E973B',
          'badgeTextHex': '#159447',
          'priceBubbleBackgroundHex': '#DDF8E4',
          'priceBubbleTextHex': '#075E2D',
          'deliveryChipBackgroundHex': '#E7F7ED',
          'deliveryChipTextHex': '#0B7C43',
          'timerChipBackgroundHex': '#F1FFE7',
          'timerChipTextHex': '#247A00',
          'stockChipBackgroundHex': '#E7F7ED',
          'stockChipTextHex': '#0B7C43',
          'progressBackgroundHex': '#CFF4DB',
          'progressValueHex': '#12A04A',
        };
      case 'blue_tech':
        return <String, String>{
          ..._orangeFresh,
          'presetId': 'blue_tech',
          'panelStartHex': '#34B7FF',
          'panelEndHex': '#1464E8',
          'surfaceStartHex': '#F8FBFF',
          'surfaceEndHex': '#EAF3FF',
          'cardBorderHex': '#2878F0',
          'titleTextHex': '#FFFFFF',
          'subtitleTextHex': '#EAF3FF',
          'priceTextHex': '#063E8D',
          'buttonStartHex': '#2DA8FF',
          'buttonEndHex': '#1264E8',
          'badgeTextHex': '#1464E8',
          'priceBubbleBackgroundHex': '#D9ECFF',
          'priceBubbleTextHex': '#063E8D',
          'deliveryChipBackgroundHex': '#E7F0FF',
          'deliveryChipTextHex': '#1565C0',
          'timerChipBackgroundHex': '#EAF6FF',
          'timerChipTextHex': '#006BA8',
          'stockChipBackgroundHex': '#E8F7FF',
          'stockChipTextHex': '#006B9C',
          'progressBackgroundHex': '#D4E8FF',
          'progressValueHex': '#1464E8',
        };
      case 'pink_beauty':
        return <String, String>{
          ..._orangeFresh,
          'presetId': 'pink_beauty',
          'panelStartHex': '#FF70C7',
          'panelEndHex': '#EC168B',
          'surfaceStartHex': '#FFF9FD',
          'surfaceEndHex': '#FFEAF7',
          'cardBorderHex': '#F054AA',
          'titleTextHex': '#FFFFFF',
          'subtitleTextHex': '#FFF0FA',
          'priceTextHex': '#9E005D',
          'buttonStartHex': '#FF70C7',
          'buttonEndHex': '#EC168B',
          'badgeTextHex': '#EC168B',
          'priceBubbleBackgroundHex': '#FFE1F4',
          'priceBubbleTextHex': '#9E005D',
          'deliveryChipBackgroundHex': '#FFEAF7',
          'deliveryChipTextHex': '#B0006F',
          'timerChipBackgroundHex': '#FFF0FA',
          'timerChipTextHex': '#A00060',
          'stockChipBackgroundHex': '#FFEAF7',
          'stockChipTextHex': '#B0006F',
          'progressBackgroundHex': '#FFD0EE',
          'progressValueHex': '#EC168B',
        };
      case 'dark_premium':
        return <String, String>{
          ..._orangeFresh,
          'presetId': 'dark_premium',
          'panelStartHex': '#2A2D3A',
          'panelEndHex': '#0F1118',
          'surfaceStartHex': '#232631',
          'surfaceEndHex': '#13151D',
          'cardBorderHex': '#FFB84D',
          'titleTextHex': '#FFFFFF',
          'subtitleTextHex': '#D9D9E3',
          'priceTextHex': '#FFCC6B',
          'originalPriceTextHex': '#9B9BA6',
          'mutedTextHex': '#C4C4CC',
          'buttonStartHex': '#FFB84D',
          'buttonEndHex': '#FF8A00',
          'buttonTextHex': '#111111',
          'badgeBackgroundHex': '#2F3340',
          'badgeTextHex': '#FFCC6B',
          'priceBubbleBackgroundHex': '#36313A',
          'priceBubbleTextHex': '#FFCC6B',
          'deliveryChipBackgroundHex': '#28303D',
          'deliveryChipTextHex': '#9CD4FF',
          'timerChipBackgroundHex': '#3A3024',
          'timerChipTextHex': '#FFCC6B',
          'stockChipBackgroundHex': '#26362F',
          'stockChipTextHex': '#9CF0B8',
          'progressBackgroundHex': '#45424D',
          'progressValueHex': '#FFB84D',
        };
      case 'minimal_white':
        return <String, String>{
          ..._orangeFresh,
          'presetId': 'minimal_white',
          'panelStartHex': '#F7F7F7',
          'panelEndHex': '#EDEDED',
          'surfaceStartHex': '#FFFFFF',
          'surfaceEndHex': '#F8F8F8',
          'cardBorderHex': '#E0E0E0',
          'titleTextHex': '#1A1A1A',
          'subtitleTextHex': '#555555',
          'priceTextHex': '#111111',
          'originalPriceTextHex': '#888888',
          'mutedTextHex': '#777777',
          'buttonStartHex': '#111111',
          'buttonEndHex': '#333333',
          'buttonTextHex': '#FFFFFF',
          'badgeBackgroundHex': '#FFFFFF',
          'badgeTextHex': '#111111',
          'priceBubbleBackgroundHex': '#F2F2F2',
          'priceBubbleTextHex': '#111111',
          'deliveryChipBackgroundHex': '#F1F1F1',
          'deliveryChipTextHex': '#333333',
          'timerChipBackgroundHex': '#F5F5F5',
          'timerChipTextHex': '#333333',
          'stockChipBackgroundHex': '#F1F1F1',
          'stockChipTextHex': '#333333',
          'progressBackgroundHex': '#E8E8E8',
          'progressValueHex': '#111111',
        };
      case 'orange_fresh':
      default:
        return Map<String, String>.from(_orangeFresh);
    }
  }

  static const Map<String, String> _orangeFresh = <String, String>{
    'presetId': 'orange_fresh',
    'panelStartHex': '#FFA53A',
    'panelEndHex': '#FF7400',
    'surfaceStartHex': '#FFFBF6',
    'surfaceEndHex': '#FFF4E8',
    'cardBorderHex': '#FF8E24',
    'titleTextHex': '#FFFFFF',
    'subtitleTextHex': '#FFF2E7',
    'priceTextHex': '#0D4C7A',
    'originalPriceTextHex': '#7A7A7A',
    'mutedTextHex': '#6C6C6C',
    'buttonStartHex': '#FF8A18',
    'buttonEndHex': '#FF6500',
    'buttonTextHex': '#FFFFFF',
    'badgeBackgroundHex': '#FFFFFF',
    'badgeTextHex': '#FF6A00',
    'priceBubbleBackgroundHex': '#FFE1CF',
    'priceBubbleTextHex': '#0D4C7A',
    'deliveryChipBackgroundHex': '#E7F0FF',
    'deliveryChipTextHex': '#1565C0',
    'timerChipBackgroundHex': '#FFF2DE',
    'timerChipTextHex': '#B55A00',
    'stockChipBackgroundHex': '#E7F7ED',
    'stockChipTextHex': '#0B7C43',
    'ratingStarHex': '#FFB300',
    'progressBackgroundHex': '#FFD8BF',
    'progressValueHex': '#FF7A00',
  };

  static Color colorFromHex(
    Object? value, {
    required Color fallback,
  }) {
    final text = normalizeHex(value?.toString() ?? '');
    if (!isValidHex(text)) return fallback;

    final hex = text.substring(1);
    final argb = hex.length == 6 ? 'FF$hex' : hex;

    final parsed = int.tryParse(argb, radix: 16);
    if (parsed == null) return fallback;

    return Color(parsed);
  }

  static String hexFromColor(Color color) {
    final a = (color.a * 255.0).round() & 0xff;
    final r = (color.r * 255.0).round() & 0xff;
    final g = (color.g * 255.0).round() & 0xff;
    final b = (color.b * 255.0).round() & 0xff;

    if (a == 0xff) {
      return '#${_hex2(r)}${_hex2(g)}${_hex2(b)}';
    }

    return '#${_hex2(a)}${_hex2(r)}${_hex2(g)}${_hex2(b)}';
  }

  static bool isValidHex(String? value) {
    final normalized = normalizeHex(value ?? '');
    return RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$')
        .hasMatch(normalized);
  }

  static String normalizeHex(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';

    final withHash = trimmed.startsWith('#') ? trimmed : '#$trimmed';

    return withHash.toUpperCase();
  }

  static String _hex2(int value) {
    return value.toRadixString(16).padLeft(2, '0').toUpperCase();
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
}

MBDesignRuntimePalette mbResolveDesignRuntimePalette(
  BuildContext context,
  MBCardDesignConfig config,
) {
  final scoped = MBDesignRuntimePaletteScope.maybeOf(context);
  return scoped ?? MBDesignRuntimePalette.fromConfig(config);
}

class MBDesignRuntimePaletteScope extends InheritedWidget {
  const MBDesignRuntimePaletteScope({
    super.key,
    required this.palette,
    required super.child,
  });

  final MBDesignRuntimePalette palette;

  static MBDesignRuntimePalette? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<MBDesignRuntimePaletteScope>();
    return scope?.palette;
  }

  @override
  bool updateShouldNotify(MBDesignRuntimePaletteScope oldWidget) {
    return palette != oldWidget.palette;
  }
}
