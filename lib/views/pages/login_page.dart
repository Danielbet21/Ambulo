import 'package:ambulo/data/styles/conatant.dart';
import 'package:ambulo/views/pages/register_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true; 
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
              color: Colors.white.withValues(alpha: 50),
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
                      'Good to see you again!\n Lets look at your next adventure.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: AppConstants.kFontSizeLarge,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'MyCustomFont',
                      ),
                  ),
                  AppConstants.kSizedBoxLarge,
                // Email field
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 0, 160, 5)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 0, 160, 5)),
                    ),
                    suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  ),
                  obscureText: _obscureText,
                
                  
                
                ),
                AppConstants.kSizedBoxMedium,
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 5, 91, 35),
                      ),
                      // Change text color based on state
                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.hovered)) {
                            return Colors.white;
                          }
                          return const Color.fromARGB(255, 17, 233, 92); // default
                        },
                      ),
                    ),
                    onPressed: () {
                      final email = _emailController.text;
                      final password = _passwordController.text;
                      debugPrint('Email: $email, Password: $password');
                    },
                    child: const Text('Login'),
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
                Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
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
