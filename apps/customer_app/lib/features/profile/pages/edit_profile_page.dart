import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileController controller = Get.find<ProfileController>();

  late final TextEditingController fullNameController;
  late final TextEditingController emailController;
  late final TextEditingController dobController;

  late String _initialFullName;
  late String _initialEmail;
  late String _initialGender;
  late String _initialDob;

  late String _selectedGender;

  bool get _hasChanges {
    final currentFullName =
    fullNameController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final currentEmail = emailController.text.trim();
    final currentDob = dobController.text.trim();
    final currentGender = _selectedGender.trim();

    return currentFullName != _initialFullName ||
        currentEmail != _initialEmail ||
        currentGender != _initialGender ||
        currentDob != _initialDob;
  }

  bool get _isFormValid {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();

    if (fullName.isEmpty) return false;

    if (email.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return false;
    }

    return true;
  }

  bool get _canUpdate {
    return _hasChanges && _isFormValid && !controller.isSaving.value;
  }

  @override
  void initState() {
    super.initState();

    _initialFullName =
        controller.fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    _initialEmail = controller.user.value.email.trim();
    _initialGender = controller.user.value.gender.trim();
    _initialDob = controller.user.value.dateOfBirth.trim();

    _selectedGender = _initialGender;

    fullNameController = TextEditingController(text: _initialFullName);
    emailController = TextEditingController(text: _initialEmail);
    dobController = TextEditingController(text: _initialDob);

    fullNameController.addListener(_refreshFormState);
    emailController.addListener(_refreshFormState);
    dobController.addListener(_refreshFormState);
  }

  void _refreshFormState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    fullNameController.removeListener(_refreshFormState);
    emailController.removeListener(_refreshFormState);
    dobController.removeListener(_refreshFormState);

    fullNameController.dispose();
    emailController.dispose();
    dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    if (controller.isSaving.value) return;

    DateTime initialDate = DateTime(2000, 1, 1);

    if (dobController.text.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(dobController.text.trim());
      if (parsed != null) {
        initialDate = parsed;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: MBColors.primaryOrange,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    final formatted =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';

    dobController.text = formatted;
    setState(() {});
  }

  Future<void> _submitUpdate() async {
    if (!_canUpdate) return;

    await controller.updateProfileInfo(
      fullName: fullNameController.text,
      email: emailController.text,
      gender: _selectedGender,
      dateOfBirth: dobController.text,
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: MBColors.card,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MBRadius.lg),
        borderSide: BorderSide(
          color: MBColors.divider.withValues(alpha: 0.90),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MBRadius.lg),
        borderSide: BorderSide(
          color: MBColors.divider.withValues(alpha: 0.90),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MBRadius.lg),
        borderSide: const BorderSide(
          color: MBColors.primaryOrange,
          width: 1.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MBAppLayout(
      backgroundColor: MBColors.background,
      padding: EdgeInsets.zero,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: MBAppText.sectionTitle(context),
        ),
      ),
      child: Obx(() {
        final bool isBusy = controller.isSaving.value;

        return Stack(
          children: [
            AbsorbPointer(
              absorbing: isBusy,
              child: Padding(
                padding: MBScreenPadding.page(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 132,
                                height: 132,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: MBColors.primaryOrange.withValues(
                                    alpha: 0.12,
                                  ),
                                  border: Border.all(
                                    color: MBColors.primaryOrange.withValues(
                                      alpha: 0.18,
                                    ),
                                    width: 1.4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: MBColors.shadow.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: controller.profilePicture.isNotEmpty
                                      ? CachedNetworkImage(
                                    imageUrl: controller.profilePicture,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 52,
                                      color: MBColors.primaryOrange,
                                    ),
                                  )
                                      : const Icon(
                                    Icons.person,
                                    size: 52,
                                    color: MBColors.primaryOrange,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: InkWell(
                                  borderRadius:
                                  BorderRadius.circular(MBRadius.pill),
                                  onTap: isBusy
                                      ? null
                                      : controller.pickAndUploadProfilePhoto,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: MBGradients.primaryGradient,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: MBColors.shadow.withValues(
                                            alpha: 0.10,
                                          ),
                                          blurRadius: 14,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          MBSpacing.h(MBSpacing.md),
                          Text(
                            'Profile picture',
                            style: MBAppText.label(context).copyWith(
                              color: MBColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          MBSpacing.h(MBSpacing.xxxs),
                          Text(
                            'Tap the edit button to upload or change your photo.',
                            textAlign: TextAlign.center,
                            style: MBAppText.bodySmall(context).copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MBSpacing.h(MBSpacing.sectionGap(context)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
                      decoration: BoxDecoration(
                        color: MBColors.card,
                        borderRadius: BorderRadius.circular(MBRadius.xl),
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
                          Text(
                            'Personal Information',
                            style: MBAppText.headline3(context).copyWith(
                              color: MBColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          MBSpacing.h(MBSpacing.xxxs),
                          Text(
                            'Update your personal details below. Only changed information will be saved.',
                            style: MBAppText.bodySmall(context).copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                          MBSpacing.h(MBSpacing.sectionGap(context)),
                          Text(
                            'Full Name',
                            style: MBAppText.label(context).copyWith(
                              color: MBColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          MBSpacing.h(MBSpacing.xs),
                          TextField(
                            controller: fullNameController,
                            textInputAction: TextInputAction.next,
                            decoration: _fieldDecoration(
                              hintText: 'Enter your full name',
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                          ),
                          MBSpacing.h(MBSpacing.lg),
                          Text(
                            'Email',
                            style: MBAppText.label(context).copyWith(
                              color: MBColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          MBSpacing.h(MBSpacing.xs),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _fieldDecoration(
                              hintText: 'Enter your email',
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                          ),
                          MBSpacing.h(MBSpacing.lg),
                          Text(
                            'Gender',
                            style: MBAppText.label(context).copyWith(
                              color: MBColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          MBSpacing.h(MBSpacing.xs),
                          DropdownButtonFormField<String>(
                            initialValue:
                            _selectedGender.isEmpty ? null : _selectedGender,
                            decoration: _fieldDecoration(
                              hintText: 'Select gender',
                              prefixIcon: const Icon(Icons.wc_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),

                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value ?? '';
                              });
                            },
                          ),
                          MBSpacing.h(MBSpacing.lg),
                          Text(
                            'Date of Birth',
                            style: MBAppText.label(context).copyWith(
                              color: MBColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          MBSpacing.h(MBSpacing.xs),
                          TextField(
                            controller: dobController,
                            readOnly: true,
                            onTap: _pickDateOfBirth,
                            decoration: _fieldDecoration(
                              hintText: 'Select your date of birth',
                              prefixIcon:
                              const Icon(Icons.calendar_today_outlined),
                              suffixIcon:
                              const Icon(Icons.chevron_right_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                    MBSpacing.h(MBSpacing.sectionGap(context)),
                    MBPrimaryButton(
                      text: isBusy ? 'Updating...' : 'Update Info',
                      onPressed: _canUpdate ? _submitUpdate : null,
                    ),
                    MBSpacing.h(MBSpacing.md),
                    Text(
                      'Phone number update is available from the separate secure phone verification page.',
                      style: MBAppText.bodySmall(context).copyWith(
                        color: MBColors.textSecondary,
                      ),
                    ),
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
                      color: MBColors.background.withValues(alpha: 0.16),
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
                          color: Colors.white.withValues(alpha: 0.92),
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
                              controller.savingMessage.value.isNotEmpty
                                  ? controller.savingMessage.value
                                  : 'Please wait while we process your request.',
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

