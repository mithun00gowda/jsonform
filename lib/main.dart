import 'package:flutter/material.dart';
import 'package:json_form_app/screen/new_json_from%20_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'JSON Schema Form',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: NewJsonFromScreen(),
      );
  }
}
