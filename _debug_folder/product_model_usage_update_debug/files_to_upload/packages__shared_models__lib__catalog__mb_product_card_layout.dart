// File: mb_product_card_layout.dart
// Product card layout helpers shared across admin, customer, and model logic.
//
// Transitional note:
// This layout enum is now intentionally trimmed to only the legacy values still
// required by the store-preview migration bridge. The real new card system uses
// MBCardVariant / variantId.
//
// Keep this file small and controlled while old layout-based code is being
// removed from the project.

enum MBProductCardLayout {
  standard,
  compact,
  deal,
  featured,
  card01,
  card02,
  card03,
}

extension MBProductCardLayoutX on MBProductCardLayout {
  String get value {
    switch (this) {
      case MBProductCardLayout.standard:
        return 'standard';
      case MBProductCardLayout.compact:
        return 'compact';
      case MBProductCardLayout.deal:
        return 'deal';
      case MBProductCardLayout.featured:
        return 'featured';
      case MBProductCardLayout.card01:
        return 'card01';
      case MBProductCardLayout.card02:
        return 'card02';
      case MBProductCardLayout.card03:
        return 'card03';
    }
  }

  String get label {
    switch (this) {
      case MBProductCardLayout.standard:
        return 'Standard';
      case MBProductCardLayout.compact:
        return 'Compact';
      case MBProductCardLayout.deal:
        return 'Deal';
      case MBProductCardLayout.featured:
        return 'Featured';
      case MBProductCardLayout.card01:
        return 'Card 01';
      case MBProductCardLayout.card02:
        return 'Card 02';
      case MBProductCardLayout.card03:
        return 'Card 03';
    }
  }

  bool get isGridSafe {
    switch (this) {
      case MBProductCardLayout.featured:
        return false;
      case MBProductCardLayout.standard:
      case MBProductCardLayout.compact:
      case MBProductCardLayout.deal:
      case MBProductCardLayout.card01:
      case MBProductCardLayout.card02:
      case MBProductCardLayout.card03:
        return true;
    }
  }

  bool get isHorizontalSafe {
    switch (this) {
      case MBProductCardLayout.standard:
      case MBProductCardLayout.compact:
      case MBProductCardLayout.deal:
      case MBProductCardLayout.featured:
      case MBProductCardLayout.card01:
      case MBProductCardLayout.card02:
      case MBProductCardLayout.card03:
        return true;
    }
  }

  bool get isCoreBuiltLayout {
    switch (this) {
      case MBProductCardLayout.standard:
      case MBProductCardLayout.compact:
      case MBProductCardLayout.deal:
      case MBProductCardLayout.featured:
        return true;
      case MBProductCardLayout.card01:
      case MBProductCardLayout.card02:
      case MBProductCardLayout.card03:
        return false;
    }
  }
}

class MBProductCardLayoutHelper {
  const MBProductCardLayoutHelper._();

  static const MBProductCardLayout fallback = MBProductCardLayout.standard;

  static List<MBProductCardLayout> get values =>
      List<MBProductCardLayout>.unmodifiable(MBProductCardLayout.values);

  static List<String> get allowedValues =>
      values.map((item) => item.value).toList(growable: false);

  static List<MBProductCardLayout> get coreBuiltValues =>
      values.where((item) => item.isCoreBuiltLayout).toList(growable: false);

  static List<MBProductCardLayout> get previewValues =>
      List<MBProductCardLayout>.unmodifiable(values);

  static MBProductCardLayout parse(dynamic raw) {
    final normalized = _normalizeRaw(raw);

    switch (normalized) {
      case 'standard':
      case 'default':
        return MBProductCardLayout.standard;
      case 'compact':
        return MBProductCardLayout.compact;
      case 'deal':
        return MBProductCardLayout.deal;
      case 'featured':
        return MBProductCardLayout.featured;
      case 'card01':
      case 'card1':
      case 'card_style_01':
      case 'style01':
        return MBProductCardLayout.card01;
      case 'card02':
      case 'card2':
      case 'card_style_02':
      case 'style02':
        return MBProductCardLayout.card02;
      case 'card03':
      case 'card3':
      case 'card_style_03':
      case 'style03':
        return MBProductCardLayout.card03;
      default:
        return fallback;
    }
  }

  static String normalize(dynamic raw) {
    return parse(raw).value;
  }

  static bool isValid(dynamic raw) {
    final normalized = _normalizeRaw(raw);
    return allowedValues.contains(normalized) || _legacyAliases.contains(normalized);
  }

  static MBProductCardLayout gridSafeOrFallback(dynamic raw) {
    final parsed = parse(raw);
    return parsed.isGridSafe ? parsed : fallback;
  }

  static MBProductCardLayout horizontalSafeOrFallback(dynamic raw) {
    final parsed = parse(raw);
    return parsed.isHorizontalSafe ? parsed : fallback;
  }

  static String _normalizeRaw(dynamic raw) {
    return raw?.toString().trim().toLowerCase() ?? '';
  }

  static const Set<String> _legacyAliases = <String>{
    'default',
    'card1',
    'card2',
    'card3',
    'style01',
    'style02',
    'style03',
    'card_style_01',
    'card_style_02',
    'card_style_03',
  };
}