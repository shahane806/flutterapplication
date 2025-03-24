import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../Events/forgetPasswordEvents.dart';
import '../States/forgetPasswordStates.dart';

class ForgetPasswordBloc extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  ForgetPasswordBloc() : super(ForgetPasswordInitial()) {
    on<ForgetPasswordSubmitEvent>((event, emit) async {
      emit(ForgetPasswordLoading());
    });
  }
}
