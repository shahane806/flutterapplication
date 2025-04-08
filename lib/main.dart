import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'MultipleBlocProviderWrapper/MultipleBlocProviderWrapper.dart';
import 'MyApp/MyApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultipleBlocProviderWrapper(const MyApp()));
}
