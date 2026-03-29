import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminAuthShell extends StatelessWidget {
  const AdminAuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.maxWidth = 520,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MBColors.background,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: MBGradients.primaryGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MBSpacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                padding: const EdgeInsets.all(MBSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(MBRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: MBColors.shadow.withValues(alpha: 0.14),
                      blurRadius: 30,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: MBTextStyles.pageTitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    MBSpacing.h(MBSpacing.xs),
                    Text(
                      subtitle,
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.textSecondary,
                      ),
                    ),
                    MBSpacing.h(MBSpacing.xl),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}