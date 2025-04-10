import 'package:equatable/equatable.dart';

abstract class ForgetPasswordEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// 🔹 Event to request OTP
class ForgetPasswordSubmitEvent extends ForgetPasswordEvent {
  final String email;

  ForgetPasswordSubmitEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

// 🔹 Event to verify OTP
class VerifyOtpEvent extends ForgetPasswordEvent {
  final String email;
  final String otp;

  VerifyOtpEvent({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

// 🔹 Event to reset password
class ResetPasswordEvent extends ForgetPasswordEvent {
  final String email;
  final String newPassword;
  final String otp; // ✅ Include OTP for validation

  ResetPasswordEvent({
    required this.email,
    required this.newPassword,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, newPassword, otp];
}
