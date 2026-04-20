import 'package:customer_app/features/home/widgets/sections/mb_home_category_grid_section.dart';
import 'package:customer_app/features/home/widgets/sections/mb_home_hero_banner_section.dart';
import 'package:customer_app/features/home/widgets/sections/mb_home_offer_strip_section.dart';
import 'package:customer_app/features/home/widgets/sections/mb_home_product_grid_section.dart';
import 'package:customer_app/features/home/widgets/sections/mb_home_product_horizontal_section.dart';
import 'package:customer_app/features/home/widgets/sections/mb_home_unknown_section.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

// MB Home Renderer
// ----------------
// Section-driven home renderer styled to match the old approved MuthoBazar UI.
//
// Updated:
// - keeps dynamic section order from MBHomeConfig
// - adds centralized section spacing control
// - filters empty sections safely
// - keeps data resolving logic clean
// - supports variation-level merchandising for variable products
// - keeps root-level merchandising for simple products

class MBHomeRenderer extends StatelessWidget {
  final MBHomeConfig config;
  final List<MBProduct> products;
  final List<MBCategory> categories;
  final List<MBBrand> brands;

  final void Function(MBBanner banner)? onBannerTap;
  final void Function(MBOffer offer)? onOfferTap;
  final void Function(MBCategory category)? onCategoryTap;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onProductAddToCart;
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
    this.onProductAddToCart,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final sections = config.activeSections;
    final visibleSections = sections
        .map((section) => _buildSection(context, section))
        .whereType<Widget>()
        .toList(growable: false);

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
          offers: config.activeOffers,
          onProductTap: onProductTap,
          onAddToCart: onProductAddToCart,
          onViewAllTap: onViewAllTap,
        );

      case 'product_grid':
        final resolvedProducts = _resolveProducts(section);
        if (resolvedProducts.isEmpty) return null;

        return MBHomeProductGridSection(
          section: section,
          products: resolvedProducts,
          offers: config.activeOffers,
          onProductTap: onProductTap,
          onAddToCart: onProductAddToCart,
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
    final all = List<MBBanner>.from(config.activeBanners);

    if (section.bannerIds.isNotEmpty) {
      return all
          .where((banner) => section.bannerIds.contains(banner.id))
          .toList(growable: false)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    all.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return all;
  }

  List<MBOffer> _resolveOffers(MBHomeSection section) {
    final all = List<MBOffer>.from(config.activeOffers);

    if (section.offerIds.isNotEmpty) {
      return all
          .where((offer) => section.offerIds.contains(offer.id))
          .toList(growable: false)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    all.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return all;
  }

  List<MBCategory> _resolveCategories(MBHomeSection section) {
    if (section.categoryIds.isNotEmpty) {
      return categories
          .where(
            (category) =>
        category.isActive && section.categoryIds.contains(category.id),
      )
          .toList(growable: false)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return categories
        .where((category) => category.isActive)
        .toList(growable: false)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<MBProduct> _resolveProducts(MBHomeSection section) {
    final String sourceType = section.dataSourceType.trim().toLowerCase();

    final List<MBProduct> enabledProducts = products
        .where((product) => product.isEnabled)
        .toList(growable: false);

    late final List<MBProduct> resolved;

    switch (sourceType) {
      case 'manual':
      // Manual must always respect the explicit productIds list and should
      // not hide variable products just because variation stock is zero.
        resolved = enabledProducts
            .where((product) => section.productIds.contains(product.id))
            .toList(growable: false);
        break;

      case 'featured':
        resolved = enabledProducts
            .where((product) => _matchesFeatured(product))
            .where((product) => _isRenderableForDynamicHome(product))
            .toList(growable: false);
        break;

      case 'flash_sale':
        resolved = enabledProducts
            .where((product) => _matchesFlashSale(product))
            .where((product) => _isRenderableForDynamicHome(product))
            .toList(growable: false);
        break;

      case 'new_arrival':
        resolved = enabledProducts
            .where((product) => _matchesNewArrival(product))
            .where((product) => _isRenderableForDynamicHome(product))
            .toList(growable: false);
        break;

      case 'best_seller':
        resolved = enabledProducts
            .where((product) => _matchesBestSeller(product))
            .where((product) => _isRenderableForDynamicHome(product))
            .toList(growable: false);
        break;

      case 'recommended':
        resolved = enabledProducts
            .where((product) => _matchesRecommended(product))
            .where((product) => _isRenderableForDynamicHome(product))
            .toList(growable: false);
        break;

      case 'category':
        resolved = enabledProducts
            .where((product) => product.categoryId == section.sourceCategoryId)
            .where((product) => _isRenderableForDynamicHome(product))
            .toList(growable: false);
        break;

      case 'brand':
        resolved = enabledProducts
            .where((product) => product.brandId == section.sourceBrandId)
            .where((product) => _isRenderableForDynamicHome(product))
            .toList(growable: false);
        break;

      default:
        resolved = enabledProducts
            .where((product) => _isRenderableForDynamicHome(product))
            .toList(growable: false);
        break;
    }

    return resolved.take(section.itemLimit).toList(growable: false);
  }

  bool _matchesFeatured(MBProduct product) {
    if (product.isFeatured) return true;
    return _enabledVariations(product).any((variation) => variation.isFeatured);
  }

  bool _matchesFlashSale(MBProduct product) {
    if (product.isFlashSale) return true;

    return _enabledVariations(product).any(
          (variation) => variation.isFlashSale || variation.isSaleActiveNow,
    );
  }

  bool _matchesNewArrival(MBProduct product) {
    if (product.isNewArrival) return true;
    return _enabledVariations(product).any((variation) => variation.isNewArrival);
  }

  bool _matchesBestSeller(MBProduct product) {
    if (product.isBestSeller) return true;
    return _enabledVariations(product).any((variation) => variation.isBestSeller);
  }

  bool _matchesRecommended(MBProduct product) {
    if (product.isFeatured ||
        product.isFlashSale ||
        product.isNewArrival ||
        product.isBestSeller) {
      return true;
    }

    return _enabledVariations(product).any(
          (variation) =>
      variation.isFeatured ||
          variation.isFlashSale ||
          variation.isNewArrival ||
          variation.isBestSeller ||
          variation.isSaleActiveNow,
    );
  }

  bool _isRenderableForHome(MBProduct product) {
    final List<MBProductVariation> enabledVariations = _enabledVariations(product);

    // Simple product or legacy product with no variation list.
    if (enabledVariations.isEmpty) {
      return true;
    }

    // Variable product: at least one enabled variation should be sellable
    // or at minimum kept active for presentation.
    return enabledVariations.any(
          (variation) => !variation.trackInventory || variation.inStock || variation.allowBackorder,
    );
  }

  bool _isRenderableForDynamicHome(MBProduct product) {
    final List<MBProductVariation> enabledVariations = _enabledVariations(product);

    // Simple product or legacy product with no variations list.
    if (enabledVariations.isEmpty) {
      return true;
    }

    // Variable product: for home visibility, presence of one enabled variation
    // is enough. Do not hard-block by stock here, because many variable products
    // may still be intended for display before stock is finalized.
    return true;
  }

  List<MBProductVariation> _enabledVariations(MBProduct product) {
    final List<MBProductVariation> items = product.variations;
    if (items.isEmpty) {
      return const <MBProductVariation>[];
    }

    return items.where((variation) => variation.isEnabled).toList(growable: false);
  }
}
