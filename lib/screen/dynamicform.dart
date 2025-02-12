import 'package:flutter/material.dart';

class DynamicForm extends StatefulWidget {
  final Map<String, dynamic> jsonSchema;
  const DynamicForm({Key? key, required this.jsonSchema}) : super(key: key);

  @override
  _DynamicFormState createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<dynamic, dynamic> formData = {};

  @override
  void initState() {
    super.initState();
    _initializeDefaults(widget.jsonSchema['properties'], formData);
  }

  /// Recursively initializes default values from the schema
  void _initializeDefaults(Map<dynamic, dynamic>? properties, Map<dynamic, dynamic> data) {
    if (properties == null) return;

    properties.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        if (value.containsKey('default')) {
          data[key] = value['default'];
        } else if (value['type'] == 'object' && value.containsKey('properties')) {
          data[key] = {};
          _initializeDefaults(value['properties'] as Map<String, dynamic>, data[key]);
        } else if (value['type'] == 'array' && value.containsKey('items')) {
          data[key] = [];
        }
      }
    });
  }

  /// Builds a form field based on type
  Widget _buildFormField(String fieldName, Map<String, dynamic> fieldSchema) {
    String type = fieldSchema['type'];

    if (fieldSchema.containsKey('enum')) {
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: fieldName),
        value: formData[fieldName],
        items: List<String>.from(fieldSchema['enum'])
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) => setState(() => formData[fieldName] = val),
      );
    } else if (type == 'string') {
      return TextFormField(
        decoration: InputDecoration(labelText: fieldName),
        initialValue: formData[fieldName] ?? '',
        onSaved: (val) => formData[fieldName] = val,
      );
    } else if (type == 'boolean') {
      return CheckboxListTile(
        title: Text(fieldName),
        value: formData[fieldName] ?? false,
        onChanged: (val) => setState(() => formData[fieldName] = val),
      );
    } else if (type == 'array') {
      return _buildArrayField(fieldName, fieldSchema['items']);
    } else if (type == 'object') {
      return _buildNestedForm(fieldName, fieldSchema['properties']);
    }
    return Container();
  }

  /// Builds nested object fields
  Widget _buildNestedForm(String fieldName, Map<String, dynamic> properties) {
    return ExpansionTile(
      title: Text(fieldName),
      children: properties.keys
          .map((key) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: _buildFormField(key, properties[key]),
      ))
          .toList(),
    );
  }

  /// Builds an array field
  Widget _buildArrayField(String fieldName, Map<String, dynamic> itemSchema) {
    List<dynamic> arrayItems = formData[fieldName] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fieldName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: arrayItems.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormField('$fieldName[$index]', itemSchema),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        arrayItems.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (itemSchema['type'] == 'object') {
                arrayItems.add({});
              } else {
                arrayItems.add('');
              }
            });
          },
          child: Text("Add $fieldName"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> properties = widget.jsonSchema['properties'];

    return Form(
      key: _formKey,
      child: Column(
        children: [
          ...properties.keys
              .map((key) => _buildFormField(key, properties[key]))
              .toList(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                print("Form Data: $formData");
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
