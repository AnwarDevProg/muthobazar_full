import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/mb_size_tokens.dart';
import '../../../core/layout/mb_app_layout.dart';
import '../../../core/layout/mb_screen_padding.dart';
import '../../../core/responsive/mb_responsive.dart';
import '../../../core/responsive/mb_spacing.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/typography/mb_app_text.dart';
import '../../../core/widgets/common/mb_primary_button.dart';
import '../../../core/widgets/common/mb_secondary_button.dart';
import '../../../theme/mb_colors.dart';
import '../../../theme/mb_gradients.dart';
import '../../../theme/mb_radius.dart';
import '../../admin/repositories/admin_setup_repository.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MBResponsive.isTablet(context);

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: true,
      safeBottom: true,
      scrollable: true,
      sliverMode: false,
      padding: EdgeInsets.zero,
      header: _TopHeroSection(isTablet: isTablet),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 520 : double.infinity,
          ),
          child: Padding(
            padding: MBScreenPadding.page(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MBSpacing.h(MBSpacing.md),
                Text(
                  'Welcome to MuthoBazar',
                  style: MBAppText.headline1(context).copyWith(
                    color: MBColors.textPrimary,
                  ),
                ),
                MBSpacing.h(MBSpacing.sm),
                Text(
                  kIsWeb
                      ? 'This web portal is intended for admin-side access. Login with your admin account, register a new admin account, or temporarily create the first super admin.'
                      : 'Shop smart, discover great products, and enjoy a clean marketplace experience designed for speed and comfort.',
                  style: MBAppText.body(context).copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxl),
                MBPrimaryButton(
                  text: 'Login',
                  onPressed: () {
                    Get.toNamed(AppRoutes.login);
                  },
                ),
                MBSpacing.h(MBSpacing.md),
                MBSecondaryButton(
                  text: 'Register',
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.register,
                      arguments: {
                        'isSuperAdmin': false,
                        'role': 'admin',
                      },
                    );
                  },
                ),
                MBSpacing.h(MBSpacing.md),
                const _RegisterSuperAdminButton(),
                if (!kIsWeb) ...[
                  MBSpacing.h(MBSpacing.xs),
                  _GuestButton(
                    onTap: () {
                      Get.offNamed(AppRoutes.shell);
                    },
                  ),
                ],
                MBSpacing.h(MBSpacing.sectionBreak),
                _InfoCard(isTablet: isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterSuperAdminButton extends StatelessWidget {
  const _RegisterSuperAdminButton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MBPrimaryButton(
          text: 'Register Super Admin',
          onPressed: () {
            Get.toNamed(
              AppRoutes.register,
              arguments: {
                'isSuperAdmin': true,
                'role': 'super_admin',
                'bootstrapSuperAdmin': true,
              },
            );
          },
        ),
        MBSpacing.h(MBSpacing.xs),
        Text(
          'Temporary setup button. Later this will be removed.',
          textAlign: TextAlign.center,
          style: MBAppText.body(context).copyWith(
            color: MBColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TopHeroSection extends StatelessWidget {
  final bool isTablet;

  const _TopHeroSection({
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isTablet ? 280 : 240,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: MBGradients.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(MBRadius.xl),
          bottomRight: Radius.circular(MBRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                MBSpacing.md,
                MBSpacing.lg,
                MBSpacing.md,
                MBSpacing.md,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: isTablet ? 76 : 68,
                      height: isTablet ? 76 : 68,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(MBRadius.lg),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: MBSizeTokens.iconXl(context),
                      ),
                    ),
                    MBSpacing.h(MBSpacing.lg),
                    Text(
                      kIsWeb
                          ? 'Admin access,\nright at your fingertips'
                          : 'Everything you need,\nright at your fingertips',
                      textAlign: TextAlign.center,
                      style: MBAppText.display(context).copyWith(
                        color: MBColors.textOnPrimary,
                        fontSize: isTablet ? 32 : 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    MBSpacing.h(MBSpacing.xs),
                    Text(
                      kIsWeb
                          ? 'Secure.   Controlled.   Admin Ready.'
                          : 'Fast.   Secure.   Trusted.',
                      textAlign: TextAlign.center,
                      style: MBAppText.bodyLarge(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
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
}

class _GuestButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GuestButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: MBColors.primaryOrange,
          padding: const EdgeInsets.symmetric(
            horizontal: MBSpacing.md,
            vertical: MBSpacing.sm,
          ),
        ),
        child: Text(
          'Browse as Guest',
          style: MBAppText.bodyLarge(context).copyWith(
            color: MBColors.primaryOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool isTablet;

  const _InfoCard({
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final infoText = kIsWeb
        ? 'Use Login for existing admin accounts, Register for a new admin account, or Register Super Admin only for first-time bootstrap. After bootstrap, user role and permissions must still be validated before admin dashboard access is granted.'
        : 'Log in for your personal experience, register to create an account, or continue as a guest to browse products right away.';

    return Container(
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: MBColors.surface,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: MBColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? 52 : 46,
            height: isTablet ? 52 : 46,
            decoration: BoxDecoration(
              color: MBColors.primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(MBRadius.md),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: MBColors.primaryOrange,
            ),
          ),
          const SizedBox(width: MBSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kIsWeb ? 'Admin access flow' : 'Start exploring instantly',
                  style: MBAppText.sectionTitle(context).copyWith(
                    color: MBColors.textPrimary,
                  ),
                ),
                MBSpacing.h(MBSpacing.xs),
                Text(
                  infoText,
                  style: MBAppText.body(context).copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}