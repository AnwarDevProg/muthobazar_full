import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

import '../controllers/admin_profile_controller.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _genderController;
  late final TextEditingController _dobController;
  late final TextEditingController _profilePictureController;

  late final AdminProfileController _controller;
  Worker? _profileWorker;

  @override
  void initState() {
    super.initState();

    _controller = Get.find<AdminProfileController>();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _genderController = TextEditingController();
    _dobController = TextEditingController();
    _profilePictureController = TextEditingController();

    _syncControllers(_controller.currentUser.value);

    _profileWorker = ever(_controller.currentUser, (user) {
      _syncControllers(user);
    });
  }

  void _syncControllers(dynamic user) {
    if (user == null) return;

    _firstNameController.text = (user.firstName ?? '').toString();
    _lastNameController.text = (user.lastName ?? '').toString();
    _emailController.text = (user.email ?? '').toString();
    _phoneController.text = (user.phoneNumber ?? '').toString();
    _genderController.text = (user.gender ?? '').toString();
    _dobController.text = (user.dateOfBirth ?? '').toString();
    _profilePictureController.text = (user.profilePicture ?? '').toString();
  }

  @override
  void dispose() {
    _profileWorker?.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _profilePictureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      child: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final user = _controller.currentUser.value;

        if (user == null) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(MBSpacing.xl),
            child: MBCard(
              child: Text(
                'Admin profile not found.',
                style: MBTextStyles.body.copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(MBSpacing.xl),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfilePageHeader(
                      title: 'My Profile',
                      subtitle:
                      'Update your personal information and profile picture.',
                    ),
                    MBSpacing.h(MBSpacing.xl),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final bool stacked = constraints.maxWidth < 1000;

                        if (stacked) {
                          return Column(
                            children: [
                              _ProfileSummaryCard(
                                user: user,
                                controller: _controller,
                              ),
                              MBSpacing.h(MBSpacing.lg),
                              _ProfileFormCard(
                                formKey: _formKey,
                                controller: _controller,
                                firstNameController: _firstNameController,
                                lastNameController: _lastNameController,
                                emailController: _emailController,
                                phoneController: _phoneController,
                                genderController: _genderController,
                                dobController: _dobController,
                                profilePictureController:
                                _profilePictureController,
                                onSubmit: _submit,
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: _ProfileSummaryCard(
                                user: user,
                                controller: _controller,
                              ),
                            ),
                            MBSpacing.w(MBSpacing.xl),
                            Expanded(
                              flex: 8,
                              child: _ProfileFormCard(
                                formKey: _formKey,
                                controller: _controller,
                                firstNameController: _firstNameController,
                                lastNameController: _lastNameController,
                                emailController: _emailController,
                                phoneController: _phoneController,
                                genderController: _genderController,
                                dobController: _dobController,
                                profilePictureController:
                                _profilePictureController,
                                onSubmit: _submit,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await _controller.updateProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      gender: _genderController.text,
      dateOfBirth: _dobController.text,
      profilePicture: _profilePictureController.text,
    );
  }
}

class _ProfilePageHeader extends StatelessWidget {
  const _ProfilePageHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MBTextStyles.sectionTitle.copyWith(
            fontWeight: FontWeight.w700,
            color: MBColors.textPrimary,
          ),
        ),
        MBSpacing.h(MBSpacing.xxxs),
        Text(
          subtitle,
          style: MBTextStyles.body.copyWith(
            color: MBColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.user,
    required this.controller,
  });

  final dynamic user;
  final AdminProfileController controller;

  @override
  Widget build(BuildContext context) {
    final String picture = (user.profilePicture ?? '').toString().trim();
    final String displayName = (user.displayNameForAdmin ?? '')
        .toString()
        .trim()
        .isNotEmpty
        ? user.displayNameForAdmin.toString().trim()
        : controller.displayNameForShell;
    final String email = (user.email ?? '').toString().trim();
    final String prettyRole = (user.prettyRole ?? '')
        .toString()
        .trim()
        .isNotEmpty
        ? user.prettyRole.toString().trim()
        : controller.displayRoleForShell;
    final String initials = (user.initials ?? '').toString().trim().isNotEmpty
        ? user.initials.toString().trim()
        : controller.initials;

    return MBCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: MBColors.primarySoft,
            backgroundImage: picture.isNotEmpty ? NetworkImage(picture) : null,
            child: picture.isEmpty
                ? Text(
              initials,
              style: MBTextStyles.sectionTitle.copyWith(
                color: MBColors.primaryOrange,
                fontWeight: FontWeight.w700,
              ),
            )
                : null,
          ),
          MBSpacing.h(MBSpacing.md),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: MBTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.xxxs),
          Text(
            email.isEmpty ? 'No email' : email,
            textAlign: TextAlign.center,
            style: MBTextStyles.body.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
          MBSpacing.h(MBSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MBSpacing.md,
              vertical: MBSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: MBColors.primaryOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(MBRadius.lg),
            ),
            child: Text(
              prettyRole,
              style: MBTextStyles.caption.copyWith(
                color: MBColors.primaryOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          MBSpacing.h(MBSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(MBSpacing.md),
            decoration: BoxDecoration(
              color: MBColors.background,
              borderRadius: BorderRadius.circular(MBRadius.lg),
              border: Border.all(
                color: MBColors.border.withValues(alpha: 0.85),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileInfoRow(
                  label: 'UID',
                  value: controller.currentUid.isEmpty
                      ? '-'
                      : controller.currentUid,
                ),
                MBSpacing.h(MBSpacing.sm),
                _ProfileInfoRow(
                  label: 'Role',
                  value: controller.displayRoleForShell,
                ),
                MBSpacing.h(MBSpacing.sm),
                _ProfileInfoRow(
                  label: 'Email',
                  value: controller.displayEmailForShell,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFormCard extends StatelessWidget {
  const _ProfileFormCard({
    required this.formKey,
    required this.controller,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.genderController,
    required this.dobController,
    required this.profilePictureController,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final AdminProfileController controller;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController genderController;
  final TextEditingController dobController;
  final TextEditingController profilePictureController;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return MBCard(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: MBTextField(
                    controller: firstNameController,
                    labelText: 'First Name',
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Enter first name';
                      }
                      return null;
                    },
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: MBTextField(
                    controller: lastNameController,
                    labelText: 'Last Name',
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                Expanded(
                  child: MBTextField(
                    controller: emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: MBTextField(
                    controller: phoneController,
                    labelText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                Expanded(
                  child: MBTextField(
                    controller: genderController,
                    labelText: 'Gender',
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: MBTextField(
                    controller: dobController,
                    labelText: 'Date of Birth',
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            MBTextField(
              controller: profilePictureController,
              labelText: 'Profile Picture URL',
            ),
            MBSpacing.h(MBSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 190,
                child: MBPrimaryButton(
                  text: 'Update Profile',
                  isLoading: controller.isSaving.value,
                  onPressed: () async => onSubmit(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: MBTextStyles.caption.copyWith(
              color: MBColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: MBTextStyles.body.copyWith(
              color: MBColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}