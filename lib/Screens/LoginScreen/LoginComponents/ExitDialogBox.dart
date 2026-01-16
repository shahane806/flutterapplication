import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
Future<bool> showExitDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
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
              Navigator.of(context).pop(true); // Return true (allow exit)
              // No need for SystemNavigator.pop() – let the system handle it
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // Default to false if dismissed
}

