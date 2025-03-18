import 'package:utm_marketplace/shared/dio/dio.dart';
import 'package:dio/dio.dart';

class LoginModel {
  final String email;
  final String password;

  LoginModel({required this.email, required this.password});

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

  static Future<Response> login(LoginModel loginModel) async {
    try {
      final response = await dio.post(
        '/login',
        data: loginModel.toJson(),
      );

      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!;
      } else {
        throw Exception('Failed to login: ${e.message}');
      }
    }
  }
}
