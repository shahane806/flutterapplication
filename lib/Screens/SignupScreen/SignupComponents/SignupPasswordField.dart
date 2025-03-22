import 'package:flutter/material.dart';

class SignupPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isObscure;
  final TextInputType inputType;
  final int? maxLength;
  final IconButton? suffixIcon; // Accept suffixIcon parameter
  final String? Function(String?)? validator; // Validator function

  const SignupPasswordField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isObscure = false,
    required this.inputType,
    this.maxLength,
    this.suffixIcon, // Pass suffixIcon here
    this.validator, // Add validator here
  }) : super(key: key);

  @override
  _SignupPasswordFieldState createState() => _SignupPasswordFieldState();
}

class _SignupPasswordFieldState extends State<SignupPasswordField> {
  @override
  void initState() {
    super.initState();

  
  }

  
  @override
  void dispose() {
   
    super.dispose();
  }

  // Password validation function
  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters long";
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return "Password must contain at least one uppercase letter, one lowercase letter, and one number";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isObscure,
          keyboardType: widget.inputType,
          maxLength: widget.maxLength,
          validator: widget.validator ?? _passwordValidator, // Use custom validator
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: Colors.white,
           
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: widget.suffixIcon, // Use the suffixIcon here
          ),
        ),
      ],
    );
  }
}
