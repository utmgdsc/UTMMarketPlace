import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/shared/utils.dart';
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

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<SuccessReason> signUp() async {
    try {
      isLoading = true;

      _signupModel =
          SignUpModel(email: _email ?? '', password: _password ?? '');
      final response = await SignUpModel.signUp(_signupModel);

      debugPrint('Sign up response: $response');
      final String reason;
      switch (response.statusCode) {
        case 201:
          reason = 'Successfully registered, please log in.';
          break;
        case 400:
          reason = 'Invalid email or password.';
          break;
        case 409:
          reason = 'User already registered.';
          break;
        case 500:
          reason = 'Server error. Please try again later.';
          break;
        default:
          reason = 'Sign up failed. Please try again.';
          break; 
      }
      final bool success = response.statusCode != null
          && 200 <= response.statusCode! && response.statusCode! < 300;

      return (success: success, reason: reason);
    } catch (exc) {
      debugPrint('Error in signUp: ${exc.toString()}');
      return (success: false, reason: 'Sign up failed. Please try again.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
