import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../../../responsive/mb_spacing.dart';
import '../../../theme/mb_colors.dart';
import '../../../theme/mb_radius.dart';
import '../../../theme/mb_text_styles.dart';
import '../mb_primary_button.dart';

class MBProductCardDeal extends StatelessWidget {
  const MBProductCardDeal({
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

  String get _title {
    final en = product.titleEn.trim();
    if (en.isNotEmpty) return en;

    final bn = product.titleBn.trim();
    if (bn.isNotEmpty) return bn;

    return 'Product';
  }

  String get _imageUrl => product.resolvedThumbnailUrl;

  String get _currentPrice => '৳${product.effectivePrice.toStringAsFixed(0)}';

  String? get _oldPrice {
    if (!product.hasDiscount) return null;
    return '৳${product.price.toStringAsFixed(0)}';
  }

  String? get _saveText {
    if (!product.hasDiscount) return null;
    final saved = product.price - product.effectivePrice;
    if (saved <= 0) return null;
    return 'Save ৳${saved.toStringAsFixed(0)}';
  }

  String get _badgeText {
    if (product.hasDiscount && product.discountPercent > 0) {
      return '${product.discountPercent}% OFF';
    }
    if (product.isFlashSale) return 'Flash Sale';
    if (product.isFeatured) return 'Featured Deal';
    return 'Deal';
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = product.inStock;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(MBRadius.lg),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: MBColors.card,
            borderRadius: BorderRadius.circular(MBRadius.lg),
            border: Border.all(
              color: MBColors.primaryOrange.withValues(alpha: 0.18),
            ),
            boxShadow: const [
              BoxShadow(
                color: MBColors.shadow,
                blurRadius: 18,
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
                        color: const Color(0xFFFFF1E8),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _DealImage(url: _imageUrl),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: MBColors.error,
                          borderRadius: BorderRadius.circular(MBRadius.pill),
                        ),
                        child: Text(
                          _badgeText,
                          style: MBTextStyles.caption.copyWith(
                            color: MBColors.textOnPrimary,
                            fontWeight: FontWeight.w700,
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
                            color: Colors.white.withValues(alpha: 0.96),
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
                    if (_saveText != null)
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: MBColors.primaryOrange,
                            borderRadius: BorderRadius.circular(MBRadius.pill),
                          ),
                          child: Text(
                            _saveText!,
                            style: MBTextStyles.caption.copyWith(
                              color: MBColors.textOnPrimary,
                              fontWeight: FontWeight.w700,
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
                    if ((product.brandNameEn ?? '').trim().isNotEmpty) ...[
                      Text(
                        product.brandNameEn!.trim(),
                        style: MBTextStyles.caption.copyWith(
                          color: MBColors.primaryOrange,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: MBSpacing.xs),
                    ],
                    Text(
                      _title,
                      style: MBTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: MBSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _currentPrice,
                            style: MBTextStyles.price.copyWith(fontSize: 17),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_oldPrice != null)
                          Padding(
                            padding: const EdgeInsets.only(left: MBSpacing.xs),
                            child: Text(
                              _oldPrice!,
                              style: MBTextStyles.caption.copyWith(
                                color: MBColors.textMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: MBSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          canAdd
                              ? Icons.local_offer_outlined
                              : Icons.inventory_2_outlined,
                          size: 15,
                          color: canAdd
                              ? MBColors.primaryOrange
                              : MBColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            canAdd ? 'Available now' : 'Out of stock',
                            style: MBTextStyles.caption.copyWith(
                              color: canAdd
                                  ? MBColors.primaryOrange
                                  : MBColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: MBSpacing.sm),
                    if (showAddToCart)
                      MBPrimaryButton(
                        text: canAdd ? 'Grab Deal' : 'Unavailable',
                        onPressed: canAdd ? onAddToCart : null,
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

class _DealImage extends StatelessWidget {
  const _DealImage({required this.url});

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