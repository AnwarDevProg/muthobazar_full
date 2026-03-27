import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../controllers/mb_home_controller.dart';
import '../widgets/mb_floating_offer_card.dart';
import '../widgets/mb_home_cache_debug_section.dart';
import '../widgets/mb_home_renderer.dart';
import '../widgets/mb_offer_details_page.dart';

// Home Page
// ---------
// Controller-driven HomePage for MuthoBazar.
// Uses a bounded SizedBox + Stack to safely support:
// - scrollable content
// - floating offer overlay

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const bool _showCacheDebugSection = false;

  late final MBHomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MBHomeController();
    _controller.addListener(_onControllerChanged);
    _controller.load();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  Future<void> _refresh() async {
    await _controller.refresh();
  }

  void _handleBannerTap(dynamic banner) {
    _controller.onBannerTap(banner.id);
  }

  void _handleOfferTap(dynamic offer) {
    _controller.onOfferTap(offer.id);
  }

  void _handleCategoryTap(dynamic category) {
    _controller.onCategoryTap(category.id);
  }

  void _handleProductTap(dynamic product) {
    _controller.onProductTap(product.id);
  }

  void _handleViewAllTap() {
    _controller.onViewAllTap('home_section');
  }

  void _openFloatingOfferDetails() {
    final offer = _controller.floatingOffer;
    if (offer == null) return;

    final matchedProducts = _controller.products.where((product) {
      if (offer.productIds.isNotEmpty) {
        return offer.productIds.contains(product.id);
      }

      if (offer.categoryIds.isNotEmpty) {
        return product.categoryId != null &&
            offer.categoryIds.contains(product.categoryId);
      }

      if (offer.brandIds.isNotEmpty) {
        return product.brandId != null &&
            offer.brandIds.contains(product.brandId);
      }

      return true;
    }).toList();

    Get.to(
          () => MBOfferDetailsPage(
        offer: offer,
        products: matchedProducts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final floatingOffer = _controller.floatingOffer;
    final screenHeight = MediaQuery.of(context).size.height;

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: true,
      safeBottom: false,
      padding: EdgeInsets.zero,
      scrollable: false,
      child: SizedBox(
        height: screenHeight,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    const _HomeHeader(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MBSpacing.pageHorizontal(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: MBSpacing.md),
                          if (_showCacheDebugSection) ...[
                            MBHomeCacheDebugSection(
                              isUsingCachedData: _controller.isUsingCachedData,
                              isLoading: _controller.isLoading,
                              isRefreshing: _controller.isRefreshing,
                              lastSyncedAt: _controller.lastSyncedAt,
                              cacheState: _controller.cacheState,
                            ),
                            const SizedBox(height: MBSpacing.lg),
                          ],
                          MBHomeRenderer(
                            config: _controller.config,
                            products: _controller.products,
                            categories: _controller.categories,
                            brands: _controller.brands,
                            onBannerTap: _handleBannerTap,
                            onOfferTap: _handleOfferTap,
                            onCategoryTap: _handleCategoryTap,
                            onProductTap: _handleProductTap,
                            onViewAllTap: _handleViewAllTap,
                          ),
                          const SizedBox(height: MBSpacing.xl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (floatingOffer != null)
              MBFloatingOfferCard(
                offer: floatingOffer,
                onClose: () {
                  _controller.closeFloatingOffer();
                },
                onTap: _openFloatingOfferDetails,
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        MBSpacing.pageHorizontal(context),
        MBSpacing.xxs,
        MBSpacing.pageHorizontal(context),
        MBSpacing.md,
      ),
      decoration: const BoxDecoration(
        gradient: MBGradients.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(MBRadius.xl),
          bottomRight: Radius.circular(MBRadius.xl),
        ),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MBSpacing.h(MBSpacing.xxs),
            Text(
              'Discover Daily Needs',
              style: MBAppText.headline2(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.xxxs),
            Text(
              'Search products, browse categories, and grab today’s offers.',
              style: MBAppText.bodySmall(context).copyWith(
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                const Expanded(
                  child: MBTextField(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                MBSpacing.w(MBSpacing.sm),
                const _NotificationButton(count: 3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final int count;

  const _NotificationButton({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: MBSpacing.buttonHeight(context) * 0.86,
          height: MBSpacing.buttonHeight(context) * 0.86,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(MBRadius.md),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
          ),
        ),
        if (count > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(MBRadius.pill),
              ),
              alignment: Alignment.center,
              child: Text(
                count > 99 ? '99+' : '$count',
                style: MBAppText.caption(context).copyWith(
                  color: MBColors.primaryOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

