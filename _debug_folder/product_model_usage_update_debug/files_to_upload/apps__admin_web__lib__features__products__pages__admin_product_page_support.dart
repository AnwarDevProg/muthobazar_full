import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

// File: admin_product_page_support.dart

class AdminProductPageQuerySummary extends StatelessWidget {
  const AdminProductPageQuerySummary({
    super.key,
    required this.totalCount,
    required this.searchQuery,
    required this.categoryName,
    required this.brandName,
    required this.statusLabel,
    required this.includeDeleted,
    required this.deletedOnly,
  });

  final int totalCount;
  final String searchQuery;
  final String? categoryName;
  final String? brandName;
  final String statusLabel;
  final bool includeDeleted;
  final bool deletedOnly;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _SummaryChip(label: 'results: $totalCount'),
    ];

    if (searchQuery.trim().isNotEmpty) {
      chips.add(_SummaryChip(label: 'search: $searchQuery'));
    }
    if ((categoryName ?? '').trim().isNotEmpty) {
      chips.add(_SummaryChip(label: 'category: ${categoryName!}'));
    }
    if ((brandName ?? '').trim().isNotEmpty) {
      chips.add(_SummaryChip(label: 'brand: ${brandName!}'));
    }
    if (statusLabel.trim().isNotEmpty) {
      chips.add(_SummaryChip(label: 'status: $statusLabel'));
    }
    if (includeDeleted) {
      chips.add(const _SummaryChip(label: 'include deleted'));
    }
    if (deletedOnly) {
      chips.add(const _SummaryChip(label: 'deleted only'));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
}

class AdminProductActionBar extends StatelessWidget {
  const AdminProductActionBar({
    super.key,
    required this.onCreate,
    required this.onRefresh,
    required this.onClearFilters,
    this.isBusy = false,
  });

  final VoidCallback onCreate;
  final VoidCallback onRefresh;
  final VoidCallback onClearFilters;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: isBusy ? null : onCreate,
          icon: const Icon(Icons.add),
          label: const Text('Create Product'),
        ),
        OutlinedButton.icon(
          onPressed: isBusy ? null : onRefresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
        OutlinedButton.icon(
          onPressed: isBusy ? null : onClearFilters,
          icon: const Icon(Icons.filter_alt_off_outlined),
          label: const Text('Clear Filters'),
        ),
      ],
    );
  }
}

class AdminProductCompactTable extends StatelessWidget {
  const AdminProductCompactTable({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onToggleEnabled,
    required this.onDelete,
    required this.onRestore,
  });

  final List<MBProduct> products;
  final ValueChanged<MBProduct> onEdit;
  final ValueChanged<MBProduct> onToggleEnabled;
  final ValueChanged<MBProduct> onDelete;
  final ValueChanged<MBProduct> onRestore;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('No products available.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Product')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Brand')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Stock')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: products.map((product) {
          return DataRow(
            cells: [
              DataCell(
                SizedBox(
                  width: 240,
                  child: Text(
                    product.titleEn.trim().isEmpty ? product.id : product.titleEn,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text(product.categoryNameEn ?? '-')),
              DataCell(Text(product.brandNameEn ?? '-')),
              DataCell(Text(product.price.toStringAsFixed(2))),
              DataCell(Text(product.stockQty.toString())),
              DataCell(Text(_statusText(product))),
              DataCell(
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: () => onEdit(product),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: product.isEnabled ? 'Disable' : 'Enable',
                      onPressed: () => onToggleEnabled(product),
                      icon: Icon(
                        product.isEnabled
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    if (product.isDeleted)
                      IconButton(
                        tooltip: 'Restore',
                        onPressed: () => onRestore(product),
                        icon: const Icon(Icons.restore),
                      )
                    else
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () => onDelete(product),
                        icon: const Icon(Icons.delete_outline),
                      ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _statusText(MBProduct product) {
    if (product.isDeleted) return 'Deleted';
    return product.isEnabled ? 'Enabled' : 'Disabled';
  }
}

class AdminProductDetailsSheet extends StatelessWidget {
  const AdminProductDetailsSheet({
    super.key,
    required this.product,
  });

  final MBProduct product;

  static Future<void> show(
      BuildContext context, {
        required MBProduct product,
      }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.88,
        child: AdminProductDetailsSheet(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.titleEn.trim().isEmpty ? product.id : product.titleEn,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _DetailsBlock(
                    title: 'Identity',
                    rows: [
                      _DetailsRow('Id', product.id),
                      _DetailsRow('Slug', product.slug),
                      _DetailsRow('SKU', product.sku ?? '-'),
                      _DetailsRow('Product Code', product.productCode ?? '-'),
                      _DetailsRow('Type', product.productType),
                    ],
                  ),
                  _DetailsBlock(
                    title: 'Pricing',
                    rows: [
                      _DetailsRow('Price', product.price.toStringAsFixed(2)),
                      _DetailsRow(
                        'Sale Price',
                        product.salePrice?.toStringAsFixed(2) ?? '-',
                      ),
                      _DetailsRow(
                        'Cost Price',
                        product.costPrice?.toStringAsFixed(2) ?? '-',
                      ),
                      _DetailsRow('Schedule Price Type', product.schedulePriceType),
                    ],
                  ),
                  _DetailsBlock(
                    title: 'Inventory',
                    rows: [
                      _DetailsRow('Stock Qty', product.stockQty.toString()),
                      _DetailsRow('Regular Stock', product.regularStockQty.toString()),
                      _DetailsRow('Reserved Instant', product.reservedInstantQty.toString()),
                      _DetailsRow('Inventory Mode', product.inventoryMode),
                      _DetailsRow('Track Inventory', product.trackInventory.toString()),
                    ],
                  ),
                  _DetailsBlock(
                    title: 'Relations',
                    rows: [
                      _DetailsRow('Category', product.categoryNameEn ?? '-'),
                      _DetailsRow('Brand', product.brandNameEn ?? '-'),
                    ],
                  ),
                  _DetailsBlock(
                    title: 'Counts',
                    rows: [
                      _DetailsRow('Media Items', product.mediaItems.length.toString()),
                      _DetailsRow('Attributes', product.attributes.length.toString()),
                      _DetailsRow('Variations', product.variations.length.toString()),
                      _DetailsRow('Purchase Options', product.purchaseOptions.length.toString()),
                    ],
                  ),
                  _DetailsBlock(
                    title: 'Flags',
                    rows: [
                      _DetailsRow('Enabled', product.isEnabled.toString()),
                      _DetailsRow('Featured', product.isFeatured.toString()),
                      _DetailsRow('Flash Sale', product.isFlashSale.toString()),
                      _DetailsRow('Deleted', product.isDeleted.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsBlock extends StatelessWidget {
  const _DetailsBlock({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<_DetailsRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...rows.map(
                (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 160,
                    child: Text(
                      row.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(child: Text(row.value.isEmpty ? '-' : row.value)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsRow {
  const _DetailsRow(this.label, this.value);

  final String label;
  final String value;
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
