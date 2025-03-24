import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:socialmedia/AlertHandler/alertHandler.dart';

import '../../../Handlers/BaseUrl.dart';
import '../../../Handlers/UserData.dart';
import '../../../Models/UserModal.dart';
import '../Events/LoginEvent.dart';
import '../States/LoginState.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState.initial()) {
    on<Login>(_LoggedIn);
  }

  void _LoggedIn(Login event, Emitter<LoginState> emit) async {
    print("In The Login Bloc : ${event.mobile} ${event.passWord}");

    try {
      final res = await http.post(
        Uri.parse(Apis.BaseUrl + "Auth/Login/login.php"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded", // Sending form data
        },
        body: {
          "MOBILE": event.mobile,
          "PASSWORD": event.passWord,
        },
      );

      if (res.statusCode == 200) {
        String responseBody = res.body.trim();
        int jsonStart = responseBody.indexOf('{');

        if (jsonStart != -1) {
          responseBody = responseBody.substring(jsonStart); // Extract valid JSON
        }

        var jsonData = jsonDecode(responseBody);

        if (jsonData['status'] == 200) {
          UserModel user = UserModel.fromJson(jsonData['data']);
          UserData(user.userName, user.phone, user.deviceId); // Save user data
          print("User Logged In: ${user.userName}, Phone: ${user.phone}");

          emit(LoginState(
            mobile: user.phone,
            userName: user.userName,
            emailId: null,
            role:user.role,
            passWord: event.passWord, authStatus: event.authStatus,
          ));
        } else {
          print("Login Failed: ${jsonData['message']}");
          emit(LoginState(mobile: event.mobile, emailId: null, userName: null, passWord: event.passWord,role:null, authStatus: event.authStatus));
        }
      } else {
        print('Failed to load data, Status Code: ${res.statusCode}');
        emit(LoginState(mobile: event.mobile, emailId: null, userName: null,role: null, passWord: event.passWord, authStatus: event.authStatus));
      }
    } catch (e) {
      print("Error in LoginBloc: $e");
      emit(LoginState(mobile: event.mobile, emailId: null, userName: null,role:null, passWord: event.passWord, authStatus: event.authStatus));
    }
  }
}
