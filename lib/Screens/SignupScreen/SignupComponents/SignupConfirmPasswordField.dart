import 'package:flutter/material.dart';

class SignupConfirmPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isObscure;
  final TextInputType inputType;
  final int? maxLength;
  final IconButton? suffixIcon; // Accept suffixIcon parameter
  final String? Function(String?)? validator; // Validator function

  const SignupConfirmPasswordField({
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
  _SignupConfirmPasswordFieldState createState() => _SignupConfirmPasswordFieldState();
}

class _SignupConfirmPasswordFieldState extends State<SignupConfirmPasswordField> {
  @override
  void initState() {
    super.initState();

   
  }

  // Method to update the state when text changes
  void _updateCounter() {
    setState(() {});
  }

  @override
  void dispose() {
  
    super.dispose();
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
          validator: widget.validator, // Use custom validator
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
