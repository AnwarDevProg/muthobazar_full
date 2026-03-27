import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AdminWebApp());
}

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
      home: const AdminWebShell(),
    );
  }
}







