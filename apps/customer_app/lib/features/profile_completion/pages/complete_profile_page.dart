import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MBColors.background,
      appBar: AppBar(
        title: const Text('Complete Profile'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(MBSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your account setup is not complete yet.',
              style: MBTextStyles.h3,
            ),
            const SizedBox(height: MBSpacing.md),
            Text(
              'Please complete your customer profile before entering the app.',
              style: MBTextStyles.body,
            ),
            const SizedBox(height: MBSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to your profile form page
                  // Get.toNamed(AppRoutes.profileSetupForm);
                },
                child: const Text('Complete Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}