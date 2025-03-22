import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomMobileField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isObscure;
  final TextInputType inputType;
  final int? maxLength;
  final IconButton? suffixIcon; // Accept suffixIcon parameter
  final String? Function(String?)? validator; // Validator function

  const CustomMobileField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isObscure = false,
    required this.inputType,
    this.maxLength,
    this.suffixIcon,
    this.validator, // Add validator parameter
  }) : super(key: key);

  @override
  _CustomMobileFieldState createState() => _CustomMobileFieldState();
}

class _CustomMobileFieldState extends State<CustomMobileField> {
  @override
  void initState() {
    super.initState();
    // Add listener to update state when text changes
    widget.controller.addListener(_updateCounter);
  }

  // Method to update the state when text changes
  void _updateCounter() {
    setState(() {});
  }

  @override
  void dispose() {
    // Remove listener when the widget is disposed to avoid memory leaks
    widget.controller.removeListener(_updateCounter);
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
          inputFormatters: [
            // Allow only + and digits for country code and phone number
            FilteringTextInputFormatter.allow(RegExp(r'^[\+]?[0-9]*$')),
            // Restrict the length of input: + country code (3 digits) + phone number (10 digits)
            LengthLimitingTextInputFormatter(widget.maxLength ?? 13),
          ],
          validator: widget.validator, // Apply validator if provided
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: Colors.white,
            counterText: widget.maxLength != null
                ? '${widget.controller.text.length}/${widget.maxLength}'
                : '',
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
