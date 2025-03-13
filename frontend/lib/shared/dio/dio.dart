import 'package:dio/dio.dart';

final dio = Dio();

void configureDio() {
  // TODO: change this url once the backend is deployed
  dio.options.baseUrl = 'http://localhost:8000';
  dio.options.connectTimeout = Duration(seconds: 10);
  dio.options.receiveTimeout = Duration(seconds: 10);
}