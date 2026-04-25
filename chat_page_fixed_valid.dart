import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/widgets/common/product_cards/mb_product_card_renderer.dart';

// File: chat_page.dart
// Location: apps/customer_app/lib/features/chat/pages/chat_page.dart
//
// Development purpose:
// This customer-app ChatPage is temporarily used as the single-card design
// preview/tuning lab for the product card currently under development.
//
// Current target:
// compact01
//
// Design workflow:
// 1. Tune compact01 here using the real customer-app page.
// 2. Keep the final compact01 widget in shared_ui.
// 3. Change _underDevelopmentVariant to compact02 when starting compact02.
// 4. This page should not write to Firestore and should not save products.
//
// Rendering path:
// MBCardInstanceConfig
// -> MBProduct.cardConfig
// -> MBProductCardRenderer
// -> MBProductCardVariantRouter
// -> target product-card widget.
//
// Notes:
// - This page intentionally behaves like a chat/design review screen.
// - The card identity stays fixed inside the card widget.
// - The controls only modify cardConfig settings.
// - Uses withValues(alpha: ...) instead of withOpacity().

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const MBCardVariant _underDevelopmentVariant = MBCardVariant.compact01;

  String _accentToken = 'accent_orange_primary';
  String _surfaceToken = 'surface_default_white';
  String _titleColorToken = 'text_title_primary';
  String _subtitleColorToken = 'text_subtitle_inverse';
  String _priceColorToken = 'text_price_primary';
  String _oldPriceColorToken = 'text_old_price_muted';
  String _borderColorToken = 'border_orange_line';
  String _effectPreset = 'none';
  String _ctaColorToken = 'cta_navy';
  String _ctaStylePreset = 'cta_strong_pill';
  String _imageFitMode = 'cover';

  bool _saleActive = true;
  bool _showSubtitle = true;
  bool _showShortDescription = true;
  bool _showBrand = false;
  bool _showUnitLabel = false;

  bool _showAddToCart = true;
  bool _showOriginalPriceWhenSaleActive = true;
  bool _showDiscountBadge = true;
  bool _showSavingsText = true;
  bool _emphasizeFinalPrice = true;
  bool _showCurrencySymbol = true;

  bool _useLongTitle = false;
  bool _useLongDescription = false;

  bool _showBorder = false;
  bool _showPromoStrip = false;
  bool _showImageShadow = true;

  double _radius = 18;
  double _elevation = 2;
  double _paddingScale = 1;
  double _borderWidth = 1;
  double _effectIntensity = 0.35;
  double _imageOverlayOpacity = 0;

  static const String _demoImageUrl =
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900';

  MBCardInstanceConfig get _cardConfig {
    return MBCardInstanceConfig(
      family: _underDevelopmentVariant.family,
      variant: _underDevelopmentVariant,
      settings: MBCardSettingsOverride(
        surface: MBCardSurfaceSettings(
          backgroundColorToken: _surfaceToken,
          borderRadius: _radius,
          elevationLevel: _elevation,
          paddingScale: _paddingScale,
        ),
        typography: MBCardTypographySettings(
          titleColorToken: _titleColorToken,
          subtitleColorToken: _subtitleColorToken,
          priceColorToken: _priceColorToken,
          oldPriceColorToken: _oldPriceColorToken,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          titleBold: true,
          priceBold: true,
        ),
        accent: MBCardAccentSettings(
          accentColorToken: _accentToken,
          showAccentBar: true,
          accentBarPosition: 'top',
          showPromoStrip: _showPromoStrip,
          promoStripColorToken: _accentToken,
        ),
        borderEffect: MBCardBorderEffectSettings(
          showBorder: _showBorder,
          borderColorToken: _borderColorToken,
          borderWidth: _borderWidth,
          effectPreset: _effectPreset,
          effectIntensity: _effectIntensity,
        ),
        price: MBCardPriceSettings(
          priceMode: _saleActive && _showOriginalPriceWhenSaleActive
              ? MBCardPriceMode.originalAndFinal
              : MBCardPriceMode.finalOnly,
          showDiscountBadge: _showDiscountBadge,
          showSavingsText: _showSavingsText,
          emphasizeFinalPrice: _emphasizeFinalPrice,
          showCurrencySymbol: _showCurrencySymbol,
        ),
        actions: MBCardActionSettings(
          showAddToCart: _showAddToCart,
          showViewDetails: false,
          ctaStylePreset: _ctaStylePreset,
          ctaColorToken: _ctaColorToken,
        ),
        media: MBCardMediaSettings(
          imageFitMode: _imageFitMode,
          imageOverlayOpacity: _imageOverlayOpacity,
          showImageShadow: _showImageShadow,
          imageFrameStyle: 'circle',
        ),
        badges: const MBCardBadgeSettings(
          showPrimaryBadge: true,
          primaryBadgeStyle: 'badge_soft_deal',
          badgePlacement: 'top_right',
        ),
        meta: MBCardMetaSettings(
          showSubtitle: _showSubtitle,
          showShortDescription: _showShortDescription,
          showBrand: _showBrand,
          showUnitLabel: _showUnitLabel,
          showStockHint: false,
          showDeliveryHint: false,
        ),
      ),
    ).normalized();
  }

  MBProduct get _previewProduct {
    final config = _cardConfig;

    return MBProduct(
      id: 'compact01-chat-preview',
      slug: 'sport-shoes',
      productCode: 'COMPACT01-DEMO',
      sku: 'COMPACT01-DEMO',
      titleEn: _useLongTitle
          ? 'SPORT SHOES FOR ACTIVE DAILY LIFESTYLE'
          : 'SPORT SHOES',
      titleBn: 'স্পোর্ট জুতা',
      shortDescriptionEn: _useLongDescription
          ? 'Comfortable daily wear for active lifestyle with soft cushioning and flexible grip.'
          : 'Comfortable daily wear for active lifestyle.',
      shortDescriptionBn: 'দৈনন্দিন ব্যবহারের আরামদায়ক জুতা।',
      descriptionEn: 'Demo product for compact01 chat design preview.',
      descriptionBn: 'compact01 কার্ড প্রিভিউর ডেমো পণ্য।',
      thumbnailUrl: _demoImageUrl,
      imageUrls: const <String>[_demoImageUrl],
      price: 150,
      salePrice: _saleActive ? 120 : null,
      costPrice: 90,
      categoryId: 'cat_preview',
      categoryNameEn: 'Shoes',
      categoryNameBn: 'জুতা',
      categorySlug: 'shoes',
      brandId: 'brand_preview',
      brandNameEn: 'MuthoFit',
      brandNameBn: 'মুঠোফিট',
      brandSlug: 'muthofit',
      productType: 'simple',
      tags: const <String>['shoes', 'sport'],
      keywords: const <String>['shoes', 'sport', 'compact01'],
      cardLayoutType: config.variantId,
      cardConfig: config,
      isFeatured: true,
      isFlashSale: _saleActive,
      isEnabled: true,
      isNewArrival: true,
      isBestSeller: false,
      stockQty: 35,
      regularStockQty: 35,
      quantityType: 'pcs',
      quantityValue: 1,
      unitLabelEn: 'pair',
      unitLabelBn: 'জোড়া',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _previewProduct;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EA),
      appBar: AppBar(
        title: const Text('Card Design Chat Lab'),
        actions: [
          TextButton.icon(
            onPressed: _resetDefaults,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset compact01'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 920;

          if (isNarrow) {
            return Column(
              children: [
                Expanded(child: _buildChatPane(context, product)),
                const Divider(height: 1),
                SizedBox(
                  height: 390,
                  child: _buildSettingsPane(context),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 6,
                child: _buildChatPane(context, product),
              ),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 430,
                child: _buildSettingsPane(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatPane(BuildContext context, MBProduct product) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        _messageBubble(
          context,
          sender: 'Design system',
          message:
          'We are tuning only ${_underDevelopmentVariant.id}. The card layout is fixed; this page changes only cardConfig settings and test product states.',
          alignRight: false,
        ),
        const SizedBox(height: 14),
        _cardPreviewBubble(context, product),
        const SizedBox(height: 14),
        _messageBubble(
          context,
          sender: 'Current config',
          message: _configSummary(product),
          alignRight: false,
          monospace: true,
        ),
        const SizedBox(height: 14),
        _messageBubble(
          context,
          sender: 'Current compact01 manual layout values',
          message: _manualLayoutSummary(),
          alignRight: false,
          monospace: true,
        ),
        const SizedBox(height: 14),
        _messageBubble(
          context,
          sender: 'Decision',
          message:
          'Fixed identity now: half-width, diagonal top panel, higher 2-line title, 2-line subtitle, larger circular media, save chip near image, bottom-left final/original price, and bottom-right Buy CTA.',
          alignRight: true,
        ),
      ],
    );
  }

  Widget _cardPreviewBubble(BuildContext context, MBProduct product) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bubbleHeader(context, 'Live customer-app card preview'),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 280,
                child: MBProductCardRenderer(
                  product: product,
                  contextType: MBProductCardRenderContext.grid,
                  onTap: () {},
                  onAddToCartTap: () {},
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _miniChip(context, 'variant: ${product.effectiveCardVariantId}'),
                _miniChip(context, 'family: ${product.effectiveCardFamilyId}'),
                _miniChip(context, 'sale: $_saleActive'),
                _miniChip(
                  context,
                  'original price: $_showOriginalPriceWhenSaleActive',
                ),
                _miniChip(context, 'save chip: $_showSavingsText'),
                _miniChip(context, 'effect: $_effectPreset'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageBubble(
      BuildContext context, {
        required String sender,
        required String message,
        required bool alignRight,
        bool monospace = false,
      }) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: alignRight ? const Color(0xFFFFD7B1) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(alignRight ? 22 : 6),
            bottomRight: Radius.circular(alignRight ? 6 : 22),
          ),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bubbleHeader(context, sender),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: monospace ? 'monospace' : null,
                height: 1.38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubbleHeader(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w900,
        color: const Color(0xFF9A4D00),
      ),
    );
  }

  Widget _miniChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSettingsPane(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Tune ${_underDevelopmentVariant.id}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'These controls update cardConfig settings and preview test states only.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 18),
          _section(
            context,
            'Theme',
            [
              _dropdown(
                label: 'Theme color',
                value: _accentToken,
                values: const [
                  'accent_orange_primary',
                  'accent_teal',
                  'accent_pink',
                  'accent_red_hot',
                  'accent_gold_premium',
                  'accent_blue',
                  'accent_green',
                ],
                onChanged: (value) => setState(() => _accentToken = value),
              ),
              _dropdown(
                label: 'Surface',
                value: _surfaceToken,
                values: const [
                  'surface_default_white',
                  'surface_soft_orange',
                  'surface_soft_gray',
                  'surface_promo_cream',
                ],
                onChanged: (value) => setState(() => _surfaceToken = value),
              ),
            ],
          ),
          _section(
            context,
            'Preview Product Test',
            [
              _switch(
                label: 'Use long title test',
                value: _useLongTitle,
                onChanged: (value) => setState(() => _useLongTitle = value),
              ),
              _switch(
                label: 'Use long short-description test',
                value: _useLongDescription,
                onChanged: (value) =>
                    setState(() => _useLongDescription = value),
              ),
            ],
          ),
          _section(
            context,
            'Text',
            [
              _dropdown(
                label: 'Title color',
                value: _titleColorToken,
                values: const [
                  'text_title_primary',
                  'text_title_inverse',
                ],
                onChanged: (value) => setState(() => _titleColorToken = value),
              ),
              _dropdown(
                label: 'Subtitle color',
                value: _subtitleColorToken,
                values: const [
                  'text_subtitle_inverse',
                  'text_subtitle_muted',
                ],
                onChanged: (value) =>
                    setState(() => _subtitleColorToken = value),
              ),
              _switch(
                label: 'Show subtitle',
                value: _showSubtitle,
                onChanged: (value) => setState(() => _showSubtitle = value),
              ),
              _switch(
                label: 'Use short description',
                value: _showShortDescription,
                onChanged: (value) =>
                    setState(() => _showShortDescription = value),
              ),
              _switch(
                label: 'Show brand fallback',
                value: _showBrand,
                onChanged: (value) => setState(() => _showBrand = value),
              ),
              _switch(
                label: 'Show unit label fallback',
                value: _showUnitLabel,
                onChanged: (value) => setState(() => _showUnitLabel = value),
              ),
            ],
          ),
          _section(
            context,
            'Price / Sale',
            [
              _switch(
                label: 'Sale active',
                value: _saleActive,
                onChanged: (value) => setState(() => _saleActive = value),
              ),
              _switch(
                label: 'Show original price beside final price',
                value: _showOriginalPriceWhenSaleActive,
                onChanged: (value) => setState(
                  () => _showOriginalPriceWhenSaleActive = value,
                ),
              ),
              _switch(
                label: 'Show save chip near image',
                value: _showSavingsText,
                onChanged: (value) => setState(() => _showSavingsText = value),
              ),
              _switch(
                label: 'Save chip format as percent',
                value: _showDiscountBadge,
                onChanged: (value) =>
                    setState(() => _showDiscountBadge = value),
              ),
              _switch(
                label: 'Emphasize final price',
                value: _emphasizeFinalPrice,
                onChanged: (value) =>
                    setState(() => _emphasizeFinalPrice = value),
              ),
              _switch(
                label: 'Show currency symbol',
                value: _showCurrencySymbol,
                onChanged: (value) =>
                    setState(() => _showCurrencySymbol = value),
              ),
            ],
          ),
          _section(
            context,
            'CTA',
            [
              _switch(
                label: 'Show Buy button',
                value: _showAddToCart,
                onChanged: (value) => setState(() => _showAddToCart = value),
              ),
              _dropdown(
                label: 'Buy button color',
                value: _ctaColorToken,
                values: const [
                  'cta_navy',
                  'cta_orange',
                  'cta_teal',
                  'cta_pink',
                  'cta_red',
                ],
                onChanged: (value) => setState(() => _ctaColorToken = value),
              ),
              _dropdown(
                label: 'Buy button style',
                value: _ctaStylePreset,
                values: const [
                  'cta_strong_pill',
                  'cta_soft_pill',
                  'cta_outline_mini',
                ],
                onChanged: (value) => setState(() => _ctaStylePreset = value),
              ),
            ],
          ),
          _section(
            context,
            'Shape / Effect',
            [
              _slider(
                label: 'Corner radius',
                value: _radius,
                min: 0,
                max: 28,
                divisions: 14,
                onChanged: (value) => setState(() => _radius = value),
              ),
              _slider(
                label: 'Shadow / elevation',
                value: _elevation,
                min: 0,
                max: 6,
                divisions: 6,
                onChanged: (value) => setState(() => _elevation = value),
              ),
              _switch(
                label: 'Show outer line',
                value: _showBorder,
                onChanged: (value) => setState(() => _showBorder = value),
              ),
              _dropdown(
                label: 'Outer line effect',
                value: _effectPreset,
                values: const [
                  'none',
                  'simple',
                  'soft_glow',
                  'wave',
                  'electric',
                  'flame',
                ],
                onChanged: (value) => setState(() => _effectPreset = value),
              ),
              _slider(
                label: 'Effect intensity',
                value: _effectIntensity,
                min: 0,
                max: 1,
                divisions: 10,
                onChanged: (value) =>
                    setState(() => _effectIntensity = value),
              ),
            ],
          ),
          _section(
            context,
            'Media',
            [
              _dropdown(
                label: 'Image fit',
                value: _imageFitMode,
                values: const ['cover', 'contain', 'fill'],
                onChanged: (value) => setState(() => _imageFitMode = value),
              ),
              _switch(
                label: 'Image shadow',
                value: _showImageShadow,
                onChanged: (value) => setState(() => _showImageShadow = value),
              ),
              _slider(
                label: 'Image overlay',
                value: _imageOverlayOpacity,
                min: 0,
                max: 0.6,
                divisions: 6,
                onChanged: (value) =>
                    setState(() => _imageOverlayOpacity = value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: values.contains(value) ? value : values.first,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: values
            .map(
              (item) => DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          ),
        )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          onChanged(value);
        },
      ),
    );
  }

  Widget _switch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}'),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }


  String _manualLayoutSummary() {
    return 'compact01.dart current manual values\n'
        'designHeight: 348\n'
        'contentPaddingHorizontal: 18 * paddingScale, clamp 12..22\n'
        'contentPaddingVertical: 12 * paddingScale, clamp 8..18\n'
        'title: base 14.5, min 11, maxLines 2, shrink step 0.5\n'
        'subtitle: font 11.5, maxLines 2, no shrink\n'
        'imageSize: width * 0.72, clamp 140..162\n'
        'imageTop: height * 0.305\n'
        'imageRing: 8\n'
        'saveChipTop: imageTop + imageSize - 24\n'
        'saveChipLeft: imageLeft + imageSize * 0.56\n'
        'bottomRowHeight: 44\n'
        'finalPriceFont: 18\n'
        'oldPriceFont: 12\n'
        'buyButton: 88 x 34\n'
        'dots: kept in code for future setting, not used in current layout';
  }

  String _configSummary(MBProduct product) {
    final config = product.effectiveCardConfig.normalized();

    return 'cardLayoutType: ${product.cardLayoutType}\n'
        'variantId: ${config.variantId}\n'
        'familyId: ${config.familyId}\n'
        'titleMaxLines: 2\n'
        'saleActive: $_saleActive\n'
        'showOriginalPrice: $_showOriginalPriceWhenSaleActive\n'
        'showSaveChip: $_showSavingsText\n'
        'saveChipAsPercent: $_showDiscountBadge\n'
        'showBuyButton: $_showAddToCart\n'
        'settings: ${config.settings.toMap()}';
  }

  void _resetDefaults() {
    setState(() {
      _accentToken = 'accent_orange_primary';
      _surfaceToken = 'surface_default_white';
      _titleColorToken = 'text_title_primary';
      _subtitleColorToken = 'text_subtitle_inverse';
      _priceColorToken = 'text_price_primary';
      _oldPriceColorToken = 'text_old_price_muted';
      _borderColorToken = 'border_orange_line';
      _effectPreset = 'none';
      _ctaColorToken = 'cta_navy';
      _ctaStylePreset = 'cta_strong_pill';
      _imageFitMode = 'cover';

      _saleActive = true;
      _showSubtitle = true;
      _showShortDescription = true;
      _showBrand = false;
      _showUnitLabel = false;

      _showAddToCart = true;
      _showOriginalPriceWhenSaleActive = true;
      _showDiscountBadge = true;
      _showSavingsText = true;
      _emphasizeFinalPrice = true;
      _showCurrencySymbol = true;

      _useLongTitle = false;
      _useLongDescription = false;

      _showBorder = false;
      _showPromoStrip = false;
      _showImageShadow = true;

      _radius = 18;
      _elevation = 2;
      _paddingScale = 1;
      _borderWidth = 1;
      _effectIntensity = 0.35;
      _imageOverlayOpacity = 0;
    });
  }
}
