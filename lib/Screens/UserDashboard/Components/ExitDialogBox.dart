import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> showExitDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent closing dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Do you want to exit the app?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false (don't exit)
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true (exit the app)
                // Exit the app
                // You can use SystemNavigator.pop() to close the app programmatically
                SystemNavigator.pop(); // Close the app
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false); // If dialog is closed without a selection, return false
  }
