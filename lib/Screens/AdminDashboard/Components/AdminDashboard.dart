import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
     ),
    );
  }
}