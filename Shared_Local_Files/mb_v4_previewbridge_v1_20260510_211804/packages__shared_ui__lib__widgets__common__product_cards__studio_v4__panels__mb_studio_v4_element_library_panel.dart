// MuthoBazar Studio V4 Design Library Panel
//
// Purpose:
// - Provides the Studio V4 element and block-library foundation.
// - Adds safe primitive layer buttons and ready-made grouped design blocks.
// - Keeps Studio V4 separate from the active Studio V3 production editor.

import 'package:flutter/material.dart';

import '../controllers/mb_studio_v4_controller.dart';

class MBStudioV4ElementLibraryPanel extends StatelessWidget {
  const MBStudioV4ElementLibraryPanel({
    super.key,
    required this.controller,
  });

  final MBStudioV4Controller controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 10),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_box_outlined,
                    color: Color(0xFFFF6500),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Element Library',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Apply templates, add elements, and insert blocks',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: <Widget>[
                _LibraryGroupTitle(
                  title: 'Starter templates',
                  subtitle: 'Replace the current V4 draft with a complete layout',
                ),
                const SizedBox(height: 10),
                _BlockTile(
                  icon: Icons.eco_outlined,
                  title: 'Clean Grocery Card',
                  subtitle: 'Fresh white/orange grocery layout',
                  color: const Color(0xFF16A34A),
                  onTap: controller.applyCleanGroceryTemplate,
                ),
                _BlockTile(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Offer Poster Card',
                  subtitle: 'Bold promo poster with offer hierarchy',
                  color: const Color(0xFFFF6500),
                  onTap: controller.applyOfferPosterTemplate,
                ),
                _BlockTile(
                  icon: Icons.diamond_outlined,
                  title: 'Premium Dark Card',
                  subtitle: 'Dark premium layout with gold accents',
                  color: const Color(0xFF0F172A),
                  onTap: controller.applyPremiumDarkTemplate,
                ),
                _BlockTile(
                  icon: Icons.photo_size_select_large_outlined,
                  title: 'Product Hero Card',
                  subtitle: 'Large cutout image with glass title area',
                  color: const Color(0xFF7C3AED),
                  onTap: controller.applyProductHeroTemplate,
                ),
                const SizedBox(height: 18),
                _LibraryGroupTitle(
                  title: 'Basic primitives',
                  subtitle: 'Tap to add and select a new layer',
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.25,
                  children: <Widget>[
                    _LibraryTile(
                      icon: Icons.title,
                      label: 'Text',
                      color: const Color(0xFF2563EB),
                      onTap: controller.addTextLayer,
                    ),
                    _LibraryTile(
                      icon: Icons.payments_outlined,
                      label: 'Price',
                      color: const Color(0xFF111827),
                      onTap: controller.addPriceLayer,
                    ),
                    _LibraryTile(
                      icon: Icons.local_offer_outlined,
                      label: 'Badge',
                      color: const Color(0xFFEF4444),
                      onTap: controller.addBadgeLayer,
                    ),
                    _LibraryTile(
                      icon: Icons.image_outlined,
                      label: 'Media',
                      color: const Color(0xFFFF6500),
                      onTap: controller.addMediaLayer,
                    ),
                    _LibraryTile(
                      icon: Icons.auto_awesome,
                      label: 'Cutout',
                      color: const Color(0xFF7C3AED),
                      onTap: controller.addTransparentMediaLayer,
                    ),
                    _LibraryTile(
                      icon: Icons.smart_button_outlined,
                      label: 'CTA',
                      color: const Color(0xFF16A34A),
                      onTap: controller.addButtonLayer,
                    ),
                    _LibraryTile(
                      icon: Icons.rounded_corner,
                      label: 'Shape',
                      color: const Color(0xFF0891B2),
                      onTap: controller.addShapeLayer,
                    ),
                    _LibraryTile(
                      icon: Icons.local_shipping_outlined,
                      label: 'Delivery',
                      color: const Color(0xFF0F766E),
                      onTap: controller.addDeliveryLayer,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _LibraryGroupTitle(
                  title: 'Ready blocks',
                  subtitle: 'Insert grouped professional card sections',
                ),
                const SizedBox(height: 10),
                _BlockTile(
                  icon: Icons.price_change_outlined,
                  title: 'Price offer block',
                  subtitle: 'Price + MRP + discount badge',
                  color: const Color(0xFF111827),
                  onTap: controller.addPriceOfferBlock,
                ),
                _BlockTile(
                  icon: Icons.notes_outlined,
                  title: 'Product title block',
                  subtitle: 'Title + supporting subtitle',
                  color: const Color(0xFF2563EB),
                  onTap: controller.addProductTitleBlock,
                ),
                _BlockTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'CTA bottom block',
                  subtitle: 'Glass surface + price + buy button',
                  color: const Color(0xFF16A34A),
                  onTap: controller.addCtaBottomBlock,
                ),
                _BlockTile(
                  icon: Icons.local_offer_outlined,
                  title: 'Offer badge block',
                  subtitle: 'Tilted sticker-style promo badge',
                  color: const Color(0xFFF97316),
                  onTap: controller.addOfferBadgeBlock,
                ),
                _BlockTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'Delivery chip block',
                  subtitle: 'Delivery + stock chips',
                  color: const Color(0xFF0F766E),
                  onTap: controller.addDeliveryChipBlock,
                ),
                _BlockTile(
                  icon: Icons.photo_size_select_actual_outlined,
                  title: 'Hero image block',
                  subtitle: 'Spotlight + transparent product image',
                  color: const Color(0xFF7C3AED),
                  onTap: controller.addHeroImageBlock,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    'Templates replace the current V4 draft and are undoable. Blocks insert multiple independent layers so you can edit each part freely.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF64748B),
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryGroupTitle extends StatelessWidget {
  const _LibraryGroupTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
          ),
        ),
        Text(
          subtitle,
          style: theme.textTheme.labelSmall?.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}


class _BlockTile extends StatelessWidget {
  const _BlockTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.add_circle_outline, color: color, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
