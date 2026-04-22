// MuthoBazar Product Card Design System
// File: mb_card_price_mode.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_price_mode.dart
//
// Purpose:
// Defines the supported price display modes used by the product card system.
//
// A price mode represents:
// - how price information should be rendered on a card
// - whether only final price, original + final price, or discount-related
//   information should be shown
// - a stable persisted identifier for config, Firestore storage, and renderer logic
//
// Important:
// - Persist the stable string id, never the enum index.
// - Renderers should use this mode to decide visibility and emphasis rules for
//   price blocks, instead of scattering price-condition logic across widgets.
// - Some variants may support only a subset of these modes.

enum MBCardPriceMode {
  finalOnly,
  originalAndFinal,
  originalFinalAndDiscount,
  hidden,
}

extension MBCardPriceModeX on MBCardPriceMode {
  String get id {
    switch (this) {
      case MBCardPriceMode.finalOnly:
        return 'final_only';
      case MBCardPriceMode.originalAndFinal:
        return 'original_and_final';
      case MBCardPriceMode.originalFinalAndDiscount:
        return 'original_final_and_discount';
      case MBCardPriceMode.hidden:
        return 'hidden';
    }
  }

  String get label {
    switch (this) {
      case MBCardPriceMode.finalOnly:
        return 'Final Only';
      case MBCardPriceMode.originalAndFinal:
        return 'Original And Final';
      case MBCardPriceMode.originalFinalAndDiscount:
        return 'Original, Final And Discount';
      case MBCardPriceMode.hidden:
        return 'Hidden';
    }
  }

  bool get showsFinalPrice {
    switch (this) {
      case MBCardPriceMode.finalOnly:
      case MBCardPriceMode.originalAndFinal:
      case MBCardPriceMode.originalFinalAndDiscount:
        return true;
      case MBCardPriceMode.hidden:
        return false;
    }
  }

  bool get showsOriginalPrice {
    switch (this) {
      case MBCardPriceMode.originalAndFinal:
      case MBCardPriceMode.originalFinalAndDiscount:
        return true;
      case MBCardPriceMode.finalOnly:
      case MBCardPriceMode.hidden:
        return false;
    }
  }

  bool get showsDiscountInfo {
    switch (this) {
      case MBCardPriceMode.originalFinalAndDiscount:
        return true;
      case MBCardPriceMode.finalOnly:
      case MBCardPriceMode.originalAndFinal:
      case MBCardPriceMode.hidden:
        return false;
    }
  }

  bool get hidesAllPrice => this == MBCardPriceMode.hidden;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'showsFinalPrice': showsFinalPrice,
      'showsOriginalPrice': showsOriginalPrice,
      'showsDiscountInfo': showsDiscountInfo,
      'hidesAllPrice': hidesAllPrice,
    };
  }
}

class MBCardPriceModeHelper {
  const MBCardPriceModeHelper._();

  static const List<MBCardPriceMode> values = MBCardPriceMode.values;

  static const List<MBCardPriceMode> defaultVisibleModes = <MBCardPriceMode>[
    MBCardPriceMode.finalOnly,
    MBCardPriceMode.originalAndFinal,
    MBCardPriceMode.originalFinalAndDiscount,
  ];

  static MBCardPriceMode parse(
      String? raw, {
        MBCardPriceMode fallback = MBCardPriceMode.originalAndFinal,
      }) {
    if (raw == null) {
      return fallback;
    }

    final normalized = _normalize(raw);
    if (normalized.isEmpty) {
      return fallback;
    }

    for (final mode in MBCardPriceMode.values) {
      if (_normalize(mode.id) == normalized) {
        return mode;
      }
      if (_normalize(mode.label) == normalized) {
        return mode;
      }
      if (_normalize(mode.name) == normalized) {
        return mode;
      }
    }

    switch (normalized) {
      case 'final':
      case 'finalprice':
      case 'final_price_only':
        return MBCardPriceMode.finalOnly;
      case 'original_final':
      case 'price_pair':
        return MBCardPriceMode.originalAndFinal;
      case 'full_discount':
      case 'with_discount':
      case 'discount':
        return MBCardPriceMode.originalFinalAndDiscount;
      default:
        return fallback;
    }
  }

  static bool isValidId(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return false;
    }

    final normalized = _normalize(raw);
    for (final mode in MBCardPriceMode.values) {
      if (_normalize(mode.id) == normalized) {
        return true;
      }
    }
    return false;
  }

  static List<String> ids() {
    return MBCardPriceMode.values
        .map((mode) => mode.id)
        .toList(growable: false);
  }

  static List<String> labels() {
    return MBCardPriceMode.values
        .map((mode) => mode.label)
        .toList(growable: false);
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }
}
