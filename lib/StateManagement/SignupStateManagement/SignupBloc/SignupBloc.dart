import 'package:flutter_application_frontend/Handlers/BaseUrl.dart';
import 'package:flutter_application_frontend/StateManagement/SignupStateManagement/SignupEvent/SignupEvent.dart';
import 'package:flutter_application_frontend/StateManagement/SignupStateManagement/SignupState/SignupState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupState.initial()) {
    on<SignupEvent>(signup);

  }

  void signup(SignupEvent event ,Emitter<SignupState> emit)async{
      final res = await http.post(Uri.parse(Apis.BaseUrl+"Auth/Signup/signup.php"),headers: {
        'content-type':'application/x-www-form-urlencoded'
      },body:{
        "MOBILE":event.mobile,
        "PASSWORD":event.password,
        "USERNAME":event.userName,
        "DEVICE_ID":event.deviceId,
        "EMAIL":event.email,
        "COUNTRY_CODE":event.countryCode,
        "DIAL_CODE":event.dialCode,
      });
      if(res.statusCode == 200){
       emit(state.copyWith(
        email: event.email,
        mobile: event.mobile,
        password: event.password,
        deviceId: event.deviceId,
        userName: event.userName,
        countryCode : event.countryCode,
        dialCode : event.dialCode,
      ));
      }
     
  }
}
