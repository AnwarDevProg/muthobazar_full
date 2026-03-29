import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:admin_web/features/products/controllers/admin_product_controller.dart';
import 'package:admin_web/features/products/widgets/admin_product_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminProductsPage extends GetView<AdminProductController> {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            _ProductsToolbar(controller: controller),
            Expanded(
              child: controller.filteredProducts.isEmpty
                  ? const _EmptyProductsState()
                  : _ProductsTable(controller: controller),
            ),
          ],
        );
      }),
    );
  }
}

class _ProductsToolbar extends StatelessWidget {
  const _ProductsToolbar({
    required this.controller,
  });

  final AdminProductController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MBSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: MBColors.border.withValues(alpha: 0.85),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Product Management',
                  style: MBTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Get.dialog(
                    const AdminProductFormDialog(),
                    barrierDismissible: false,
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Product'),
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.md),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.setSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search by title, SKU, code, tags, category, brand...',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: controller.statusFilter.value,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'enabled', child: Text('Enabled')),
                    DropdownMenuItem(value: 'disabled', child: Text('Disabled')),
                    DropdownMenuItem(value: 'featured', child: Text('Featured')),
                    DropdownMenuItem(value: 'bestSeller', child: Text('Best Seller')),
                    DropdownMenuItem(value: 'newArrival', child: Text('New Arrival')),
                    DropdownMenuItem(value: 'flashSale', child: Text('Flash Sale')),
                    DropdownMenuItem(value: 'inStock', child: Text('In Stock')),
                    DropdownMenuItem(value: 'outOfStock', child: Text('Out of Stock')),
                  ],
                  onChanged: (value) =>
                      controller.setStatusFilter(value ?? 'all'),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: controller.categoryFilter.value,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All')),
                    ...controller.categories.map(
                          (e) => DropdownMenuItem(
                        value: e.id,
                        child: Text(e.name),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      controller.setCategoryFilter(value ?? 'all'),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: controller.brandFilter.value,
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All')),
                    ...controller.brands.map(
                          (e) => DropdownMenuItem(
                        value: e.id,
                        child: Text(e.name),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      controller.setBrandFilter(value ?? 'all'),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              OutlinedButton(
                onPressed: controller.resetFilters,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductsTable extends StatelessWidget {
  const _ProductsTable({
    required this.controller,
  });

  final AdminProductController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MBSpacing.lg),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MBRadius.lg),
          side: BorderSide(
            color: MBColors.border.withValues(alpha: 0.9),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            headingRowHeight: 56,
            dataRowMinHeight: 84,
            dataRowMaxHeight: 96,
            columns: const [
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Brand')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Inventory')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Updated')),
              DataColumn(label: Text('Actions')),
            ],
            rows: controller.filteredProducts.map((product) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 340,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(MBRadius.md),
                            child: product.thumbnailUrl.isNotEmpty
                                ? Image.network(
                              product.thumbnailUrl,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              width: 54,
                              height: 54,
                              color: MBColors.background,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                          MBSpacing.w(MBSpacing.md),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.titleEn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: MBTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                MBSpacing.h(MBSpacing.xxxs),
                                Text(
                                  product.titleBn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: MBTextStyles.caption.copyWith(
                                    color: MBColors.textSecondary,
                                  ),
                                ),
                                MBSpacing.h(MBSpacing.xxxs),
                                Text(
                                  'SKU: ${product.sku ?? '-'} | Code: ${product.productCode ?? '-'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: MBTextStyles.caption.copyWith(
                                    color: MBColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text(product.categoryId ?? '-')),
                  DataCell(Text(product.brandId ?? '-')),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('৳ ${product.effectivePrice.toStringAsFixed(2)}'),
                        if (product.hasDiscount)
                          Text(
                            'Base: ৳ ${product.price.toStringAsFixed(2)}',
                            style: MBTextStyles.caption.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stock: ${product.stockQty}'),
                        Text(
                          'Instant: ${product.instantAvailableToday}',
                          style: MBTextStyles.caption.copyWith(
                            color: MBColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        Switch(
                          value: product.isEnabled,
                          onChanged: (value) =>
                              controller.toggleEnabled(product, value),
                        ),
                        Text(product.isEnabled ? 'Enabled' : 'Disabled'),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      product.updatedAt.toString().split('.').first,
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Edit product',
                          onPressed: () {
                            Get.dialog(
                              AdminProductFormDialog(product: product),
                              barrierDismissible: false,
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Disable product',
                          onPressed: () async {
                            final confirm = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text('Disable product'),
                                content: Text(
                                  'Do you want to disable "${product.titleEn}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Get.back(result: true),
                                    child: const Text('Disable'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await controller.softDisableProduct(product);
                            }
                          },
                          icon: const Icon(
                            Icons.visibility_off_outlined,
                            color: MBColors.error,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete product',
                          onPressed: () async {
                            final confirm = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text('Delete product'),
                                content: Text(
                                  'This will permanently delete "${product.titleEn}". Continue?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Get.back(result: true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await controller.deleteProduct(product);
                            }
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: MBColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(MBSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MBRadius.xl),
          boxShadow: [
            BoxShadow(
              color: MBColors.shadow.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 44,
              color: MBColors.primaryOrange,
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              'No products found',
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.xs),
            Text(
              'Create your first product or adjust the current filters.',
              textAlign: TextAlign.center,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}