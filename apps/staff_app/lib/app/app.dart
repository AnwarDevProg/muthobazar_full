import 'package:flutter/material.dart';

class StaffApp extends StatelessWidget {
  const StaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuthoBazar Staff',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text('MuthoBazar Staff'),
        ),
      ),
    );
  }
}
