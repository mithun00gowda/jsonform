import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/form_bloc.dart';
import '../blocs/form_state.dart';

class PreviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("JSON-LD Output")),
      body: BlocBuilder<FormBloc, AppFormState>(
        builder: (context, state) {
          if (state is FormSubmitted) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(state.formData.toString(), style: TextStyle(fontSize: 16)),
              ),
            );
          }
          return Center(child: Text("No data available"));
        },
      ),
    );
  }
}
