import 'package:equatable/equatable.dart';

abstract class FormEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SubmitForm extends FormEvent {
  final Map<String, dynamic> formData;
  SubmitForm(this.formData);

  @override
  List<Object> get props => [formData];
}
