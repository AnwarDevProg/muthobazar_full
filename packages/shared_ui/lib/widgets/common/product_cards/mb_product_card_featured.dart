import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../../../responsive/mb_spacing.dart';
import '../../../theme/mb_colors.dart';
import '../../../theme/mb_gradients.dart';
import '../../../theme/mb_radius.dart';
import '../../../theme/mb_text_styles.dart';
import '../mb_primary_button.dart';

class MBProductCardFeatured extends StatelessWidget {
  const MBProductCardFeatured({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.showAddToCart = true,
    this.height = 320,
  });

  final MBProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool showAddToCart;
  final double height;

  String get _title {
    final en = product.titleEn.trim();
    if (en.isNotEmpty) return en;

    final bn = product.titleBn.trim();
    if (bn.isNotEmpty) return bn;

    return 'Product';
  }

  String get _subtitle {
    final brand = (product.brandNameEn ?? '').trim();
    if (brand.isNotEmpty) return brand;

    final category = (product.categoryNameEn ?? '').trim();
    if (category.isNotEmpty) return category;

    if (product.isFeatured) return 'Featured Collection';
    if (product.isNewArrival) return 'New Arrival';
    if (product.isFlashSale) return 'Limited Time Offer';

    return 'Popular Pick';
  }

  String get _imageUrl => product.resolvedThumbnailUrl;

  String get _currentPrice => '৳${product.effectivePrice.toStringAsFixed(0)}';

  String? get _oldPrice {
    if (!product.hasDiscount) return null;
    return '৳${product.price.toStringAsFixed(0)}';
  }

  String get _primaryBadge {
    if (product.isFlashSale) return 'Flash Sale';
    if (product.isFeatured) return 'Featured';
    if (product.isNewArrival) return 'New Arrival';
    if (product.hasDiscount && product.discountPercent > 0) {
      return '${product.discountPercent}% OFF';
    }
    return 'Spotlight';
  }

  String? get _secondaryBadge {
    if (product.hasDiscount && product.discountPercent > 0) {
      final saved = product.price - product.effectivePrice;
      if (saved > 0) {
        return 'Save ৳${saved.toStringAsFixed(0)}';
      }
    }

    if (product.inStock) return 'In Stock';
    return 'Out of Stock';
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = product.inStock;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(MBRadius.xl),
        onTap: onTap,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: MBColors.card,
            borderRadius: BorderRadius.circular(MBRadius.xl),
            boxShadow: const [
              BoxShadow(
                color: MBColors.shadow,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(MBRadius.xl),
                child: SizedBox.expand(
                  child: _FeaturedImage(url: _imageUrl),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(MBRadius.xl),
                    gradient: MBGradients.featuredOverlayGradient,
                  ),
                ),
              ),
              Positioned(
                top: MBSpacing.sm,
                left: MBSpacing.sm,
                right: MBSpacing.sm,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: MBSpacing.xs,
                        runSpacing: MBSpacing.xs,
                        children: [
                          _FeaturedChip(
                            text: _primaryBadge,
                            backgroundColor:
                            MBColors.primaryOrange.withValues(alpha: 0.96),
                            foregroundColor: MBColors.textOnPrimary,
                          ),
                          if (_secondaryBadge != null)
                            _FeaturedChip(
                              text: _secondaryBadge!,
                              backgroundColor:
                              Colors.white.withValues(alpha: 0.92),
                              foregroundColor: MBColors.textPrimary,
                            ),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 19,
                          color: isFavorite
                              ? MBColors.error
                              : MBColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: MBSpacing.md,
                right: MBSpacing.md,
                bottom: MBSpacing.md,
                child: Container(
                  padding: const EdgeInsets.all(MBSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(MBRadius.lg),
                    boxShadow: const [
                      BoxShadow(
                        color: MBColors.shadow,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _subtitle,
                        style: MBTextStyles.caption.copyWith(
                          color: MBColors.primaryOrange,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: MBSpacing.xs),
                      Text(
                        _title,
                        style: MBTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: MBColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: MBSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _currentPrice,
                              style: MBTextStyles.price.copyWith(fontSize: 20),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_oldPrice != null)
                            Padding(
                              padding:
                              const EdgeInsets.only(left: MBSpacing.xs),
                              child: Text(
                                _oldPrice!,
                                style: MBTextStyles.bodySmall.copyWith(
                                  color: MBColors.textMuted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: MBSpacing.sm),
                      if (showAddToCart)
                        MBPrimaryButton(
                          text: canAdd ? 'Add to Cart' : 'Out of Stock',
                          onPressed: canAdd ? onAddToCart : null,
                          height: 42,
                          textStyle: MBTextStyles.bodyMedium.copyWith(
                            color: MBColors.textOnPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedImage extends StatelessWidget {
  const _FeaturedImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return Container(
        color: const Color(0xFFFDF1E8),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 42,
          color: MBColors.textMuted,
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFFDF1E8),
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_outlined,
            size: 42,
            color: MBColors.textMuted,
          ),
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return Container(
          color: const Color(0xFFFDF1E8),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: MBColors.primaryOrange,
            ),
          ),
        );
      },
    );
  }
}

class _FeaturedChip extends StatelessWidget {
  const _FeaturedChip({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(MBRadius.pill),
      ),
      child: Text(
        text,
        style: MBTextStyles.caption.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}