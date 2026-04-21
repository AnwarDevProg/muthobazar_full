import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:customer_app/app/routes/customer_app_routes.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: true,
      safeBottom: false,
      scrollable: true,
      padding: EdgeInsets.zero,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final suggestedProducts = controller.randomSuggestedProducts;
        final productGrid = MBLayoutGrid.products(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeaderSection(controller: controller),
            Padding(
              padding: MBScreenPadding.pageNoTop(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: _QuickStatsRow(controller: controller),
                  ),
                  MBSpacing.h(MBSpacing.xs),
                  _ProfileActionsCard(controller: controller),
                  MBSpacing.h(MBSpacing.sectionGap(context)),
                  const _SectionTitle(
                    title: 'Suggestions',
                    subtitle: 'Useful shortcuts for your account and shopping.',
                  ),

                  MBSpacing.h(MBSpacing.blockGap(context)),
                  _SuggestionMenuGrid(controller: controller),
                  MBSpacing.h(MBSpacing.sectionGap(context)),
                  const _SectionTitle(
                    title: 'Product Suggestions',
                    subtitle:
                    'Random picks for now. Later we will make this smarter.',
                  ),
                  MBSpacing.h(MBSpacing.blockGap(context)),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: suggestedProducts.length,
                    gridDelegate: MBLayoutGrid.delegate(config: productGrid),
                    itemBuilder: (context, index) {
                      final product = suggestedProducts[index];
                      return _SuggestedProductCard(
                        title: product.title,
                        category: product.category,
                        price: product.price,
                        discountText: product.discountText,
                      );
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 90,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ProfileHeaderSection extends StatelessWidget {
  final ProfileController controller;

  const _ProfileHeaderSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      final bool isGuestUser = user.isGuest;
      final String displayName = isGuestUser
          ? 'Guest User'
          : (user.fullName.trim().isEmpty ? 'User' : user.fullName);
      final String phoneText = isGuestUser
          ? 'Login to access your account features'
          : user.phoneNumber;
      final String image = user.profilePicture;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          MBSpacing.pageHorizontal(context),
          MBSpacing.pageVertical(context),
          MBSpacing.pageHorizontal(context),
          MBSpacing.xl,
        ),
        decoration: const BoxDecoration(
          gradient: MBGradients.headerGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(MBRadius.xl),
            bottomRight: Radius.circular(MBRadius.xl),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MBSpacing.h(MBSpacing.xxxs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90,
                  height: 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.40),
                      width: 1.2,
                    ),
                  ),
                  child: ClipOval(
                    child: image.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (_, __, ___) =>
                      const Icon(Icons.person, size: 42),
                    )
                        : const Icon(Icons.person, size: 42),
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MBSpacing.h(MBSpacing.xs),
                      Text(
                        displayName,
                        style: MBAppText.headline2(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      MBSpacing.h(MBSpacing.xxs),
                      Text(
                        phoneText,
                        style: MBAppText.body(context).copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(MBRadius.pill),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: isGuestUser
                      ? Text(
                    'Guest mode',
                    style: MBAppText.bodySmall(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: Colors.blue,
                      ),
                      MBSpacing.w(MBSpacing.xxs),
                      Text(
                        'Verified',
                        style: MBAppText.bodySmall(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.sm),
          ],
        ),
      );
    });
  }
}

class _QuickStatsRow extends StatelessWidget {
  final ProfileController controller;

  const _QuickStatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isGuest = controller.isGuest;

