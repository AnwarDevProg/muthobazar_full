import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

// MB Home Category Section
// ------------------------
// Styled to match the old approved MuthoBazar horizontal category strip.

class MBHomeCategoryGridSection extends StatelessWidget {
  final MBHomeSection section;
  final List<MBCategory> categories;
  final void Function(MBCategory category)? onCategoryTap;

  const MBHomeCategoryGridSection({
    super.key,
    required this.section,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MBSectionTitle(
          title: section.titleEn.isNotEmpty ? section.titleEn : 'Categories',
          actionText: section.showViewAll ? 'See All' : null,
        ),
        MBSpacing.h(MBSpacing.xs),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => MBSpacing.w(MBSpacing.sm),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryItem(
                title: category.nameEn,
                imageUrl: category.iconUrl.isNotEmpty
                    ? category.iconUrl
                    : category.imageUrl,
                onTap: () => onCategoryTap?.call(category),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback? onTap;

  const _CategoryItem({
    required this.title,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: MBColors.card,
                borderRadius: BorderRadius.circular(MBRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: MBColors.shadow.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(MBRadius.lg),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.grid_view_rounded,
                      color: MBColors.primaryOrange,
                      size: 26,
                    );
                  },
                ),
              ),
            ),
            MBSpacing.h(MBSpacing.xs),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: MBAppText.caption(context).copyWith(
                    color: MBColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}