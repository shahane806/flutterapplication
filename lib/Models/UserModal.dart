import 'dart:convert';

import '../Handlers/AuthStatus.dart';

class UserModel {
  final int id;
  final String userName;
  final String phone;
  final String? otp;
  final String? role;
  final String deviceId;
  final AuthStatus authStatus;

  UserModel({
    required this.id,
    required this.userName,
    required this.phone,
    this.otp,
    this.role,
    required this.deviceId,
    required this.authStatus,
  });

  // Factory constructor to create an object from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      userName: json['userName'],
      phone: json['phone'],
      otp: json['otp'], // Nullable field
      deviceId: json['deviceId'],
      role: json['role'],
      authStatus:
          AuthStatus.loggedIn, // Default to logged in if user data exists
    );
  }

  // Convert an object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'phone': phone,
      'otp': otp,
      'role': role,
      'deviceId': deviceId,
      'authStatus':
          authStatus.toString().split('.').last, // Convert enum to string
    };
  }

  // Helper function to parse JSON from a string
  static UserModel fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString)['data']);
  }

  // Copy method for immutability
  UserModel copyWith({
    int? id,
    String? userName,
    String? phone,
    String? otp,
    String? role,
    String? deviceId,
    AuthStatus? authStatus,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      phone: phone ?? this.phone,
      otp: otp ?? this.otp,
      role: role ?? this.role,
      deviceId: deviceId ?? this.deviceId,
      authStatus: authStatus ?? this.authStatus,
    );
  }
}
