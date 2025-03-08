import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/signup/model/signup.model.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class SignUpViewModel extends LoadingViewModel {

  SignUpModel _signupModel = SignUpModel(email: '', password: '');
  int signUpResponse = 0;

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

  Future<void> signUp() async {
    try {
      isLoading = true;

      _signupModel = SignUpModel(email: _email ?? '', password: _password ?? '');
      final response = await SignUpModel.signUp(_signupModel);

      debugPrint('Sign up response: $response');
      signUpResponse = response['statusCode'];
    } catch (exc) {
      debugPrint('Error in signUp: ${exc.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
