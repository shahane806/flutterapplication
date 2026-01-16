import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'MultipleBlocProviderWrapper/MultipleBlocProviderWrapper.dart';    //change this to : multiple_bloc_provider_wrapper/multiple_bloc_provider_wrapper.dart
import 'MyApp/MyApp.dart'; //my_app/my_app.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultipleBlocProviderWrapper(
      const MyApp()
    )
  );
}

