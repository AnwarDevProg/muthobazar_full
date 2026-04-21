import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class MBProductCardCard02 extends StatelessWidget {
  const MBProductCardCard02({
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
    final imageUrl = _imageUrl(product);
    final title = _title(product);
    final subtitle = _subtitle(product);
    final category = (product.categoryNameEn ?? '').trim();
    final brand = (product.brandNameEn ?? '').trim();
    final unitText = _unitText(product);
    final currentPrice = _effectivePrice(product);
    final regularPrice = product.price;
    final hasDiscount = _hasDiscount(product);
    final discountPercent = _discountPercent(product);
    final inStock = product.stockQty > 0 || product.allowBackorder;

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
              color: MBColors.primaryOrange.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: MBColors.shadow.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 9,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  decoration: BoxDecoration(
                    color: MBColors.primaryOrange.withValues(alpha: 0.06),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(MBRadius.xl),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (category.isNotEmpty)
                                  _Card02Tag(
                                    label: category,
                                    backgroundColor: Colors.white,
                                    foregroundColor: MBColors.textPrimary,
                                  ),
                                if (product.isFlashSale)
                                  const _Card02Tag(
                                    label: 'Flash Sale',
                                    backgroundColor: MBColors.primaryOrange,
                                    foregroundColor: Colors.white,
                                  ),
                                if (product.isBestSeller)
                                  _Card02Tag(
                                    label: 'Best Seller',
                                    backgroundColor: Colors.amber.withValues(alpha: 0.18),
                                    foregroundColor: Colors.orange.shade900,
                                  ),
                              ],
                            ),
                          ),
                          if (showFavorite)
                            _Card02FavoriteButton(
                              isFavorite: isFavorite,
                              onTap: onFavoriteTap,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 170),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(MBRadius.xl),
                              border: Border.all(
                                color: MBColors.primaryOrange.withValues(alpha: 0.10),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: MBColors.shadow.withValues(alpha: 0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(MBRadius.lg),
                                child: imageUrl.isEmpty
                                    ? const _Card02ImagePlaceholder()
                                    : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                  const _Card02ImagePlaceholder(),
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const _Card02ImagePlaceholder();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _Card02PromoStrip(
                              label: '${discountPercent.toStringAsFixed(0)}% OFF',
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 12,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: MBAppText.bodySmall(context).copyWith(
                          color: MBColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (brand.isNotEmpty || unitText.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (brand.isNotEmpty)
                              _Card02MetaLine(
                                icon: Icons.storefront_outlined,
                                label: brand,
                              ),
                            if (unitText.isNotEmpty)
                              _Card02MetaLine(
                                icon: Icons.inventory_2_outlined,
                                label: unitText,
                              ),
                          ],
                        ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: MBColors.background,
                          borderRadius: BorderRadius.circular(MBRadius.lg),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                      color: MBColors.primaryOrange,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (hasDiscount)
                                    Text(
                                      '৳${regularPrice.toStringAsFixed(0)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: MBAppText.caption(context).copyWith(
                                        color: MBColors.textMuted,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    )
                                  else
                                    Text(
                                      inStock ? 'Ready to order' : 'Stock unavailable',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: MBAppText.caption(context).copyWith(
                                        color: inStock
                                            ? MBColors.success
                                            : MBColors.warning,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (showAddToCart)
                              _Card02CartButton(
                                enabled: inStock,
                                onTap: inStock ? onAddToCart : null,
                              ),
                          ],
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

  String _imageUrl(MBProduct product) {
    final thumb = product.thumbnailUrl.trim();
    if (thumb.isNotEmpty) return thumb;
    if (product.imageUrls.isNotEmpty) {
      return product.imageUrls.first.trim();
    }
    return '';
  }

  String _title(MBProduct product) {
    final en = product.titleEn.trim();
    if (en.isNotEmpty) return en;
    final bn = product.titleBn.trim();
    if (bn.isNotEmpty) return bn;
    return 'Untitled Product';
  }

  String _subtitle(MBProduct product) {
    final shortEn = product.shortDescriptionEn.trim();
    if (shortEn.isNotEmpty) return shortEn;
    final shortBn = product.shortDescriptionBn.trim();
    if (shortBn.isNotEmpty) return shortBn;
    final desc = product.descriptionEn.trim();
    if (desc.isNotEmpty) return desc;
    return 'A structured commerce card focused on framed product media and clean pricing details.';
  }

  String _unitText(MBProduct product) {
    final label = (product.unitLabelEn ?? '').trim();
    final value = product.quantityValue;
    if (label.isEmpty || value == null || value <= 0) {
      return '';
    }
    final normalizedValue = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
    return '$normalizedValue $label';
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

class _Card02ImagePlaceholder extends StatelessWidget {
  const _Card02ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MBColors.primaryOrange.withValues(alpha: 0.08),
            MBColors.primaryOrange.withValues(alpha: 0.22),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 42,
          color: MBColors.primaryOrange.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

class _Card02Tag extends StatelessWidget {
  const _Card02Tag({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
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
        label,
        style: MBAppText.caption(context).copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Card02FavoriteButton extends StatelessWidget {
  const _Card02FavoriteButton({
    required this.isFavorite,
    required this.onTap,
  });

  final bool isFavorite;
  final VoidCallback? onTap;

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
            color: Colors.white,
            border: Border.all(
              color: MBColors.divider.withValues(alpha: 0.9),
            ),
          ),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: isFavorite ? Colors.redAccent : MBColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _Card02PromoStrip extends StatelessWidget {
  const _Card02PromoStrip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: MBGradients.primaryGradient,
        borderRadius: BorderRadius.circular(MBRadius.pill),
      ),
      child: Text(
        label,
        style: MBAppText.bodySmall(context).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Card02MetaLine extends StatelessWidget {
  const _Card02MetaLine({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: MBColors.textSecondary,
        ),
        const SizedBox(width: 5),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: MBAppText.caption(context).copyWith(
              color: MBColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Card02CartButton extends StatelessWidget {
  const _Card02CartButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = enabled
        ? MBColors.primaryOrange
        : MBColors.textMuted.withValues(alpha: 0.20);
    final foreground = enabled ? Colors.white : MBColors.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(MBRadius.lg),
        onTap: enabled ? onTap : null,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(MBRadius.lg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_shopping_cart_outlined,
                size: 16,
                color: foreground,
              ),
              const SizedBox(width: 6),
              Text(
                'Cart',
                style: MBAppText.bodySmall(context).copyWith(
                  color: foreground,
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
