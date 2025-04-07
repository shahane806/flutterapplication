import 'package:flutter/material.dart';

import '../../../Handlers/AuthStatus.dart';

abstract class LoginEvent {}

class Login extends LoginEvent {
  final String? userName;
  final String? passWord;
  final String? mobile;
  final String? emailId;
  final AuthStatus? authStatus;
  final BuildContext context;
  Login(
      {required this.mobile,
      required this.emailId,
      required this.userName,
      required this.passWord,
      required this.authStatus,
      required this.context});
}

class Logout extends LoginEvent {}
