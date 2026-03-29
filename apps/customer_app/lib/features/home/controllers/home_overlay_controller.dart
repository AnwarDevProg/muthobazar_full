import 'dart:math';

import 'package:shared_models/home/mb_home_config.dart';
import 'package:shared_models/marketing/mb_offer.dart';

// MB Home Overlay Controller
// --------------------------
// Keeps session-only memory for floating offers.
// "During this app life" logic.

class MBHomeOverlayController {
  final Set<String> _shownOfferIds = <String>{};

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

  MBOffer? pickOffer(MBHomeConfig config) {
    final eligible = config.floatingOffers.where((offer) {
      if (!offer.canShowAsFloating) return false;
      if (offer.showOncePerAppLife && hasShown(offer.id)) return false;
      return true;
    }).toList();

    if (eligible.isEmpty) return null;

    final randomEligible = eligible.where((e) => e.randomEligible).toList();

    if (randomEligible.isNotEmpty) {
      final random = Random();
      final picked = randomEligible[random.nextInt(randomEligible.length)];
      markShown(picked.id);
      return picked;
    }

    eligible.sort((a, b) => b.floatingPriority.compareTo(a.floatingPriority));
    final picked = eligible.first;
    markShown(picked.id);
    return picked;
  }
}