      return Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.shopping_bag_outlined,
              label: 'Orders',
              value: isGuest ? '0' : '12',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.local_offer_outlined,
              label: 'Coupons',
              value: isGuest ? '0' : '4',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: isGuest
                  ? '0'
                  : controller.user.value.addresses.length.toString(),
            ),
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
      decoration: BoxDecoration(
        color: MBColors.card,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: MBColors.primaryOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(MBRadius.md),
            ),
            child: Icon(
              icon,
              color: MBColors.primaryOrange,
              size: 20,
            ),
          ),
          MBSpacing.h(MBSpacing.xs),
          Text(
            value,
            style: MBAppText.headline3(context).copyWith(
              color: MBColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.xxxs),
          Text(
            label,
            style: MBAppText.bodySmall(context).copyWith(
              color: MBColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionsCard extends StatelessWidget {
  final ProfileController controller;

  const _ProfileActionsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isGuest = controller.isGuest;

      return Container(
        padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
        decoration: BoxDecoration(
          color: MBColors.card,
          borderRadius: BorderRadius.circular(MBRadius.lg),
          boxShadow: [
            BoxShadow(
              color: MBColors.shadow.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
              _ProfileListTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: isGuest
                  ? 'Login to update your name, profile photo, and basic info.'
                  : 'Update your name, profile photo, and basic info.',
                onTap: () async {
                  if (controller.isGuest) {
                    await MBDialogs.showLoginRequired(
                      context,
                      onLoginTap: () async {
                        Get.toNamed(AppRoutes.login);
                      },
                    );
                    return;
                  }
                  Get.toNamed(AppRoutes.editProfile);
                },
            ),
            if (!isGuest) ...[
              const _TileDivider(),
              _ProfileListTile(
                icon: Icons.phone_outlined,
                title: 'Update Phone Number',
                subtitle: 'Requires phone authentication before saving.',
                onTap: () {
                  Get.toNamed(AppRoutes.updatePhone);
                },
              ),
              const _TileDivider(),
              _ProfileListTile(
                icon: Icons.location_on_outlined,
                title: 'My Addresses',
                subtitle: controller.defaultAddressText.isEmpty
                    ? 'Manage your saved delivery addresses.'
                    : controller.defaultAddressText,
                onTap: () {
                  Get.toNamed(AppRoutes.addresses);
                },
              ),
            ],
            const _TileDivider(),
            _ProfileListTile(
              icon: isGuest ? Icons.login_rounded : Icons.logout_rounded,
              title: isGuest ? 'Login' : 'Log Out',
              subtitle: isGuest
                  ? 'Sign in to access your account features.'
                  : 'Sign out from this device.',
              iconColor: isGuest ? MBColors.primaryOrange : MBColors.warning,
              onTap: () async {
                if (controller.isGuest) {
                  Get.toNamed(AppRoutes.login);
                  return;
                }

                final confirmed = await MBDialogs.showConfirm(
                  context: context,
                  title: 'Log Out',
                  message: 'Are you sure you want to log out?',
                  confirmText: 'Log Out',
                  cancelText: 'Cancel',
                  type: MBDialogType.warning,
                  icon: Icons.logout_rounded,
                );

                if (confirmed == true) {
                  await controller.logout();
                }
              },
            ),
            if (!isGuest) ...[
              const _TileDivider(),
              _ProfileListTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently remove your account after confirmation.',
                iconColor: MBColors.error,
                titleColor: MBColors.error,
                onTap: () async {
                  final confirmed = await MBDialogs.showConfirm(
                    context: context,
                    title: 'Delete Account',
                    message:
                    'This action is permanent. Your profile and saved addresses will be removed.',
                    confirmText: 'Continue',
                    cancelText: 'Cancel',
                    type: MBDialogType.danger,
                    icon: Icons.delete_outline_rounded,
                  );

                  if (confirmed == true) {
                    Get.toNamed(AppRoutes.deleteAccountVerify);
                  }
                },
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _SuggestionMenuGrid extends StatelessWidget {
  final ProfileController controller;

  const _SuggestionMenuGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    final items = <_SuggestionItem>[
      const _SuggestionItem(
        icon: Icons.receipt_long_outlined,
        title: 'My Orders',
        subtitle: 'Track and manage orders',
      ),
      const _SuggestionItem(
        icon: Icons.local_offer_outlined,
        title: 'My Coupons',
        subtitle: 'Available offers and rewards',
      ),
      const _SuggestionItem(
        icon: Icons.favorite_border,
        title: 'Wishlist',
        subtitle: 'Saved products',
      ),
      const _SuggestionItem(
        icon: Icons.location_on_outlined,
        title: 'Addresses',
        subtitle: 'Manage delivery locations',
      ),
      const _SuggestionItem(
        icon: Icons.settings_outlined,
        title: 'App Settings',
        subtitle: 'Language, notifications and more',
      ),
      const _SuggestionItem(
        icon: Icons.support_agent_outlined,
        title: 'Help Center',
        subtitle: 'Support and common answers',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.mbValue(
          mobileSmall: 2,
          mobile: 2,
          mobileLarge: 2,
          tablet: 3,
          tabletLarge: 3,
        ),
        mainAxisSpacing: MBSpacing.itemGap(context),
        crossAxisSpacing: MBSpacing.itemGap(context),
        childAspectRatio: context.mbValue(
          mobileSmall: 1.40,
          mobile: 1.45,
          mobileLarge: 1.50,
          tablet: 1.80,
          tabletLarge: 1.85,
        ),
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _SuggestionCard(
          item: item,
          controller: controller,
        );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final _SuggestionItem item;
  final ProfileController controller;

  const _SuggestionCard({
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MBColors.card,
      borderRadius: BorderRadius.circular(MBRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(MBRadius.lg),
        onTap: () async {
          if (controller.isGuest) {
            await MBDialogs.showLoginRequired(
              context,
              onLoginTap: () async {
                Get.toNamed(AppRoutes.login);
              },
            );
            return;
          }


          switch (item.title) {
            case 'My Orders':
              Get.toNamed(AppRoutes.myOrders);
              break;
            case 'My Coupons':
              Get.toNamed(AppRoutes.myCoupons);
              break;
            case 'Wishlist':
              Get.toNamed(AppRoutes.wishlist);
              break;
            case 'Addresses':
              Get.toNamed(AppRoutes.addresses);
              break;
            case 'App Settings':
              Get.toNamed(AppRoutes.appSettings);
              break;
            case 'Help Center':
              Get.toNamed(AppRoutes.helpCenter);
              break;
          }
        },
        child: Ink(
          padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MBRadius.lg),
            boxShadow: [
              BoxShadow(
                color: MBColors.shadow.withValues(alpha: 0.02),
                blurRadius: 1,
                offset: const Offset(6, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: MBGradients.primaryGradient,
                      borderRadius: BorderRadius.circular(MBRadius.md),
                    ),
                    child: Icon(
                      item.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  MBSpacing.w(MBSpacing.sm),
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MBAppText.label(context).copyWith(
                        color: MBColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              MBSpacing.h(MBSpacing.xs),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: MBAppText.bodySmall(context).copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestedProductCard extends StatelessWidget {
  final String title;
  final String category;
  final String price;
  final String discountText;

  const _SuggestedProductCard({
    required this.title,
    required this.category,
    required this.price,
    required this.discountText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MBColors.card,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: MBColors.primaryOrange.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(MBRadius.lg),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 42,
                      color: MBColors.primaryOrange.withValues(alpha: 0.85),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: MBColors.primaryOrange,
                        borderRadius: BorderRadius.circular(MBRadius.pill),
                      ),
                      child: Text(
                        discountText,
                        style: MBAppText.caption(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MBAppText.caption(context).copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MBAppText.body(context).copyWith(
                    color: MBColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                MBSpacing.h(MBSpacing.xs),
                Text(
                  price,
                  style: MBAppText.sectionTitle(context).copyWith(
                    color: MBColors.primaryOrange,
                    fontWeight: FontWeight.w700,
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

class _ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool isEnabled;

  const _ProfileListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final baseIconColor = iconColor ?? MBColors.primaryOrange;
    final baseTitleColor = titleColor ?? MBColors.textPrimary;

    final effectiveIconColor =
    isEnabled ? baseIconColor : baseIconColor.withValues(alpha: 0.40);
    final effectiveTitleColor =
    isEnabled ? baseTitleColor : baseTitleColor.withValues(alpha: 0.40);

    return InkWell(
      borderRadius: BorderRadius.circular(MBRadius.md),
      onTap: isEnabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(MBRadius.md),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: 20,
              ),
            ),
            MBSpacing.w(MBSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MBAppText.label(context).copyWith(
                      color: effectiveTitleColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    subtitle,
                    style: MBAppText.bodySmall(context).copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isEnabled
                  ? MBColors.textMuted
                  : MBColors.textMuted.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: MBColors.divider.withValues(alpha: 0.90),
    );
  }
}




class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MBAppText.headline3(context).copyWith(
            color: MBColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        MBSpacing.h(MBSpacing.xxxs),
        Text(
          subtitle,
          style: MBAppText.bodySmall(context).copyWith(
            color: MBColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SuggestionItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SuggestionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

