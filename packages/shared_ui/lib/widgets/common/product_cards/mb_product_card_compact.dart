import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../../../responsive/mb_spacing.dart';
import '../../../theme/mb_colors.dart';
import '../../../theme/mb_radius.dart';
import '../../../theme/mb_text_styles.dart';

class MBProductCardCompact extends StatelessWidget {
  const MBProductCardCompact({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.showFavorite = true,
    this.showAddButton = true,
  });

  final MBProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool showFavorite;
  final bool showAddButton;

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

  String? get _badgeText {
    if (product.isFlashSale) return 'Flash';
    if (product.hasDiscount && product.discountPercent > 0) {
      return '${product.discountPercent}% OFF';
    }
    if (product.isNewArrival) return 'New';
    if (product.isFeatured) return 'Featured';
    return null;
  }

  String get _imageUrl => product.resolvedThumbnailUrl;

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
            boxShadow: const [
              BoxShadow(
                color: MBColors.shadow,
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(MBSpacing.sm),
            child: Row(
              children: [
                _CompactImage(
                  url: _imageUrl,
                  badgeText: _badgeText,
                ),
                const SizedBox(width: MBSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _title,
                        style: MBTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: MBSpacing.xs),
                      if ((product.brandNameEn ?? '').trim().isNotEmpty)
                        Text(
                          product.brandNameEn!.trim(),
                          style: MBTextStyles.caption.copyWith(
                            color: MBColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: MBSpacing.xs),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _priceText,
                              style: MBTextStyles.price.copyWith(fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_oldPriceText != null) ...[
                            const SizedBox(width: MBSpacing.xs),
                            Flexible(
                              child: Text(
                                _oldPriceText!,
                                style: MBTextStyles.caption.copyWith(
                                  color: MBColors.textMuted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: MBSpacing.xs),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showFavorite)
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: onFavoriteTap,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: MBColors.softBackground,
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
                    if (showFavorite && showAddButton)
                      const SizedBox(height: MBSpacing.xs),
                    if (showAddButton)
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: canAdd ? onAddToCart : null,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: canAdd
                                ? MBColors.primaryOrange
                                : MBColors.softBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            canAdd ? Icons.add_shopping_cart : Icons.remove,
                            size: 18,
                            color: canAdd
                                ? MBColors.textOnPrimary
                                : MBColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactImage extends StatelessWidget {
  const _CompactImage({
    required this.url,
    required this.badgeText,
  });

  final String url;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(MBRadius.md),
          child: Container(
            width: 86,
            height: 86,
            color: const Color(0xFFFDF1E8),
            child: url.trim().isEmpty
                ? const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 28,
                color: MBColors.textMuted,
              ),
            )
                : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 28,
                    color: MBColors.textMuted,
                  ),
                );
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MBColors.primaryOrange,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (badgeText != null)
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: MBColors.primaryOrange,
                borderRadius: BorderRadius.circular(MBRadius.pill),
              ),
              child: Text(
                badgeText!,
                style: MBTextStyles.caption.copyWith(
                  color: MBColors.textOnPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}