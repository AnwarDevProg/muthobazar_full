import 'package:flutter/material.dart';
import '../../../theme/mb_colors.dart';
import '../../../theme/mb_radius.dart';


class MBCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const MBCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MBColors.card,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: MBColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}











