import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmedia/AlertHandler/alertHandler.dart';

import '../../../Handlers/BaseUrl.dart';
import '../../../Handlers/UserData.dart';
import '../../../Models/UserModal.dart';
import '../Events/LoginEvent.dart';
import '../States/LoginState.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState.initial()) {
    on<Login>(_LoggedIn);
    on<Logout>(_LogOut);
  }

  void _LoggedIn(Login event, Emitter<LoginState> emit) async {
    print("In The Login Bloc : ${event.mobile} ${event.passWord}");

    try {
      final res = await http.post(
        Uri.parse(Apis.BaseUrl + "Auth/Login/login.php"),
        headers: {
          "Content-Type":
              "application/x-www-form-urlencoded", // Sending form data
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
          responseBody =
              responseBody.substring(jsonStart); // Extract valid JSON
        }

        var jsonData = jsonDecode(responseBody);

        if (jsonData['status'] == 200) {
          UserModel user = UserModel.fromJson(jsonData['data']);
          UserData(user.userName, user.phone,
              user.deviceId); // Save initial user data
          print("User Logged In: ${user.role}, Phone: ${user.phone}");

          // Fetch username from userProfile table
          final profileRes = await http.post(
            Uri.parse("${Apis.BaseUrl}/SocialMediaApis/updateUserProfile.php"),
            body: {
              "MOBILE": user.phone,
              "FUNCTION_TYPE": "getUserProfileData",
            },
          );

          if (profileRes.statusCode == 200) {
            var profileData = jsonDecode(profileRes.body);
            if (profileData['status'] == 200 &&
                profileData['data']['userName'] != null) {
              String fetchedUsername = profileData['data']['userName'];
              UserData.username =
                  fetchedUsername; // Update UserData.username with fetched value
              print("Fetched Username from userProfile: $fetchedUsername");
            } else {
              print("Failed to fetch username: ${profileData['message']}");
            }
          } else {
            print(
                "Profile API Error: ${profileRes.statusCode} - ${profileRes.body}");
          }

          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString("mobile", user.phone);
          emit(LoginState(
            mobile: user.phone,
            userName: UserData.username, // Use updated UserData.username
            emailId: null,
            role: user.role,
            passWord: event.passWord,
            authStatus: event.authStatus,
          ));
        } else {
          print("Login Failed: ${jsonData['message']}");
          AlertHandler.showLoginFailedSnackbar(event.context);
        }
      } else {
        AlertHandler.showLoginFailedSnackbar(event.context);
      }
    } catch (e) {
      AlertHandler.showLoginFailedSnackbar(event.context);
    }
  }

  void _LogOut(Logout event, Emitter<LoginState> emit) async {
    emit(LoginState.initial());
  }
}
