import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:customer_app/features/cart/controllers/cart_controller.dart';
import 'package:customer_app/features/cart/helpers/cart_item_builder.dart';
import 'package:customer_app/features/home/controllers/home_controller.dart';
import 'package:customer_app/features/home/pages/offer_details_page.dart';
import 'package:customer_app/features/home/widgets/floating_offer_card.dart';
import 'package:customer_app/features/home/widgets/home_cache_debug_section.dart';
import 'package:customer_app/features/home/widgets/home_renderer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

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
    _controller.dispose();
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
    if (product is! MBProduct) return;

    _controller.onProductTap(product.id);

    Get.toNamed(
      AppRoutes.productDetails,
      arguments: {
        'product': product,
        'offers': _controller.config.activeOffers,
      },
    );
  }

  void _handleProductAddToCart(dynamic product) {
    if (product is! MBProduct) return;

    if (product.productType.trim().toLowerCase() == 'variable') {
      MBNotification.info(
        title: 'Select Options',
        message: 'Please open the product and choose a variation first.',
      );

      _handleProductTap(product);
      return;
    }

    final cartController = Get.find<CartController>();
    final item = MBCartItemBuilder.buildForProduct(
      product: product,
      quantity: 1,
      purchaseMode: 'instant',
      offers: _controller.config.activeOffers,
    );

    cartController.addItem(item);
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
        return product.brandId != null && offer.brandIds.contains(product.brandId);
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

  void _openSearch() {
    // Later: navigate to product search page or open search overlay.
  }

  void _openNotifications() {
    // Later: navigate to notification center.
  }

  @override
  Widget build(BuildContext context) {
    final floatingOffer = _controller.floatingOffer;
    final topBarHeight = _HomeTopBar.totalHeight(context);

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: false,
      safeBottom: false,
      padding: EdgeInsets.zero,
      scrollable: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: topBarHeight + _HomeTopBar.kContentTopGap,
                  bottom: 140,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MBSpacing.pageHorizontal(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          onProductAddToCart: _handleProductAddToCart,
                          onViewAllTap: _handleViewAllTap,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky top search/notification bar.
          // This remains visible while the page scrolls.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _HomeTopBar(
              notificationCount: 3,
              onSearchTap: _openSearch,
              onNotificationTap: _openNotifications,
            ),
          ),

          if (floatingOffer != null)
            Positioned(
              right: 16,
              bottom: 20,
              child: MBFloatingOfferCard(
                offer: floatingOffer,
                onClose: () {
                  _controller.closeFloatingOffer();
                },
                onTap: _openFloatingOfferDetails,
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.notificationCount,
    this.onSearchTap,
    this.onNotificationTap,
  });

  // Manual adjustment values
  // ------------------------
  // kSearchHeight:
  //   Height of both search box and notification button.
  //   Recommended compact range: 40-46.
  //
  // kTopGapAfterStatusArea:
  //   Space between phone status/notch area and search row.
  //   Lower value = search row goes higher.
  //   Recommended range: 4-10.
  //
  // kBottomPadding:
  //   Orange area below the search row.
  //   Lower value = top bar becomes shorter.
  //   Recommended range: 7-14.
  //
  // kContentTopGap:
  //   Space between sticky top bar and first home section.
  //   Recommended range: 10-18.
  //
  // kBottomRadius:
  //   Curved bottom edge of the orange header.
  //   Recommended range: 18-26.
  static const double kSearchHeight = 30;
  static const double kTopGapAfterStatusArea = 3;
  static const double kBottomPadding = 4;
  static const double kContentTopGap = -8;
  static const double kBottomRadius = 6;
  static const double kSearchRadius = 5;
  static const double kNotificationRadius = 6;
  static const double kSearchIconSize = 20;
  static const double kNotificationIconSize = 22;
  static const double kNotificationBadgeTop = -3;
  static const double kNotificationBadgeRight = -3;

  final int notificationCount;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;

  static double totalHeight(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return topInset +
        kTopGapAfterStatusArea +
        kSearchHeight +
        kBottomPadding;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final horizontalPadding = MBSpacing.pageHorizontal(context);

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: MBGradients.headerGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(kBottomRadius),
            bottomRight: Radius.circular(kBottomRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topInset + kTopGapAfterStatusArea,
            horizontalPadding,
            kBottomPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _HomeSearchBox(
                  height: kSearchHeight,
                  radius: kSearchRadius,
                  iconSize: kSearchIconSize,
                  onTap: onSearchTap,
                ),
              ),
              SizedBox(width: MBSpacing.sm),
              _NotificationButton(
                size: kSearchHeight,
                radius: kNotificationRadius,
                iconSize: kNotificationIconSize,
                count: notificationCount,
                onTap: onNotificationTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSearchBox extends StatelessWidget {
  const _HomeSearchBox({
    required this.height,
    required this.radius,
    required this.iconSize,
    this.onTap,
  });

  final double height;
  final double radius;
  final double iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MBSpacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: MBColors.textSecondary,
                  size: iconSize,
                ),
                SizedBox(width: MBSpacing.sm),
                Expanded(
                  child: Text(
                    'Search products...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MBAppText.body(context).copyWith(
                      color: MBColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.size,
    required this.radius,
    required this.iconSize,
    required this.count,
    this.onTap,
  });

  final double size;
  final double radius;
  final double iconSize;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            top: _HomeTopBar.kNotificationBadgeTop,
            right: _HomeTopBar.kNotificationBadgeRight,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 17,
                minHeight: 17,
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
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
