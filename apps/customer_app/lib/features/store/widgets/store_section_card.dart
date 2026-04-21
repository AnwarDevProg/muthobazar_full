import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../models/mb_store_card_preview_entry.dart';
import 'store_section_grid.dart';

class StoreSectionCard extends StatelessWidget {
  const StoreSectionCard({
    super.key,
    required this.sectionIndex,
    required this.title,
    required this.entries,
    required this.productsById,
    required this.onAddTap,
    required this.onRemoveTap,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 16,
    this.showMetaChips = true,
    this.featuredHeight = 320,
    this.backgroundColor = Colors.white,
  });

  final int sectionIndex;
  final String title;
  final List<MBStoreCardPreviewEntry> entries;
  final Map<String, MBProduct> productsById;
  final VoidCallback onAddTap;
  final ValueChanged<MBStoreCardPreviewEntry> onRemoveTap;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final bool showMetaChips;
  final double featuredHeight;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _StoreSectionHeader(
              sectionIndex: sectionIndex,
              title: title,
              itemCount: entries.length,
              onAddTap: onAddTap,
            ),
            SizedBox(height: spacing),
            if (entries.isEmpty)
              const _StoreSectionEmptyState()
            else
              StoreSectionGrid(
                entries: entries,
                productsById: productsById,
                onRemoveTap: onRemoveTap,
                spacing: spacing,
                featuredHeight: featuredHeight,
                showMetaChips: showMetaChips,
              ),
          ],
        ),
      ),
    );
  }
}

class _StoreSectionHeader extends StatelessWidget {
  const _StoreSectionHeader({
    required this.sectionIndex,
    required this.title,
    required this.itemCount,
    required this.onAddTap,
  });

  final int sectionIndex;
  final String title;
  final int itemCount;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Section ${sectionIndex + 1}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E8),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$itemCount items',
            style: const TextStyle(
              color: Color(0xFFE67E22),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: onAddTap,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ],
    );
  }
}

class _StoreSectionEmptyState extends StatelessWidget {
  const _StoreSectionEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.view_module_outlined,
            size: 36,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 12),
          Text(
            'No cards added yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap Add to choose a product and a card layout for this section.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
