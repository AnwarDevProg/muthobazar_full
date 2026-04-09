import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

import '../controllers/admin_banner_controller.dart';
import '../widgets/admin_banner_form_dialog.dart';

class AdminBannersPage extends GetView<AdminBannerController> {
  const AdminBannersPage({super.key});

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
                  final String? error = controller.operationError.value;
                  final List<MBBanner> items = controller.filteredBanners;
                  final List<MBBanner> allItems = controller.banners;

                  if (loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Column(
                    children: [
                      _buildTopCard(context, allItems),
                      if ((error ?? '').trim().isNotEmpty) ...[
                        MBSpacing.h(MBSpacing.lg),
                        MBAdminFormErrorBanner(message: error!),
                      ],
                      MBSpacing.h(MBSpacing.lg),
                      Expanded(
                        child: items.isEmpty
                            ? _buildEmptyState()
                            : _buildBannerGrid(items),
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
                'Banner Management',
                style: MBTextStyles.pageTitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              MBSpacing.h(MBSpacing.xs),
              Text(
                'Manage wide and mobile banners, target behavior, scheduling, order, and home placement.',
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
          label: const Text('Create Banner'),
        ),
      ],
    );
  }

  Widget _buildTopCard(BuildContext context, List<MBBanner> items) {
    final int total = items.length;
    final int active = items.where((e) => e.isActive).length;
    final int home = items.where((e) => e.showOnHome).length;
    final int scheduled = items.where((e) => e.startAt != null || e.endAt != null).length;

    return MBAdminFormSectionCard(
      title: 'Search & filters',
      subtitle: 'Filter by text, status, target type, and see quick banner stats.',
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
                  _summaryChipCard('Show on home', '$home', itemWidth),
                  _summaryChipCard('Scheduled', '$scheduled', itemWidth),
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
                    labelText: 'Search banners',
                    hintText: 'title, subtitle, route, URL',
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
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    ],
                    onChanged: (value) {
                      controller.setStatusFilter(value ?? 'all');
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: Obx(
                      () => DropdownButtonFormField<String>(
                    initialValue: controller.targetTypeFilter.value,
                    decoration: const InputDecoration(
                      labelText: 'Target Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'none', child: Text('No action')),
                      DropdownMenuItem(value: 'product', child: Text('Product')),
                      DropdownMenuItem(value: 'category', child: Text('Category')),
                      DropdownMenuItem(value: 'brand', child: Text('Brand')),
                      DropdownMenuItem(value: 'route', child: Text('Route')),
                      DropdownMenuItem(value: 'external', child: Text('Custom URL')),
                    ],
                    onChanged: (value) {
                      controller.setTargetTypeFilter(value ?? 'all');
                    },
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: controller.refreshBanners,
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
        border: Border.all(color: MBColors.border.withValues(alpha: 0.90)),
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
        border: Border.all(color: MBColors.border.withValues(alpha: 0.90)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MBSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: MBColors.textMuted,
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              'No banners found',
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.sm),
            Text(
              'Try changing your filters or create a new banner.',
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

  Widget _buildBannerGrid(List<MBBanner> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1024) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 780) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 520) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 408,
          ),
          itemBuilder: (context, index) {
            final MBBanner banner = items[index];
            return _buildBannerCard(context, banner);
          },
        );
      },
    );
  }

  Widget _buildBannerCard(BuildContext context, MBBanner banner) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        border: Border.all(color: MBColors.border.withValues(alpha: 0.90)),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(MBRadius.xl),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: banner.imageUrl.trim().isEmpty
                  ? Container(
                color: MBColors.background,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_outlined,
                  size: 36,
                  color: MBColors.textMuted,
                ),
              )
                  : Image.network(
                banner.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: MBColors.background,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 36,
                    color: MBColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(MBSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.titleEn.trim().isEmpty ? 'Untitled Banner' : banner.titleEn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MBTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    banner.subtitleEn.trim().isEmpty
                        ? 'No subtitle provided.'
                        : banner.subtitleEn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MBTextStyles.caption.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.sm),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _tag(banner.isActive ? 'Active' : 'Inactive'),
                      _tag(banner.showOnHome ? 'Home' : 'Hidden'),
                      _tag('Sort: ${banner.sortOrder}'),
                    ],
                  ),
                  MBSpacing.h(MBSpacing.sm),
                  _infoLine('Target', _prettyTargetType(banner.targetType)),
                  _infoLine('Position', banner.position),
                  _infoLine('Schedule', _scheduleText(banner)),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: OutlinedButton.icon(
                            onPressed: () => _openFormDialog(context, banner: banner),
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
                            onPressed: () => _toggleActive(banner),
                            icon: Icon(
                              banner.isActive
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 16,
                            ),
                            label: Text(banner.isActive ? 'Disable' : 'Enable'),
                          ),
                        ),
                      ),
                      MBSpacing.w(MBSpacing.xs),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          tooltip: 'Delete',
                          onPressed: () => _deleteBanner(context, banner),
                          icon: const Icon(Icons.delete_outline_rounded, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(color: MBColors.border.withValues(alpha: 0.90)),
      ),
      child: Text(
        text,
        style: MBTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MBSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: MBTextStyles.caption.copyWith(
                color: MBColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '—' : value.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MBTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }

  String _prettyTargetType(String value) {
    switch (value.trim().toLowerCase()) {
      case 'product':
        return 'Product';
      case 'category':
        return 'Category';
      case 'brand':
        return 'Brand';
      case 'route':
        return 'Route';
      case 'external':
        return 'Custom URL';
      default:
        return 'No action';
    }
  }

  String _scheduleText(MBBanner banner) {
    final String start = banner.startAt?.toIso8601String() ?? '—';
    final String end = banner.endAt?.toIso8601String() ?? '—';
    return '$start → $end';
  }

  Future<void> _openFormDialog(
      BuildContext context, {
        MBBanner? banner,
      }) async {
    await Get.dialog<bool>(
      AdminBannerFormDialog(banner: banner),
      barrierDismissible: false,
    );
  }

  Future<void> _toggleActive(MBBanner banner) async {
    await controller.toggleBannerActive(banner);
  }

  Future<void> _deleteBanner(BuildContext context, MBBanner banner) async {
    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Banner'),
        content: Text(
          'Are you sure you want to delete "${banner.titleEn.trim().isEmpty ? 'this banner' : banner.titleEn}"?',
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
      await controller.deleteBanner(banner.id);
    }
  }
}
