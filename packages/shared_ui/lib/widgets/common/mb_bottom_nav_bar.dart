import 'package:flutter/material.dart';

import '../../../theme/mb_colors.dart';
import '../../../theme/mb_gradients.dart';

class MBBottomNavItem {
  final IconData icon;
  final String label;

  const MBBottomNavItem({
    required this.icon,
    required this.label,
  });
}

class MBBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<MBBottomNavItem> items;
  final ValueChanged<int> onTap;

  const MBBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  }) : assert(items.length >= 2 && items.length <= 5);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        decoration: BoxDecoration(
          color: MBColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.75),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: MBColors.shadow.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: MBColors.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final bool selected = currentIndex == index;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.symmetric(
                    vertical: selected ? 5 : 3,
                    horizontal: 6,
                  ),
                  transform: selected
                      ? (Matrix4.identity()..translateByDouble(0.0, -1.5, 0.0, 1.0))
                      : Matrix4.identity(),
                  decoration: BoxDecoration(
                    gradient: selected ? MBGradients.primaryGradient : null,
                    color: selected ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: selected
                        ? Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1,
                    )
                        : null,
                    boxShadow: selected
                        ? [
                      BoxShadow(
                        color: MBColors.primaryOrange.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.12),
                        blurRadius: 2,
                        offset: const Offset(0, -1),
                      ),
                    ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: selected
                            ? Colors.white
                            : MBColors.textSecondary.withValues(alpha: 0.92),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.0,
                          fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? Colors.white
                              : MBColors.textSecondary.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}











