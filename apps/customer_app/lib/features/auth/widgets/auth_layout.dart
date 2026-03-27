// Auth Layout
// -----------
// Provides common layout for login/register screens.

import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';
import 'auth_card.dart';
import 'auth_header.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool showGuestButton;

  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showGuestButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MBResponsive.isTablet(context);
    final double maxWidth = isTablet ? 520 : 420;

    return Scaffold(
      backgroundColor: MBColors.background,
      body: Column(
        children: [
          AuthHeader(
            title: title,
            subtitle: subtitle,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: MBScreenPadding.page(context),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      AuthCard(child: child),
                      if (showGuestButton) ...[
                        MBSpacing.h(MBSpacing.sectionBreak),
                        TextButton(
                          onPressed: () {
                            Get.offAllNamed(AppRoutes.shell);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: MBColors.primaryOrange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: MBSpacing.sm,
                              vertical: MBSpacing.sm,
                            ),
                          ),
                          child: Text(
                            'Browse as Guest →',
                            style: MBAppText.bodyLarge(context).copyWith(
                              color: MBColors.primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}