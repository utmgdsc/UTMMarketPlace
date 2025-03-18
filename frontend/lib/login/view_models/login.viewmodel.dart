import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/login/model/login.model.dart';
import 'package:utm_marketplace/shared/secure_storage/secure_storage.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';
import 'package:utm_marketplace/shared/utils.dart';

class LoginViewModel extends LoadingViewModel {
  final storage = secureStorage;
  LoginModel _loginModel = LoginModel(email: '', password: '');

  String? _email;
  String? get email => _email;
  set email(String? value) {
    _email = value;
    notifyListeners();
  }

  String? _password;
  String? get password => _password;
  set password(String? value) {
    _password = value;
    notifyListeners();
  }

  // Validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a valid UofT email address';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@(mail\.utoronto\.ca|utoronto\.ca)$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid UofT email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  Future<SuccessReason> login() async {
    try {
      isLoading = true;

      _loginModel = LoginModel(email: _email ?? '', password: _password ?? '');
      final response = await LoginModel.login(_loginModel);

      debugPrint('Login response: $response');
      final String reason;
      switch (response.statusCode) {
        case 200:
          final token = response.data['access_token'];
          await storeToken(token);
          if (!isTokenExpired(token)) {
            debugPrint('Token is valid');
          } else {
            debugPrint('Token is expired');
          }
          reason = 'Login successful';
          break;
        case 400:
          reason = 'Invalid email or password.';
          break;
        case 500:
          reason = 'Server error. Please try again later.';
          break;
        default:
          reason = 'Login failed. Please try again.';
          break;
      }
      final success =
          (response.statusCode ?? 0) >= 200 && response.statusCode! < 300;

      return (success: success, reason: reason);
    } catch (exc) {
      debugPrint('Error in login: ${exc.toString()}');
      return (success: false, reason: 'Login failed. Please try again.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
