import 'dart:async';

import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:admin_web/features/products/controllers/admin_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminQuarantineProductsPage extends StatefulWidget {
  const AdminQuarantineProductsPage({
    super.key,
    this.actorUid = '',
    this.actorName,
    this.actorPhone,
    this.actorRole,
  });

  final String actorUid;
  final String? actorName;
  final String? actorPhone;
  final String? actorRole;

  @override
  State<AdminQuarantineProductsPage> createState() =>
      _AdminQuarantineProductsPageState();
}

class _AdminQuarantineProductsPageState
    extends State<AdminQuarantineProductsPage> {
  late final AdminAccessController _accessController;
  late final AdminProductController _productController;

  @override
  void initState() {
    super.initState();
    _accessController = Get.find<AdminAccessController>();
    _productController = Get.find<AdminProductController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _productController.setDeletedOnly(true);
    });
  }

  @override
  void dispose() {
    unawaited(_productController.setDeletedOnly(false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      child: Obx(() {
        if (!_accessController.canRestoreProducts) {
          return const _NoRestorePermissionState();
        }

        if (_productController.isLoading.value &&
            _productController.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_productController.products.isEmpty) {
          return const _EmptyQuarantineState();
        }

        return Column(
          children: [
            _QuarantineHeader(
              count: _productController.products.length,
            ),
            Expanded(
              child: _QuarantineProductsTable(
                items: _productController.products,
                onRestore: (product) async {
                  await _productController.restoreProduct(
                    productId: product.id,
                    actorUid: widget.actorUid,
                    actorName: widget.actorName,
                    actorPhone: widget.actorPhone,
                    actorRole: widget.actorRole,
                  );
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
                  'Deleted products can be restored from here.',
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
  });

  final List<MBProduct> items;
  final Future<void> Function(MBProduct product) onRestore;

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
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: items.map((item) {
              final String titleEn = item.titleEn.trim().isEmpty
                  ? 'Untitled Product'
                  : item.titleEn;
              final String titleBn = item.titleBn.trim();
              final String thumbnailUrl = item.resolvedThumbnailUrl;
              final String sku = (item.sku ?? '-').trim().isEmpty
                  ? '-'
                  : item.sku!.trim();
              final String deletedAt = _prettyDate(item.deletedAt);

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
                            final bool? confirmed = await Get.dialog(
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
                              await onRestore(item);
                            }
                          },
                        ),
                        MBSpacing.w(MBSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: MBSpacing.md,
                            vertical: MBSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: MBColors.textMuted.withValues(alpha: 0.35),
                            ),
                            borderRadius: BorderRadius.circular(MBRadius.pill),
                          ),
                          child: Text(
                            'Permanent delete not wired',
                            style: MBTextStyles.caption.copyWith(
                              color: MBColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
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

  static String _prettyDate(DateTime? value) {
    if (value == null) return '-';
    return value.toString().split('.').first;
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