import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/login/model/login.model.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class LoginViewModel extends LoadingViewModel {
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

  Future<void> login() async {
    try {
      isLoading = true;

      _loginModel = LoginModel(email: _email ?? '', password: _password ?? '');
      final token = await LoginModel.login(_loginModel);

      await _loginModel.storeToken(token);

      if (_loginModel.isTokenExpired(token)) {
        debugPrint('Token is expired');
      } else {
        debugPrint('Token is valid');
      }

      debugPrint('Login token: $token');
    } catch (exc) {
      debugPrint('Error in login: ${exc.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
