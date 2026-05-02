import 'dart:async';

import 'package:admin_web/features/products/controllers/admin_product_controller.dart';
import 'package:admin_web/features/products/pages/admin_product_lookup_support.dart';
import 'package:admin_web/features/products/widgets/admin_product_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({
    super.key,
    this.controller,
    this.actorUid = '',
    this.actorName,
    this.actorPhone,
    this.actorRole,
    this.availableCategories = const <AdminProductRelationOption>[],
    this.availableBrands = const <AdminProductRelationOption>[],
  });

  final AdminProductController? controller;
  final String actorUid;
  final String? actorName;
  final String? actorPhone;
  final String? actorRole;
  final List<AdminProductRelationOption> availableCategories;
  final List<AdminProductRelationOption> availableBrands;

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  late final AdminProductController _controller;
  late final bool _ownsController;
  late final TextEditingController _searchController;
  late final AdminProductLookupSupport _lookupSupport;

  List<AdminProductRelationOption> _categoryOptions = const [];
  List<AdminProductRelationOption> _brandOptions = const [];
  bool _isLookupLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? Get.put(AdminProductController());
    _ownsController = widget.controller == null;
    _searchController = TextEditingController(text: _controller.searchQuery.value);
    _lookupSupport = AdminProductLookupSupport();
    _categoryOptions = [...widget.availableCategories];
    _brandOptions = [...widget.availableBrands];

    if (_controller.products.isEmpty && !_controller.isLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.loadProducts(clearMessages: false);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLookupOptions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsController && Get.isRegistered<AdminProductController>()) {
      Get.delete<AdminProductController>();
    }
    super.dispose();
  }

  Future<void> _loadLookupOptions() async {
    if (_isLookupLoading) return;

    setState(() {
      _isLookupLoading = true;
    });

    final bundle = await _lookupSupport.safeLoadLookupBundle(onlyActive: true);

    if (!mounted) return;

    setState(() {
      if (bundle.categories.isNotEmpty) {
        _categoryOptions = bundle.categories;
      }
      if (bundle.brands.isNotEmpty) {
        _brandOptions = bundle.brands;
      }
      _isLookupLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(
              () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildToolbar(context),
              _buildStats(context),
              if (_controller.hasError) _buildErrorBanner(context),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Products',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage products, pricing, attributes, variations, media, lifecycle states, and customer card styles.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: _handleCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              controller: _searchController,
              onChanged: (_) {
                _controller.setSearchQuery(_searchController.text);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search by title, slug, sku, tags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.trim().isEmpty
                    ? null
                    : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _controller.setSearchQuery('');
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          _buildCategoryFilter(context),
          _buildBrandFilter(context),
          _buildStatusFilter(context),
          FilterChip(
            label: const Text('Include Deleted'),
            selected: _controller.includeDeleted.value,
            onSelected: (value) => _controller.setIncludeDeleted(value),
          ),
          FilterChip(
            label: const Text('Deleted Only'),
            selected: _controller.deletedOnly.value,
            onSelected: (value) => _controller.setDeletedOnly(value),
          ),
          OutlinedButton.icon(
            onPressed: _controller.clearFilters,
            icon: const Icon(Icons.filter_alt_off_outlined),
            label: const Text('Clear Filters'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              await _loadLookupOptions();
              await _controller.loadProducts(clearMessages: false);
            },
            icon: _controller.isLoading.value || _isLookupLoading
                ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return SizedBox(
      width: 220,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            isExpanded: true,
            value: _normalizeOptionValue(
              _controller.selectedCategoryId.value,
              _categoryOptions.map((e) => e.id).toList(growable: false),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All categories'),
              ),
              ..._categoryOptions.map(
                    (item) => DropdownMenuItem<String?>(
                  value: item.id,
                  child: Text(item.nameEn),
                ),
              ),
            ],
            onChanged: (value) => _controller.setCategoryFilter(value),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandFilter(BuildContext context) {
    return SizedBox(
      width: 220,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Brand',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            isExpanded: true,
            value: _normalizeOptionValue(
              _controller.selectedBrandId.value,
              _brandOptions.map((e) => e.id).toList(growable: false),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All brands'),
              ),
              ..._brandOptions.map(
                    (item) => DropdownMenuItem<String?>(
                  value: item.id,
                  child: Text(item.nameEn),
                ),
              ),
            ],
            onChanged: (value) => _controller.setBrandFilter(value),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    return SizedBox(
      width: 180,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Status',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<bool?>(
            isExpanded: true,
            value: _controller.selectedEnabled.value,
            items: const [
              DropdownMenuItem<bool?>(value: null, child: Text('All statuses')),
              DropdownMenuItem<bool?>(value: true, child: Text('Enabled')),
              DropdownMenuItem<bool?>(value: false, child: Text('Disabled')),
            ],
            onChanged: (value) => _controller.setEnabledFilter(value),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _StatCard(title: 'Total', value: _controller.totalCount.toString()),
          _StatCard(title: 'Active', value: _controller.activeCount.toString()),
          _StatCard(title: 'Inactive', value: _controller.inactiveCount.toString()),
          _StatCard(title: 'Deleted', value: _controller.deletedCount.toString()),
          _StatCard(title: 'Featured', value: _controller.featuredCount.toString()),
          _StatCard(title: 'Flash Sale', value: _controller.flashSaleCount.toString()),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Material(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _controller.errorMessage.value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _controller.clearError,
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.isLoading.value && _controller.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.isEmptyState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 56),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first product or adjust your filters.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _handleCreate,
                icon: const Icon(Icons.add),
                label: const Text('Create Product'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: _controller.products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = _controller.products[index];
        return _ProductListTile(
          product: product,
          onEdit: () => _handleEdit(product),
          onToggleEnabled: () => _handleToggleEnabled(product),
          onDelete: () => _handleDelete(product),
          onRestore: () => _handleRestore(product),
        );
      },
    );
  }

  String? _normalizeOptionValue(String? value, List<String> options) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return options.contains(normalized) ? normalized : null;
  }

  Future<void> _handleCreate() async {
    final MBProduct? saved = await AdminProductFormDialog.show(
      context,
      actorUid: widget.actorUid,
      actorName: widget.actorName,
      actorPhone: widget.actorPhone,
      actorRole: widget.actorRole,
      controller: _controller,
      availableCategories: _categoryOptions,
      availableBrands: _brandOptions,
    );

    if (!mounted || saved == null) return;

    _controller.clearError();
    unawaited(_controller.loadProducts(clearMessages: false));
  }

  Future<void> _handleEdit(MBProduct product) async {
    final MBProduct? saved = await AdminProductFormDialog.show(
      context,
      actorUid: widget.actorUid,
      actorName: widget.actorName,
      actorPhone: widget.actorPhone,
      actorRole: widget.actorRole,
      controller: _controller,
      initialProduct: product,
      availableCategories: _categoryOptions,
      availableBrands: _brandOptions,
      dialogTitle: 'Edit Product',
    );

    if (!mounted || saved == null) return;

    _controller.clearError();
    unawaited(_controller.loadProducts(clearMessages: false));
  }

  Future<void> _handleToggleEnabled(MBProduct product) async {
    await _controller.setProductEnabled(
      productId: product.id,
      isEnabled: !product.isEnabled,
      actorUid: widget.actorUid,
      actorName: widget.actorName,
      actorPhone: widget.actorPhone,
      actorRole: widget.actorRole,
    );
  }

  Future<void> _handleDelete(MBProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.titleEn}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _controller.deleteProduct(
      productId: product.id,
      actorUid: widget.actorUid,
      actorName: widget.actorName,
      actorPhone: widget.actorPhone,
      actorRole: widget.actorRole,
    );
  }

  Future<void> _handleRestore(MBProduct product) async {
    await _controller.restoreProduct(
      productId: product.id,
      actorUid: widget.actorUid,
      actorName: widget.actorName,
      actorPhone: widget.actorPhone,
      actorRole: widget.actorRole,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({
    required this.product,
    required this.onEdit,
    required this.onToggleEnabled,
    required this.onDelete,
    required this.onRestore,
  });

  final MBProduct product;
  final VoidCallback onEdit;
  final VoidCallback onToggleEnabled;
  final VoidCallback onDelete;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final title = product.titleEn.trim().isEmpty ? product.id : product.titleEn;

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductThumb(url: product.resolvedThumbImageUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (product.isDeleted)
                        const Chip(label: Text('Deleted'))
                      else if (product.isEnabled)
                        const Chip(label: Text('Enabled'))
                      else
                        const Chip(label: Text('Disabled')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'slug: ${product.slug.isEmpty ? '-' : product.slug}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(text: 'price: ${product.price.toStringAsFixed(2)}'),
                      _InfoChip(text: 'stock: ${product.stockQty}'),
                      _InfoChip(text: 'type: ${product.productType}'),
                      _InfoChip(text: 'card: ${product.normalizedCardLayoutType}'),
                      _InfoChip(text: 'category: ${product.categoryNameEn ?? '-'}'),
                      _InfoChip(text: 'brand: ${product.brandNameEn ?? '-'}'),
                      _InfoChip(text: 'featured: ${product.isFeatured}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: onToggleEnabled,
                  icon: Icon(
                    product.isEnabled
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  label: Text(product.isEnabled ? 'Disable' : 'Enable'),
                ),
                if (product.isDeleted)
                  FilledButton.tonalIcon(
                    onPressed: onRestore,
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore'),
                  )
                else
                  FilledButton.tonalIcon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        width: 84,
        height: 84,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(text));
  }
}
