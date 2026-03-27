import 'dart:math';

import '../../../models/home/mb_offer.dart';

// MB Offer Overlay Manager
// ------------------------
// Controls floating promo offers during a single app session.

class MBOfferOverlayManager {
  final Set<String> _shownOfferIds = <String>{};
  final Random _random = Random();

  bool hasShown(String offerId) => _shownOfferIds.contains(offerId);

  void markShown(String offerId) {
    _shownOfferIds.add(offerId);
  }

  void markClosed(String offerId) {
    _shownOfferIds.add(offerId);
  }

  void resetSession() {
    _shownOfferIds.clear();
  }

  List<MBOffer> eligibleOffers(List<MBOffer> offers) {
    return offers.where((offer) {
      if (!offer.canShowAsFloating) return false;

      if (offer.showOncePerAppLife && hasShown(offer.id)) {
        return false;
      }

      return true;
    }).toList();
  }

  MBOffer? pickOne(List<MBOffer> offers) {
    final eligible = eligibleOffers(offers);

    if (eligible.isEmpty) return null;

    final randomEligible = eligible.where((e) => e.randomEligible).toList();

    if (randomEligible.isNotEmpty) {
      final picked = randomEligible[_random.nextInt(randomEligible.length)];
      markShown(picked.id);
      return picked;
    }

    eligible.sort((a, b) => b.floatingPriority.compareTo(a.floatingPriority));
    final picked = eligible.first;
    markShown(picked.id);
    return picked;
  }

  MBOffer? pickNext(List<MBOffer> offers, {String? currentOfferId}) {
    final eligible = eligibleOffers(offers).where((offer) {
      if (currentOfferId == null) return true;
      return offer.id != currentOfferId;
    }).toList();

    if (eligible.isEmpty) return null;

    final randomEligible = eligible.where((e) => e.randomEligible).toList();

    if (randomEligible.isNotEmpty) {
      final picked = randomEligible[_random.nextInt(randomEligible.length)];
      markShown(picked.id);
      return picked;
    }

    eligible.sort((a, b) => b.floatingPriority.compareTo(a.floatingPriority));
    final picked = eligible.first;
    markShown(picked.id);
    return picked;
  }
}

