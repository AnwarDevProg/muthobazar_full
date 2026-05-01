import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_card_config_resolver.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_card_variant_registry.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_product_card_variant_router.dart';

class AdminProductCardSettingsResult {
  const AdminProductCardSettingsResult({
    required this.variantId,
    required this.showDiscountBadge,
    required this.showSavingsText,
    required this.emphasizeFinalPrice,
    required this.showAddToCart,
    required this.showViewDetails,
    required this.showSubtitle,
    required this.showBrand,
    required this.showUnitLabel,
    required this.showStockHint,
    required this.showDeliveryHint,
    required this.showBorder,
    required this.showPromoStrip,
  });

  final String variantId;
  final bool showDiscountBadge;
  final bool showSavingsText;
  final bool emphasizeFinalPrice;
  final bool showAddToCart;
  final bool showViewDetails;
  final bool showSubtitle;
  final bool showBrand;
  final bool showUnitLabel;
  final bool showStockHint;
  final bool showDeliveryHint;
  final bool showBorder;
  final bool showPromoStrip;

  MBCardVariant get variant => MBCardVariantHelper.parse(
    variantId,
    fallback: MBCardVariant.compact01,
  );

  AdminProductCardSettingsResult copyWith({
    String? variantId,
    bool? showDiscountBadge,
    bool? showSavingsText,
    bool? emphasizeFinalPrice,
    bool? showAddToCart,
    bool? showViewDetails,
    bool? showSubtitle,
    bool? showBrand,
    bool? showUnitLabel,
    bool? showStockHint,
    bool? showDeliveryHint,
    bool? showBorder,
    bool? showPromoStrip,
  }) {
    return AdminProductCardSettingsResult(
      variantId: variantId ?? this.variantId,
      showDiscountBadge: showDiscountBadge ?? this.showDiscountBadge,
      showSavingsText: showSavingsText ?? this.showSavingsText,
      emphasizeFinalPrice: emphasizeFinalPrice ?? this.emphasizeFinalPrice,
      showAddToCart: showAddToCart ?? this.showAddToCart,
      showViewDetails: showViewDetails ?? this.showViewDetails,
      showSubtitle: showSubtitle ?? this.showSubtitle,
      showBrand: showBrand ?? this.showBrand,
      showUnitLabel: showUnitLabel ?? this.showUnitLabel,
      showStockHint: showStockHint ?? this.showStockHint,
      showDeliveryHint: showDeliveryHint ?? this.showDeliveryHint,
      showBorder: showBorder ?? this.showBorder,
      showPromoStrip: showPromoStrip ?? this.showPromoStrip,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'variantId': variantId,
      'showDiscountBadge': showDiscountBadge,
      'showSavingsText': showSavingsText,
      'emphasizeFinalPrice': emphasizeFinalPrice,
      'showAddToCart': showAddToCart,
      'showViewDetails': showViewDetails,
      'showSubtitle': showSubtitle,
      'showBrand': showBrand,
      'showUnitLabel': showUnitLabel,
      'showStockHint': showStockHint,
      'showDeliveryHint': showDeliveryHint,
      'showBorder': showBorder,
      'showPromoStrip': showPromoStrip,
    };
  }

  factory AdminProductCardSettingsResult.fromMap(
      Map<String, dynamic> map, {
        required MBCardVariant fallbackVariant,
      }) {
    return AdminProductCardSettingsResult(
      variantId: (map['variantId'] ?? '').toString().trim().isEmpty
          ? fallbackVariant.id
          : (map['variantId'] ?? '').toString().trim(),
      showDiscountBadge: map['showDiscountBadge'] == true,
      showSavingsText: map['showSavingsText'] == true,
      emphasizeFinalPrice: map['emphasizeFinalPrice'] != false,
      showAddToCart: map['showAddToCart'] == true,
      showViewDetails: map['showViewDetails'] == true,
      showSubtitle: map['showSubtitle'] == true,
      showBrand: map['showBrand'] == true,
      showUnitLabel: map['showUnitLabel'] == true,
      showStockHint: map['showStockHint'] == true,
      showDeliveryHint: map['showDeliveryHint'] == true,
      showBorder: map['showBorder'] == true,
      showPromoStrip: map['showPromoStrip'] == true,
    );
  }

