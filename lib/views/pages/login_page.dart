import 'package:ambulo/data/styles/conatant.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Make the entire body a background image
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/tree_login.png'),
            fit: BoxFit.cover, // Adjust how the image fills the screen
          ),
        ),
        // Center the login box
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            // Limit the max width so it doesn’t stretch too wide
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            // White box decoration
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content vertically
              children: [
                    Text(
                      'Welcome Back!\n Login for your next Adventure.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: AppConstants.kFontSizeLarge,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                  ),
                  AppConstants.kSizedBoxLarge,
                // Email field
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                AppConstants.kSizedBoxMedium,
                ElevatedButton(
                  //color of the button
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 5, 91, 35),
                  ),
                  onPressed: () {
                    // TODO: Add your login logic
                    final email = _emailController.text;
                    final password = _passwordController.text;
                    debugPrint('Email: $email, Password: $password');
                  },
                  child: const Text('Login', style: TextStyle(color: Color.fromARGB(255, 17, 233, 92),)),
                ),
                AppConstants.kSizedBoxMedium,

                // Placeholder for 3rd-party comment or sign-in
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Or',
                        style: TextStyle(color: Colors.black45),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                Text("Area for the 3rd-party sign-in buttons"),
                const SizedBox(height: 24),
                // Login button
                Text("Don't have an account? Sign up"),
                Text("Sign Up", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                Text("Forgot password?"),
                Text("Reset password", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
