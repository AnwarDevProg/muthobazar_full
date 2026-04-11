// File: mb_product_card_layout.dart
// Product card layout helpers shared across admin, customer, and backend-facing model logic.

enum MBProductCardLayout {
  standard,
  compact,
  deal,
  featured,
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
    }
  }

  bool get isGridSafe {
    switch (this) {
      case MBProductCardLayout.standard:
      case MBProductCardLayout.compact:
      case MBProductCardLayout.deal:
        return true;
      case MBProductCardLayout.featured:
        return false;
    }
  }

  bool get isHorizontalSafe {
    switch (this) {
      case MBProductCardLayout.standard:
      case MBProductCardLayout.compact:
      case MBProductCardLayout.deal:
      case MBProductCardLayout.featured:
        return true;
    }
  }
}

class MBProductCardLayoutHelper {
  const MBProductCardLayoutHelper._();

  static const MBProductCardLayout fallback = MBProductCardLayout.standard;

  static List<MBProductCardLayout> get values => MBProductCardLayout.values;

  static MBProductCardLayout parse(dynamic raw) {
    final normalized = raw?.toString().trim().toLowerCase() ?? '';

    switch (normalized) {
      case 'compact':
        return MBProductCardLayout.compact;
      case 'deal':
        return MBProductCardLayout.deal;
      case 'featured':
        return MBProductCardLayout.featured;
      case 'standard':
      default:
        return fallback;
    }
  }

  static String normalize(dynamic raw) {
    return parse(raw).value;
  }

  static bool isValid(dynamic raw) {
    final normalized = raw?.toString().trim().toLowerCase() ?? '';
    return normalized == 'standard' ||
        normalized == 'compact' ||
        normalized == 'deal' ||
        normalized == 'featured';
  }

  static List<String> get allowedValues {
    return values.map((item) => item.value).toList(growable: false);
  }

  static MBProductCardLayout gridSafeOrFallback(dynamic raw) {
    final parsed = parse(raw);
    return parsed.isGridSafe ? parsed : fallback;
  }

  static MBProductCardLayout horizontalSafeOrFallback(dynamic raw) {
    final parsed = parse(raw);
    return parsed.isHorizontalSafe ? parsed : fallback;
  }
}
