import 'package:equatable/equatable.dart';

abstract class AppFormState extends Equatable {
  @override
  List<Object> get props => [];
}

class FormInitial extends AppFormState {}

class FormSubmitting extends AppFormState {}

class FormSubmitted extends AppFormState {
  final Map<String, dynamic> formData;
  FormSubmitted(this.formData);

  @override
  List<Object> get props => [formData];
}
