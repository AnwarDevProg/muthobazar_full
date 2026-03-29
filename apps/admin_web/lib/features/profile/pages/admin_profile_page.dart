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

    ever(_controller.currentUser, (user) {
      if (user == null) return;
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _genderController.text = user.gender;
      _dobController.text = user.dateOfBirth;
      _profilePictureController.text = user.profilePicture;
    });
  }

  @override
  void dispose() {
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
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final user = _controller.currentUser.value;

      if (user == null) {
        return SingleChildScrollView(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: MBTextStyles.sectionTitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              MBSpacing.h(MBSpacing.xxs),
              Text(
                'Update your personal information and profile picture.',
                style: MBTextStyles.body.copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
              MBSpacing.h(MBSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: MBCard(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: MBColors.primarySoft,
                            backgroundImage:
                            user.profilePicture.trim().isNotEmpty
                                ? NetworkImage(user.profilePicture)
                                : null,
                            child: user.profilePicture.trim().isEmpty
                                ? Text(
                              user.initials,
                              style: MBTextStyles.sectionTitle.copyWith(
                                color: MBColors.primaryOrange,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                                : null,
                          ),
                          MBSpacing.h(MBSpacing.md),
                          Text(
                            user.displayNameForAdmin,
                            style: MBTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          MBSpacing.h(MBSpacing.xxxs),
                          Text(
                            user.email.isEmpty ? 'No email' : user.email,
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
                              user.prettyRole,
                              style: MBTextStyles.caption.copyWith(
                                color: MBColors.primaryOrange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  MBSpacing.w(MBSpacing.xl),
                  Expanded(
                    flex: 8,
                    child: MBCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: MBTextField(
                                    controller: _firstNameController,
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
                                    controller: _lastNameController,
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
                                    controller: _emailController,
                                    labelText: 'Email',
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                                MBSpacing.w(MBSpacing.md),
                                Expanded(
                                  child: MBTextField(
                                    controller: _phoneController,
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
                                    controller: _genderController,
                                    labelText: 'Gender',
                                  ),
                                ),
                                MBSpacing.w(MBSpacing.md),
                                Expanded(
                                  child: MBTextField(
                                    controller: _dobController,
                                    labelText: 'Date of Birth',
                                  ),
                                ),
                              ],
                            ),
                            MBSpacing.h(MBSpacing.md),
                            MBTextField(
                              controller: _profilePictureController,
                              labelText: 'Profile Picture URL',
                            ),
                            MBSpacing.h(MBSpacing.lg),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 180,
                                child: MBPrimaryButton(
                                  text: 'Update Profile',
                                  isLoading: _controller.isSaving.value,
                                  onPressed: _submit,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
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