  factory AdminProductCardSettingsResult.fromVariantDefaults(
      MBCardVariant variant,
      ) {
    final definition = MBCardVariantRegistry.definitionFor(variant);
    final defaults = definition.defaults;

    return AdminProductCardSettingsResult(
      variantId: variant.id,
      showDiscountBadge: defaults.price?.showDiscountBadge ?? false,
      showSavingsText: defaults.price?.showSavingsText ?? false,
      emphasizeFinalPrice: defaults.price?.emphasizeFinalPrice ?? true,
      showAddToCart: defaults.actions?.showAddToCart ?? false,
      showViewDetails: defaults.actions?.showViewDetails ?? false,
      showSubtitle: defaults.meta?.showSubtitle ?? false,
      showBrand: defaults.meta?.showBrand ?? false,
      showUnitLabel: defaults.meta?.showUnitLabel ?? false,
      showStockHint: defaults.meta?.showStockHint ?? false,
      showDeliveryHint: defaults.meta?.showDeliveryHint ?? false,
      showBorder: defaults.borderEffect?.showBorder ?? false,
      showPromoStrip: defaults.accent?.showPromoStrip ?? false,
    );
  }
}

class AdminProductCardSettingsDialog extends StatefulWidget {
  const AdminProductCardSettingsDialog({
    super.key,
    required this.previewProduct,
    required this.variant,
    this.initialValue,
    this.title = 'Edit card',
  });

  final MBProduct previewProduct;
  final MBCardVariant variant;
  final AdminProductCardSettingsResult? initialValue;
  final String title;

  static Future<AdminProductCardSettingsResult?> show(
      BuildContext context, {
        required MBProduct previewProduct,
        required MBCardVariant variant,
        AdminProductCardSettingsResult? initialValue,
        String title = 'Edit card',
      }) {
    return showDialog<AdminProductCardSettingsResult>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AdminProductCardSettingsDialog(
        previewProduct: previewProduct,
        variant: variant,
        initialValue: initialValue,
        title: title,
      ),
    );
  }

  @override
  State<AdminProductCardSettingsDialog> createState() =>
      _AdminProductCardSettingsDialogState();
}

