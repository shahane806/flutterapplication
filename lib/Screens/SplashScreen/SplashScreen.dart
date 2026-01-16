import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LoginScreen/LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  /// Navigates after a delay of [seconds] to the appropriate screen
  Future<void> _navigateAfterDelay({int seconds = 5}) async {
    await Future.delayed(Duration(seconds: seconds));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? mobile = prefs.getString('mobile');

    if (mobile != null && mobile.isNotEmpty) {
      // Navigate to LoginScreen if mobile exists
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: screenWidth * 0.55,
                height: screenHeight * 0.25,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
