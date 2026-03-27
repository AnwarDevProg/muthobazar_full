import 'dart:convert';

import 'mb_banner.dart';
import 'mb_home_section.dart';
import 'mb_offer.dart';

// MB Home Config Model
// --------------------
// The top-level home engine configuration.
// Holds all home banners, offers, and sections together.
//
// This allows the app to build an Amazon-style dynamic home page.

class MBHomeConfig {
  final List<MBBanner> banners;
  final List<MBOffer> offers;
  final List<MBHomeSection> sections;

  const MBHomeConfig({
    this.banners = const [],
    this.offers = const [],
    this.sections = const [],
  });

  factory MBHomeConfig.empty() => const MBHomeConfig();

  MBHomeConfig copyWith({
    List<MBBanner>? banners,
    List<MBOffer>? offers,
    List<MBHomeSection>? sections,
  }) {
    return MBHomeConfig(
      banners: banners ?? this.banners,
      offers: offers ?? this.offers,
      sections: sections ?? this.sections,
    );
  }

  List<MBBanner> get activeBanners => banners
      .where((banner) => banner.isAvailable)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<MBOffer> get activeOffers => offers
      .where((offer) => offer.isAvailable)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<MBHomeSection> get activeSections => sections
      .where((section) => section.isActive)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<MBOffer> get floatingOffers => activeOffers
      .where((offer) => offer.canShowAsFloating)
      .toList()
    ..sort((a, b) => b.floatingPriority.compareTo(a.floatingPriority));

  Map<String, dynamic> toMap() {
    return {
      'banners': banners.map((e) => e.toMap()).toList(),
      'offers': offers.map((e) => e.toMap()).toList(),
      'sections': sections.map((e) => e.toMap()).toList(),
    };
  }

  factory MBHomeConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBHomeConfig.empty();

    return MBHomeConfig(
      banners: (map['banners'] as List<dynamic>? ?? const [])
          .map((e) => MBBanner.fromMap(e as Map<String, dynamic>))
          .toList(),
      offers: (map['offers'] as List<dynamic>? ?? const [])
          .map((e) => MBOffer.fromMap(e as Map<String, dynamic>))
          .toList(),
      sections: (map['sections'] as List<dynamic>? ?? const [])
          .map((e) => MBHomeSection.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBHomeConfig.fromJson(String source) =>
      MBHomeConfig.fromMap(json.decode(source) as Map<String, dynamic>);
}











