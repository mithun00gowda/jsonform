import 'package:flutter/material.dart';
import 'package:json_form_app/screen/dynamicscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DynamicFormScreen(),
    );
  }
}
