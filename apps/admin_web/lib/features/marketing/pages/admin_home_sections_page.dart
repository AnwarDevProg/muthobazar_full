import 'package:admin_web/features/marketing/controllers/admin_home_section_controller.dart';
import 'package:admin_web/features/marketing/widgets/admin_home_section_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminHomeSectionsPage extends GetView<AdminHomeSectionController> {
  const AdminHomeSectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MBColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MBSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              MBSpacing.h(MBSpacing.lg),
              Expanded(
                child: Obx(() {
                  final bool loading = controller.isLoading.value;
                  final List<MBHomeSection> items = controller.filteredSections;
                  final List<MBHomeSection> allItems = controller.sections;

                  if (loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Column(
                    children: [
                      _buildTopCard(context, allItems),
                      MBSpacing.h(MBSpacing.lg),
                      Expanded(
                        child: items.isEmpty
                            ? _buildEmptyState()
                            : _buildSectionsTable(items),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home Sections',
                style: MBTextStyles.pageTitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              MBSpacing.h(MBSpacing.xs),
              Text(
                'Manage homepage sections, layout blocks, source behavior, and visibility.',
                style: MBTextStyles.body.copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () => _openFormDialog(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Create Section'),
        ),
      ],
    );
  }

  Widget _buildTopCard(BuildContext context, List<MBHomeSection> items) {
    final int total = items.length;
    final int active = items.where((e) => e.isActive).length;
    final int manual = items
        .where((e) => e.dataSourceType.trim().toLowerCase() == 'manual')
        .length;
    final int dynamic = total - manual;

    return MBAdminFormSectionCard(
      title: 'Search & filters',
      subtitle:
      'Filter by text, status, section type, data source, and review quick stats.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              const double gap = MBSpacing.sm;
              final double width = constraints.maxWidth;

              final double itemWidth = width >= 1000
                  ? (width - (gap * 3)) / 4
                  : width >= 720
                  ? (width - gap) / 2
                  : width;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  _summaryChipCard('Total', '$total', itemWidth),
                  _summaryChipCard('Active', '$active', itemWidth),
                  _summaryChipCard('Manual', '$manual', itemWidth),
                  _summaryChipCard('Dynamic', '$dynamic', itemWidth),
                ],
              );
            },
          ),
          MBSpacing.h(MBSpacing.lg),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: TextField(
                  onChanged: controller.setSearchQuery,
                  decoration: const InputDecoration(
                    labelText: 'Search sections',
                    hintText: 'title, subtitle, ids, source',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: Obx(
                      () => DropdownButtonFormField<String>(
                    initialValue: controller.statusFilter.value,
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
                    onChanged: (value) {
                      controller.setStatusFilter(value ?? 'all');
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: Obx(
                      () => DropdownButtonFormField<String>(
                    initialValue: controller.sectionTypeFilter.value,
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
                    onChanged: (value) {
                      controller.setSectionTypeFilter(value ?? 'all');
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: Obx(
                      () => DropdownButtonFormField<String>(
                    initialValue: controller.dataSourceFilter.value,
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
                    onChanged: (value) {
                      controller.setDataSourceFilter(value ?? 'all');
                    },
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: controller.refreshSections,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
              ),
              OutlinedButton.icon(
                onPressed: controller.resetFilters,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChipCard(String label, String value, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.md,
        vertical: MBSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.90),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MBTextStyles.caption.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
          ),
          MBSpacing.w(MBSpacing.sm),
          Text(
            value,
            style: MBTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.90),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MBSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.view_quilt_outlined,
              size: 48,
              color: MBColors.textMuted,
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              'No home sections found',
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.sm),
            Text(
              'Try changing your filters or create a new home section.',
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionsTable(List<MBHomeSection> items) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.90),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(MBSpacing.lg),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            headingRowHeight: 56,
            dataRowMinHeight: 88,
            dataRowMaxHeight: 104,
            columns: const [
              DataColumn(label: Text('Section')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Source')),
              DataColumn(label: Text('Config')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: items.map((section) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 280,
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
                            style: MBTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          MBSpacing.h(MBSpacing.xxs),
                          Text(
                            section.subtitleEn.trim().isEmpty
                                ? 'No subtitle'
                                : section.subtitleEn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MBTextStyles.caption.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                          MBSpacing.h(MBSpacing.xxs),
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
                          Text(
                            _labelize(section.sectionType),
                            style: MBTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          MBSpacing.h(MBSpacing.xxs),
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
                      width: 170,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MBSpacing.sm,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: section.isActive
                            ? MBColors.success.withValues(alpha: 0.12)
                            : MBColors.textMuted.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(MBRadius.lg),
                      ),
                      child: Text(
                        section.isActive ? 'Active' : 'Inactive',
                        style: MBTextStyles.caption.copyWith(
                          color: section.isActive
                              ? MBColors.success
                              : MBColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _openFormDialog(Get.context!, section: section),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit'),
                            ),
                          ),
                        ),
                        MBSpacing.w(MBSpacing.xs),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: FilledButton.tonalIcon(
                              onPressed: () =>
                                  controller.toggleSectionActive(section),
                              icon: Icon(
                                section.isActive
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 16,
                              ),
                              label: Text(
                                section.isActive ? 'Disable' : 'Enable',
                              ),
                            ),
                          ),
                        ),
                        MBSpacing.w(MBSpacing.xs),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            tooltip: 'Delete',
                            onPressed: () =>
                                _deleteSection(Get.context!, section),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
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

  Future<void> _openFormDialog(
      BuildContext context, {
        MBHomeSection? section,
      }) async {
    await Get.dialog(
      AdminHomeSectionFormDialog(section: section),
      barrierDismissible: false,
    );
  }

  Future<void> _deleteSection(
      BuildContext context,
      MBHomeSection section,
      ) async {
    final bool? confirmed = await Get.dialog(
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
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteSection(section.id);
    }
  }

  String _labelize(String value) {
    final parts = value.trim().split('_').where((part) => part.isNotEmpty);
    return parts
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}