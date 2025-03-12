import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';

class LoginModel {
  final String email;
  final String password;

  final storage = FlutterSecureStorage();

  LoginModel({required this.email, required this.password});

  // JWT Operations --------------------------------------------
  Future<void> storeToken(String token) async {
    await storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }
  // -----------------------------------------------------------

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  static Future<String> login(LoginModel loginModel) async {
    try {
      final response = await dio.post(
        '/login',
        data: loginModel.toJson(),
      );

      if (response.statusCode == 200) {
        return response.data['access_token'];
      } else {
        throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to login: ${e.response!.data['detail']}');
      } else {
        throw Exception('Failed to login: ${e.message}');
      }
    }
  }
}
