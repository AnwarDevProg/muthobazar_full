import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:admin_web/features/products/controllers/admin_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminQuarantineProductsPage extends StatelessWidget {
  const AdminQuarantineProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAccessController accessController =
    Get.find<AdminAccessController>();
    final AdminProductController productController =
    Get.find<AdminProductController>();

    return AdminWebShell(
      child: Obx(() {
        if (!accessController.canRestoreProducts) {
          return const _NoRestorePermissionState();
        }

        if (productController.isQuarantineLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (productController.quarantineProducts.isEmpty) {
          return const _EmptyQuarantineState();
        }

        return Column(
          children: [
            _QuarantineHeader(
              count: productController.quarantineProducts.length,
            ),
            Expanded(
              child: _QuarantineProductsTable(
                items: productController.quarantineProducts,
                onRestore: (id) async {
                  await productController.restoreProduct(id);
                },
                onPermanentDelete: (id) async {
                  await productController.hardDeleteQuarantineProduct(id);
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _QuarantineHeader extends StatelessWidget {
  const _QuarantineHeader({
    required this.count,
  });

  final int count;

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quarantine Products',
                  style: MBTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  'Products moved here can be restored or permanently deleted.',
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MBSpacing.md,
              vertical: MBSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: MBGradients.primaryGradient,
              borderRadius: BorderRadius.circular(MBRadius.pill),
            ),
            child: Text(
              '$count item${count == 1 ? '' : 's'}',
              style: MBTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuarantineProductsTable extends StatelessWidget {
  const _QuarantineProductsTable({
    required this.items,
    required this.onRestore,
    required this.onPermanentDelete,
  });

  final List<Map<String, dynamic>> items;
  final Future<void> Function(String id) onRestore;
  final Future<void> Function(String id) onPermanentDelete;

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
            dataRowMinHeight: 92,
            dataRowMaxHeight: 108,
            columns: const [
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Deleted At')),
              DataColumn(label: Text('Auto Delete After')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: items.map((item) {
              final Map<String, dynamic> productData = Map<String, dynamic>.from(
                item['productData'] as Map<String, dynamic>? ?? const {},
              );

              final String id = item['id'].toString();
              final String titleEn =
              (productData['titleEn'] ?? 'Untitled Product').toString();
              final String titleBn =
              (productData['titleBn'] ?? '').toString();
              final String thumbnailUrl =
              (productData['thumbnailUrl'] ?? '').toString();
              final String sku = (productData['sku'] ?? '-').toString();
              final String deletedAt = _prettyDate(item['deletedAt']);
              final String deleteAfterAt = _prettyDate(item['deleteAfterAt']);

              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 340,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(MBRadius.md),
                            child: thumbnailUrl.isNotEmpty
                                ? Image.network(
                              thumbnailUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 56,
                                height: 56,
                                color: MBColors.background,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                ),
                              ),
                            )
                                : Container(
                              width: 56,
                              height: 56,
                              color: MBColors.background,
                              child: const Icon(
                                Icons.inventory_2_outlined,
                              ),
                            ),
                          ),
                          MBSpacing.w(MBSpacing.md),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titleEn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: MBTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (titleBn.isNotEmpty) ...[
                                  MBSpacing.h(MBSpacing.xxxs),
                                  Text(
                                    titleBn,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: MBTextStyles.caption.copyWith(
                                      color: MBColors.textSecondary,
                                    ),
                                  ),
                                ],
                                MBSpacing.h(MBSpacing.xxxs),
                                Text(
                                  'SKU: $sku',
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
                  DataCell(Text(deletedAt)),
                  DataCell(Text(deleteAfterAt)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MBSpacing.md,
                        vertical: MBSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: MBColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(MBRadius.pill),
                      ),
                      child: Text(
                        'In Quarantine',
                        style: MBTextStyles.caption.copyWith(
                          color: MBColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        MBSecondaryButton(
                          text: 'Restore',
                          expand: false,
                          height: 40,
                          onPressed: () async {
                            final bool? confirmed = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text('Restore product'),
                                content: Text(
                                  'Do you want to restore "$titleEn" back to active products?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Get.back(result: true),
                                    child: const Text('Restore'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await onRestore(id);
                            }
                          },
                        ),
                        MBSpacing.w(MBSpacing.sm),
                        MBSecondaryButton(
                          text: 'Delete Permanently',
                          expand: false,
                          height: 40,
                          foregroundColor: MBColors.error,
                          borderColor: MBColors.error,
                          onPressed: () async {
                            final bool? confirmed = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text('Delete permanently'),
                                content: Text(
                                  'Delete "$titleEn" permanently from quarantine?',
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

                            if (confirmed == true) {
                              await onPermanentDelete(id);
                            }
                          },
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

  static String _prettyDate(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return '-';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    return parsed.toString().split('.').first;
  }
}

class _NoRestorePermissionState extends StatelessWidget {
  const _NoRestorePermissionState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 480,
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
              Icons.lock_outline_rounded,
              size: 44,
              color: MBColors.error,
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              'Permission Required',
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.xs),
            Text(
              'You do not have permission to restore quarantine products.',
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

class _EmptyQuarantineState extends StatelessWidget {
  const _EmptyQuarantineState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 460,
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
              'No Quarantine Products',
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.xs),
            Text(
              'Deleted products will appear here before permanent removal.',
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