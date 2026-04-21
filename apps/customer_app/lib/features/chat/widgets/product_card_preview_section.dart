import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class ProductCardPreviewSection extends StatelessWidget {
  const ProductCardPreviewSection({
    super.key,
    required this.product,
  });

  final MBProduct product;

  @override
  Widget build(BuildContext context) {
    final layouts = MBProductCardRenderer.availableLayouts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewProductSummary(product: product),
        MBSpacing.h(MBSpacing.sectionGap(context)),
        ...layouts.map(
              (layout) => Padding(
            padding: EdgeInsets.only(bottom: MBSpacing.sectionGap(context)),
            child: _CardLayoutPreviewBlock(
              sourceProduct: product,
              layout: layout,
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewProductSummary extends StatelessWidget {
  const _PreviewProductSummary({
    required this.product,
  });

  final MBProduct product;

  @override
  Widget build(BuildContext context) {
    final title =
    product.titleEn.trim().isEmpty ? 'Untitled Product' : product.titleEn.trim();
    final subtitleParts = <String>[
      if ((product.categoryNameEn ?? '').trim().isNotEmpty)
        product.categoryNameEn!.trim(),
      if ((product.brandNameEn ?? '').trim().isNotEmpty)
        product.brandNameEn!.trim(),
      'Layout: ${MBProductCardLayoutHelper.parse(product.cardLayoutType).label}',
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
      decoration: BoxDecoration(
        gradient: MBGradients.primaryGradient,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryChip(
                icon: Icons.inventory_2_outlined,
                label: title,
              ),
              _SummaryChip(
                icon: Icons.photo_library_outlined,
                label: '${product.imageUrls.length} images',
              ),
              _SummaryChip(
                icon: Icons.sell_outlined,
                label: '৳${product.effectivePrice.toStringAsFixed(0)}',
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.sm),
          Text(
            'Previewing one product across all registered card layouts.',
            style: MBAppText.body(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.xxxs),
          Text(
            subtitleParts.join(' • '),
            style: MBAppText.bodySmall(context).copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardLayoutPreviewBlock extends StatelessWidget {
  const _CardLayoutPreviewBlock({
    required this.sourceProduct,
    required this.layout,
  });

  final MBProduct sourceProduct;
  final MBProductCardLayout layout;

  @override
  Widget build(BuildContext context) {
    final previewProduct = sourceProduct.copyWith(cardLayoutType: layout.value);
    final isBuilt = MBProductCardRenderer.isLayoutBuilt(layout);
    final fallbackLabel = MBProductCardRenderer.previewFallbackLabelFor(layout);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
      decoration: BoxDecoration(
        color: MBColors.card,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BlockHeader(
            layout: layout,
            isBuilt: isBuilt,
            fallbackLabel: fallbackLabel,
          ),
          MBSpacing.h(MBSpacing.blockGap(context)),
          _PreviewCanvas(
            child: _buildRendererPreview(previewProduct, layout),
          ),
        ],
      ),
    );
  }

  Widget _buildRendererPreview(MBProduct previewProduct, MBProductCardLayout layout) {
    switch (layout) {
      case MBProductCardLayout.featured:
        return SizedBox(
          width: double.infinity,
          child: MBProductCardRenderer(
            product: previewProduct,
            contextType: MBProductCardRenderContext.featured,
            showAddToCart: true,
            showFavorite: true,
            featuredHeight: 320,
          ),
        );

      case MBProductCardLayout.compact:
        return SizedBox(
          width: 320,
          child: MBProductCardRenderer(
            product: previewProduct,
            contextType: MBProductCardRenderContext.horizontal,
            showAddToCart: true,
            showFavorite: true,
          ),
        );

      case MBProductCardLayout.card03:
        return SizedBox(
          width: 260,
          height: 560,
          child: MBProductCardRenderer(
            product: previewProduct,
            contextType: MBProductCardRenderContext.auto,
            showAddToCart: true,
            showFavorite: true,
          ),
        );

      case MBProductCardLayout.deal:
      case MBProductCardLayout.standard:
      case MBProductCardLayout.card01:
      case MBProductCardLayout.card02:
      case MBProductCardLayout.card04:
      case MBProductCardLayout.card05:
      case MBProductCardLayout.card06:
      case MBProductCardLayout.card07:
      case MBProductCardLayout.card08:
      case MBProductCardLayout.card09:
      case MBProductCardLayout.card10:
      case MBProductCardLayout.card11:
      case MBProductCardLayout.card12:
      case MBProductCardLayout.card13:
      case MBProductCardLayout.card14:
      case MBProductCardLayout.card15:
      case MBProductCardLayout.card16:
      case MBProductCardLayout.card17:
      case MBProductCardLayout.card18:
      case MBProductCardLayout.card19:
      case MBProductCardLayout.card20:
        return SizedBox(
          width: 240,
          height: 320,
          child: MBProductCardRenderer(
            product: previewProduct,
            contextType: MBProductCardRenderContext.grid,
            showAddToCart: true,
            showFavorite: true,
          ),
        );
    }
  }
}

class _BlockHeader extends StatelessWidget {
  const _BlockHeader({
    required this.layout,
    required this.isBuilt,
    required this.fallbackLabel,
  });

  final MBProductCardLayout layout;
  final bool isBuilt;
  final String fallbackLabel;

  @override
  Widget build(BuildContext context) {
    final subtitle = isBuilt
        ? 'This layout is built and rendered directly.'
        : 'Preview uses fallback renderer: $fallbackLabel';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                layout.label,
                style: MBAppText.headline3(context).copyWith(
                  color: MBColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              MBSpacing.h(MBSpacing.xxxs),
              Text(
                subtitle,
                style: MBAppText.bodySmall(context).copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        MBSpacing.w(MBSpacing.sm),
        _StatusChip(
          label: isBuilt ? 'Built' : 'Fallback Preview',
          isBuilt: isBuilt,
        ),
      ],
    );
  }
}

class _PreviewCanvas extends StatelessWidget {
  const _PreviewCanvas({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MBSpacing.lg),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.divider.withValues(alpha: 0.85),
        ),
      ),
      child: Center(child: child),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
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
            size: 16,
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.isBuilt,
  });

  final String label;
  final bool isBuilt;

  @override
  Widget build(BuildContext context) {
    final color = isBuilt ? MBColors.success : MBColors.primaryOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(MBRadius.pill),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: MBAppText.bodySmall(context).copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
