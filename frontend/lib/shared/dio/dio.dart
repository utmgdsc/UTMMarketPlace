import 'package:dio/dio.dart';

final dio = Dio();

void configureDio() {
  // TODO: change this url once the backend is deployed
  dio.options.baseUrl = 'http://10.0.2.2:8000';
  dio.options.connectTimeout = Duration(seconds: 10);
  dio.options.receiveTimeout = Duration(seconds: 10);
}
