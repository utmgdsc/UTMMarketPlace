
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Note: There's a small issue regarding the flex Spacer widget, it's not too important
// but would be nice to find a way that makes it so the UI elements
// don't shift when a validator fails.

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
    return Scaffold(
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
              Text(
                'UTMarketplace',
                style: TextStyle(
                  fontSize: 40.0,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Spacer(flex: 1),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'UofT Email Address',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your UofT email',
                  errorMaxLines: 1, 
                  errorStyle: TextStyle(
                    height: 0.0,
                  ),
                ),
                // TODO: REGEX for valid UofT domain email, uncomment when ready
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please a valid UofT email address';
                //   }
                //   return null;
                // },
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextFormField(
                obscureText: _obscureText,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your password',
                  errorMaxLines: 1, 
                  errorStyle: TextStyle(
                    height: 0.0,
                  ),
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
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Implement login functionality (backend)
                    // If this condition passed, a redirect call to the home 
                    // page should be made
                    context.go('/temp_view');
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Log In'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement redirect to sign up page
                    },
                    child: Text('Sign Up'),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement forgot password functionality
                },
                child: Text('Forgot Password?'),
              ),
              Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
