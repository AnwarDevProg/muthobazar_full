import 'package:flutter/material.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../models/catalog/mb_brand.dart';
import '../../../models/catalog/mb_category.dart';
import '../../../models/catalog/mb_product.dart';
import '../../../models/home/mb_banner.dart';
import '../../../models/home/mb_home_config.dart';
import '../../../models/home/mb_home_section.dart';
import '../../../models/home/mb_offer.dart';
import 'sections/mb_home_category_grid_section.dart';
import 'sections/mb_home_hero_banner_section.dart';
import 'sections/mb_home_offer_strip_section.dart';
import 'sections/mb_home_product_grid_section.dart';
import 'sections/mb_home_product_horizontal_section.dart';
import 'sections/mb_home_unknown_section.dart';

// MB Home Renderer
// ----------------
// Section-driven home renderer styled to match the old approved MuthoBazar UI.
//
// Improvements:
// - keeps dynamic section order from MBHomeConfig
// - adds centralized section spacing control
// - filters empty sections safely
// - keeps data resolving logic clean
// - preserves old-page style structure while staying CMS-ready

class MBHomeRenderer extends StatelessWidget {
  final MBHomeConfig config;
  final List<MBProduct> products;
  final List<MBCategory> categories;
  final List<MBBrand> brands;

  final void Function(MBBanner banner)? onBannerTap;
  final void Function(MBOffer offer)? onOfferTap;
  final void Function(MBCategory category)? onCategoryTap;
  final void Function(MBProduct product)? onProductTap;
  final VoidCallback? onViewAllTap;

  const MBHomeRenderer({
    super.key,
    required this.config,
    required this.products,
    required this.categories,
    required this.brands,
    this.onBannerTap,
    this.onOfferTap,
    this.onCategoryTap,
    this.onProductTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final sections = config.activeSections;
    final visibleSections = sections
        .map((section) => _buildSection(context, section))
        .whereType<Widget>()
        .toList();

    if (visibleSections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        visibleSections.length,
            (index) {
          final widget = visibleSections[index];
          final bool isLast = index == visibleSections.length - 1;

          return Padding(
            padding: EdgeInsets.only(
              bottom: isLast ? 0 : _sectionBottomSpacing(context),
            ),
            child: widget,
          );
        },
      ),
    );
  }

  Widget? _buildSection(BuildContext context, MBHomeSection section) {
    switch (section.sectionType) {
      case 'hero_banner':
        final banners = _resolveBanners(section);
        if (banners.isEmpty) return null;

        return MBHomeHeroBannerSection(
          section: section,
          banners: banners,
          onBannerTap: onBannerTap,
        );

      case 'category_grid':
        final resolvedCategories = _resolveCategories(section);
        if (resolvedCategories.isEmpty) return null;

        return MBHomeCategoryGridSection(
          section: section,
          categories: resolvedCategories,
          onCategoryTap: onCategoryTap,
        );

      case 'product_horizontal':
        final resolvedProducts = _resolveProducts(section);
        if (resolvedProducts.isEmpty) return null;

        return MBHomeProductHorizontalSection(
          section: section,
          products: resolvedProducts,
          onProductTap: onProductTap,
          onViewAllTap: onViewAllTap,
        );

      case 'product_grid':
        final resolvedProducts = _resolveProducts(section);
        if (resolvedProducts.isEmpty) return null;

        return MBHomeProductGridSection(
          section: section,
          products: resolvedProducts,
          onProductTap: onProductTap,
          onViewAllTap: onViewAllTap,
        );

      case 'offer_strip':
        final resolvedOffers = _resolveOffers(section);
        if (resolvedOffers.isEmpty) return null;

        return MBHomeOfferStripSection(
          section: section,
          offers: resolvedOffers,
          onOfferTap: onOfferTap,
        );

      default:
        return MBHomeUnknownSection(section: section);
    }
  }

  double _sectionBottomSpacing(BuildContext context) {
    return MBSpacing.sectionGap(context);
  }

  List<MBBanner> _resolveBanners(MBHomeSection section) {
    final all = config.activeBanners;

    if (section.bannerIds.isNotEmpty) {
      return all
          .where((banner) => section.bannerIds.contains(banner.id))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return all..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<MBOffer> _resolveOffers(MBHomeSection section) {
    final all = config.activeOffers;

    if (section.offerIds.isNotEmpty) {
      return all.where((offer) => section.offerIds.contains(offer.id)).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return all..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<MBCategory> _resolveCategories(MBHomeSection section) {
    if (section.categoryIds.isNotEmpty) {
      return categories
          .where(
            (category) =>
        category.isActive && section.categoryIds.contains(category.id),
      )
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return categories.where((category) => category.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<MBProduct> _resolveProducts(MBHomeSection section) {
    final activeProducts = products.where((product) => product.isEnabled).toList();

    switch (section.dataSourceType) {
      case 'manual':
        return activeProducts
            .where((product) => section.productIds.contains(product.id))
            .take(section.itemLimit)
            .toList();

      case 'featured':
        return activeProducts
            .where((product) => product.isFeatured)
            .take(section.itemLimit)
            .toList();

      case 'flash_sale':
        return activeProducts
            .where((product) => product.isFlashSale)
            .take(section.itemLimit)
            .toList();

      case 'new_arrival':
        return activeProducts
            .where((product) => product.isNewArrival)
            .take(section.itemLimit)
            .toList();

      case 'best_seller':
        return activeProducts
            .where((product) => product.isBestSeller)
            .take(section.itemLimit)
            .toList();

      case 'recommended':
        return activeProducts.take(section.itemLimit).toList();

      case 'category':
        return activeProducts
            .where((product) => product.categoryId == section.sourceCategoryId)
            .take(section.itemLimit)
            .toList();

      case 'brand':
        return activeProducts
            .where((product) => product.brandId == section.sourceBrandId)
            .take(section.itemLimit)
            .toList();

      default:
        return activeProducts.take(section.itemLimit).toList();
    }
  }
}

