import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../../../responsive/mb_spacing.dart';
import '../../../theme/mb_colors.dart';
import '../../../theme/mb_radius.dart';
import '../../../theme/mb_text_styles.dart';
import '../mb_primary_button.dart';

class MBProductCardStandard extends StatelessWidget {
  const MBProductCardStandard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.showAddToCart = true,
  });

  final MBProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool showAddToCart;

  String? get _badgeText {
    if (product.isFlashSale) return 'Flash Sale';
    if (product.hasDiscount && product.discountPercent > 0) {
      return '${product.discountPercent}% OFF';
    }
    if (product.isNewArrival) return 'New';
    if (product.isFeatured) return 'Featured';
    return null;
  }

  String get _title {
    final en = product.titleEn.trim();
    if (en.isNotEmpty) return en;

    final bn = product.titleBn.trim();
    if (bn.isNotEmpty) return bn;

    return 'Product';
  }

  String get _priceText => '৳${product.effectivePrice.toStringAsFixed(0)}';

  String? get _oldPriceText {
    if (!product.hasDiscount) return null;
    return '৳${product.price.toStringAsFixed(0)}';
  }

  String get _imageUrl => product.resolvedThumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(MBRadius.lg),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: MBColors.card,
            borderRadius: BorderRadius.circular(MBRadius.lg),
            boxShadow: const [
              BoxShadow(
                color: MBColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(MBRadius.lg),
                      ),
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFFFDF1E8),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _ProductImage(url: _imageUrl),
                        ),
                      ),
                    ),
                    if (_badgeText != null)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: MBColors.primaryOrange,
                            borderRadius: BorderRadius.circular(MBRadius.pill),
                          ),
                          child: Text(
                            _badgeText!,
                            style: MBTextStyles.caption.copyWith(
                              color: MBColors.textOnPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: onFavoriteTap,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: isFavorite
                                ? MBColors.error
                                : MBColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(MBSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: MBTextStyles.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: MBSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _priceText,
                            style: MBTextStyles.price.copyWith(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_oldPriceText != null)
                          Padding(
                            padding: const EdgeInsets.only(left: MBSpacing.xs),
                            child: Text(
                              _oldPriceText!,
                              style: MBTextStyles.caption.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: MBColors.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: MBSpacing.sm),
                    if (showAddToCart)
                      MBPrimaryButton(
                        text: product.inStock ? 'Add to Cart' : 'Out of Stock',
                        onPressed: product.inStock ? onAddToCart : null,
                        height: 40,
                        textStyle: MBTextStyles.bodyMedium.copyWith(
                          color: MBColors.textOnPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 34,
          color: MBColors.textMuted,
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 34,
            color: MBColors.textMuted,
          ),
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
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