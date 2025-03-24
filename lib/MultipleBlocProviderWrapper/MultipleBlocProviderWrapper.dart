import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../StateManagement/ForgetPasswordStateManagement/Blocs/forgetPasswordBlocs.dart';
import '../StateManagement/LoginStateManagement/Blocs/LoginBloc.dart';
import '../StateManagement/PostStateManagement/Blocs/PostBloc.dart';
import '../StateManagement/SignupStateManagement/SignupBloc/SignupBloc.dart';

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
