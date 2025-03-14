import 'package:utm_marketplace/shared/dio/dio.dart';
import 'package:dio/dio.dart';

class SignUpModel {
  final String email;
  final String password;

  SignUpModel({required this.email, required this.password});

  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(
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

  static Future<Response> signUp(SignUpModel signUpModel) async {
    try {
      final response = await dio.post(
        '/sign-up',
        data: signUpModel.toJson(),
      );

      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!;
      } else {
        throw Exception('Failed to sign up: ${e.message}');
      }
    }
  }
}
