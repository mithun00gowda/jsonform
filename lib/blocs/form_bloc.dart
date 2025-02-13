import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_event.dart';
import 'form_state.dart';

class FormBloc extends Bloc<FormEvent, AppFormState> {
  FormBloc() : super(FormInitial()) {
    // Register event handler
    on<SubmitForm>((event, emit) async {
      emit(FormSubmitting());
      await Future.delayed(Duration(seconds: 1)); // Simulating processing
      emit(FormSubmitted(event.formData));
    });
  }
}
