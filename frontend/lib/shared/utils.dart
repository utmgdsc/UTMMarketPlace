import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:utm_marketplace/shared/secure_storage/secure_storage.dart';

typedef SuccessReason = ({bool success, String reason});

String? _globalEmail;

void storeEmail(String userEmail) {
  _globalEmail = userEmail;
}

String? getEmail() {
  return _globalEmail;
}

// JWT Operations
Future<void> storeToken(String token) async {
  await secureStorage.write(key: 'jwt_token', value: token);
}

Future<String?> getToken() async {
  return await secureStorage.read(key: 'jwt_token');
}

bool isTokenExpired(String? token) {
  if (token == null) {
    debugPrint('Token is null');
    return true;
  }
  try {
    debugPrint('Token: $token');
    return JwtDecoder.isExpired(token);
  } catch (e, stackTrace) {
    debugPrint('Error in JwtDecoder.isExpired: $e');
    debugPrint('Stack trace: $stackTrace');
    return true;
  }
}
