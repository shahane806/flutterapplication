import 'package:equatable/equatable.dart';

import '../../../Handlers/AuthStatus.dart';

class LoginState extends Equatable {
  final String? userName;
  final String? passWord;
  final String? emailId;
  final String? mobile;
  final AuthStatus? authStatus;
  final String? role;

  const LoginState({
    required this.mobile,
    required this.emailId,
    required this.userName,
    required this.passWord,
    required this.authStatus,
    required this.role,
  });

  @override
  List<Object?> get props =>
      [userName, passWord, emailId, mobile, authStatus, role];

  // Factory for the initial state
  factory LoginState.initial() {
    return const LoginState(
      userName: '',
      passWord: '',
      mobile: '',
      emailId: '',
      role: '',
      authStatus: AuthStatus.loggedOut,
    );
  }

  // CopyWith method to update state
  LoginState copyWith({
    String? userName,
    String? passWord,
    String? emailId,
    String? mobile,
    String? role,
    AuthStatus? authStatus,
  }) {
    return LoginState(
      userName: userName ?? this.userName,
      passWord: passWord ?? this.passWord,
      emailId: emailId ?? this.emailId,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      authStatus: authStatus ?? this.authStatus,
    );
  }
}