class _AdminProductCardSettingsDialogState
    extends State<AdminProductCardSettingsDialog> {
  static const double _kPreviewCanvasWidth = 320.0;
  static const double _kPreviewCanvasPadding = 12.0;
  static const double _kPreviewCanvasGap = 12.0;

  late final AdminProductCardSettingsResult _initialResult;

  late bool _showDiscountBadge;
  late bool _showSavingsText;
  late bool _emphasizeFinalPrice;

  late bool _showAddToCart;
  late bool _showViewDetails;

  late bool _showSubtitle;
  late bool _showBrand;
  late bool _showUnitLabel;
  late bool _showStockHint;
  late bool _showDeliveryHint;

  late bool _showBorder;
  late bool _showPromoStrip;

  MBCardVariantDefinition get _definition =>
      MBCardVariantRegistry.definitionFor(widget.variant);

  MBCardSupportedSettings get _supported => _definition.supportedSettings;

  double get _halfCardWidth =>
      (_kPreviewCanvasWidth - (_kPreviewCanvasPadding * 2) - _kPreviewCanvasGap) /
          2;

  double get _fullCardWidth =>
      _kPreviewCanvasWidth - (_kPreviewCanvasPadding * 2);

  @override
  void initState() {
    super.initState();

    _initialResult = widget.initialValue ??
        AdminProductCardSettingsResult.fromVariantDefaults(widget.variant);

    _showDiscountBadge = _initialResult.showDiscountBadge;
    _showSavingsText = _initialResult.showSavingsText;
    _emphasizeFinalPrice = _initialResult.emphasizeFinalPrice;

    _showAddToCart = _initialResult.showAddToCart;
    _showViewDetails = _initialResult.showViewDetails;

    _showSubtitle = _initialResult.showSubtitle;
    _showBrand = _initialResult.showBrand;
    _showUnitLabel = _initialResult.showUnitLabel;
    _showStockHint = _initialResult.showStockHint;
    _showDeliveryHint = _initialResult.showDeliveryHint;

    _showBorder = _initialResult.showBorder;
    _showPromoStrip = _initialResult.showPromoStrip;
  }

  AdminProductCardSettingsResult get _currentResult {
    return AdminProductCardSettingsResult(
      variantId: widget.variant.id,
      showDiscountBadge: _showDiscountBadge,
      showSavingsText: _showSavingsText,
      emphasizeFinalPrice: _emphasizeFinalPrice,
      showAddToCart: _showAddToCart,
      showViewDetails: _showViewDetails,
      showSubtitle: _showSubtitle,
      showBrand: _showBrand,
      showUnitLabel: _showUnitLabel,
      showStockHint: _showStockHint,
      showDeliveryHint: _showDeliveryHint,
      showBorder: _showBorder,
      showPromoStrip: _showPromoStrip,
    );
  }

  MBCardVariant _peerVariantFor(MBCardVariant currentVariant) {
    final siblings = MBCardVariant.values
        .where((item) => item.family == currentVariant.family)
        .toList(growable: false);

    for (final sibling in siblings) {
      if (sibling != currentVariant) {
        return sibling;
      }
    }

    return currentVariant;
  }

  MBCardSettingsOverride _buildSettingsOverride() {
    return MBCardSettingsOverride(
      price: MBCardPriceSettings(
        showDiscountBadge: _showDiscountBadge,
        showSavingsText: _showSavingsText,
        emphasizeFinalPrice: _emphasizeFinalPrice,
      ),
      actions: MBCardActionSettings(
        showAddToCart: _showAddToCart,
        showViewDetails: _showViewDetails,
      ),
      meta: MBCardMetaSettings(
        showSubtitle: _showSubtitle,
        showBrand: _showBrand,
        showUnitLabel: _showUnitLabel,
        showStockHint: _showStockHint,
        showDeliveryHint: _showDeliveryHint,
      ),
      borderEffect: MBCardBorderEffectSettings(
        showBorder: _showBorder,
      ),
      accent: MBCardAccentSettings(
        showPromoStrip: _showPromoStrip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final maxWidth = media.width < 1360 ? media.width - 24 : 1260.0;
    final maxHeight = media.height < 920 ? media.height - 28 : 860.0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: Column(
          children: <Widget>[
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child: _buildBody(context),
            ),
            const Divider(height: 1),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${widget.title} • ${widget.variant.id}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Adjust the supported settings for this card, while keeping a larger live preview visible.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 960;

        if (isNarrow) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildPreviewPanel(context),
                const SizedBox(height: 18),
                _buildControlsPanel(context),
              ],
            ),
          );
        }

        return Row(
          children: <Widget>[
            SizedBox(
              width: 430,
              child: _buildPreviewRail(context),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _buildControlsPane(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPreviewRail(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: _buildPreviewPanel(context),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsPane(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: _buildControlsPanel(context),
        ),
      ),
    );
  }

  Widget _buildPreviewPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Live preview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This preview updates immediately with the current settings and uses a readable mobile-style canvas.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _InfoChip(
                        label: 'family',
                        value: _familyLabel(widget.variant.family),
                      ),
                      _InfoChip(
                        label: 'variant',
                        value: widget.variant.id,
                      ),
                      _InfoChip(
                        label: 'footprint',
                        value: widget.variant.isFullWidth ? 'full' : 'half',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLargePreviewCanvas(widget.variant),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLargePreviewCanvas(MBCardVariant variant) {
    final peer = _peerVariantFor(variant);

    return Container(
      width: _kPreviewCanvasWidth,
      padding: const EdgeInsets.all(_kPreviewCanvasPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _showBorder
              ? const Color(0xFFFF8A00)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_showPromoStrip)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Promo strip enabled',
                style: TextStyle(
                  color: Color(0xFFE67E22),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          if (_showPromoStrip) const SizedBox(height: 12),
          if (variant.isFullWidth)
            Column(
              children: <Widget>[
                SizedBox(
                  width: _fullCardWidth,
                  child: _buildRenderedPreviewCard(variant),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: _fullCardWidth,
                  child: Opacity(
                    opacity: 0.82,
                    child: _buildRenderedPreviewCard(peer),
                  ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: _halfCardWidth,
                  child: _buildRenderedPreviewCard(variant),
                ),
                const SizedBox(width: _kPreviewCanvasGap),
                SizedBox(
                  width: _halfCardWidth,
                  child: Opacity(
                    opacity: 0.82,
                    child: _buildRenderedPreviewCard(peer),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRenderedPreviewCard(MBCardVariant variant) {
    final resolved = MBCardConfigResolver.resolveByVariant(
      variant,
      settings: _buildSettingsOverride(),
    );

    return AbsorbPointer(
      absorbing: true,
      child: MBProductCardVariantRouter.build(
        context: context,
        resolved: resolved,
        product: widget.previewProduct,
        onTap: () {},
        onAddToCartTap: () {},
      ),
    );
  }

  Widget _buildControlsPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        if (_supported.canChangePrice) ...<Widget>[
          _SettingsGroup(
            title: 'Price',
            subtitle: 'Control pricing emphasis and savings visibility.',
            child: Column(
              children: <Widget>[
                _switchTile(
                  context,
                  title: 'Show discount badge',
                  value: _showDiscountBadge,
                  onChanged: (value) => setState(() {
                    _showDiscountBadge = value;
                  }),
                ),
                _switchTile(
                  context,
                  title: 'Show savings text',
                  value: _showSavingsText,
                  onChanged: (value) => setState(() {
                    _showSavingsText = value;
                  }),
                ),
                _switchTile(
                  context,
                  title: 'Emphasize final price',
                  value: _emphasizeFinalPrice,
                  onChanged: (value) => setState(() {
                    _emphasizeFinalPrice = value;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (_supported.canChangeActions) ...<Widget>[
          _SettingsGroup(
            title: 'Actions',
            subtitle: 'Show or hide action buttons on the card.',
            child: Column(
              children: <Widget>[
                _switchTile(
                  context,
                  title: 'Show add to cart',
                  value: _showAddToCart,
                  onChanged: (value) => setState(() {
                    _showAddToCart = value;
                  }),
                ),
                _switchTile(
                  context,
                  title: 'Show view details',
                  value: _showViewDetails,
                  onChanged: (value) => setState(() {
                    _showViewDetails = value;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (_supported.canChangeMeta) ...<Widget>[
          _SettingsGroup(
            title: 'Meta',
            subtitle: 'Control supportive information under the main content.',
            child: Column(
              children: <Widget>[
                _switchTile(
                  context,
                  title: 'Show subtitle',
                  value: _showSubtitle,
                  onChanged: (value) => setState(() {
                    _showSubtitle = value;
                  }),
                ),
                _switchTile(
                  context,
                  title: 'Show brand',
                  value: _showBrand,
                  onChanged: (value) => setState(() {
                    _showBrand = value;
                  }),
                ),
                _switchTile(
                  context,
                  title: 'Show unit label',
                  value: _showUnitLabel,
                  onChanged: (value) => setState(() {
                    _showUnitLabel = value;
                  }),
                ),
                _switchTile(
                  context,
                  title: 'Show stock hint',
                  value: _showStockHint,
                  onChanged: (value) => setState(() {
                    _showStockHint = value;
                  }),
                ),
                _switchTile(
                  context,
                  title: 'Show delivery hint',
                  value: _showDeliveryHint,
                  onChanged: (value) => setState(() {
                    _showDeliveryHint = value;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (_supported.canChangeBorderEffect || _supported.canChangeAccent) ...<
            Widget>[
          _SettingsGroup(
            title: 'Style',
            subtitle: 'Control decorative presentation.',
            child: Column(
              children: <Widget>[
                if (_supported.canChangeBorderEffect)
                  _switchTile(
                    context,
                    title: 'Show border emphasis',
                    value: _showBorder,
                    onChanged: (value) => setState(() {
                      _showBorder = value;
                    }),
                  ),
                if (_supported.canChangeAccent)
                  _switchTile(
                    context,
                    title: 'Show promo strip',
                    value: _showPromoStrip,
                    onChanged: (value) => setState(() {
                      _showPromoStrip = value;
                    }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Text(
            'Only supported settings for the selected variant are exposed here. Save to return the settings draft to the product form.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _switchTile(
      BuildContext context, {
        required String title,
        required bool value,
        required ValueChanged<bool> onChanged,
      }) {
    return SwitchListTile.adaptive(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'Variant: ${widget.variant.id}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _showDiscountBadge = _initialResult.showDiscountBadge;
                _showSavingsText = _initialResult.showSavingsText;
                _emphasizeFinalPrice = _initialResult.emphasizeFinalPrice;
                _showAddToCart = _initialResult.showAddToCart;
                _showViewDetails = _initialResult.showViewDetails;
                _showSubtitle = _initialResult.showSubtitle;
                _showBrand = _initialResult.showBrand;
                _showUnitLabel = _initialResult.showUnitLabel;
                _showStockHint = _initialResult.showStockHint;
                _showDeliveryHint = _initialResult.showDeliveryHint;
                _showBorder = _initialResult.showBorder;
                _showPromoStrip = _initialResult.showPromoStrip;
              });
            },
            child: const Text('Reset'),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(_currentResult);
            },
            child: const Text('Save settings'),
          ),
        ],
      ),
    );
  }

  String _familyLabel(MBCardFamily family) {
    switch (family) {
      case MBCardFamily.compact:
        return 'Compact';
      case MBCardFamily.price:
        return 'Price';
      case MBCardFamily.horizontal:
        return 'Horizontal';
      case MBCardFamily.premium:
        return 'Premium';
      case MBCardFamily.wide:
        return 'Wide';
      case MBCardFamily.featured:
        return 'Featured';
      case MBCardFamily.promo:
        return 'Promo';
      case MBCardFamily.flashSale:
        return 'Flash Sale';
      case MBCardFamily.combo:
        return 'Combo';
      case MBCardFamily.variant:
        return 'Variant';
      case MBCardFamily.minimal:
        return 'Minimal';
      case MBCardFamily.infoRich:
        return 'Info Rich';
    }
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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