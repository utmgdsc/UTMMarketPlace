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

      // TODO: When response status is cleaned up on backend, remove this if condition have a single line for signUpReponse assignment
      debugPrint('Sign up response: $response');
      if (response.containsKey('user_id')) {
        signUpResponse = 201;
      } else {
        signUpResponse = response['status_code'];
      }
    } catch (exc) {
      debugPrint('Error in signUp: ${exc.toString()}');
      signUpResponse = 500;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
