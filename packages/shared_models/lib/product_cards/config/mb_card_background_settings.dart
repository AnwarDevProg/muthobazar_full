// MuthoBazar Product Card Design System
// File: mb_card_background_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_background_settings.dart
//
// Purpose:
// Defines optional background, top-panel, diagonal, curve, and pattern settings.

class MBCardBackgroundSettings {
  const MBCardBackgroundSettings({
    this.showTopPanel,
    this.topPanelColorToken,
    this.topPanelGradientToken,
    this.panelShape,
    this.panelHeightRatio,
    this.diagonalStartRatio,
    this.diagonalEndRatio,
    this.showPattern,
    this.patternToken,
    this.patternOpacity,
  });

  factory MBCardBackgroundSettings.fromMap(Map map) {
    return MBCardBackgroundSettings(
      showTopPanel: _readNullableBool(map['showTopPanel'] ?? map['show_top_panel']),
      topPanelColorToken: _readNullableString(
        map['topPanelColorToken'] ?? map['top_panel_color_token'],
      ),
      topPanelGradientToken: _readNullableString(
        map['topPanelGradientToken'] ?? map['top_panel_gradient_token'],
      ),
      panelShape: _readNullableString(map['panelShape'] ?? map['panel_shape']),
      panelHeightRatio: _readNullableDouble(
        map['panelHeightRatio'] ?? map['panel_height_ratio'],
      ),
      diagonalStartRatio: _readNullableDouble(
        map['diagonalStartRatio'] ?? map['diagonal_start_ratio'],
      ),
      diagonalEndRatio: _readNullableDouble(
        map['diagonalEndRatio'] ?? map['diagonal_end_ratio'],
      ),
      showPattern: _readNullableBool(map['showPattern'] ?? map['show_pattern']),
      patternToken: _readNullableString(map['patternToken'] ?? map['pattern_token']),
      patternOpacity: _readNullableDouble(
        map['patternOpacity'] ?? map['pattern_opacity'],
      ),
    );
  }

  final bool? showTopPanel;
  final String? topPanelColorToken;
  final String? topPanelGradientToken;
  final String? panelShape;
  final double? panelHeightRatio;
  final double? diagonalStartRatio;
  final double? diagonalEndRatio;
  final bool? showPattern;
  final String? patternToken;
  final double? patternOpacity;

  bool get isEmpty => toMap().isEmpty;
  bool get isNotEmpty => !isEmpty;

  MBCardBackgroundSettings copyWith({
    Object? showTopPanel = _sentinel,
    Object? topPanelColorToken = _sentinel,
    Object? topPanelGradientToken = _sentinel,
    Object? panelShape = _sentinel,
    Object? panelHeightRatio = _sentinel,
    Object? diagonalStartRatio = _sentinel,
    Object? diagonalEndRatio = _sentinel,
    Object? showPattern = _sentinel,
    Object? patternToken = _sentinel,
    Object? patternOpacity = _sentinel,
  }) {
    return MBCardBackgroundSettings(
      showTopPanel: identical(showTopPanel, _sentinel)
          ? this.showTopPanel
          : _readNullableBool(showTopPanel),
      topPanelColorToken: identical(topPanelColorToken, _sentinel)
          ? this.topPanelColorToken
          : _readNullableString(topPanelColorToken),
      topPanelGradientToken: identical(topPanelGradientToken, _sentinel)
          ? this.topPanelGradientToken
          : _readNullableString(topPanelGradientToken),
      panelShape: identical(panelShape, _sentinel)
          ? this.panelShape
          : _readNullableString(panelShape),
      panelHeightRatio: identical(panelHeightRatio, _sentinel)
          ? this.panelHeightRatio
          : _readNullableDouble(panelHeightRatio),
      diagonalStartRatio: identical(diagonalStartRatio, _sentinel)
          ? this.diagonalStartRatio
          : _readNullableDouble(diagonalStartRatio),
      diagonalEndRatio: identical(diagonalEndRatio, _sentinel)
          ? this.diagonalEndRatio
          : _readNullableDouble(diagonalEndRatio),
      showPattern: identical(showPattern, _sentinel)
          ? this.showPattern
          : _readNullableBool(showPattern),
      patternToken: identical(patternToken, _sentinel)
          ? this.patternToken
          : _readNullableString(patternToken),
      patternOpacity: identical(patternOpacity, _sentinel)
          ? this.patternOpacity
          : _readNullableDouble(patternOpacity),
    );
  }

  Map<String, Object?> toMap() {
    return _cleanMap({
      'showTopPanel': showTopPanel,
      'topPanelColorToken': topPanelColorToken,
      'topPanelGradientToken': topPanelGradientToken,
      'panelShape': panelShape,
      'panelHeightRatio': panelHeightRatio,
      'diagonalStartRatio': diagonalStartRatio,
      'diagonalEndRatio': diagonalEndRatio,
      'showPattern': showPattern,
      'patternToken': patternToken,
      'patternOpacity': patternOpacity,
    });
  }

  static const Object _sentinel = Object();
}


String? _readNullableString(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

bool? _readNullableBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;

  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return null;
}

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

double? _readNullableDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

Map<String, Object?> _cleanMap(Map<String, Object?> map) {
  return Map<String, Object?>.fromEntries(
    map.entries.where((entry) => entry.value != null),
  );
}
