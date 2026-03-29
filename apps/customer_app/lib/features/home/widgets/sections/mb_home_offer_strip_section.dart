import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';
// MB Home Offer Strip Section
// ---------------------------
// Styled to match the old approved promo banner UI.

class MBHomeOfferStripSection extends StatelessWidget {
  final MBHomeSection section;
  final List<MBOffer> offers;
  final void Function(MBOffer offer)? onOfferTap;

  const MBHomeOfferStripSection({
    super.key,
    required this.section,
    required this.offers,
    this.onOfferTap,
  });

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();

    final offer = offers.first;

    return GestureDetector(
      onTap: () => onOfferTap?.call(offer),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
        decoration: BoxDecoration(
          gradient: MBGradients.primaryGradient,
          borderRadius: BorderRadius.circular(MBRadius.xl),
          boxShadow: [
            BoxShadow(
              color: MBColors.shadow.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(MBRadius.lg),
              ),
              child: const Icon(
                Icons.local_offer_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            MBSpacing.w(MBSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.titleEn.isNotEmpty
                        ? offer.titleEn
                        : 'Special Deals Today!',
                    style: MBAppText.headline3(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    offer.subtitleEn.isNotEmpty
                        ? offer.subtitleEn
                        : 'Save more on groceries, essentials, and daily picks.',
                    style: MBAppText.bodySmall(context).copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}