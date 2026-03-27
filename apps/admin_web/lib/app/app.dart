import 'package:flutter/material.dart';

class AdminWebApp extends StatelessWidget {
  const AdminWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuthoBazar Admin Web',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text('MuthoBazar Admin Web'),
        ),
      ),
    );
  }
}













