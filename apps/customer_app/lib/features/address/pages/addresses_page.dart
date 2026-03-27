import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:shared_models/shared_models.dart';
import '../controllers/address_controller.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AddressController controller = Get.find<AddressController>();

    return MBAppLayout(
      backgroundColor: MBColors.background,
      padding: EdgeInsets.zero,
      appBar: AppBar(
        title: Text(
          'My Addresses',
          style: MBAppText.sectionTitle(context),
        ),
      ),
      child: Obx(() {
        final bool isBusy = controller.isAddressProcessing.value;

        return Stack(
          children: [
            AbsorbPointer(
              absorbing: isBusy,
              child: Padding(
                padding: MBScreenPadding.page(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MBPrimaryButton(
                      text: 'Add New Address',
                      onPressed: () => Get.toNamed(AppRoutes.addAddress),
                      prefixIcon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    MBSpacing.h(MBSpacing.sectionGap(context)),
                    Obx(() {
                      final addresses = controller.addresses;

                      if (addresses.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(
                            MBSpacing.cardPadding(context),
                          ),
                          decoration: BoxDecoration(
                            color: MBColors.card,
                            borderRadius: BorderRadius.circular(MBRadius.lg),
                          ),
                          child: Text(
                            'No address added yet.',
                            style: MBAppText.body(context).copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        );
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          key: ValueKey(
                            addresses
                                .map((e) => '${e.id}-${e.isDefault}')
                                .join('|'),
                          ),
                          children: addresses
                              .map(
                                (address) => Padding(
                              key: ValueKey(address.id),
                              padding: EdgeInsets.only(
                                bottom: MBSpacing.itemGap(context),
                              ),
                              child: _AddressCard(
                                address: address,
                                onSetDefault: () => controller
                                    .setDefaultAddressWithDelay(address.id),
                                onEdit: () => Get.toNamed(
                                  AppRoutes.editAddress,
                                  arguments: address,
                                ),
                                onDelete: () async {
                                  final confirmed =
                                  await MBDialogs.showConfirm(
                                    context: context,
                                    title: 'Delete Address',
                                    message:
                                    'Are you sure you want to delete this address?',
                                    confirmText: 'Delete',
                                    cancelText: 'Cancel',
                                    type: MBDialogType.danger,
                                    icon: Icons.delete_outline_rounded,
                                  );

                                  if (confirmed == true) {
                                    await controller
                                        .deleteAddressWithDelay(address.id);
                                  }
                                },
                              ),
                            ),
                          )
                              .toList(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            if (isBusy)
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
                    child: Container(
                      color: MBColors.background.withValues(alpha: 0.18),
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: MBSpacing.pageHorizontal(context),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: MBSpacing.lg,
                          vertical: MBSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(MBRadius.xl),
                          boxShadow: [
                            BoxShadow(
                              color: MBColors.shadow.withValues(alpha: 0.10),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                color: MBColors.primaryOrange,
                              ),
                            ),
                            MBSpacing.h(MBSpacing.sm),
                            Text(
                              'Please wait...',
                              style: MBAppText.label(context).copyWith(
                                color: MBColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            MBSpacing.h(MBSpacing.xxs),
                            Text(
                              controller.addressProcessingMessage.value.isNotEmpty
                                  ? controller.addressProcessingMessage.value
                                  : 'Updating your address settings...',
                              textAlign: TextAlign.center,
                              style: MBAppText.bodySmall(context).copyWith(
                                color: MBColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final UserAddressModel address;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  String get _displayLabel {
    switch (address.label.trim().toLowerCase()) {
      case 'home':
        return 'Home Address';
      case 'office':
        return 'Office Address';
      default:
        return 'Other Address';
    }
  }

  Widget _divider() {
    return Container(
      width: double.infinity,
      height: 1.2,
      decoration: BoxDecoration(
        color: MBColors.divider.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.04),
            blurRadius: 1.5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      BuildContext context, {
        required String title,
        required String value,
        bool multiline = false,
      }) {
    return Row(
      crossAxisAlignment:
      multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            title,
            style: MBAppText.caption(context).copyWith(
              color: MBColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          ':',
          style: MBAppText.caption(context).copyWith(
            color: MBColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        MBSpacing.w(MBSpacing.xs),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            softWrap: true,
            maxLines: multiline ? 4 : 1,
            overflow: multiline ? TextOverflow.visible : TextOverflow.ellipsis,
            style: MBAppText.bodySmall(context).copyWith(
              color: MBColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: multiline ? 1.40 : 1.22,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: MBColors.card,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        border: Border.all(
          color: address.isDefault
              ? MBColors.primaryOrange.withValues(alpha: 0.20)
              : MBColors.divider.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: MBGradients.primaryGradient,
                    borderRadius: BorderRadius.circular(MBRadius.pill),
                  ),
                  child: Text(
                    _displayLabel,
                    style: MBAppText.caption(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                MBSpacing.h(MBSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(MBRadius.lg),
                    border: Border.all(
                      color: MBColors.divider.withValues(alpha: 0.78),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.88),
                        blurRadius: 0,
                        offset: const Offset(-1, -1),
                      ),
                      BoxShadow(
                        color: MBColors.shadow.withValues(alpha: 0.09),
                        blurRadius: 10,
                        offset: const Offset(2, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        context,
                        title: 'Name',
                        value: address.fullName,
                      ),
                      MBSpacing.h(6),
                      _divider(),
                      MBSpacing.h(6),
                      _infoRow(
                        context,
                        title: 'Number',
                        value: address.phoneNumber,
                      ),
                      MBSpacing.h(6),
                      _divider(),
                      MBSpacing.h(6),
                      _infoRow(
                        context,
                        title: 'Full Address',
                        value: address.fullAddress,
                        multiline: true,
                      ),
                    ],
                  ),
                ),
                MBSpacing.h(MBSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 16,
                        ),
                        label: Text(
                          'Edit',
                          style: MBAppText.bodySmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide(
                            color:
                            MBColors.primaryOrange.withValues(alpha: 0.40),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(MBRadius.lg),
                          ),
                        ),
                      ),
                    ),
                    MBSpacing.w(MBSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 16,
                        ),
                        label: Text(
                          'Delete',
                          style: MBAppText.bodySmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: Colors.redAccent,
                          side: BorderSide(
                            color: Colors.redAccent.withValues(alpha: 0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(MBRadius.lg),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: address.isDefault
                ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: MBColors.primaryOrange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(MBRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Default',
                    style: MBAppText.caption(context).copyWith(
                      color: MBColors.primaryOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
                : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(MBRadius.pill),
                onTap: onSetDefault,
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: MBColors.primaryOrange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(MBRadius.pill),
                    border: Border.all(
                      color:
                      MBColors.primaryOrange.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    'Set Default',
                    style: MBAppText.caption(context).copyWith(
                      color: MBColors.primaryOrange,
                      fontWeight: FontWeight.w700,
                    ),
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

