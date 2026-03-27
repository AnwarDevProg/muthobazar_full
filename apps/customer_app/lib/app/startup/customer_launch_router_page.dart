import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_ui/shared_ui.dart';

class AppLaunchRouterPage extends StatefulWidget {
  const AppLaunchRouterPage({super.key});

  @override
  State<AppLaunchRouterPage> createState() => _AppLaunchRouterPageState();
}

class _AppLaunchRouterPageState extends State<AppLaunchRouterPage> {
  @override
  void initState() {
    super.initState();
    _routeApp();
  }

  Future<void> _routeApp() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final bool requiresUpdate = await _checkForceUpdate();

    if (!mounted) return;

    if (requiresUpdate) {
      Get.offAllNamed(AppRoutes.forceUpdate);
      return;
    }

    final bool isFirstRun = StorageService.isFirstRun;
    if (isFirstRun) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    final bool isLoggedIn = AuthService.isLoggedIn;
    if (!isLoggedIn) {
      Get.offAllNamed(AppRoutes.welcome);
      return;
    }

    Get.offAllNamed(AppRoutes.shell);
  }

  Future<bool> _checkForceUpdate() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MBColors.background,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: MBGradients.headerGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(MBSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: MBSpacing.xl),
                Text(
                  'MuthoBazar',
                  style: MBTextStyles.hero.copyWith(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: MBSpacing.sm),
                Text(
                  'Smart shopping, simplified.',
                  style: MBTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                const Spacer(),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: MBSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


