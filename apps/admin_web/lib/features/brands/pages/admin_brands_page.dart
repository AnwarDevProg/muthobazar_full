import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:admin_web/features/brands/controllers/admin_brand_controller.dart';
import 'package:admin_web/features/brands/widgets/admin_brand_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminBrandsPage extends StatefulWidget {
  const AdminBrandsPage({super.key});

  @override
  State<AdminBrandsPage> createState() => _AdminBrandsPageState();
}

class _AdminBrandsPageState extends State<AdminBrandsPage> {
  late final AdminAccessController _accessController;
  late final AdminBrandController _controller;

  late final TextEditingController _searchController;

  bool _isDeleting = false;
  bool _isToggling = false;
  String _pageError = '';

  @override
  void initState() {
    super.initState();

    _accessController = Get.find<AdminAccessController>();
    _controller = Get.isRegistered<AdminBrandController>()
        ? Get.find<AdminBrandController>()
        : Get.put(AdminBrandController());

    _searchController = TextEditingController(
      text: _controller.searchQuery.value,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reloadBrands() async {
    setState(() {
      _pageError = '';
    });

    try {
      await _controller.refreshBrands();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pageError = e.toString();
      });
    }
  }

  Future<void> _openCreateDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AdminBrandFormDialog(),
    );
  }

  Future<void> _openEditDialog(MBBrand brand) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AdminBrandFormDialog(brand: brand),
    );
  }

  Future<void> _toggleActive(MBBrand brand) async {
    if (_isDeleting || _isToggling) return;

    setState(() {
      _isToggling = true;
      _pageError = '';
    });

    try {
      final ok = await _controller.toggleBrandActive(brand);
      if (!ok && mounted) {
        setState(() {
          _pageError = _controller.operationError.value ?? 'Status update failed.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pageError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isToggling = false;
      });
    }
  }

  Future<void> _deleteBrand(MBBrand brand) async {
    if (_isDeleting || _isToggling) return;

    try {
      final String? blockReason = await _controller.getDeleteBlockReason(
        brandId: brand.id,
      );

      if (!mounted) return;

      if (blockReason != null && blockReason.trim().isNotEmpty) {
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
            title: const Text('Delete Brand'),
            content: Text(
              'Are you sure you want to delete "${brand.nameEn.trim().isEmpty ? 'this brand' : brand.nameEn}"?\n\nIts uploaded image files may also need cleanup if you are storing them in Firebase Storage.',
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

      if (confirmed != true || !mounted) return;

      setState(() {
        _isDeleting = true;
        _pageError = '';
      });

      final bool ok = await _controller.deleteBrand(brand.id);

      if (!mounted) return;

      if (!ok) {
        setState(() {
          _pageError = _controller.operationError.value ?? 'Delete failed.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _pageError = e.toString();
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

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      child: Obx(() {
        final bool hasPermission = _accessController.canManageBrands;
        final bool isLoading = _controller.isLoading.value;
        final List<MBBrand> brands = _controller.filteredBrands.toList();
        final bool isBusy = _isDeleting || _isToggling;

        return Padding(
          padding: const EdgeInsets.all(MBSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(
                hasPermission: hasPermission,
                isLoading: isLoading,
                isBusy: isBusy,
              ),
              MBSpacing.h(MBSpacing.lg),
              Expanded(
                child: _buildBody(
                  hasPermission: hasPermission,
                  isLoading: isLoading,
                  isBusy: isBusy,
                  brands: brands,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTopBar({
    required bool hasPermission,
    required bool isLoading,
    required bool isBusy,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Brands',
            style: MBTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: !hasPermission || isLoading || isBusy ? null : _openCreateDialog,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Brand'),
        ),
        MBSpacing.w(MBSpacing.md),
        OutlinedButton.icon(
          onPressed: isLoading || isBusy ? null : _reloadBrands,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reload'),
        ),
      ],
    );
  }

  Widget _buildBody({
    required bool hasPermission,
    required bool isLoading,
    required bool isBusy,
    required List<MBBrand> brands,
  }) {
    if (!hasPermission) {
      return _buildShellCard(
        child: Center(
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
                  'You do not have permission to manage brands.',
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

    if (isLoading) {
      return _buildShellCard(
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_pageError.trim().isNotEmpty) {
      return _buildShellCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(MBSpacing.lg),
            child: SelectableText(
              _pageError,
              style: MBTextStyles.body.copyWith(
                color: MBColors.error,
                height: 1.5,
              ),
            ),
          ),
        ),
      );
    }

    return _buildShellCard(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(MBSpacing.lg),
            children: [
              _buildFilterCard(),
              MBSpacing.h(MBSpacing.lg),
              if (brands.isEmpty)
                _buildEmptyState()
              else
                ...brands.map(_buildBrandCard),
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
                        _isDeleting ? 'Deleting brand...' : 'Updating brand...',
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

  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(MBSpacing.lg),
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
            'Filters',
            style: MBTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: MBColors.textPrimary,
            ),
          ),
          MBSpacing.h(MBSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool stacked = constraints.maxWidth < 1100;

              final searchField = SizedBox(
                width: stacked ? double.infinity : 320,
                child: TextField(
                  controller: _searchController,
                  onChanged: _controller.setSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search by name, slug, description...',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
              );

              final statusField = SizedBox(
                width: stacked ? double.infinity : 180,
                child: DropdownButtonFormField<String>(
                  value: _controller.statusFilter.value,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (value) => _controller.setStatusFilter(value ?? 'all'),
                ),
              );

              final featuredField = SizedBox(
                width: stacked ? double.infinity : 180,
                child: DropdownButtonFormField<String>(
                  value: _controller.featuredFilter.value,
                  decoration: const InputDecoration(
                    labelText: 'Featured',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'featured', child: Text('Featured')),
                    DropdownMenuItem(
                      value: 'notFeatured',
                      child: Text('Not Featured'),
                    ),
                  ],
                  onChanged: (value) =>
                      _controller.setFeaturedFilter(value ?? 'all'),
                ),
              );

              final homeField = SizedBox(
                width: stacked ? double.infinity : 200,
                child: DropdownButtonFormField<String>(
                  value: _controller.homeFilter.value,
                  decoration: const InputDecoration(
                    labelText: 'Home Visibility',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(
                      value: 'showOnHome',
                      child: Text('Show On Home'),
                    ),
                    DropdownMenuItem(
                      value: 'hideFromHome',
                      child: Text('Hide From Home'),
                    ),
                  ],
                  onChanged: (value) => _controller.setHomeFilter(value ?? 'all'),
                ),
              );

              final resetButton = SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    _controller.resetFilters();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset'),
                ),
              );

              if (stacked) {
                return Column(
                  children: [
                    searchField,
                    MBSpacing.h(MBSpacing.md),
                    statusField,
                    MBSpacing.h(MBSpacing.md),
                    featuredField,
                    MBSpacing.h(MBSpacing.md),
                    homeField,
                    MBSpacing.h(MBSpacing.md),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: resetButton,
                    ),
                  ],
                );
              }

              return Wrap(
                spacing: MBSpacing.md,
                runSpacing: MBSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  searchField,
                  statusField,
                  featuredField,
                  homeField,
                  resetButton,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.store_outlined,
            size: 44,
            color: MBColors.primaryOrange,
          ),
          MBSpacing.h(MBSpacing.md),
          Text(
            'No data found',
            style: MBTextStyles.sectionTitle.copyWith(
              color: MBColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.xs),
          Text(
            'Create your first brand or adjust the filters.',
            textAlign: TextAlign.center,
            style: MBTextStyles.body.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard(MBBrand brand) {
    return Container(
      margin: const EdgeInsets.only(bottom: MBSpacing.md),
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 900;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BrandCardHeader(brand: brand),
                MBSpacing.h(MBSpacing.md),
                _BrandCardMeta(brand: brand),
                MBSpacing.h(MBSpacing.md),
                _BrandCardActions(
                  brand: brand,
                  onEdit: () => _openEditDialog(brand),
                  onToggle: () => _toggleActive(brand),
                  onDelete: () => _deleteBrand(brand),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BrandCardImage(
                imageUrl: brand.imageUrl.trim().isNotEmpty
                    ? brand.imageUrl
                    : brand.logoUrl,
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: SizedBox(
                  height: 132,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BrandCardHeader(brand: brand),
                      MBSpacing.h(MBSpacing.sm),
                      Expanded(
                        child: _BrandCardMeta(brand: brand),
                      ),
                    ],
                  ),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              SizedBox(
                width: 210,
                child: _BrandCardActions(
                  brand: brand,
                  onEdit: () => _openEditDialog(brand),
                  onToggle: () => _toggleActive(brand),
                  onDelete: () => _deleteBrand(brand),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShellCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.9),
        ),
      ),
      child: child,
    );
  }
}

class _BrandCardHeader extends StatelessWidget {
  const _BrandCardHeader({
    required this.brand,
  });

  final MBBrand brand;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                brand.nameEn.trim().isEmpty ? 'Unnamed Brand' : brand.nameEn,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MBTextStyles.bodyMedium.copyWith(
                  color: MBColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (brand.nameBn.trim().isNotEmpty) ...[
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  brand.nameBn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MBTextStyles.caption.copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        MBSpacing.w(MBSpacing.md),
        Wrap(
          spacing: MBSpacing.xs,
          runSpacing: MBSpacing.xs,
          alignment: WrapAlignment.end,
          children: [
            _StatusChip(
              label: brand.isActive ? 'Active' : 'Inactive',
              color: brand.isActive ? MBColors.success : MBColors.textSecondary,
            ),
            _StatusChip(
              label: brand.showOnHome ? 'Home: Shown' : 'Home: Hidden',
              color: brand.showOnHome
                  ? MBColors.info
                  : MBColors.textSecondary,
            ),
            _StatusChip(
              label: brand.isFeatured ? 'Featured' : 'Normal',
              color: brand.isFeatured
                  ? MBColors.warning
                  : MBColors.textSecondary,
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandCardMeta extends StatelessWidget {
  const _BrandCardMeta({
    required this.brand,
  });

  final MBBrand brand;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (brand.descriptionEn.trim().isNotEmpty) ...[
          Text(
            brand.descriptionEn,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: MBTextStyles.body.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
          MBSpacing.h(MBSpacing.sm),
        ],
        Wrap(
          spacing: MBSpacing.md,
          runSpacing: MBSpacing.xs,
          children: [
            _MetaText(
              label: 'Slug',
              value: brand.slug.trim().isEmpty ? '—' : brand.slug,
            ),
            _MetaText(
              label: 'Sort',
              value: '${brand.sortOrder}',
            ),
            _MetaText(
              label: 'Products',
              value: '${brand.productsCount}',
            ),
            _MetaText(
              label: 'Logo URL',
              value: brand.logoUrl.trim().isEmpty ? '—' : 'Available',
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandCardActions extends StatelessWidget {
  const _BrandCardActions({
    required this.brand,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final MBBrand brand;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit'),
          ),
        ),
        MBSpacing.h(MBSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onToggle,
            icon: Icon(
              brand.isActive
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            label: Text(brand.isActive ? 'Deactivate' : 'Activate'),
          ),
        ),
        MBSpacing.h(MBSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: MBColors.error,
            ),
            label: const Text('Delete'),
          ),
        ),
      ],
    );
  }
}

class _BrandCardImage extends StatelessWidget {
  const _BrandCardImage({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(MBRadius.lg),
      child: Container(
        width: 132,
        height: 132,
        color: MBColors.surface,
        child: imageUrl.trim().isNotEmpty
            ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const _BrandFallbackImage();
          },
        )
            : const _BrandFallbackImage(),
      ),
    );
  }
}

class _BrandFallbackImage extends StatelessWidget {
  const _BrandFallbackImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MBColors.background,
      child: const Center(
        child: Icon(
          Icons.store_outlined,
          color: MBColors.primaryOrange,
          size: 34,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.sm,
        vertical: MBSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(MBRadius.pill),
      ),
      child: Text(
        label,
        style: MBTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: MBTextStyles.caption.copyWith(
          color: MBColors.textSecondary,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: MBTextStyles.caption.copyWith(
              color: MBColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: value,
            style: MBTextStyles.caption.copyWith(
              color: MBColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}