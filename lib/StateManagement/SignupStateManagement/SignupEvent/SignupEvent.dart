import 'package:equatable/equatable.dart';

class SignupEvent extends Equatable {
  final String email;
  final String mobile;
  final String password;
  final String userName;
  final String deviceId;
  final String countryCode;
  final String dialCode;

  SignupEvent({required this.email, required this.mobile, required this.password, required this.deviceId, required this.userName, required this.countryCode, required this.dialCode});

  @override
  List<Object> get props => [email, mobile, password, deviceId, userName, countryCode, dialCode];
}
