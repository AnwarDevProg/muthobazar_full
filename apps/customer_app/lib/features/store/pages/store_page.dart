import 'package:customer_app/features/store/data/product_card_preview_dummy_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import '../models/mb_store_card_preview_entry.dart';
import '../widgets/store_card_add_dialog.dart';
import '../widgets/store_section_card.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final Map<String, List<MBStoreCardPreviewEntry>> _sectionEntriesByKey =
  <String, List<MBStoreCardPreviewEntry>>{};

  List<MBProduct> get _allProducts => MBProductCardPreviewDummyData.allProducts;

  @override
  Widget build(BuildContext context) {
    final categories = MBProductCardPreviewDummyData.categories;
    final productsById = _buildProductsById(_allProducts);
    final sections = _buildSections();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 140),
          children: <Widget>[
            const _StorePageHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _StoreStatusCard(
                totalProducts: _allProducts.length,
                totalCategories: categories.length,
                totalSections: sections.length,
              ),
            ),
            if (_allProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: _StoreEmptyCard(),
              )
            else
              ...List<Widget>.generate(sections.length, (index) {
                final section = sections[index];
                final entries = _sectionEntriesByKey[section.sectionKey] ??
                    <MBStoreCardPreviewEntry>[];

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: StoreSectionCard(
                    sectionIndex: index,
                    title: section.title,
                    entries: entries,
                    productsById: productsById,
                    onAddTap: () => _onAddTap(section),
                    onRemoveTap: (entry) => _removeEntry(
                      sectionKey: section.sectionKey,
                      entryId: entry.id,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _onAddTap(_StoreSection section) async {
    final sectionProducts = MBProductCardPreviewDummyData.productsForCategory(
      section.categoryId,
    );

    if (sectionProducts.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No dummy products available for ${section.title}.'),
        ),
      );
      return;
    }

    final currentEntries =
        _sectionEntriesByKey[section.sectionKey] ?? <MBStoreCardPreviewEntry>[];

    final entry = await StoreCardAddDialog.show(
      context,
      products: sectionProducts,
      sectionKey: section.sectionKey,
      nextSortOrder: _nextSortOrder(currentEntries),
      title: 'Add card to ${section.title}',
      confirmText: 'Add',
    );

    if (entry == null) {
      return;
    }

    setState(() {
      final updated = List<MBStoreCardPreviewEntry>.from(currentEntries)
        ..add(entry)
        ..sort(MBStoreCardPreviewEntry.sortComparator);
      _sectionEntriesByKey[section.sectionKey] = updated;
    });
  }

  void _removeEntry({
    required String sectionKey,
    required String entryId,
  }) {
    setState(() {
      final currentEntries =
          _sectionEntriesByKey[sectionKey] ?? <MBStoreCardPreviewEntry>[];
      final updated = List<MBStoreCardPreviewEntry>.from(currentEntries)
        ..removeWhere((entry) => entry.id == entryId);
      _sectionEntriesByKey[sectionKey] = updated;
    });
  }

  List<_StoreSection> _buildSections() {
    final source = MBProductCardPreviewDummyData.categories;
    final sections = <_StoreSection>[];

    for (final category in source.take(6)) {
      final title = category.nameEn.trim().isNotEmpty
          ? category.nameEn.trim()
          : category.nameBn.trim();

      sections.add(
        _StoreSection(
          sectionKey: 'category_${category.id}',
          categoryId: category.id,
          title: title,
        ),
      );
    }

    while (sections.length < 6) {
      final number = sections.length + 1;
      sections.add(
        _StoreSection(
          sectionKey: 'placeholder_$number',
          categoryId: 'placeholder_$number',
          title: 'Category ${number.toString().padLeft(2, '0')}',
        ),
      );
    }

    return sections;
  }

  Map<String, MBProduct> _buildProductsById(List<MBProduct> products) {
    final map = <String, MBProduct>{};

    for (final product in products) {
      if (product.id.trim().isEmpty) {
        continue;
      }
      map[product.id.trim()] = product;
    }

    return map;
  }

  int _nextSortOrder(List<MBStoreCardPreviewEntry> entries) {
    if (entries.isEmpty) {
      return 0;
    }

    var maxSort = -1;
    for (final entry in entries) {
      final sort = entry.sortOrder;
      if (sort > maxSort) {
        maxSort = sort;
      }
    }

    return maxSort + 1;
  }
}

class _StoreSection {
  const _StoreSection({
    required this.sectionKey,
    required this.categoryId,
    required this.title,
  });

  final String sectionKey;
  final String categoryId;
  final String title;
}

class _StorePageHeader extends StatelessWidget {
  const _StorePageHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xFFFF8A00),
            Color(0xFFFF6A00),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 4),
          Text(
            'Store Layout Builder',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Using preview dummy categories and products for now. Add products with different card layouts and test the mixed grid directly on the store page.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreStatusCard extends StatelessWidget {
  const _StoreStatusCard({
    required this.totalProducts,
    required this.totalCategories,
    required this.totalSections,
  });

  final int totalProducts;
  final int totalCategories;
  final int totalSections;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          _StoreInfoChip(label: 'Products', value: '$totalProducts'),
          _StoreInfoChip(label: 'Categories', value: '$totalCategories'),
          _StoreInfoChip(label: 'Sections', value: '$totalSections'),
          const _StoreInfoChip(label: 'Source', value: 'Dummy data'),
        ],
      ),
    );
  }
}

class _StoreInfoChip extends StatelessWidget {
  const _StoreInfoChip({
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

class _StoreEmptyCard extends StatelessWidget {
  const _StoreEmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.inventory_2_outlined,
            size: 44,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 12),
          Text(
            'No dummy products available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add preview data first, then use each section\'s Add button to place cards.',
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
