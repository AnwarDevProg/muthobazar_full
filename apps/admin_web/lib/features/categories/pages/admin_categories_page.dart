import 'dart:async';

import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:admin_web/features/categories/controllers/admin_category_controller.dart';
import 'package:admin_web/features/categories/widgets/admin_category_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  late final AdminCategoryController _controller;

  List<MBCategory> _categories = <MBCategory>[];
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _isReordering = false;
  bool _isToggling = false;
  String _error = '';

  StreamSubscription<List<MBCategory>>? _categoriesSubscription;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<AdminCategoryController>()
        ? Get.find<AdminCategoryController>()
        : Get.put(AdminCategoryController());
    _listenCategories();
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    super.dispose();
  }

  void _listenCategories() {
    _categoriesSubscription?.cancel();

    setState(() {
      _isLoading = true;
      _error = '';
    });

    _categoriesSubscription = AdminCategoryRepository.instance.watchCategories().listen(
          (items) {
        if (!mounted) return;
        setState(() {
          _categories = items;
          _isLoading = false;
          _error = '';
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _reloadCategories() async {
    _listenCategories();
  }

  Future<void> _openCreateDialog() async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AdminCategoryFormDialog(
        categories: _categories,
      ),
    );
  }

  Future<void> _openEditDialog(MBCategory category) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AdminCategoryFormDialog(
        category: category,
        categories: _categories,
      ),
    );
  }

  Future<void> _deleteCategory(MBCategory category) async {
    try {
      final String? blockReason =
      await AdminCategoryRepository.instance.getDeleteBlockReason(category.id);
      if (!mounted) return;

      if (blockReason != null) {
        await showDialog<void>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Delete Not Allowed'),
              content: Text(blockReason),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Delete Category'),
            content: Text(
              'Are you sure you want to delete "${category.nameEn.trim().isEmpty ? 'this category' : category.nameEn}"?\n\nIts uploaded image files will also be removed.',
            ),
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
          );
        },
      );

      if (confirmed != true) return;

      setState(() {
        _isDeleting = true;
        _error = '';
      });

      await _controller.deleteCategory(category: category);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${category.nameEn.trim().isEmpty ? 'Category' : category.nameEn} deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
      });
    }
  }

  Future<void> _toggleActive(MBCategory category) async {
    try {
      setState(() {
        _isToggling = true;
        _error = '';
      });

      await _controller.toggleActive(category: category);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status update failed: $e'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isToggling = false;
      });
    }
  }

  String _normalizeParentId(String? parentId) {
    return parentId?.trim() ?? '';
  }

  List<MBCategory> _rootCategories() {
    final items = _categories
        .where((item) => _normalizeParentId(item.parentId).isEmpty)
        .toList();

    items.sort((a, b) {
      final int bySort = a.sortOrder.compareTo(b.sortOrder);
      if (bySort != 0) return bySort;
      return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
    });

    return items;
  }

  List<MBCategory> _childrenOf(String parentId) {
    final items = _categories
        .where((item) => _normalizeParentId(item.parentId) == parentId.trim())
        .toList();

    items.sort((a, b) {
      final int bySort = a.sortOrder.compareTo(b.sortOrder);
      if (bySort != 0) return bySort;
      return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
    });

    return items;
  }

  Future<void> _reorderGroup({
    required String? parentId,
    required int oldIndex,
    required int newIndex,
  }) async {
    final normalizedParentId = _normalizeParentId(parentId);

    final currentGroup = _categories.where((item) {
      return _normalizeParentId(item.parentId) == normalizedParentId;
    }).toList()
      ..sort((a, b) {
        final int bySort = a.sortOrder.compareTo(b.sortOrder);
        if (bySort != 0) return bySort;
        return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
      });

    if (oldIndex < 0 || oldIndex >= currentGroup.length) return;

    int targetIndex = newIndex;
    if (targetIndex > oldIndex) {
      targetIndex -= 1;
    }

    if (targetIndex < 0 || targetIndex >= currentGroup.length) return;
    if (oldIndex == targetIndex) return;

    final moved = currentGroup.removeAt(oldIndex);
    currentGroup.insert(targetIndex, moved);

    final updatedGroup = [
      for (int i = 0; i < currentGroup.length; i++)
        currentGroup[i].copyWith(sortOrder: i),
    ];

    final Map<String, MBCategory> updatedById = {
      for (final item in updatedGroup) item.id: item,
    };

    final optimisticCategories = _categories.map((item) {
      return updatedById[item.id] ?? item;
    }).toList();

    if (!mounted) return;

    setState(() {
      _categories = optimisticCategories;
      _isReordering = true;
      _error = '';
    });

    try {
      await _controller.reorderGroup(
        parentId: parentId,
        orderedCategoryIds: updatedGroup.map((e) => e.id).toList(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reorder failed: $e'),
        ),
      );
      _listenCategories();
    } finally {
      if (!mounted) return;
      setState(() {
        _isReordering = false;
      });
    }
  }

  String _busyLabel() {
    if (_isDeleting) return 'Deleting...';
    if (_isReordering) return 'Reordering...';
    if (_isToggling) return 'Updating status...';
    return 'Working...';
  }

  @override
  Widget build(BuildContext context) {
    final rootCategories = _rootCategories();

    return AdminWebShell(
      child: Padding(
        padding: const EdgeInsets.all(MBSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(MBSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(MBRadius.xl),
                border: Border.all(
                  color: MBColors.border.withValues(alpha: 0.90),
                ),
                boxShadow: [
                  BoxShadow(
                    color: MBColors.shadow.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Categories',
                      style: MBTextStyles.sectionTitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _isLoading || _isDeleting || _isReordering || _isToggling
                        ? null
                        : _openCreateDialog,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Category'),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  OutlinedButton.icon(
                    onPressed: _isLoading || _isDeleting || _isReordering || _isToggling
                        ? null
                        : _reloadCategories,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reload'),
                  ),
                ],
              ),
            ),
            MBSpacing.h(MBSpacing.lg),
            Expanded(
              child: _buildBody(rootCategories),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<MBCategory> rootCategories) {
    if (_isLoading) {
      return _buildShellCard(
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error.trim().isNotEmpty) {
      return _buildShellCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(MBSpacing.lg),
            child: SelectableText(
              _error,
              style: MBTextStyles.body.copyWith(
                color: MBColors.error,
                height: 1.5,
              ),
            ),
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return _buildShellCard(
        child: Center(
          child: Text(
            'No data found',
            style: MBTextStyles.sectionTitle.copyWith(
              color: MBColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final bool isBusy = _isDeleting || _isReordering || _isToggling;

    return _buildShellCard(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(MBSpacing.lg),
            children: [
              Text(
                'Root Categories',
                style: MBTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              MBSpacing.h(MBSpacing.sm),
              _buildRootReorderList(rootCategories),
            ],
          ),
          if (isBusy)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.55),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      MBSpacing.h(MBSpacing.sm),
                      Text(
                        _busyLabel(),
                        style: MBTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRootReorderList(List<MBCategory> rootCategories) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      buildDefaultDragHandles: false,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rootCategories.length,
      onReorder: (oldIndex, newIndex) {
        _reorderGroup(
          parentId: null,
          oldIndex: oldIndex,
          newIndex: newIndex,
        );
      },
      itemBuilder: (context, index) {
        final item = rootCategories[index];
        final children = _childrenOf(item.id);

        return Container(
          key: ValueKey('root_${item.id}'),
          margin: const EdgeInsets.only(bottom: MBSpacing.md),
          child: Column(
            children: [
              _buildCategoryCard(
                item: item,
                dragIndex: index,
                isChild: false,
              ),
              if (children.isNotEmpty) ...[
                MBSpacing.h(MBSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: _buildChildSection(
                    parent: item,
                    children: children,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildChildSection({
    required MBCategory parent,
    required List<MBCategory> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Children of ${parent.nameEn.trim().isEmpty ? 'Unnamed Category' : parent.nameEn}',
            style: MBTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: MBColors.textSecondary,
            ),
          ),
          MBSpacing.h(MBSpacing.sm),
          ReorderableListView.builder(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            onReorder: (oldIndex, newIndex) {
              _reorderGroup(
                parentId: parent.id,
                oldIndex: oldIndex,
                newIndex: newIndex,
              );
            },
            itemBuilder: (context, index) {
              final item = children[index];
              return Container(
                key: ValueKey('child_${parent.id}_${item.id}'),
                margin: const EdgeInsets.only(bottom: MBSpacing.sm),
                child: _buildCategoryCard(
                  item: item,
                  dragIndex: index,
                  isChild: true,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required MBCategory item,
    required int dragIndex,
    required bool isChild,
  }) {
    return Container(
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isChild) ...[
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Icon(
                Icons.subdirectory_arrow_right_rounded,
                size: 20,
                color: MBColors.textSecondary,
              ),
            ),
            MBSpacing.w(MBSpacing.sm),
          ],
          _CategoryCardImage(
            imageUrl: item.imageUrl,
            iconUrl: item.iconUrl,
          ),
          MBSpacing.w(MBSpacing.md),
          Expanded(
            child: SizedBox(
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.nameEn.trim().isEmpty
                              ? 'Unnamed Category'
                              : item.nameEn,
                          style: MBTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ReorderableDragStartListener(
                        index: dragIndex,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(MBRadius.md),
                              border: Border.all(
                                color: MBColors.border.withValues(alpha: 0.85),
                              ),
                            ),
                            child: Icon(
                              Icons.drag_indicator_rounded,
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      MBSpacing.w(MBSpacing.sm),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await _openEditDialog(item);
                          } else if (value == 'delete') {
                            await _deleteCategory(item);
                          } else if (value == 'toggle') {
                            await _toggleActive(item);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem<String>(
                            value: 'toggle',
                            child: Text(
                              item.isActive ? 'Set Inactive' : 'Set Active',
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (item.nameBn.trim().isNotEmpty) ...[
                    MBSpacing.h(MBSpacing.xs),
                    Text(
                      item.nameBn,
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.textSecondary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Wrap(
                    spacing: MBSpacing.sm,
                    runSpacing: MBSpacing.sm,
                    children: [
                      if (isChild) const _InfoChip(label: 'Child category'),
                      _InfoChip(label: 'Slug: ${item.slug}'),
                      _InfoChip(label: 'Sort: ${item.sortOrder}'),
                      _InfoChip(label: item.isActive ? 'Active' : 'Inactive'),
                      _InfoChip(
                        label: item.isFeatured ? 'Featured' : 'Not featured',
                      ),
                      _InfoChip(
                        label: item.showOnHome ? 'Home visible' : 'Home hidden',
                      ),
                      _InfoChip(label: 'Products: ${item.productsCount}'),
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

  Widget _buildShellCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.90),
        ),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CategoryCardImage extends StatelessWidget {
  const _CategoryCardImage({
    required this.imageUrl,
    required this.iconUrl,
  });

  final String imageUrl;
  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    final String primaryUrl = imageUrl.trim();
    final String fallbackUrl = iconUrl.trim();
    final String finalUrl = primaryUrl.isNotEmpty ? primaryUrl : fallbackUrl;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: MBColors.primaryOrange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(MBRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: finalUrl.isEmpty
          ? Center(
        child: Icon(
          Icons.category_rounded,
          size: 34,
          color: MBColors.primaryOrange,
        ),
      )
          : Image.network(
        finalUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 34,
              color: MBColors.primaryOrange,
            ),
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.md),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Text(
        label,
        style: MBTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: MBColors.textSecondary,
        ),
      ),
    );
  }
}
