import 'package:flutter/material.dart';
import 'package:flutter_application_frontend/AlertHandler/alertHandler.dart';
import 'package:flutter_application_frontend/Screens/ForgetPasswordScreen/ForgetPasswordComponents/customButton.dart';
import 'package:flutter_application_frontend/Screens/ForgetPasswordScreen/ForgetPasswordComponents/customTextField.dart';
import 'package:flutter_application_frontend/Screens/LoginScreen/LoginScreen.dart';
import 'package:flutter_application_frontend/StateManagement/ForgetPasswordStateManagement/Blocs/forgetPasswordBlocs.dart';
import 'package:flutter_application_frontend/StateManagement/ForgetPasswordStateManagement/Events/forgetPasswordEvents.dart';
import 'package:flutter_application_frontend/StateManagement/ForgetPasswordStateManagement/States/forgetPasswordStates.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _mobileController.dispose();
  }

  // Override the back button behavior
  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    return false; // Prevent default back button action
  }

// Phone number validation function
  String? _phoneValidator(String? value) {
    return AlertHandler.phoneValidator(
        context, value); // Call the validation function from AlertHandler
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop, // Handle back button press
      child: Scaffold(
        body: BlocListener<ForgetPasswordBloc, ForgetPasswordState>(
          listener: (context, state) {
            if (state is ForgetPasswordSuccess) {
              // Show success message using the AlertHandler
              AlertHandler.showSuccessSnackBar(context, state.message);
            } else if (state is ForgetPasswordFailure) {
              // Show error message using the AlertHandler
              AlertHandler.showErrorSnackBar(context, state.error);
            }
          },
          child: Stack(
            children: [
              // Gradient Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.orangeAccent,
                      Colors.orangeAccent,
                      Color(0xFFF5F5F5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Page Title
                        Text(
                          "Reset Password",
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Enter your mobile number to reset your password",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        // Mobile Text Field with White Background
                        CustomMobileField(
                          controller: _mobileController,
                          label: "Mobile Number",
                          hint: "mobile number",
                          inputType: TextInputType.phone,
                          maxLength: 10, // Maximum length: +xxx xxxxxxxxxx
                          isObscure: false,
                          validator: _phoneValidator,
                        ),
                        const SizedBox(height: 20),

                        // Reset Password Button
                        CustomButton(
                          label: "Reset Password",
                          onPressed: () {
                            context.read<ForgetPasswordBloc>().add(
                                  ForgetPasswordSubmitEvent(
                                    mobileNumber: _mobileController.text,
                                  ),
                                );
                          },
                          backgroundColor:
                              Colors.white, // Same as login button background
                          textColor:
                              Colors.blue, // Same as login button text color
                        ),

                        const SizedBox(height: 20),

                        // Footer Text
                        Text(
                          "By resetting your password, you agree to our Terms & Conditions.",
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
