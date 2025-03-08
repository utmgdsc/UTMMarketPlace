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

  static Future<Map<String, dynamic>> signUp(SignUpModel signUpModel) async {
    final dio = Dio();
    final String endpoint = 'http://10.0.2.2:8000/sign-up';

    try {
      final response = await dio.post(
        endpoint,
        data: signUpModel.toJson(),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      } else {
        throw Exception('Failed to sign up: ${e.message}');
      }
    }
  }
}