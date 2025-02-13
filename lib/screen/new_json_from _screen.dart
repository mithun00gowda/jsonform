import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'newformwidget.dart';

class NewJsonFromScreen extends StatefulWidget {
  const NewJsonFromScreen({super.key});

  @override
  State<NewJsonFromScreen> createState() => _NewJsonFromScreenState();
}

class _NewJsonFromScreenState extends State<NewJsonFromScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _imageBase64 = {}; // Store images in Base64 format
  final Map<String, dynamic> _formData = {};
  var jsonSchema_list;
  String? select_json;
  var jsonSchema;
  var tempjson = {};
  int i = 0;

  @override
  void initState() {
    super.initState();
     _loadSchema();
  }
  Future<void> _loadSchema() async {
    String jsonString = await rootBundle.loadString('assets/castecertificateSchema.json');
    setState(() {
      jsonSchema = json.decode(jsonString);
    });
    print(jsonSchema);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: JsonFormWidget(jsonSchema: jsonSchema),
        ),
      ),
    );
  }
}
