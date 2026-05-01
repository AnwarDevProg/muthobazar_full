// MuthoBazar Product Card Design System
// File: mb_card_settings_override.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_settings_override.dart
//
// Purpose:
// Defines the sparse, optional per-instance card settings override.
//
// Design rule:
// - null group = no override.
// - empty group = no custom value.
// - unknown/unsupported groups should be ignored by a specific card variant.
// - each card variant decides which groups/fields it supports.
//
// Merge flow:
// system defaults
// -> family defaults
// -> variant defaults
// -> preset defaults
// -> this per-instance override.

import 'mb_card_action_settings.dart';
import 'mb_card_accent_settings.dart';
import 'mb_card_animation_settings.dart';
import 'mb_card_background_settings.dart';
import 'mb_card_badge_settings.dart';
import 'mb_card_border_effect_settings.dart';
import 'mb_card_delivery_settings.dart';
import 'mb_card_indicator_settings.dart';
import 'mb_card_layout_settings.dart';
import 'mb_card_media_settings.dart';
import 'mb_card_meta_settings.dart';
import 'mb_card_price_settings.dart';
import 'mb_card_progress_settings.dart';
import 'mb_card_quantity_settings.dart';
import 'mb_card_rating_settings.dart';
import 'mb_card_ribbon_settings.dart';
import 'mb_card_stock_settings.dart';
import 'mb_card_surface_settings.dart';
import 'mb_card_timer_settings.dart';
import 'mb_card_typography_settings.dart';

class MBCardSettingsOverride {
  const MBCardSettingsOverride({
    this.surface,
    this.layout,
    this.background,
    this.typography,
    this.accent,
    this.borderEffect,
    this.price,
    this.actions,
    this.media,
    this.badges,
    this.meta,
    this.stock,
    this.delivery,
    this.rating,
    this.quantity,
    this.timer,
    this.progress,
    this.indicator,
    this.ribbon,
    this.animation,
  });

