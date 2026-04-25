// MuthoBazar Product Card Design System
// File: mb_card_rating_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_rating_settings.dart
//
// Purpose:
// Defines optional rating/review display settings for product cards.

class MBCardRatingSettings {
  const MBCardRatingSettings({
    this.showRating,
    this.showReviewCount,
    this.ratingStyleToken,
    this.maxStars,
  });

  factory MBCardRatingSettings.fromMap(Map map) {
    return MBCardRatingSettings(
      showRating: _readNullableBool(map['showRating'] ?? map['show_rating']),
      showReviewCount: _readNullableBool(
        map['showReviewCount'] ?? map['show_review_count'],
      ),
      ratingStyleToken: _readNullableString(
        map['ratingStyleToken'] ?? map['rating_style_token'],
      ),
      maxStars: _readNullableInt(map['maxStars'] ?? map['max_stars']),
    );
  }

  final bool? showRating;
  final bool? showReviewCount;
  final String? ratingStyleToken;
  final int? maxStars;

  bool get isEmpty => toMap().isEmpty;
  bool get isNotEmpty => !isEmpty;

  Map<String, Object?> toMap() {
    return _cleanMap({
      'showRating': showRating,
      'showReviewCount': showReviewCount,
      'ratingStyleToken': ratingStyleToken,
      'maxStars': maxStars,
    });
  }
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
