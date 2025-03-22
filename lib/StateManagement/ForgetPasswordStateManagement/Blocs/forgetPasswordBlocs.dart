import 'package:flutter_application_frontend/StateManagement/ForgetPasswordStateManagement/Events/forgetPasswordEvents.dart';
import 'package:flutter_application_frontend/StateManagement/ForgetPasswordStateManagement/States/forgetPasswordStates.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class ForgetPasswordBloc extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  ForgetPasswordBloc() : super(ForgetPasswordInitial()) {
    on<ForgetPasswordSubmitEvent>((event, emit) async {
      emit(ForgetPasswordLoading());
    });
  }
}
