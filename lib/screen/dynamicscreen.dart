import 'package:flutter/material.dart';

import '../userScreen/form_screen/formScreen.dart';
import 'dynamicform.dart';
import 'jsonload.dart';

class DynamicFormScreen extends StatefulWidget {
  @override
  _DynamicFormScreenState createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  late Map<dynamic, dynamic> jsonSchema;

  @override
  void initState() {
    super.initState();
    loadSchema();
  }

  Future<void> loadSchema() async {
    var schema = await JsonLoader.loadJsonSchema();
    setState(() {
      jsonSchema = schema;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dynamic Form")),
      body: jsonSchema == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Formscreen(jsonSchema: jsonSchema,),
      ),
    );
  }
}
