import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:admin_web/features/marketing/controllers/admin_home_section_controller.dart';
import 'package:admin_web/features/marketing/widgets/admin_home_section_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminHomeSectionsPage extends StatelessWidget {
  const AdminHomeSectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAccessController accessController = Get.find();
    final AdminHomeSectionController controller = Get.find();

    return Obx(() {
      if (accessController.isLoading.value || controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (!accessController.canManageHomeSections) {
        return const _NoPermissionState();
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(MBSpacing.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - (MBSpacing.lg * 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HomeSectionsHeader(),
                  MBSpacing.h(MBSpacing.lg),
                  if (controller.filteredSections.isEmpty)
                    const _EmptyHomeSectionsState()
                  else
                    _HomeSectionsTable(
                      sections: controller.filteredSections,
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class _HomeSectionsHeader extends StatelessWidget {
  const _HomeSectionsHeader();

  @override
  Widget build(BuildContext context) {
    final AdminHomeSectionController controller = Get.find();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.lg),
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
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Obx(() {
        final int total = controller.sections.length;
        final int active =
            controller.sections.where((section) => section.isActive).length;
        final int inactive = total - active;
        final int manual = controller.sections
            .where(
              (section) =>
          section.dataSourceType.trim().toLowerCase() == 'manual',
        )
            .length;
        final int dynamic = total - manual;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Home Sections',
                        style: MBTextStyles.sectionTitle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      MBSpacing.h(MBSpacing.xxs),
                      Text(
                        'Manage homepage section layout, source rules, and visibility.',
                        style: MBTextStyles.body.copyWith(
                          color: MBColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.dialog(
                      const AdminHomeSectionFormDialog(),
                      barrierDismissible: false,
                    );
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Section'),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Wrap(
              spacing: MBSpacing.sm,
              runSpacing: MBSpacing.sm,
              children: [
                _SummaryChip(label: 'Total', value: '$total'),
                _SummaryChip(label: 'Active', value: '$active'),
                _SummaryChip(label: 'Inactive', value: '$inactive'),
                _SummaryChip(label: 'Manual', value: '$manual'),
                _SummaryChip(label: 'Dynamic', value: '$dynamic'),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Wrap(
              spacing: MBSpacing.md,
              runSpacing: MBSpacing.md,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 340,
                  child: TextField(
                    onChanged: controller.setSearchQuery,
                    decoration: const InputDecoration(
                      hintText: 'Search sections, titles, ids, source ids...',
                      prefixIcon: Icon(Icons.search_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: controller.statusFilter.value,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Inactive'),
                      ),
                      DropdownMenuItem(
                        value: 'viewAllOn',
                        child: Text('View All On'),
                      ),
                      DropdownMenuItem(
                        value: 'viewAllOff',
                        child: Text('View All Off'),
                      ),
                    ],
                    onChanged: (value) =>
                        controller.setStatusFilter(value ?? 'all'),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    value: controller.sectionTypeFilter.value,
                    decoration: const InputDecoration(
                      labelText: 'Section Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(
                        value: 'hero_banner',
                        child: Text('Hero Banner'),
                      ),
                      DropdownMenuItem(
                        value: 'category_grid',
                        child: Text('Category Grid'),
                      ),
                      DropdownMenuItem(
                        value: 'product_horizontal',
                        child: Text('Product Horizontal'),
                      ),
                      DropdownMenuItem(
                        value: 'product_grid',
                        child: Text('Product Grid'),
                      ),
                      DropdownMenuItem(
                        value: 'offer_strip',
                        child: Text('Offer Strip'),
                      ),
                      DropdownMenuItem(
                        value: 'promo_banner',
                        child: Text('Promo Banner'),
                      ),
                      DropdownMenuItem(
                        value: 'brand_row',
                        child: Text('Brand Row'),
                      ),
                    ],
                    onChanged: (value) =>
                        controller.setSectionTypeFilter(value ?? 'all'),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    value: controller.dataSourceFilter.value,
                    decoration: const InputDecoration(
                      labelText: 'Data Source',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'manual', child: Text('Manual')),
                      DropdownMenuItem(
                        value: 'featured',
                        child: Text('Featured'),
                      ),
                      DropdownMenuItem(
                        value: 'flash_sale',
                        child: Text('Flash Sale'),
                      ),
                      DropdownMenuItem(
                        value: 'new_arrival',
                        child: Text('New Arrival'),
                      ),
                      DropdownMenuItem(
                        value: 'best_seller',
                        child: Text('Best Seller'),
                      ),
                      DropdownMenuItem(
                        value: 'recommended',
                        child: Text('Recommended'),
                      ),
                      DropdownMenuItem(
                        value: 'category',
                        child: Text('Category'),
                      ),
                      DropdownMenuItem(value: 'brand', child: Text('Brand')),
                    ],
                    onChanged: (value) =>
                        controller.setDataSourceFilter(value ?? 'all'),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: controller.layoutFilter.value,
                    decoration: const InputDecoration(
                      labelText: 'Layout',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(
                        value: 'compact',
                        child: Text('Compact'),
                      ),
                      DropdownMenuItem(
                        value: 'standard',
                        child: Text('Standard'),
                      ),
                      DropdownMenuItem(
                        value: 'large',
                        child: Text('Large'),
                      ),
                      DropdownMenuItem(
                        value: 'card',
                        child: Text('Card'),
                      ),
                      DropdownMenuItem(
                        value: 'slider',
                        child: Text('Slider'),
                      ),
                    ],
                    onChanged: (value) =>
                        controller.setLayoutFilter(value ?? 'all'),
                  ),
                ),
                OutlinedButton(
                  onPressed: controller.resetFilters,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _HomeSectionsTable extends StatelessWidget {
  const _HomeSectionsTable({
    required this.sections,
  });

  final List<MBHomeSection> sections;

  @override
  Widget build(BuildContext context) {
    final AdminHomeSectionController controller = Get.find();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MBRadius.xl),
        side: BorderSide(
          color: MBColors.border.withValues(alpha: 0.90),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(MBSpacing.lg),
        child: DataTable(
          columnSpacing: 24,
          headingRowHeight: 56,
          dataRowMinHeight: 88,
          dataRowMaxHeight: 104,
          columns: const [
            DataColumn(label: Text('Section')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Source')),
            DataColumn(label: Text('Content')),
            DataColumn(label: Text('Config')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: sections.map((section) {
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 320,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.titleEn.trim().isEmpty
                              ? 'Untitled Section'
                              : section.titleEn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MBTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (section.titleBn.trim().isNotEmpty) ...[
                          MBSpacing.h(MBSpacing.xxxs),
                          Text(
                            section.titleBn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MBTextStyles.caption.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ],
                        MBSpacing.h(MBSpacing.xxxs),
                        Text(
                          'ID: ${section.id}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MBTextStyles.caption.copyWith(
                            color: MBColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 180,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InlinePill(
                          label: _labelize(section.sectionType),
                          active: true,
                        ),
                        MBSpacing.h(MBSpacing.xs),
                        Text(
                          'Layout: ${_labelize(section.layoutStyle)}',
                          style: MBTextStyles.caption.copyWith(
                            color: MBColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 220,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _labelize(section.dataSourceType),
                          style: MBTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if ((section.sourceCategoryId ?? '').trim().isNotEmpty)
                          Text(
                            'Category: ${section.sourceCategoryId}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MBTextStyles.caption.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        if ((section.sourceBrandId ?? '').trim().isNotEmpty)
                          Text(
                            'Brand: ${section.sourceBrandId}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MBTextStyles.caption.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Products: ${section.productIds.length}',
                          style: MBTextStyles.caption,
                        ),
                        Text(
                          'Categories: ${section.categoryIds.length}',
                          style: MBTextStyles.caption,
                        ),
                        Text(
                          'Brands: ${section.brandIds.length}',
                          style: MBTextStyles.caption,
                        ),
                        Text(
                          'Banners: ${section.bannerIds.length}',
                          style: MBTextStyles.caption,
                        ),
                        Text(
                          'Offers: ${section.offerIds.length}',
                          style: MBTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sort: ${section.sortOrder}'),
                        Text('Limit: ${section.itemLimit}'),
                        Text(
                          section.showViewAll
                              ? 'View All: Enabled'
                              : 'View All: Disabled',
                          style: MBTextStyles.caption.copyWith(
                            color: MBColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  _InlinePill(
                    label: section.isActive ? 'Active' : 'Inactive',
                    active: section.isActive,
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      Switch(
                        value: section.isActive,
                        onChanged: (_) =>
                            controller.toggleSectionActive(section),
                      ),
                      IconButton(
                        tooltip: 'Edit section',
                        onPressed: () {
                          Get.dialog(
                            AdminHomeSectionFormDialog(section: section),
                            barrierDismissible: false,
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete section',
                        onPressed: () async {
                          final bool? confirmed = await Get.dialog<bool>(
                            AlertDialog(
                              title: const Text('Delete Home Section'),
                              content: Text(
                                'Are you sure you want to delete "${section.titleEn.trim().isEmpty ? 'this section' : section.titleEn}"?',
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
                            await controller.deleteSection(section.id);
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
    );
  }

  String _labelize(String value) {
    final parts = value.trim().split('_').where((part) => part.isNotEmpty);
    return parts
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.md,
        vertical: MBSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.pill),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.9),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: MBTextStyles.caption.copyWith(
            color: MBColors.textSecondary,
          ),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: MBTextStyles.caption.copyWith(
                color: MBColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlinePill extends StatelessWidget {
  const _InlinePill({
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.md,
        vertical: MBSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: active
            ? MBColors.success.withValues(alpha: 0.12)
            : MBColors.textMuted.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(MBRadius.pill),
      ),
      child: Text(
        label,
        style: MBTextStyles.caption.copyWith(
          color: active ? MBColors.success : MBColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NoPermissionState extends StatelessWidget {
  const _NoPermissionState();

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
              'You do not have permission to manage home sections.',
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

class _EmptyHomeSectionsState extends StatelessWidget {
  const _EmptyHomeSectionsState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Center(
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
                Icons.view_quilt_outlined,
                size: 44,
                color: MBColors.primaryOrange,
              ),
              MBSpacing.h(MBSpacing.md),
              Text(
                'No Home Sections Found',
                style: MBTextStyles.sectionTitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              MBSpacing.h(MBSpacing.xs),
              Text(
                'Create your first homepage section to control the customer app home layout.',
                textAlign: TextAlign.center,
                style: MBTextStyles.body.copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}