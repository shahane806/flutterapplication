import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../AlertHandler/alertHandler.dart';
import '../../StateManagement/ForgetPasswordStateManagement/Blocs/forgetPasswordBlocs.dart';
import '../../StateManagement/ForgetPasswordStateManagement/Events/forgetPasswordEvents.dart';
import '../../StateManagement/ForgetPasswordStateManagement/States/forgetPasswordStates.dart';
import '../LoginScreen/LoginScreen.dart';
import 'ForgetPasswordComponents/customButton.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0; // 0: Email, 1: OTP, 2: New Password

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: BlocListener<ForgetPasswordBloc, ForgetPasswordState>(
          listener: (context, state) {
            if (state is ForgetPasswordSuccess) {
              if (_currentStep == 0) {
                setState(() => _currentStep = 1);
                AlertHandler.showSuccessSnackBar(context, state.message);
              } else if (_currentStep == 1) {
                setState(() => _currentStep = 2);
                AlertHandler.showSuccessSnackBar(context, state.message);
              } else if (_currentStep == 2) {
                AlertHandler.showSuccessSnackBar(context, state.message);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            } else if (state is ForgetPasswordError) {
              AlertHandler.showErrorSnackBar(context, state.error);
            }
          },
          child: Stack(
            children: [
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
                        Text(
                          "Reset Password",
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_currentStep == 0) ...[
                          _buildEmailInput(),
                          _buildButton("Send OTP", () {
                            if (_formKey.currentState!.validate()) {
                              context.read<ForgetPasswordBloc>().add(
                                ForgetPasswordSubmitEvent(
                                  email: _emailController.text.trim(),
                                ),
                              );
                            }
                          }),
                        ] else if (_currentStep == 1) ...[
                          _buildOTPInput(),
                          _buildButton("Verify OTP", () {
                            if (_otpController.text.isNotEmpty) {
                              context.read<ForgetPasswordBloc>().add(
                                VerifyOtpEvent(
                                  email: _emailController.text.trim(),
                                  otp: _otpController.text.trim(),
                                ),
                              );
                            } else {
                              AlertHandler.showErrorSnackBar(context, "Please enter OTP");
                            }
                          }),
                        ] else if (_currentStep == 2) ...[
                          _buildPasswordInput(),
                          _buildButton("Update Password", () {
                            if (_newPasswordController.text.isNotEmpty) {
                              context.read<ForgetPasswordBloc>().add(
                                ResetPasswordEvent(
                                  email: _emailController.text.trim(),
                                  otp: _otpController.text.trim(),
                                  newPassword: _newPasswordController.text.trim(),
                                ),
                              );
                            } else {
                              AlertHandler.showErrorSnackBar(context, "Please enter new password");
                            }
                          }),
                        ],
                        const SizedBox(height: 20),
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

  Widget _buildEmailInput() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.black),
          decoration: _inputDecoration("Email", "Enter your email"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOTPInput() {
    return Column(
      children: [
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.black),
          decoration: _inputDecoration("OTP", "Enter OTP"),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      children: [
        TextFormField(
          controller: _newPasswordController,
          obscureText: true,
          style: const TextStyle(color: Colors.black),
          decoration: _inputDecoration("New Password", "Enter new password"),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return CustomButton(
      label: label,
      onPressed: onPressed,
      backgroundColor: Colors.white,
      textColor: Colors.blue,
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
