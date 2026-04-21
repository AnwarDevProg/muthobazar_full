// File: mb_product_card_layout.dart
// Product card layout helpers shared across admin, customer, and model logic.

enum MBProductCardLayout {
  standard,
  compact,
  deal,
  featured,
  card01,
  card02,
  card03,
  card04,
  card05,
  card06,
  card07,
  card08,
  card09,
  card10,
  card11,
  card12,
  card13,
  card14,
  card15,
  card16,
  card17,
  card18,
  card19,
  card20,
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
      case MBProductCardLayout.card04:
        return 'card04';
      case MBProductCardLayout.card05:
        return 'card05';
      case MBProductCardLayout.card06:
        return 'card06';
      case MBProductCardLayout.card07:
        return 'card07';
      case MBProductCardLayout.card08:
        return 'card08';
      case MBProductCardLayout.card09:
        return 'card09';
      case MBProductCardLayout.card10:
        return 'card10';
      case MBProductCardLayout.card11:
        return 'card11';
      case MBProductCardLayout.card12:
        return 'card12';
      case MBProductCardLayout.card13:
        return 'card13';
      case MBProductCardLayout.card14:
        return 'card14';
      case MBProductCardLayout.card15:
        return 'card15';
      case MBProductCardLayout.card16:
        return 'card16';
      case MBProductCardLayout.card17:
        return 'card17';
      case MBProductCardLayout.card18:
        return 'card18';
      case MBProductCardLayout.card19:
        return 'card19';
      case MBProductCardLayout.card20:
        return 'card20';
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
      case MBProductCardLayout.card04:
        return 'Card 04';
      case MBProductCardLayout.card05:
        return 'Card 05';
      case MBProductCardLayout.card06:
        return 'Card 06';
      case MBProductCardLayout.card07:
        return 'Card 07';
      case MBProductCardLayout.card08:
        return 'Card 08';
      case MBProductCardLayout.card09:
        return 'Card 09';
      case MBProductCardLayout.card10:
        return 'Card 10';
      case MBProductCardLayout.card11:
        return 'Card 11';
      case MBProductCardLayout.card12:
        return 'Card 12';
      case MBProductCardLayout.card13:
        return 'Card 13';
      case MBProductCardLayout.card14:
        return 'Card 14';
      case MBProductCardLayout.card15:
        return 'Card 15';
      case MBProductCardLayout.card16:
        return 'Card 16';
      case MBProductCardLayout.card17:
        return 'Card 17';
      case MBProductCardLayout.card18:
        return 'Card 18';
      case MBProductCardLayout.card19:
        return 'Card 19';
      case MBProductCardLayout.card20:
        return 'Card 20';
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
      case MBProductCardLayout.card04:
      case MBProductCardLayout.card05:
      case MBProductCardLayout.card06:
      case MBProductCardLayout.card07:
      case MBProductCardLayout.card08:
      case MBProductCardLayout.card09:
      case MBProductCardLayout.card10:
      case MBProductCardLayout.card11:
      case MBProductCardLayout.card12:
      case MBProductCardLayout.card13:
      case MBProductCardLayout.card14:
      case MBProductCardLayout.card15:
      case MBProductCardLayout.card16:
      case MBProductCardLayout.card17:
      case MBProductCardLayout.card18:
      case MBProductCardLayout.card19:
      case MBProductCardLayout.card20:
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
      case MBProductCardLayout.card04:
      case MBProductCardLayout.card05:
      case MBProductCardLayout.card06:
      case MBProductCardLayout.card07:
      case MBProductCardLayout.card08:
      case MBProductCardLayout.card09:
      case MBProductCardLayout.card10:
      case MBProductCardLayout.card11:
      case MBProductCardLayout.card12:
      case MBProductCardLayout.card13:
      case MBProductCardLayout.card14:
      case MBProductCardLayout.card15:
      case MBProductCardLayout.card16:
      case MBProductCardLayout.card17:
      case MBProductCardLayout.card18:
      case MBProductCardLayout.card19:
      case MBProductCardLayout.card20:
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
      case MBProductCardLayout.card04:
      case MBProductCardLayout.card05:
      case MBProductCardLayout.card06:
      case MBProductCardLayout.card07:
      case MBProductCardLayout.card08:
      case MBProductCardLayout.card09:
      case MBProductCardLayout.card10:
      case MBProductCardLayout.card11:
      case MBProductCardLayout.card12:
      case MBProductCardLayout.card13:
      case MBProductCardLayout.card14:
      case MBProductCardLayout.card15:
      case MBProductCardLayout.card16:
      case MBProductCardLayout.card17:
      case MBProductCardLayout.card18:
      case MBProductCardLayout.card19:
      case MBProductCardLayout.card20:
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
      case 'card04':
      case 'card4':
      case 'card_style_04':
      case 'style04':
        return MBProductCardLayout.card04;
      case 'card05':
      case 'card5':
      case 'card_style_05':
      case 'style05':
        return MBProductCardLayout.card05;
      case 'card06':
      case 'card6':
      case 'card_style_06':
      case 'style06':
        return MBProductCardLayout.card06;
      case 'card07':
      case 'card7':
      case 'card_style_07':
      case 'style07':
        return MBProductCardLayout.card07;
      case 'card08':
      case 'card8':
      case 'card_style_08':
      case 'style08':
        return MBProductCardLayout.card08;
      case 'card09':
      case 'card9':
      case 'card_style_09':
      case 'style09':
        return MBProductCardLayout.card09;
      case 'card10':
      case 'card_style_10':
      case 'style10':
        return MBProductCardLayout.card10;
      case 'card11':
      case 'card_style_11':
      case 'style11':
        return MBProductCardLayout.card11;
      case 'card12':
      case 'card_style_12':
      case 'style12':
        return MBProductCardLayout.card12;
      case 'card13':
      case 'card_style_13':
      case 'style13':
        return MBProductCardLayout.card13;
      case 'card14':
      case 'card_style_14':
      case 'style14':
        return MBProductCardLayout.card14;
      case 'card15':
      case 'card_style_15':
      case 'style15':
        return MBProductCardLayout.card15;
      case 'card16':
      case 'card_style_16':
      case 'style16':
        return MBProductCardLayout.card16;
      case 'card17':
      case 'card_style_17':
      case 'style17':
        return MBProductCardLayout.card17;
      case 'card18':
      case 'card_style_18':
      case 'style18':
        return MBProductCardLayout.card18;
      case 'card19':
      case 'card_style_19':
      case 'style19':
        return MBProductCardLayout.card19;
      case 'card20':
      case 'card_style_20':
      case 'style20':
        return MBProductCardLayout.card20;
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
    'card4',
    'card5',
    'card6',
    'card7',
    'card8',
    'card9',
    'style01',
    'style02',
    'style03',
    'style04',
    'style05',
    'style06',
    'style07',
    'style08',
    'style09',
    'style10',
    'style11',
    'style12',
    'style13',
    'style14',
    'style15',
    'style16',
    'style17',
    'style18',
    'style19',
    'style20',
    'card_style_01',
    'card_style_02',
    'card_style_03',
    'card_style_04',
    'card_style_05',
    'card_style_06',
    'card_style_07',
    'card_style_08',
    'card_style_09',
    'card_style_10',
    'card_style_11',
    'card_style_12',
    'card_style_13',
    'card_style_14',
    'card_style_15',
    'card_style_16',
    'card_style_17',
    'card_style_18',
    'card_style_19',
    'card_style_20',
  };
}
