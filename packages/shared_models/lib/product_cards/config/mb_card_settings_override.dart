// MuthoBazar Product Card Design System
// File: mb_card_settings_override.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_settings_override.dart
//
// Purpose:
// Defines the optional per-instance settings override container used by the
// product card system.
//
// A settings override represents:
// - partial adjustments on top of resolved family/variant/preset defaults
// - a serializable structure that can be stored with a card instance config
// - grouped override data for surface, typography, accent, border effect,
//   price, actions, media, badges, and metadata
//
// Important:
// - This model is intentionally partial. Each group is nullable so only the
//   explicitly overridden groups need to be stored.
// - The UI layer should merge these values later with family defaults,
//   variant defaults, and preset values.
// - This file does not perform merge logic; it only represents structured
//   override data.

import 'mb_card_action_settings.dart';
import 'mb_card_accent_settings.dart';
import 'mb_card_badge_settings.dart';
import 'mb_card_border_effect_settings.dart';
import 'mb_card_media_settings.dart';
import 'mb_card_meta_settings.dart';
import 'mb_card_price_settings.dart';
import 'mb_card_surface_settings.dart';
import 'mb_card_typography_settings.dart';

class MBCardSettingsOverride {
  const MBCardSettingsOverride({
    this.surface,
    this.typography,
    this.accent,
    this.borderEffect,
    this.price,
    this.actions,
    this.media,
    this.badges,
    this.meta,
  });

  factory MBCardSettingsOverride.fromMap(Map<String, dynamic> map) {
    return MBCardSettingsOverride(
      surface: _readGroup(
        map['surface'],
            (value) => MBCardSurfaceSettings.fromMap(value),
      ),
      typography: _readGroup(
        map['typography'],
            (value) => MBCardTypographySettings.fromMap(value),
      ),
      accent: _readGroup(
        map['accent'],
            (value) => MBCardAccentSettings.fromMap(value),
      ),
      borderEffect: _readGroup(
        map['borderEffect'] ?? map['border_effect'],
            (value) => MBCardBorderEffectSettings.fromMap(value),
      ),
      price: _readGroup(
        map['price'],
            (value) => MBCardPriceSettings.fromMap(value),
      ),
      actions: _readGroup(
        map['actions'],
            (value) => MBCardActionSettings.fromMap(value),
      ),
      media: _readGroup(
        map['media'],
            (value) => MBCardMediaSettings.fromMap(value),
      ),
      badges: _readGroup(
        map['badges'],
            (value) => MBCardBadgeSettings.fromMap(value),
      ),
      meta: _readGroup(
        map['meta'],
            (value) => MBCardMetaSettings.fromMap(value),
      ),
    );
  }

  final MBCardSurfaceSettings? surface;
  final MBCardTypographySettings? typography;
  final MBCardAccentSettings? accent;
  final MBCardBorderEffectSettings? borderEffect;
  final MBCardPriceSettings? price;
  final MBCardActionSettings? actions;
  final MBCardMediaSettings? media;
  final MBCardBadgeSettings? badges;
  final MBCardMetaSettings? meta;

  bool get isEmpty {
    return surface == null &&
        typography == null &&
        accent == null &&
        borderEffect == null &&
        price == null &&
        actions == null &&
        media == null &&
        badges == null &&
        meta == null;
  }

  bool get isNotEmpty => !isEmpty;

  MBCardSettingsOverride copyWith({
    Object? surface = _sentinel,
    Object? typography = _sentinel,
    Object? accent = _sentinel,
    Object? borderEffect = _sentinel,
    Object? price = _sentinel,
    Object? actions = _sentinel,
    Object? media = _sentinel,
    Object? badges = _sentinel,
    Object? meta = _sentinel,
  }) {
    return MBCardSettingsOverride(
      surface: identical(surface, _sentinel)
          ? this.surface
          : surface as MBCardSurfaceSettings?,
      typography: identical(typography, _sentinel)
          ? this.typography
          : typography as MBCardTypographySettings?,
      accent: identical(accent, _sentinel)
          ? this.accent
          : accent as MBCardAccentSettings?,
      borderEffect: identical(borderEffect, _sentinel)
          ? this.borderEffect
          : borderEffect as MBCardBorderEffectSettings?,
      price: identical(price, _sentinel)
          ? this.price
          : price as MBCardPriceSettings?,
      actions: identical(actions, _sentinel)
          ? this.actions
          : actions as MBCardActionSettings?,
      media: identical(media, _sentinel)
          ? this.media
          : media as MBCardMediaSettings?,
      badges: identical(badges, _sentinel)
          ? this.badges
          : badges as MBCardBadgeSettings?,
      meta: identical(meta, _sentinel)
          ? this.meta
          : meta as MBCardMetaSettings?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (surface != null) 'surface': surface!.toMap(),
      if (typography != null) 'typography': typography!.toMap(),
      if (accent != null) 'accent': accent!.toMap(),
      if (borderEffect != null) 'borderEffect': borderEffect!.toMap(),
      if (price != null) 'price': price!.toMap(),
      if (actions != null) 'actions': actions!.toMap(),
      if (media != null) 'media': media!.toMap(),
      if (badges != null) 'badges': badges!.toMap(),
      if (meta != null) 'meta': meta!.toMap(),
    };
  }

  @override
  String toString() {
    return 'MBCardSettingsOverride('
        'surface: ${surface != null}, '
        'typography: ${typography != null}, '
        'accent: ${accent != null}, '
        'borderEffect: ${borderEffect != null}, '
        'price: ${price != null}, '
        'actions: ${actions != null}, '
        'media: ${media != null}, '
        'badges: ${badges != null}, '
        'meta: ${meta != null}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBCardSettingsOverride &&
        other.surface == surface &&
        other.typography == typography &&
        other.accent == accent &&
        other.borderEffect == borderEffect &&
        other.price == price &&
        other.actions == actions &&
        other.media == media &&
        other.badges == badges &&
        other.meta == meta;
  }

  @override
  int get hashCode {
    return Object.hash(
      surface,
      typography,
      accent,
      borderEffect,
      price,
      actions,
      media,
      badges,
      meta,
    );
  }

  static const Object _sentinel = Object();

  static T? _readGroup<T>(
      Object? raw,
      T Function(Map<String, dynamic> value) builder,
      ) {
    if (raw == null) {
      return null;
    }
    if (raw is Map<String, dynamic>) {
      return builder(raw);
    }
    if (raw is Map) {
      return builder(
        raw.map(
              (key, value) => MapEntry(key.toString(), value),
        ),
      );
    }
    return null;
  }
}
