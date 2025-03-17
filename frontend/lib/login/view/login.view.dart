import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/shared/themes/theme.dart';
import 'package:utm_marketplace/login/view_models/login.viewmodel.dart';
import 'package:utm_marketplace/shared/utils.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await getToken();
    if (mounted && token != null && !isTokenExpired(token)) {
      context.replace('/marketplace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);

    final logoText = StyleText(
      text: 'UTMarketplace',
      style: ThemeText.header.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    );

    final emailField = TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Enter your UofT email',
      ),
      onChanged: (value) {
        loginViewModel.email = value;
      },
      validator: (value) => loginViewModel.validateEmail(value),
    );

    final passwordField = TextFormField(
      obscureText: _obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Enter your password',
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      onChanged: (value) {
        loginViewModel.password = value;
      },
      validator: (value) => loginViewModel.validatePassword(value),
    );

    final loginButton = ElevatedButton(
      onPressed: () async {
        if (!_formKey.currentState!.validate()) {
          return;
        }

        final successReason = await loginViewModel.login();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(successReason.reason)),
          );

          if (successReason.success && !loginViewModel.isLoading) {
            context.replace('/marketplace');
          }
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
      ),
      child: loginViewModel.isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text('Log In'),
    );

    final signUpRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Don\'t have an account?'),
        TextButton(
          onPressed: () {
            context.replace('/signup');
          },
          child: Text('Sign Up'),
        ),
      ],
    );

    final forgotPasswordButton = TextButton(
      onPressed: () {
        // TODO: Implement forgot password functionality
      },
      child: Text('Forgot Password?'),
    );

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Spacer(flex: 1),
                logoText,
                Spacer(flex: 1),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StyleText(
                    text: 'UofT Email Address',
                    style: ThemeText.label,
                  ),
                ),
                emailField,
                SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StyleText(
                    text: 'Password',
                    style: ThemeText.label,
                  ),
                ),
                passwordField,
                SizedBox(height: 16.0),
                loginButton,
                signUpRow,
                forgotPasswordButton,
                Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
