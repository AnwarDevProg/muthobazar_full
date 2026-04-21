import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class MBProductCardCard01 extends StatelessWidget {
  const MBProductCardCard01({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.showAddToCart = true,
    this.showFavorite = true,
  });

  final MBProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool showAddToCart;
  final bool showFavorite;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(product);
    final title = _resolveTitle(product);
    final category = (product.categoryNameEn ?? '').trim();
    final brand = (product.brandNameEn ?? '').trim();
    final currentPrice = _effectivePrice(product);
    final regularPrice = product.price;
    final hasDiscount = _hasDiscount(product);
    final discountPercent = _discountPercent(product);
    final inStock = (product.stockQty > 0) || product.allowBackorder;
    final accentColor = MBColors.primaryOrange;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(MBRadius.xl),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: MBColors.card,
            borderRadius: BorderRadius.circular(MBRadius.xl),
            border: Border.all(
              color: MBColors.divider.withValues(alpha: 0.65),
            ),
            boxShadow: [
              BoxShadow(
                color: MBColors.shadow.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 11,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(MBRadius.xl),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(MBRadius.xl),
                          ),
                          child: imageUrl.isEmpty
                              ? _ImagePlaceholder(accentColor: accentColor)
                              : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return _ImagePlaceholder(accentColor: accentColor);
                            },
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return _ImagePlaceholder(accentColor: accentColor);
                            },
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.00),
                                Colors.black.withValues(alpha: 0.04),
                                Colors.black.withValues(alpha: 0.22),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (hasDiscount)
                                    _TopChip(
                                      text: '-${discountPercent.toStringAsFixed(0)}%',
                                      backgroundColor: accentColor,
                                      foregroundColor: Colors.white,
                                    ),
                                  if (product.isFlashSale)
                                    _TopChip(
                                      text: 'Flash',
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                  if (product.isNewArrival)
                                    _TopChip(
                                      text: 'New',
                                      backgroundColor: Colors.white,
                                      foregroundColor: accentColor,
                                    ),
                                ],
                              ),
                            ),
                            if (showFavorite)
                              _CircleAction(
                                icon: isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                onTap: onFavoriteTap,
                                foregroundColor:
                                isFavorite ? Colors.redAccent : Colors.white,
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: Row(
                          children: [
                            Expanded(
                              child: _BottomGlassPill(
                                icon: inStock
                                    ? Icons.inventory_2_outlined
                                    : Icons.remove_shopping_cart_outlined,
                                label: inStock ? 'In stock' : 'Out of stock',
                              ),
                            ),
                            if (brand.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: _BottomGlassPill(
                                  icon: Icons.storefront_outlined,
                                  label: brand,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category.isNotEmpty)
                        Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MBAppText.caption(context).copyWith(
                            color: MBColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (category.isNotEmpty) const SizedBox(height: 4),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: MBAppText.body(context).copyWith(
                          color: MBColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _resolveShortLine(product),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: MBAppText.bodySmall(context).copyWith(
                          color: MBColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '৳${currentPrice.toStringAsFixed(0)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: MBAppText.sectionTitle(context).copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (hasDiscount)
                                  Text(
                                    '৳${regularPrice.toStringAsFixed(0)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: MBAppText.bodySmall(context).copyWith(
                                      color: MBColors.textMuted,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (showAddToCart)
                            _AddButton(
                              enabled: inStock,
                              onTap: inStock ? onAddToCart : null,
                            ),
                        ],
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

  String _resolveImageUrl(MBProduct product) {
    final thumb = product.thumbnailUrl.trim();
    if (thumb.isNotEmpty) return thumb;
    if (product.imageUrls.isNotEmpty) {
      return product.imageUrls.first.trim();
    }
    return '';
  }

  String _resolveTitle(MBProduct product) {
    final titleEn = product.titleEn.trim();
    if (titleEn.isNotEmpty) return titleEn;
    final titleBn = product.titleBn.trim();
    if (titleBn.isNotEmpty) return titleBn;
    return 'Untitled Product';
  }

  String _resolveShortLine(MBProduct product) {
    final shortEn = product.shortDescriptionEn.trim();
    if (shortEn.isNotEmpty) return shortEn;
    final shortBn = product.shortDescriptionBn.trim();
    if (shortBn.isNotEmpty) return shortBn;
    final descEn = product.descriptionEn.trim();
    if (descEn.isNotEmpty) return descEn;
    return 'Designed for previewing product card layouts with realistic shared product data.';
  }

  double _effectivePrice(MBProduct product) {
    final sale = product.salePrice;
    if (sale != null && sale > 0 && sale < product.price) {
      return sale;
    }
    return product.price;
  }

  bool _hasDiscount(MBProduct product) {
    final sale = product.salePrice;
    return sale != null && sale > 0 && sale < product.price;
  }

  double _discountPercent(MBProduct product) {
    if (!_hasDiscount(product)) return 0;
    final sale = product.salePrice!;
    final percent = ((product.price - sale) / product.price) * 100;
    return percent.isFinite ? percent : 0;
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.accentColor,
  });

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.08),
            accentColor.withValues(alpha: 0.20),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 42,
          color: accentColor.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

class _TopChip extends StatelessWidget {
  const _TopChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(MBRadius.pill),
      ),
      child: Text(
        text,
        style: MBAppText.caption(context).copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    required this.foregroundColor,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}

class _BottomGlassPill extends StatelessWidget {
  const _BottomGlassPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(MBRadius.pill),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MBAppText.caption(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = enabled
        ? MBColors.primaryOrange
        : MBColors.textMuted.withValues(alpha: 0.25);
    final foregroundColor = enabled ? Colors.white : MBColors.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(MBRadius.pill),
        onTap: enabled ? onTap : null,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(MBRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_shopping_cart_outlined,
                size: 16,
                color: foregroundColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Add',
                style: MBAppText.bodySmall(context).copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
