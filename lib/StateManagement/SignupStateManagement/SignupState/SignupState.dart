import 'package:equatable/equatable.dart';

class SignupState extends Equatable {
  final String email;
  final String mobile;
  final String password;
  final String deviceId;
  final String userName;
  final String countryCode;
  final String dialCode;
  const SignupState({required this.email, required this.mobile, required this.password, required this.userName, required this.deviceId, required this.countryCode, required this.dialCode});

  factory SignupState.initial() => const SignupState(email: '', mobile: '', password: '', deviceId: '', userName: '', dialCode: '',countryCode: '');

  SignupState copyWith({String? email, String? mobile, String? password, required String? deviceId , required String ? userName, required String ? dialCode, required String ? countryCode}) {
    return SignupState(
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      password: password ?? this.password,
      deviceId: deviceId ?? this.deviceId,
      userName: userName ?? this.userName,
      countryCode: countryCode?? this.countryCode,
      dialCode:  dialCode ?? this.dialCode,
    );
  }

  @override
  List<Object> get props => [email, mobile, password,deviceId,userName, countryCode, dialCode];
}
