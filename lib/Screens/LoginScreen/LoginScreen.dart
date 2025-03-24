import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Handlers/AuthStatus.dart';
import '../../Handlers/UserData.dart';
import '../../StateManagement/LoginStateManagement/Blocs/LoginBloc.dart';
import '../../StateManagement/LoginStateManagement/Events/LoginEvent.dart';
import '../../StateManagement/LoginStateManagement/States/LoginState.dart';
import '../AdminDashboard/Components/AdminDashboard.dart';
import '../ForgetPasswordScreen/ForgetPasswordComponents/customButton.dart';
import '../ForgetPasswordScreen/ForgetPasswordComponents/customTextField.dart';
import '../ForgetPasswordScreen/ForgetPasswordScreen.dart';
import '../SignupScreen/SignupScreen.dart';
import '../UserDashboard/UserDashboard.dart';
import 'LoginComponents/ExitDialogBox.dart';
import 'LoginComponents/LoginPasswordField.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // For password visibility toggle
  final _formKey = GlobalKey<FormState>(); // For form validation

  @override
  void dispose() {
    super.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
  }

  // Method to toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  // Phone number validation function
  String? _phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Mobile number is required";
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return "Enter a valid phone number";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          return showExitDialog(context);
        },
        child: Scaffold(
          body: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state.authStatus == AuthStatus.loggedIn) {
                UserData(state.userName.toString(), state.mobile.toString(),
                    state.role.toString());
                if (state.role == 'user') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserDashboard()));
                } else if (state.role == 'admin') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminDashboard()));
                }
              } else {
                context.read<LoginBloc>().add(Login(
                    mobile: null,
                    emailId: null,
                    userName: null,
                    passWord: null,
                    authStatus: AuthStatus.loggedOut));
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
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: Form(
                      key: _formKey, // Use form key for validation
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Network Image Placeholder
                          Container(
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromARGB(129, 141, 139, 139)
                                          .withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipOval(
                                child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: MediaQuery.of(context).size.width * 0.55,
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                fit: BoxFit
                                    .cover, // Adjusts how the image is displayed
                              ),
                            )),
                          ),
                          const SizedBox(height: 20),

                          // Welcome Text
                          Text(
                            "Welcome Back!",
                            style: TextStyle(
                              fontSize: screenWidth * 0.08,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Please log in to continue.",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Mobile TextField with Phone Validation
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

                          // Password TextField with Visibility Toggle
                          CustomPasswordField(
                            controller: _passwordController,
                            label: "Password",
                            hint: "Enter Password",
                            isObscure:
                                !_isPasswordVisible, // Toggle password visibility
                            inputType: TextInputType.text,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed:
                                  _togglePasswordVisibility, // Toggle on icon press
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Links Row: New Register and Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignupScreen()));
                                },
                                child: Text(
                                  "New Register",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgetPasswordScreen()));
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Login Button
                          CustomButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                // Trigger login event
                                context.read<LoginBloc>().add(Login(
                                      mobile: _mobileController.text,
                                      emailId: null,
                                      userName: null,
                                      passWord: _passwordController.text,
                                      authStatus: AuthStatus.loggedIn,
                                    ));
                              }
                            },
                            label: "Login",
                            // width: screenWidth * 0.6,
                            // height: screenHeight * 0.07,
                            backgroundColor: Colors.white,
                            textColor: Colors.blue,
                          ),

                          const SizedBox(height: 20),

                          // Footer Text
                          Text(
                            "By logging in, you agree to our Terms & Conditions.",
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
        ));
  }
}
