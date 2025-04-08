import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../Handlers/BaseUrl.dart';
import '../Events/forgetPasswordEvents.dart';
import '../States/forgetPasswordStates.dart';

class ForgetPasswordBloc extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  ForgetPasswordBloc() : super(ForgetPasswordInitial()) {
    
    // Step 1: Request OTP
    on<ForgetPasswordSubmitEvent>((event, emit) async {
      emit(ForgetPasswordLoading());

      try {
        final url = Uri.parse("${Apis.BaseUrl}/Auth/ForgetPassword/forget_password.php");
        final response = await http.post(
          url,
          body: {
            "action": "request_otp",
            "email": event.email,
          },
        );

        final data = json.decode(response.body);
        if (response.statusCode == 200 && data["status"] == 200) {
          emit(ForgetPasswordSuccess(message: data["message"]));
        } else {
          emit(ForgetPasswordError(error: data["message"] ?? "Failed to send OTP"));
        }
      } catch (e) {
        emit(ForgetPasswordError(error: "Network error: $e"));
      }
    });

    // Step 2: Verify OTP
    on<VerifyOtpEvent>((event, emit) async {
      emit(ForgetPasswordLoading());

      try {
        final url = Uri.parse("${Apis.BaseUrl}/Auth/ForgetPassword/forget_password.php");
        final response = await http.post(
          url,
          body: {
            "action": "verify_otp",
            "email": event.email,
            "otp": event.otp,
          },
        );

        final data = json.decode(response.body);
        if (response.statusCode == 200 && data["status"] == 200) {
          emit(ForgetPasswordSuccess(message: data["message"]));
        } else {
          emit(ForgetPasswordError(error: data["message"] ?? "OTP verification failed"));
        }
      } catch (e) {
        emit(ForgetPasswordError(error: "Network error: $e"));
      }
    });

    // Step 3: Reset Password
    on<ResetPasswordEvent>((event, emit) async {
      emit(ForgetPasswordLoading());

      try {
        final url = Uri.parse("${Apis.BaseUrl}/Auth/ForgetPassword/forget_password.php");
        final response = await http.post(
          url,
          body: {
            "action": "reset_password",
            "email": event.email,
            "otp": event.otp,
            "newPassword": event.newPassword,
          },
        );

        final data = json.decode(response.body);
        if (response.statusCode == 200 && data["status"] == 200) {
          emit(ForgetPasswordSuccess(message: data["message"]));
        } else {
          emit(ForgetPasswordError(error: data["message"] ?? "Password reset failed"));
        }
      } catch (e) {
        emit(ForgetPasswordError(error: "Network error: $e"));
      }
    });
  }
}
