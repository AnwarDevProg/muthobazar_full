import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

// MB Home Top Bar
// ----------------
// Notch-aware home top bar for the customer app.
//
// Design goals:
// - No title or subtitle text at the top.
// - Orange top area starts from the very top of the screen.
// - The top background extends behind / includes the notch area.
// - Search bar and notification button render below the notch / status area.
// - Rounded bottom corners to match the current MuthoBazar style.
//
// Usage:
// Replace the old home page top header widget with MBHomeTopBar(
//   searchController: _searchController,
//   onSearchTap: ...,
//   onNotificationTap: ...,
//   notificationCount: 3,
// )
class MBHomeTopBar extends StatelessWidget {
  const MBHomeTopBar({
    super.key,
    this.searchController,
    this.notificationCount = 0,
    this.searchHintText = 'Search products...',
    this.onSearchTap,
    this.onSearchChanged,
    this.onNotificationTap,
    this.margin,
    this.backgroundColor,
  });

  final TextEditingController? searchController;
  final int notificationCount;
  final String searchHintText;
  final VoidCallback? onSearchTap;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onNotificationTap;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;
    final EdgeInsets pagePadding = MBScreenPadding.page(context);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? MBColors.primaryOrange,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          pagePadding.left,
          topInset + MBSpacing.md,
          pagePadding.right,
          MBSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _SearchField(
                controller: searchController,
                hintText: searchHintText,
                onTap: onSearchTap,
                onChanged: onSearchChanged,
              ),
            ),
            MBSpacing.w(MBSpacing.sm),
            _NotificationButton(
              count: notificationCount,
              onTap: onNotificationTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.hintText,
    this.controller,
    this.onTap,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 52,
          padding: EdgeInsets.symmetric(
            horizontal: MBSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 22,
                color: MBColors.textMuted,
              ),
              MBSpacing.w(MBSpacing.sm),
              Expanded(
                child: TextField(
                  controller: controller,
                  onTap: onSearchTapOrNull(onTap),
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hintText,
                    border: InputBorder.none,
                    hintStyle: MBTextStyles.body.copyWith(
                      color: MBColors.textMuted,
                    ),
                  ),
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback? onSearchTapOrNull(VoidCallback? callback) {
    if (callback == null) return null;
    return callback;
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.count,
    this.onTap,
  });

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              if (count > 0)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      textAlign: TextAlign.center,
                      style: MBTextStyles.caption.copyWith(
                        color: MBColors.primaryOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}