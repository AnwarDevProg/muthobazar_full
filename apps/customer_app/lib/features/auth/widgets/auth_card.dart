// Auth Card Widget
// ----------------

import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';



class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
      decoration: BoxDecoration(
        color: MBColors.surface,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: MBColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}