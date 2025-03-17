import 'package:flutter_application_frontend/Handlers/AuthStatus.dart';

abstract class LoginEvent {}

class Login extends LoginEvent {
  final String? userName;
  final String? passWord;
  final String? mobile;
  final String? emailId;
  final AuthStatus? authStatus;
  Login({required this.mobile, required this.emailId, required this.userName, required this.passWord, required this.authStatus});
}
