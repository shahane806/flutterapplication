// alertHandler.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_frontend/AlertHandler/snackBarManager.dart';

class AlertHandler {
  // Phone number validation function
  static String? phoneValidator(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      // Trigger warning if the mobile number is empty
      SnackBarManager.showWarningSnackBar(context, "Mobile number is required.");
      return null; // Prevent form submission
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      // Trigger warning if the mobile number is invalid
      SnackBarManager.showWarningSnackBar(context, "Enter a valid phone number.");
      return null; // Prevent form submission
    }
    return null; // Return null if the value is valid
  }

  // Show success message
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Show error message
  static void showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show information/warning message (if needed)
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }


  static void showLoginFailedSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Login Failed. Please try again."),
      duration: Duration(seconds: 2), // Duration of snackbar display
      backgroundColor: Colors.red, // Red color for error
      behavior: SnackBarBehavior.floating, // Floating style
    ),
  );

  
}



}
