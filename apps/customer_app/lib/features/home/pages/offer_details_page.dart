import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../core/responsive/mb_layout_grid.dart';
import '../../../models/catalog/mb_product.dart';
import '../../../models/home/mb_offer.dart';

class MBOfferDetailsPage extends StatelessWidget {
  final MBOffer offer;
  final List<MBProduct> products;

  const MBOfferDetailsPage({
    super.key,
    required this.offer,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final grid = MBLayoutGrid.homeProducts(context);

    return MBAppLayout(
      backgroundColor: Colors.white,
      scrollable: true,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroSection(offer: offer),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MBSpacing.pageHorizontal(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MBSpacing.h(MBSpacing.md),

                Text(
                  offer.titleEn,
                  style: MBTextStyles.sectionTitle,
                ),

                MBSpacing.h(MBSpacing.xs),

                if (offer.subtitleEn.isNotEmpty)
                  Text(
                    offer.subtitleEn,
                    style: MBTextStyles.body,
                  ),

                MBSpacing.h(MBSpacing.xl),

                Text(
                  'Products in this Offer',
                  style: MBTextStyles.sectionTitle,
                ),

                MBSpacing.h(MBSpacing.sm),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: MBLayoutGrid.delegate(config: grid),
                  itemBuilder: (_, index) {
                    final product = products[index];

                    return MBProductCard(
                      title: product.titleEn,
                      priceText:
                      '৳${product.effectivePrice.toStringAsFixed(0)}',
                      oldPriceText: product.hasDiscount
                          ? '৳${product.price.toStringAsFixed(0)}'
                          : null,
                      imageUrl: product.thumbnailUrl,
                    );
                  },
                ),

                MBSpacing.h(MBSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final MBOffer offer;

  const _HeroSection({
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          offer.imageUrl,
          height: 240,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              height: 240,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: MBGradients.headerGradient,
              ),
            );
          },
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 8,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: Text(
            offer.titleEn,
            style: MBTextStyles.sectionTitle.copyWith(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

