import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  Future<String?>? _refreshTokenFuture;
  final FlutterSecureStorage secureStorage;

  AuthInterceptor(this.dio, this.secureStorage);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await secureStorage.read(key: 'jwt_token');
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (_isUnauthorized(err) && _shouldRefresh(err.requestOptions)) {
      // Attempt refresh if not already happening
      _refreshTokenFuture ??= _refreshAccessToken();

      final newToken = await _refreshTokenFuture;
      if (newToken != null) {
        // Retry the original request
        final clonedRequest = _retryRequest(err.requestOptions, newToken);
        try {
          final response = await dio.fetch(clonedRequest);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(e as DioException);
        }
      }
      // If refresh fails, newToken == null => pass the 401 up
    }
    return handler.next(err);
  }

  bool _isUnauthorized(DioException err) {
    return err.response?.statusCode == 401;
  }

  bool _shouldRefresh(RequestOptions requestOptions) {
    // Avoid refreshing again if it's the refresh token call
    return !requestOptions.path.contains('/refresh');
  }

  RequestOptions _retryRequest(RequestOptions requestOptions, String newToken) {
    final newHeaders = Map<String, dynamic>.from(requestOptions.headers);
    newHeaders['Authorization'] = 'Bearer $newToken';
    return requestOptions.copyWith(headers: newHeaders);
  }

  Future<String?> _refreshAccessToken() async {
    try {
      final refreshToken = await secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      // TODO: Finalize the refresh token endpoint with backend team
      final response = await dio.post(
        '/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );
      final newAccessToken = response.data['access_token'];

      await secureStorage.write(key: 'jwt_token', value: newAccessToken);
      return newAccessToken;
    } catch (e) {
      // If fail, remove token or force user to re-log
      await secureStorage.delete(key: 'jwt_token');
      return null;
    } finally {
      // Allow future refresh attempts next time 401 is encountered
      _refreshTokenFuture = null;
    }
  }
}
