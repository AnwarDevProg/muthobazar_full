// MuthoBazar Product Card Design System
// File: mb_card_footprint.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_footprint.dart
//
// Purpose:
// Defines the structural footprint options used by the product card system.
//
// A card footprint represents:
// - the spatial size intent of a card inside a section/grid layout
// - whether a card is expected to occupy half-width, full-width, or a larger
//   block-style area
// - a stable persisted identifier for registry/config usage
//
// Important:
// - Persist the stable string id, never the enum index.
// - Family may imply a default footprint, but variants can still explicitly
//   declare a footprint.
// - UI layout systems should resolve actual pixel sizing from this footprint,
//   not from arbitrary hardcoded assumptions spread across widgets.

enum MBCardFootprint {
  halfWidth,
  fullWidth,
  twoByTwo,
}

extension MBCardFootprintX on MBCardFootprint {
  String get id {
    switch (this) {
      case MBCardFootprint.halfWidth:
        return 'half';
      case MBCardFootprint.fullWidth:
        return 'full';
      case MBCardFootprint.twoByTwo:
        return 'two_by_two';
    }
  }

  String get label {
    switch (this) {
      case MBCardFootprint.halfWidth:
        return 'Half Width';
      case MBCardFootprint.fullWidth:
        return 'Full Width';
      case MBCardFootprint.twoByTwo:
        return 'Two By Two';
    }
  }

  bool get isHalfWidth => this == MBCardFootprint.halfWidth;

  bool get isFullWidth => this == MBCardFootprint.fullWidth;

  bool get isLargeBlock => this == MBCardFootprint.twoByTwo;

  bool get isMultiCell =>
      this == MBCardFootprint.fullWidth || this == MBCardFootprint.twoByTwo;

  int get horizontalCellSpan {
    switch (this) {
      case MBCardFootprint.halfWidth:
        return 1;
      case MBCardFootprint.fullWidth:
      case MBCardFootprint.twoByTwo:
        return 2;
    }
  }

  int get verticalCellSpan {
    switch (this) {
      case MBCardFootprint.halfWidth:
      case MBCardFootprint.fullWidth:
        return 1;
      case MBCardFootprint.twoByTwo:
        return 2;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'horizontalCellSpan': horizontalCellSpan,
      'verticalCellSpan': verticalCellSpan,
      'isMultiCell': isMultiCell,
    };
  }
}

class MBCardFootprintHelper {
  const MBCardFootprintHelper._();

  static const List<MBCardFootprint> values = MBCardFootprint.values;

  static const List<MBCardFootprint> starterValues = <MBCardFootprint>[
    MBCardFootprint.halfWidth,
    MBCardFootprint.fullWidth,
  ];

  static MBCardFootprint parse(
      String? raw, {
        MBCardFootprint fallback = MBCardFootprint.halfWidth,
      }) {
    if (raw == null) {
      return fallback;
    }

    final normalized = _normalize(raw);
    if (normalized.isEmpty) {
      return fallback;
    }

    for (final footprint in MBCardFootprint.values) {
      if (_normalize(footprint.id) == normalized) {
        return footprint;
      }
      if (_normalize(footprint.label) == normalized) {
        return footprint;
      }
      if (_normalize(footprint.name) == normalized) {
        return footprint;
      }
    }

    switch (normalized) {
      case 'half_width':
      case 'half-width':
        return MBCardFootprint.halfWidth;
      case 'full_width':
      case 'full-width':
        return MBCardFootprint.fullWidth;
      case 'twobytwo':
      case '2x2':
      case 'two_x_two':
      case 'two-by-two':
        return MBCardFootprint.twoByTwo;
      default:
        return fallback;
    }
  }

  static bool isValidId(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return false;
    }

    final normalized = _normalize(raw);
    for (final footprint in MBCardFootprint.values) {
      if (_normalize(footprint.id) == normalized) {
        return true;
      }
    }
    return false;
  }

  static List<String> ids() {
    return MBCardFootprint.values
        .map((footprint) => footprint.id)
        .toList(growable: false);
  }

  static List<String> labels() {
    return MBCardFootprint.values
        .map((footprint) => footprint.label)
        .toList(growable: false);
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }
}
