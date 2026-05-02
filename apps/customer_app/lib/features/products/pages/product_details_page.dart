import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:customer_app/features/cart/controllers/cart_controller.dart';
import 'package:customer_app/features/cart/helpers/cart_item_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

// File: product_details_page.dart

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({
    super.key,
    this.product,
    this.offers = const <MBOffer>[],
  });

  final MBProduct? product;
  final List<MBOffer> offers;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  MBProduct? _product;
  List<MBOffer> _offers = const <MBOffer>[];

  String? _selectedVariationId;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _readArguments();
    _selectInitialVariation();
    _syncQuantityWithRules();
  }

  void _readArguments() {
    final args = Get.arguments;

    if (widget.product != null) {
      _product = widget.product;
      _offers = widget.offers;
      return;
    }

    if (args is MBProduct) {
      _product = args;
      return;
    }

    if (args is Map) {
      final dynamic productArg = args['product'];
      final dynamic offersArg = args['offers'];

      if (productArg is MBProduct) {
        _product = productArg;
      }

      if (offersArg is List) {
        _offers = offersArg.whereType<MBOffer>().toList();
      }
    }
  }

  void _selectInitialVariation() {
    final product = _product;
    if (product == null) return;
    if (!_isVariableProduct(product)) return;
    if (product.variations.isEmpty) return;

    final defaultVariation = product.variations.cast<MBProductVariation?>().firstWhere(
          (item) => item != null && item.isDefault && item.isPublishedNow,
      orElse: () => null,
    );

    final firstPublished = product.variations.cast<MBProductVariation?>().firstWhere(
          (item) => item != null && item.isPublishedNow,
      orElse: () => null,
    );

    final selected = defaultVariation ?? firstPublished ?? product.variations.first;
    _selectedVariationId = selected.id;
  }

  bool _isVariableProduct(MBProduct product) {
    return product.productType.trim().toLowerCase() == 'variable';
  }

  MBProductVariation? get _selectedVariation {
    final product = _product;
    if (product == null) return null;
    if (!_isVariableProduct(product)) return null;

    for (final variation in product.variations) {
      if (variation.id == _selectedVariationId) {
        return variation;
      }
    }

    return null;
  }

  MBResolvedPrice? get _resolvedProductPrice {
    final product = _product;
    if (product == null) return null;

    if (_isVariableProduct(product)) {
      final variation = _selectedVariation;
      if (variation == null) return null;

      return MBPricingResolver.resolveVariation(
        product: product,
        variation: variation,
        offers: _offers,
      );
    }

    return MBPricingResolver.resolveProduct(
      product: product,
      offers: _offers,
    );
  }

  String? get _displayImageUrl {
    final product = _product;
    if (product == null) return null;

    final variation = _selectedVariation;
    if (variation != null) {
      final variationImage = variation.effectiveFullImageUrl.trim();
      if (variationImage.isNotEmpty) return variationImage;

      final variationThumb = variation.effectiveThumbImageUrl.trim();
      if (variationThumb.isNotEmpty) return variationThumb;
    }

    final productFullImage = product.resolvedFullImageUrl.trim();
    if (productFullImage.isNotEmpty) return productFullImage;

    final productThumbImage = product.resolvedThumbImageUrl.trim();
    if (productThumbImage.isNotEmpty) return productThumbImage;

    return null;
  }

  String _displayTitleEn() {
    final product = _product;
    if (product == null) return 'Product';

    final variation = _selectedVariation;
    if (variation != null && variation.titleEn.trim().isNotEmpty) {
      return variation.titleEn.trim();
    }

    return product.titleEn;
  }

  String _displayTitleBn() {
    final product = _product;
    if (product == null) return '';

    final variation = _selectedVariation;
    if (variation != null && variation.titleBn.trim().isNotEmpty) {
      return variation.titleBn.trim();
    }

    return product.titleBn;
  }

  String _displayDescription() {
    final product = _product;
    if (product == null) return '';

    final variation = _selectedVariation;
    if (variation != null && variation.descriptionEn.trim().isNotEmpty) {
      return variation.descriptionEn.trim();
    }

    return product.descriptionEn;
  }

  String _variationSummary(MBProductVariation variation) {
    if (variation.attributeValues.isEmpty) return 'No attributes';

    return variation.attributeValues.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(' • ');
  }

  double _currentMinOrderQty() {
    final product = _product;
    if (product == null) return 1;

    if (_isVariableProduct(product)) {
      final variation = _selectedVariation;
      if (variation == null) return 1;
      return _sanitizePositiveOrDefault(variation.minOrderQty, 1);
    }

    return _sanitizePositiveOrDefault(product.minOrderQty, 1);
  }

  double? _currentMaxOrderQty() {
    final product = _product;
    if (product == null) return null;

    if (_isVariableProduct(product)) {
      final variation = _selectedVariation;
      if (variation == null) return null;
      return _sanitizeNullablePositive(variation.maxOrderQty);
    }

    return _sanitizeNullablePositive(product.maxOrderQty);
  }

  double _currentStepQty() {
    final product = _product;
    if (product == null) return 1;

    if (_isVariableProduct(product)) {
      final variation = _selectedVariation;
      if (variation == null) return 1;
      return _sanitizePositiveOrDefault(variation.stepQty, 1);
    }

    return _sanitizePositiveOrDefault(product.stepQty, 1);
  }

  bool get _isPurchasable {
    final product = _product;
    if (product == null) return false;

    if (_isVariableProduct(product)) {
      final variation = _selectedVariation;
      if (variation == null) return false;
      if (!variation.isPublishedNow) return false;
      if (!variation.inStock) return false;
      return true;
    }

    if (!product.isPublishedNow) return false;
    if (!product.inStock) return false;
    return true;
  }

  String get _availabilityText {
    final product = _product;
    if (product == null) return 'Product unavailable';

    if (_isVariableProduct(product)) {
      final variation = _selectedVariation;
      if (variation == null) return 'Select a variation';

      if (!variation.isPublishedNow) {
        return variation.isDeleted
            ? 'Selected variation is unavailable'
            : 'Selected variation is not published yet';
      }

      if (!variation.inStock) {
        return variation.allowBackorder
            ? 'Available on backorder'
            : 'Out of stock';
      }

      if (variation.trackInventory) {
        return 'In stock: ${variation.availableStock}';
      }

      return 'Available';
    }

    if (!product.isPublishedNow) {
      return product.isDeleted ? 'Product is unavailable' : 'Product is not published yet';
    }

    if (!product.inStock) {
      return product.allowBackorder
          ? 'Available on backorder'
          : 'Out of stock';
    }

    if (product.trackInventory) {
      return 'In stock: ${product.instantAvailableToday}';
    }

    return 'Available';
  }

  void _syncQuantityWithRules() {
    final minQty = _currentMinOrderQty().round();
    final stepQty = _currentStepQty().round();
    final maxQty = _currentMaxOrderQty()?.round();

    var value = _quantity < 1 ? 1 : _quantity;

    if (value < minQty) {
      value = minQty;
    }

    final diff = value - minQty;
    final remainder = stepQty <= 0 ? 0 : diff % stepQty;
    if (remainder != 0) {
      value = value - remainder;
      if (value < minQty) {
        value = minQty;
      }
    }

    if (maxQty != null && value > maxQty) {
      value = maxQty;
      final backDiff = value - minQty;
      final backRemainder = stepQty <= 0 ? 0 : backDiff % stepQty;
      if (backRemainder != 0) {
        value = value - backRemainder;
        if (value < minQty) {
          value = minQty;
        }
      }
    }

    _quantity = value < 1 ? 1 : value;
  }

  void _increaseQty() {
    final step = _currentStepQty().round();
    final maxQty = _currentMaxOrderQty()?.round();

    setState(() {
      final next = _quantity + (step <= 0 ? 1 : step);
      if (maxQty != null && next > maxQty) {
        _quantity = maxQty;
      } else {
        _quantity = next;
      }
      _syncQuantityWithRules();
    });
  }

  void _decreaseQty() {
    final step = _currentStepQty().round();
    final minQty = _currentMinOrderQty().round();

    setState(() {
      final next = _quantity - (step <= 0 ? 1 : step);
      _quantity = next < minQty ? minQty : next;
      _syncQuantityWithRules();
    });
  }

  void _onVariationSelected(MBProductVariation variation) {
    setState(() {
      _selectedVariationId = variation.id;
      _syncQuantityWithRules();
    });
  }

  void _addToCart() {
    final product = _product;
    if (product == null) return;

    if (!_isPurchasable) {
      MBNotification.warning(
        title: 'Unavailable',
        message: _availabilityText,
      );
      return;
    }

    final cartController = Get.find<CartController>();

    if (_isVariableProduct(product)) {
      final variation = _selectedVariation;
      if (variation == null) {
        MBNotification.warning(
          title: 'Select Variation',
          message: 'Please choose a variation first.',
        );
        return;
      }

      final item = MBCartItemBuilder.buildForVariation(
        product: product,
        variation: variation,
        quantity: _quantity,
        purchaseMode: 'instant',
        offers: _offers,
      );

      cartController.addItem(item);
      return;
    }

    final item = MBCartItemBuilder.buildForProduct(
      product: product,
      quantity: _quantity,
      purchaseMode: 'instant',
      offers: _offers,
    );

    cartController.addItem(item);
  }

  void _buyNow() {
    final product = _product;
    if (product == null) return;

    if (!_isPurchasable) {
      MBNotification.warning(
        title: 'Unavailable',
        message: _availabilityText,
      );
      return;
    }

    _addToCart();
    Get.toNamed(AppRoutes.checkout, arguments: 'all');
  }

  Widget _buildQuantityRulesInfo() {
    final minQty = _currentMinOrderQty();
    final maxQty = _currentMaxOrderQty();
    final stepQty = _currentStepQty();

    final parts = <String>[
      'Min: ${_formatQty(minQty)}',
      'Step: ${_formatQty(stepQty)}',
    ];

    if (maxQty != null) {
      parts.add('Max: ${_formatQty(maxQty)}');
    }

    return Text(
      parts.join(' • '),
      style: MBTextStyles.bodySmall.copyWith(
        color: MBColors.textSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final resolved = _resolvedProductPrice;

    if (product == null) {
      return MBAppLayout(
        backgroundColor: MBColors.background,
        safeTop: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Details',
              style: MBTextStyles.pageTitle,
            ),
            MBSpacing.h(MBSpacing.lg),
            const MBCard(
              child: Text('Product not found in page arguments.'),
            ),
          ],
        ),
      );
    }

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: true,
      safeBottom: true,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _ProductImageHeader(
            imageUrl: _displayImageUrl,
          ),
          MBSpacing.h(MBSpacing.lg),
          MBCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayTitleEn(),
                  style: MBTextStyles.sectionTitle,
                ),
                if (_displayTitleBn().trim().isNotEmpty) ...[
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    _displayTitleBn(),
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                ],
                MBSpacing.h(MBSpacing.md),
                if (resolved != null)
                  Row(
                    children: [
                      Text(
                        '৳${resolved.finalUnitPrice.toStringAsFixed(0)}',
                        style: MBTextStyles.price,
                      ),
                      if (resolved.isDiscounted) ...[
                        MBSpacing.w(MBSpacing.sm),
                        Text(
                          '৳${resolved.basePrice.toStringAsFixed(0)}',
                          style: MBTextStyles.body.copyWith(
                            color: MBColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                MBSpacing.h(MBSpacing.sm),
                Text(
                  _availabilityText,
                  style: MBTextStyles.bodySmall.copyWith(
                    color: _isPurchasable ? MBColors.success : MBColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                MBSpacing.h(MBSpacing.md),
                Text(
                  _displayDescription().trim().isEmpty
                      ? 'No description available.'
                      : _displayDescription(),
                  style: MBTextStyles.body,
                ),
              ],
            ),
          ),
          if (_isVariableProduct(product)) ...[
            MBSpacing.h(MBSpacing.lg),
            MBCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Variation',
                    style: MBTextStyles.sectionTitle,
                  ),
                  MBSpacing.h(MBSpacing.md),
                  ...product.variations.map(
                        (variation) {
                      final isSelected = variation.id == _selectedVariationId;
                      final resolvedVariation = MBPricingResolver.resolveVariation(
                        product: product,
                        variation: variation,
                        offers: _offers,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: MBSpacing.sm),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(MBRadius.lg),
                          onTap: variation.isPublishedNow
                              ? () => _onVariationSelected(variation)
                              : null,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(MBSpacing.md),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? MBColors.primaryOrange.withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(MBRadius.lg),
                              border: Border.all(
                                color: isSelected
                                    ? MBColors.primaryOrange
                                    : MBColors.border,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  variation.titleEn.trim().isEmpty
                                      ? 'Variation'
                                      : variation.titleEn,
                                  style: MBTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                MBSpacing.h(MBSpacing.xs),
                                Text(
                                  _variationSummary(variation),
                                  style: MBTextStyles.bodySmall.copyWith(
                                    color: MBColors.textSecondary,
                                  ),
                                ),
                                MBSpacing.h(MBSpacing.xs),
                                Row(
                                  children: [
                                    Text(
                                      '৳${resolvedVariation.finalUnitPrice.toStringAsFixed(0)}',
                                      style: MBTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (resolvedVariation.isDiscounted) ...[
                                      MBSpacing.w(MBSpacing.xs),
                                      Text(
                                        '৳${resolvedVariation.basePrice.toStringAsFixed(0)}',
                                        style: MBTextStyles.bodySmall.copyWith(
                                          color: MBColors.textMuted,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    Text(
                                      variation.isPublishedNow
                                          ? (variation.inStock
                                          ? (variation.trackInventory
                                          ? 'Stock: ${variation.availableStock}'
                                          : 'Available')
                                          : (variation.allowBackorder
                                          ? 'Backorder'
                                          : 'Out of stock'))
                                          : (variation.isDeleted ? 'Unavailable' : 'Not published'),
                                      style: MBTextStyles.bodySmall.copyWith(
                                        color: !variation.isPublishedNow
                                            ? MBColors.error
                                            : (variation.inStock
                                            ? MBColors.success
                                            : MBColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          MBSpacing.h(MBSpacing.lg),
          MBCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quantity',
                  style: MBTextStyles.sectionTitle,
                ),
                MBSpacing.h(MBSpacing.sm),
                _buildQuantityRulesInfo(),
                MBSpacing.h(MBSpacing.md),
                Row(
                  children: [
                    IconButton(
                      onPressed: _decreaseQty,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Container(
                      width: 72,
                      alignment: Alignment.center,
                      child: Text(
                        _formatQty(_quantity.toDouble()),
                        style: MBTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _increaseQty,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                MBSpacing.h(MBSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: MBSecondaryButton(
                        text: 'Buy Now',
                        onPressed: _isPurchasable ? _buyNow : null,
                      ),
                    ),
                    MBSpacing.w(MBSpacing.md),
                    Expanded(
                      child: MBPrimaryButton(
                        text: 'Add to Cart',
                        onPressed: _isPurchasable ? _addToCart : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          MBSpacing.h(MBSpacing.xxl),
        ],
      ),
    );
  }
}

class _ProductImageHeader extends StatelessWidget {
  const _ProductImageHeader({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final trimmed = (imageUrl ?? '').trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(MBRadius.xl),
      child: Container(
        height: 280,
        width: double.infinity,
        color: MBColors.card,
        child: trimmed.isEmpty
            ? const Center(
          child: Icon(
            Icons.image_outlined,
            size: 54,
          ),
        )
            : Image.network(
          trimmed,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 54,
            ),
          ),
        ),
      ),
    );
  }
}

double _sanitizePositiveOrDefault(double? value, double fallback) {
  if (value == null || value <= 0) return fallback;
  return value;
}

double? _sanitizeNullablePositive(double? value) {
  if (value == null || value <= 0) return null;
  return value;
}

String _formatQty(double value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}