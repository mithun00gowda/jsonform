import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../blocs/form_bloc.dart';
import '../blocs/form_event.dart';
import '../widgets/json_form_builder.dart';

class FormScreen extends StatefulWidget {
  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic>? jsonSchema;

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
      appBar: AppBar(title: Text("Fill Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: jsonSchema == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              child: Container(
                child: Column(
                          children: [
                // JsonFormBuilder(
                //   schema: jsonSchema!,
                //   formKey: _formKey,
                // ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final formData = _formKey.currentState?.value;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewScreen(formData: formData!),
                        ),
                      );
                    }
                  },
                  child: Text("Review"),
                ),
                          ],
                        ),
              ),
            ),
      ),
    );
  }
}

class ReviewScreen extends StatelessWidget {
  final Map<String, dynamic> formData;

  ReviewScreen({required this.formData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Review Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: formData.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value.toString()),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final formBloc = context.read<FormBloc>();
                formBloc.add(SubmitForm(formData));
                Navigator.pop(context);
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
