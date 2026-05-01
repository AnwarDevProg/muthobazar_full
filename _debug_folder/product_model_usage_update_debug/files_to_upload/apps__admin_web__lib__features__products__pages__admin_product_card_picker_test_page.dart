import 'package:admin_web/features/products/widgets/admin_product_card_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_card_config_resolver.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_product_card_variant_router.dart';

// Admin Product Card Picker Test Page
//
// Purpose:
// A standalone admin-side test page for the product card picker workflow.
//
// What this page does:
// - builds a realistic preview product
// - opens the admin card gallery dialog
// - receives the selected card variant id
// - renders the selected card on the page for testing
//
// Why this exists:
// Before wiring the picker into the real product create/edit page, this page
// allows safe testing of:
// - family filtering
// - variant selection
// - live preview rendering
// - selected card flow
//
// Notes:
// - This is a temporary admin test page.
// - The real integration will later move into the product create/edit flow.
// - "Edit selected card" currently shows a placeholder message.

class AdminProductCardPickerTestPage extends StatefulWidget {
  const AdminProductCardPickerTestPage({super.key});

  @override
  State<AdminProductCardPickerTestPage> createState() =>
      _AdminProductCardPickerTestPageState();
}

class _AdminProductCardPickerTestPageState
    extends State<AdminProductCardPickerTestPage> {
  late final MBProduct _previewProduct;
  String _selectedVariantId = MBCardVariant.compact01.id;

  MBCardVariant get _selectedVariant => MBCardVariantHelper.parse(
    _selectedVariantId,
    fallback: MBCardVariant.compact01,
  );

  @override
  void initState() {
    super.initState();
    _previewProduct = _buildPreviewProduct();
  }

  @override
  Widget build(BuildContext context) {
    final resolved = MBCardConfigResolver.resolveByVariant(_selectedVariant);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeader(context),
              const SizedBox(height: 18),
              _buildTopStatusCard(context),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 1100;

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildControlPanel(context),
                        const SizedBox(height: 18),
                        _buildPreviewPanel(context, resolved),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 360,
                        child: _buildControlPanel(context),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _buildPreviewPanel(context, resolved),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFFFF8A00),
            Color(0xFFFF6A00),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Admin Product Card Picker Test',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use this page to test the card showcase dialog before wiring it into the real product create/edit workflow.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.94),
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatusCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          _InfoChip(
            label: 'Selected Family',
            value: _selectedVariant.family.label,
          ),
          _InfoChip(
            label: 'Selected Variant',
            value: _selectedVariant.id,
          ),
          _InfoChip(
            label: 'Footprint',
            value: _selectedVariant.isFullWidth ? 'Full width' : 'Half width',
          ),
          const _InfoChip(
            label: 'Mode',
            value: 'Admin test',
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Picker controls',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Preview product',
            value: _productLabel(_previewProduct),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Brand',
            value: _previewProduct.brandNameEn?.trim().isNotEmpty == true
                ? _previewProduct.brandNameEn!.trim()
                : 'Unknown',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Price',
            value: _priceLabel(_previewProduct),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Selected card',
            value: _selectedVariant.id,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openPicker,
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('Open card gallery'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _editSelectedCard,
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Edit selected card'),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Workflow note',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'In the final admin workflow, this same picker will open from the bottom of the product create/edit page using the current form data as the preview source.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPanel(
      BuildContext context,
      MBResolvedCardConfig resolved,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Selected card preview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This preview uses the currently selected variant with the current test product data.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          _buildPreviewCanvas(context, resolved),
        ],
      ),
    );
  }

  Widget _buildPreviewCanvas(
      BuildContext context,
      MBResolvedCardConfig resolved,
      ) {
    Widget preview = MBProductCardVariantRouter.build(
      context: context,
      resolved: resolved,
      product: _previewProduct,
      onTap: () {},
      onAddToCartTap: () {},
    );

    if (resolved.footprint.isFullWidth) {
      preview = SizedBox(
        height: 330,
        child: preview,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final halfWidth = maxWidth > 620 ? (maxWidth - 14) / 2 : maxWidth;

        if (resolved.footprint.isFullWidth) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: preview,
          );
        }

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: <Widget>[
            SizedBox(
              width: halfWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: preview,
              ),
            ),
            SizedBox(
              width: halfWidth,
              child: Opacity(
                opacity: 0.88,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: MBProductCardVariantRouter.build(
                    context: context,
                    resolved: resolved,
                    product: _previewProduct,
                    onTap: () {},
                    onAddToCartTap: () {},
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openPicker() async {
    final result = await AdminProductCardPickerDialog.show(
      context,
      previewProduct: _previewProduct,
      initialVariantId: _selectedVariantId,
      onEditCard: (context, variant) async {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Edit dialog for ${variant.id} will be wired next.'),
          ),
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _selectedVariantId = result.variantId;
    });
  }

  void _editSelectedCard() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit dialog for ${_selectedVariant.id} will be wired next.',
        ),
      ),
    );
  }

  MBProduct _buildPreviewProduct() {
    return MBProduct.fromMap(
      <String, dynamic>{
        'id': 'admin_preview_product_01',
        'slug': 'premium-basmati-rice-5kg',
        'titleEn': 'Premium Basmati Rice 5kg',
        'titleBn': 'প্রিমিয়াম বাসমতি চাল ৫ কেজি',
        'nameEn': 'Premium Basmati Rice 5kg',
        'nameBn': 'প্রিমিয়াম বাসমতি চাল ৫ কেজি',
        'shortDescriptionEn':
        'Long grain aromatic rice for everyday family meals.',
        'shortDescriptionBn':
        'দৈনন্দিন পারিবারিক খাবারের জন্য লং গ্রেইন সুগন্ধি চাল।',
        'descriptionEn':
        'Long grain aromatic rice for everyday family meals.',
        'descriptionBn':
        'দৈনন্দিন পারিবারিক খাবারের জন্য লং গ্রেইন সুগন্ধি চাল।',
        'thumbnailUrl':
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=1200&q=80',
        'imageUrl':
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=1200&q=80',
        'imageUrls': <String>[
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=1200&q=80',
        ],
        'price': 620.0,
        'salePrice': 549.0,
        'stockQty': 18,
        'regularStockQty': 18,
        'trackInventory': true,
        'allowBackorder': false,
        'categoryId': 'rice',
        'categoryNameEn': 'Rice',
        'categoryNameBn': 'চাল',
        'brandNameEn': 'Mutho Select',
        'brandNameBn': 'মুঠো সিলেক্ট',
        'unitLabelEn': '5 kg',
        'productType': 'simple',
        'tags': <String>['rice', 'premium', 'family'],
        'isFeatured': true,
        'isBestSeller': true,
        'isNewArrival': false,
        'isFlashSale': false,
        'cardVariantId': _selectedVariantId,
        'cardVariant': _selectedVariantId,
        'cardLayoutType': _selectedVariantId,
      },
    );
  }

  String _productLabel(MBProduct product) {
    final titleEn = product.titleEn.trim();
    if (titleEn.isNotEmpty) {
      return titleEn;
    }

    final titleBn = product.titleBn.trim();
    if (titleBn.isNotEmpty) {
      return titleBn;
    }

    final slug = product.slug.trim();
    if (slug.isNotEmpty) {
      return slug;
    }

    return 'Preview product';
  }

  String _priceLabel(MBProduct product) {
    final salePrice = product.salePrice;
    final base = '৳${product.price.toStringAsFixed(0)}';

    if (salePrice != null && salePrice < product.price) {
      return '৳${salePrice.toStringAsFixed(0)} (was $base)';
    }

    return base;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF374151),
            fontWeight: FontWeight.w600,
          ),
          children: <InlineSpan>[
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFFE67E22),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 104,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}