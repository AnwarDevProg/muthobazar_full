import 'package:admin_web/app/bindings/admin_web_binding.dart';
import 'package:admin_web/app/routes/admin_web_pages.dart';
import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/shell/admin_shell_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminWebApp extends StatelessWidget {
  const AdminWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MuthoBazar Admin',
      debugShowCheckedModeBanner: false,

      theme: MBTheme.theme,
      darkTheme: MBTheme.theme,
      themeMode: ThemeMode.light,

      initialBinding: AdminWebBinding(),
      initialRoute: AdminWebRoutes.launch,
      getPages: AdminWebPages.pages,

      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 180),

      builder: (context, child) {
        return _GlobalKeyboardWrapper(
          child: Scaffold(
            backgroundColor: MBColors.background,
            body: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

class _GlobalKeyboardWrapper extends StatefulWidget {
  const _GlobalKeyboardWrapper({
    required this.child,
  });

  final Widget child;

  @override
  State<_GlobalKeyboardWrapper> createState() =>
      _GlobalKeyboardWrapperState();
}

class _GlobalKeyboardWrapperState extends State<_GlobalKeyboardWrapper> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Ensure focus is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: widget.child,
    );
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    final bool isCtrlPressed =
        event.isControlPressed || event.isMetaPressed;

    // 🔥 CTRL + K → Command Palette
    if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyK) {
      if (Get.isRegistered<AdminShellStateController>()) {
        final controller = Get.find<AdminShellStateController>();
        controller.openCommandPalette();
      }
    }

    // 🔥 ESC → Close palette
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (Get.isRegistered<AdminShellStateController>()) {
        final controller = Get.find<AdminShellStateController>();
        controller.closeCommandPalette();
      }
    }
  }
}