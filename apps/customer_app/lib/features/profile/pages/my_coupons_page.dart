import 'package:flutter/material.dart';

import 'package:shared_ui/shared_ui.dart';

class MyCouponsPage extends StatelessWidget {
  const MyCouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MBAppLayout(
      backgroundColor: MBColors.background,
      appBar: AppBar(
        title: Text(
          'My Coupons',
          style: MBAppText.sectionTitle(context),
        ),
      ),
      child: Padding(
        padding: MBScreenPadding.page(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CouponTopCard(),
            MBSpacing.h(MBSpacing.sectionGap(context)),
            ..._demoCoupons.map(
                  (coupon) => Padding(
                padding: EdgeInsets.only(
                  bottom: MBSpacing.itemGap(context),
                ),
                child: _CouponCard(coupon: coupon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponTopCard extends StatelessWidget {
  const _CouponTopCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
      decoration: BoxDecoration(
        gradient: MBGradients.primaryGradient,
        borderRadius: BorderRadius.circular(MBRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(MBRadius.lg),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: Colors.white,
            ),
          ),
          MBSpacing.w(MBSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save more on every order',
                  style: MBAppText.headline3(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  'Use available coupons before checkout to reduce order total.',
                  style: MBAppText.bodySmall(context).copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final _CouponItem coupon;

  const _CouponCard({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
      decoration: BoxDecoration(
        color: MBColors.card,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: MBGradients.primaryGradient,
              borderRadius: BorderRadius.circular(MBRadius.lg),
            ),
            child: Center(
              child: Text(
                coupon.discount,
                textAlign: TextAlign.center,
                style: MBAppText.label(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          MBSpacing.w(MBSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.title,
                  style: MBAppText.label(context).copyWith(
                    color: MBColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  coupon.description,
                  style: MBAppText.bodySmall(context).copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
                MBSpacing.h(MBSpacing.xs),
                Text(
                  'Code: ${coupon.code}',
                  style: MBAppText.bodySmall(context).copyWith(
                    color: MBColors.primaryOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  'Valid till ${coupon.expiry}',
                  style: MBAppText.caption(context).copyWith(
                    color: MBColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _CouponItem {
  final String title;
  final String description;
  final String code;
  final String discount;
  final String expiry;

  const _CouponItem({
    required this.title,
    required this.description,
    required this.code,
    required this.discount,
    required this.expiry,
  });
}

const List<_CouponItem> _demoCoupons = [
  _CouponItem(
    title: 'Flat Grocery Discount',
    description: 'Get discount on grocery orders above ৳1000.',
    code: 'SAVE100',
    discount: '৳100\nOFF',
    expiry: '20 Mar 2026',
  ),
  _CouponItem(
    title: 'Free Delivery',
    description: 'No delivery charge on selected categories.',
    code: 'FREEDEL',
    discount: 'FREE\nSHIP',
    expiry: '18 Mar 2026',
  ),
  _CouponItem(
    title: 'Weekend Offer',
    description: 'Extra savings on weekend shopping.',
    code: 'WEEKEND15',
    discount: '15%\nOFF',
    expiry: '22 Mar 2026',
  ),
];

