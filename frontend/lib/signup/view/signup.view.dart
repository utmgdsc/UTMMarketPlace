import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/shared/themes/theme.dart';
import 'package:utm_marketplace/signup/view_models/signup.viewmodel.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final signUpViewModel = Provider.of<SignUpViewModel>(context);

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
        signUpViewModel.email = value;
      },
      validator: (value) => signUpViewModel.validateEmail(value),
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
        signUpViewModel.password = value;
      },
      validator: (value) => signUpViewModel.validatePassword(value),
    );

    final confirmPasswordField = TextFormField(
      obscureText: _obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Confirm your password',
      ),
      validator: (value) => signUpViewModel.validateConfirmPassword(value),
    );

    final signupButton = ElevatedButton(
      onPressed: () async {
        if (!_formKey.currentState!.validate()) {
          return; // Don't do anything else if form is invalid
        }

        final successReason = await signUpViewModel.signUp();
        // As of Flutter 3.7, we can use `context.mounted` to safely check
        //  for a valid context during async gaps
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(successReason.reason)),
          );

          if (successReason.success && !signUpViewModel.isLoading) {
            context.replace('/login');
          }
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
      ),
      child: signUpViewModel.isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text('Sign Up'),
    );

    final loginRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Already have an account?'),
        TextButton(
          onPressed: () {
            context.replace('/login');
          },
          child: Text('Log In'),
        ),
      ],
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: StyleText(
                    text: 'Confirm Password',
                    style: ThemeText.label,
                  ),
                ),
                confirmPasswordField,
                SizedBox(height: 16.0),
                signupButton,
                loginRow,
                Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
