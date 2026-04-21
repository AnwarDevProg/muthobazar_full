import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

import '../data/product_card_preview_dummy_data.dart';
import '../models/product_card_preview_option.dart';

class ProductCardPreviewToolbar extends StatelessWidget {
  const ProductCardPreviewToolbar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.products,
    required this.selectedProductId,
    required this.onProductChanged,
  });

  final List<MBProductCardPreviewCategory> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategoryChanged;
  final List<MBProduct> products;
  final String selectedProductId;
  final ValueChanged<String> onProductChanged;

  @override
  Widget build(BuildContext context) {
    final categoryOptions = categories
        .map(
          (category) => ProductCardPreviewOption(
        id: category.id,
        label: category.nameEn,
        subtitle: category.nameBn,
      ),
    )
        .toList(growable: false);

    final productOptions = products
        .map(
          (product) => ProductCardPreviewOption(
        id: product.id,
        label: product.titleEn,
        subtitle: _buildProductSubtitle(product),
      ),
    )
        .toList(growable: false);

    final isWide = context.mbValue(
      mobileSmall: false,
      mobile: false,
      mobileLarge: true,
      tablet: true,
      tabletLarge: true,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
      decoration: BoxDecoration(
        color: MBColors.card,
        borderRadius: BorderRadius.circular(MBRadius.xl),
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
          _ToolbarHeader(
            categoryCount: categories.length,
            productCount: products.length,
          ),
          MBSpacing.h(MBSpacing.blockGap(context)),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PreviewDropdownCard(
                    title: 'Category',
                    hint: 'Select category',
                    icon: Icons.category_outlined,
                    value: selectedCategoryId,
                    options: categoryOptions,
                    onChanged: onCategoryChanged,
                  ),
                ),
                MBSpacing.w(MBSpacing.itemGap(context)),
                Expanded(
                  child: _PreviewDropdownCard(
                    title: 'Product',
                    hint: 'Select product',
                    icon: Icons.inventory_2_outlined,
                    value: selectedProductId,
                    options: productOptions,
                    onChanged: onProductChanged,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _PreviewDropdownCard(
                  title: 'Category',
                  hint: 'Select category',
                  icon: Icons.category_outlined,
                  value: selectedCategoryId,
                  options: categoryOptions,
                  onChanged: onCategoryChanged,
                ),
                MBSpacing.h(MBSpacing.itemGap(context)),
                _PreviewDropdownCard(
                  title: 'Product',
                  hint: 'Select product',
                  icon: Icons.inventory_2_outlined,
                  value: selectedProductId,
                  options: productOptions,
                  onChanged: onProductChanged,
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _buildProductSubtitle(MBProduct product) {
    final brand = (product.brandNameEn ?? '').trim();
    final price = product.effectivePrice.toStringAsFixed(0);

    if (brand.isEmpty) {
      return '৳$price';
    }

    return '$brand • ৳$price';
  }
}

class _ToolbarHeader extends StatelessWidget {
  const _ToolbarHeader({
    required this.categoryCount,
    required this.productCount,
  });

  final int categoryCount;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preview Controls',
                style: MBAppText.headline3(context).copyWith(
                  color: MBColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              MBSpacing.h(MBSpacing.xxxs),
              Text(
                'Pick one product and preview all card layouts with the same data.',
                style: MBAppText.bodySmall(context).copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        MBSpacing.w(MBSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            _InfoChip(
              icon: Icons.category_rounded,
              label: '$categoryCount categories',
            ),
            _InfoChip(
              icon: Icons.widgets_outlined,
              label: '$productCount products',
            ),
          ],
        ),
      ],
    );
  }
}

class _PreviewDropdownCard extends StatelessWidget {
  const _PreviewDropdownCard({
    required this.title,
    required this.hint,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final String hint;
  final IconData icon;
  final String value;
  final List<ProductCardPreviewOption> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final validIds = options.map((item) => item.id).toSet();
    final selectedValue = validIds.contains(value) ? value : null;
    final selectedOption = options.where((item) => item.id == selectedValue).firstOrNull;

    return Container(
      padding: EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.divider.withValues(alpha: 0.9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: MBColors.primaryOrange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(MBRadius.md),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: MBColors.primaryOrange,
                ),
              ),
              MBSpacing.w(MBSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: MBAppText.label(context).copyWith(
                    color: MBColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.sm),
          DropdownButtonFormField<String>(
            value: selectedValue,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: MBColors.card,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MBRadius.md),
                borderSide: BorderSide(
                  color: MBColors.divider.withValues(alpha: 0.85),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MBRadius.md),
                borderSide: BorderSide(
                  color: MBColors.divider.withValues(alpha: 0.85),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MBRadius.md),
                borderSide: const BorderSide(
                  color: MBColors.primaryOrange,
                  width: 1.2,
                ),
              ),
            ),
            items: options
                .map(
                  (item) => DropdownMenuItem<String>(
                value: item.id,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MBAppText.body(context).copyWith(
                    color: MBColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null || value.trim().isEmpty) return;
              onChanged(value);
            },
          ),
          if (selectedOption != null &&
              (selectedOption.subtitle ?? '').trim().isNotEmpty) ...[
            MBSpacing.h(MBSpacing.xs),
            Text(
              selectedOption.subtitle!.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MBAppText.caption(context).copyWith(
                color: MBColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
        color: MBColors.primaryOrange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(MBRadius.pill),
        border: Border.all(
          color: MBColors.primaryOrange.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: MBColors.primaryOrange,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: MBAppText.bodySmall(context).copyWith(
              color: MBColors.primaryOrange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
