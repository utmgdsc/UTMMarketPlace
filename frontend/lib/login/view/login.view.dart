import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:utm_marketplace/shared/themes/theme.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
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
      // TODO: REGEX for valid UofT domain email, uncomment when ready
      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return 'Please a valid UofT email address';
      //   }
      //   return null;
      // },
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
      // TODO: Implement email validation and password validation (backend), uncomment when ready
      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return 'Password or email is incorrect';
      //   }
      //   return null;
      // },
    );

    final loginButton = ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // TODO: Implement login functionality (backend)
          // If this condition passed, a redirect call to the home
          // page should be made
          context.replace('/marketplace');
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
      ),
      child: Text('Log In'),
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
