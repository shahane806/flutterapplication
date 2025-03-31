import 'package:equatable/equatable.dart';

abstract class ForgetPasswordEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ForgetPasswordSubmitEvent extends ForgetPasswordEvent {
  final String mobileNumber;

  ForgetPasswordSubmitEvent({required this.mobileNumber});

  @override
  List<Object?> get props => [mobileNumber];
}
