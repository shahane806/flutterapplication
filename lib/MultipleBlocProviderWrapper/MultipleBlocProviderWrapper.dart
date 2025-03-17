import 'package:flutter/material.dart';
import 'package:flutter_application_frontend/StateManagement/ForgetPasswordStateManagement/Blocs/forgetPasswordBlocs.dart';
import 'package:flutter_application_frontend/StateManagement/LoginStateManagement/Blocs/LoginBloc.dart';
import 'package:flutter_application_frontend/StateManagement/PostStateManagement/Blocs/PostBloc.dart';
import 'package:flutter_application_frontend/StateManagement/SignupStateManagement/SignupBloc/SignupBloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget MultipleBlocProviderWrapper(Widget child) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(),
      ),
      
      BlocProvider<SignupBloc>(
        create: (context) => SignupBloc(),
      ),
      BlocProvider<ForgetPasswordBloc>(
        create: (context) => ForgetPasswordBloc(),
      ),
        BlocProvider<UploadVideoPostBloc>(
        create: (context) => UploadVideoPostBloc(),
      ),
       BlocProvider<UploadImagePostBloc>(
        create: (context) => UploadImagePostBloc(),
      ),
       BlocProvider<UploadTextPostBloc>(
        create: (context) => UploadTextPostBloc(),
      ),
    ],
    child: child,
  );
}
