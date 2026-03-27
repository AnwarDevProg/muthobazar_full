import 'package:flutter/material.dart';

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuthoBazar Customer',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text('MuthoBazar Customer'),
        ),
      ),
    );
  }
}