  factory MBCardSettingsOverride.fromMap(Map map) {
    return MBCardSettingsOverride(
      surface: _readGroup(
        map['surface'],
        (value) => MBCardSurfaceSettings.fromMap(value),
      ),
      layout: _readGroup(
        map['layout'],
        (value) => MBCardLayoutSettings.fromMap(value),
      ),
      background: _readGroup(
        map['background'],
        (value) => MBCardBackgroundSettings.fromMap(value),
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
      stock: _readGroup(
        map['stock'],
        (value) => MBCardStockSettings.fromMap(value),
      ),
      delivery: _readGroup(
        map['delivery'],
        (value) => MBCardDeliverySettings.fromMap(value),
      ),
      rating: _readGroup(
        map['rating'],
        (value) => MBCardRatingSettings.fromMap(value),
      ),
      quantity: _readGroup(
        map['quantity'],
        (value) => MBCardQuantitySettings.fromMap(value),
      ),
      timer: _readGroup(
        map['timer'],
        (value) => MBCardTimerSettings.fromMap(value),
      ),
      progress: _readGroup(
        map['progress'],
        (value) => MBCardProgressSettings.fromMap(value),
      ),
      indicator: _readGroup(
        map['indicator'],
        (value) => MBCardIndicatorSettings.fromMap(value),
      ),
      ribbon: _readGroup(
        map['ribbon'],
        (value) => MBCardRibbonSettings.fromMap(value),
      ),
      animation: _readGroup(
        map['animation'],
        (value) => MBCardAnimationSettings.fromMap(value),
      ),
    );
  }

  final MBCardSurfaceSettings? surface;
  final MBCardLayoutSettings? layout;
  final MBCardBackgroundSettings? background;
  final MBCardTypographySettings? typography;
  final MBCardAccentSettings? accent;
  final MBCardBorderEffectSettings? borderEffect;
  final MBCardPriceSettings? price;
  final MBCardActionSettings? actions;
  final MBCardMediaSettings? media;
  final MBCardBadgeSettings? badges;
  final MBCardMetaSettings? meta;
  final MBCardStockSettings? stock;
  final MBCardDeliverySettings? delivery;
  final MBCardRatingSettings? rating;
  final MBCardQuantitySettings? quantity;
  final MBCardTimerSettings? timer;
  final MBCardProgressSettings? progress;
  final MBCardIndicatorSettings? indicator;
  final MBCardRibbonSettings? ribbon;
  final MBCardAnimationSettings? animation;

  bool get isEmpty => toMap().isEmpty;
  bool get isNotEmpty => !isEmpty;

  MBCardSettingsOverride copyWith({
    Object? surface = _sentinel,
    Object? layout = _sentinel,
    Object? background = _sentinel,
    Object? typography = _sentinel,
    Object? accent = _sentinel,
    Object? borderEffect = _sentinel,
    Object? price = _sentinel,
    Object? actions = _sentinel,
    Object? media = _sentinel,
    Object? badges = _sentinel,
    Object? meta = _sentinel,
    Object? stock = _sentinel,
    Object? delivery = _sentinel,
    Object? rating = _sentinel,
    Object? quantity = _sentinel,
    Object? timer = _sentinel,
    Object? progress = _sentinel,
    Object? indicator = _sentinel,
    Object? ribbon = _sentinel,
    Object? animation = _sentinel,
  }) {
    return MBCardSettingsOverride(
      surface: identical(surface, _sentinel)
          ? this.surface
          : surface as MBCardSurfaceSettings?,
      layout: identical(layout, _sentinel)
          ? this.layout
          : layout as MBCardLayoutSettings?,
      background: identical(background, _sentinel)
          ? this.background
          : background as MBCardBackgroundSettings?,
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
      stock: identical(stock, _sentinel)
          ? this.stock
          : stock as MBCardStockSettings?,
      delivery: identical(delivery, _sentinel)
          ? this.delivery
          : delivery as MBCardDeliverySettings?,
      rating: identical(rating, _sentinel)
          ? this.rating
          : rating as MBCardRatingSettings?,
      quantity: identical(quantity, _sentinel)
          ? this.quantity
          : quantity as MBCardQuantitySettings?,
      timer: identical(timer, _sentinel)
          ? this.timer
          : timer as MBCardTimerSettings?,
      progress: identical(progress, _sentinel)
          ? this.progress
          : progress as MBCardProgressSettings?,
      indicator: identical(indicator, _sentinel)
          ? this.indicator
          : indicator as MBCardIndicatorSettings?,
      ribbon: identical(ribbon, _sentinel)
          ? this.ribbon
          : ribbon as MBCardRibbonSettings?,
      animation: identical(animation, _sentinel)
          ? this.animation
          : animation as MBCardAnimationSettings?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (_hasMap(surface)) 'surface': surface!.toMap(),
      if (_hasMap(layout)) 'layout': layout!.toMap(),
      if (_hasMap(background)) 'background': background!.toMap(),
      if (_hasMap(typography)) 'typography': typography!.toMap(),
      if (_hasMap(accent)) 'accent': accent!.toMap(),
      if (_hasMap(borderEffect)) 'borderEffect': borderEffect!.toMap(),
      if (_hasMap(price)) 'price': price!.toMap(),
      if (_hasMap(actions)) 'actions': actions!.toMap(),
      if (_hasMap(media)) 'media': media!.toMap(),
      if (_hasMap(badges)) 'badges': badges!.toMap(),
      if (_hasMap(meta)) 'meta': meta!.toMap(),
      if (_hasMap(stock)) 'stock': stock!.toMap(),
      if (_hasMap(delivery)) 'delivery': delivery!.toMap(),
      if (_hasMap(rating)) 'rating': rating!.toMap(),
      if (_hasMap(quantity)) 'quantity': quantity!.toMap(),
      if (_hasMap(timer)) 'timer': timer!.toMap(),
      if (_hasMap(progress)) 'progress': progress!.toMap(),
      if (_hasMap(indicator)) 'indicator': indicator!.toMap(),
      if (_hasMap(ribbon)) 'ribbon': ribbon!.toMap(),
      if (_hasMap(animation)) 'animation': animation!.toMap(),
    };
  }

  @override
  String toString() {
    return 'MBCardSettingsOverride(${toMap().keys.join(', ')})';
  }

  static const Object _sentinel = Object();

  static T? _readGroup<T>(
    Object? raw,
    T Function(Map value) builder,
  ) {
    if (raw is Map) {
      return builder(raw);
    }

    return null;
  }

  static bool _hasMap(dynamic group) {
    if (group == null) return false;

    final value = group.toMap();
    return value is Map && value.isNotEmpty;
  }
}
