import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

import '../data/product_card_preview_dummy_data.dart';
import '../widgets/product_card_preview_section.dart';
import '../widgets/product_card_preview_toolbar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String _selectedCategoryId;
  late String _selectedProductId;

  @override
  void initState() {
    super.initState();
    final initialCategory = MBProductCardPreviewDummyData.categories.first;
    final initialProducts =
    MBProductCardPreviewDummyData.productsForCategory(initialCategory.id);

    _selectedCategoryId = initialCategory.id;
    _selectedProductId = initialProducts.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final categories = MBProductCardPreviewDummyData.categories;
    final products =
    MBProductCardPreviewDummyData.productsForCategory(_selectedCategoryId);

    final selectedProduct =
        _resolveSelectedProduct(products) ?? MBProductCardPreviewDummyData.fallbackProduct;

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: true,
      safeBottom: false,
      scrollable: true,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: MBScreenPadding.page(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChatPreviewHero(
              totalCategoryCount: categories.length,
              totalProductCount: MBProductCardPreviewDummyData.allProducts.length,
              selectedProduct: selectedProduct,
            ),
            MBSpacing.h(MBSpacing.sectionGap(context)),
            ProductCardPreviewToolbar(
              categories: categories,
              selectedCategoryId: _selectedCategoryId,
              onCategoryChanged: _onCategoryChanged,
              products: products,
              selectedProductId: selectedProduct.id,
              onProductChanged: _onProductChanged,
            ),
            MBSpacing.h(MBSpacing.sectionGap(context)),
            ProductCardPreviewSection(product: selectedProduct),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom + 96,
            ),
          ],
        ),
      ),
    );
  }

  void _onCategoryChanged(String categoryId) {
    if (_selectedCategoryId == categoryId) return;

    final nextProducts = MBProductCardPreviewDummyData.productsForCategory(categoryId);
    if (nextProducts.isEmpty) return;

    setState(() {
      _selectedCategoryId = categoryId;
      _selectedProductId = nextProducts.first.id;
    });
  }

  void _onProductChanged(String productId) {
    if (_selectedProductId == productId) return;

    setState(() {
      _selectedProductId = productId;
    });
  }

  MBProduct? _resolveSelectedProduct(List<MBProduct> products) {
    for (final product in products) {
      if (product.id == _selectedProductId) {
        return product;
      }
    }

    if (products.isNotEmpty) {
      return products.first;
    }

    return null;
  }
}

class _ChatPreviewHero extends StatelessWidget {
  const _ChatPreviewHero({
    required this.totalCategoryCount,
    required this.totalProductCount,
    required this.selectedProduct,
  });

  final int totalCategoryCount;
  final int totalProductCount;
  final MBProduct selectedProduct;

  @override
  Widget build(BuildContext context) {
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
        gradient: MBGradients.headerGradient,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isWide
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _HeroTextBlock(selectedProduct: selectedProduct),
          ),
          MBSpacing.w(MBSpacing.blockGap(context)),
          _HeroStatsBlock(
            totalCategoryCount: totalCategoryCount,
            totalProductCount: totalProductCount,
            selectedProduct: selectedProduct,
          ),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroTextBlock(selectedProduct: selectedProduct),
          MBSpacing.h(MBSpacing.blockGap(context)),
          _HeroStatsBlock(
            totalCategoryCount: totalCategoryCount,
            totalProductCount: totalProductCount,
            selectedProduct: selectedProduct,
          ),
        ],
      ),
    );
  }
}

class _HeroTextBlock extends StatelessWidget {
  const _HeroTextBlock({
    required this.selectedProduct,
  });

  final MBProduct selectedProduct;

  @override
  Widget build(BuildContext context) {
    final categoryName = (selectedProduct.categoryNameEn ?? '').trim();
    final brandName = (selectedProduct.brandNameEn ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(MBRadius.pill),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            'Temporary Product Card Lab',
            style: MBAppText.bodySmall(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        MBSpacing.h(MBSpacing.sm),
        Text(
          'Preview all product card styles in one page',
          style: MBAppText.headline2(context).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        MBSpacing.h(MBSpacing.xxs),
        Text(
          'Use the selectors below to switch category and product. The same product will render through all registered card layouts so design differences are easy to compare.',
          style: MBAppText.body(context).copyWith(
            color: Colors.white.withValues(alpha: 0.94),
          ),
        ),
        MBSpacing.h(MBSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (categoryName.isNotEmpty)
              _HeroPill(
                icon: Icons.category_outlined,
                label: categoryName,
              ),
            if (brandName.isNotEmpty)
              _HeroPill(
                icon: Icons.storefront_outlined,
                label: brandName,
              ),
            _HeroPill(
              icon: Icons.widgets_outlined,
              label:
              MBProductCardLayoutHelper.parse(selectedProduct.cardLayoutType).label,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroStatsBlock extends StatelessWidget {
  const _HeroStatsBlock({
    required this.totalCategoryCount,
    required this.totalProductCount,
    required this.selectedProduct,
  });

  final int totalCategoryCount;
  final int totalProductCount;
  final MBProduct selectedProduct;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroStatCard(
            icon: Icons.grid_view_rounded,
            label: 'Categories',
            value: '$totalCategoryCount',
          ),
          MBSpacing.h(MBSpacing.sm),
          _HeroStatCard(
            icon: Icons.inventory_2_outlined,
            label: 'Products',
            value: '$totalProductCount',
          ),
          MBSpacing.h(MBSpacing.sm),
          _HeroStatCard(
            icon: Icons.sell_outlined,
            label: 'Selected Price',
            value: '৳${selectedProduct.effectivePrice.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }
}

class _HeroStatCard extends StatelessWidget {
  const _HeroStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(MBRadius.md),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
          ),
          MBSpacing.w(MBSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: MBAppText.label(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: MBAppText.caption(context).copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
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
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(MBRadius.pill),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: MBAppText.bodySmall(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
