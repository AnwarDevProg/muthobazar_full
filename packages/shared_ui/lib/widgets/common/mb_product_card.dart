import 'package:flutter/material.dart';

import '../../../theme/mb_colors.dart';
import '../../../theme/mb_radius.dart';
import '../../../theme/mb_text_styles.dart';
import '../../responsive/mb_spacing.dart';
import 'mb_primary_button.dart';

class MBProductCard extends StatelessWidget {
  final String title;
  final String priceText;
  final String? oldPriceText;
  final String imageUrl;
  final String? badgeText;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const MBProductCard({
    super.key,
    required this.title,
    required this.priceText,
    required this.imageUrl,
    this.oldPriceText,
    this.badgeText,
    this.onTap,
    this.onAddToCart,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

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
                          child: Image.network(
                            imageUrl,
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
                          ),
                        ),
                      ),
                    ),
                    if (badgeText != null && badgeText!.trim().isNotEmpty)
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
                            badgeText!,
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
                      title,
                      style: MBTextStyles.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: MBSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            priceText,
                            style: MBTextStyles.price.copyWith(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (oldPriceText != null &&
                            oldPriceText!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: MBSpacing.xs),
                            child: Text(
                              oldPriceText!,
                              style: MBTextStyles.caption.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: MBColors.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: MBSpacing.sm),
                    MBPrimaryButton(
                      text: 'Add to Cart',
                      onPressed: onAddToCart,
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











