import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/main.dart';
import 'package:ambulo/utils/user_utils.dart';
import 'package:ambulo/views/pages/HomePage.dart';
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
  String? _errorMessage;

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
              color: Colors.white.withOpacity(0.7),
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
                  "Good to see you again!\n Let's look at your next adventure.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: AppConstants.kFontSizeLarge,
                    fontFamily: 'monospace',
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
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 160, 5)),
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
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 160, 5)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
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
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                        color: Colors.red), // Display the error message in red
                  ),
                AppConstants.kSizedBoxMedium,
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Color.fromARGB(255, 5, 91, 35),
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        return const Color.fromARGB(255, 40, 255, 115);
                      },
                    ),
                  ),
                  onPressed: () async {
                    //TODO: make sure it works
                    final user = await loginAndWrapUser(dataManager,
                        _emailController.text, _passwordController.text);
                    if (user != null) {
                      await user.load();
                      globalUser = user;

                      // Check if admin
                      isAdmin = await dataManager.isAdmin();

                      // Get theme preference from user
                      final themePreference =
                          globalUser.isLightTheme ? 'light' : 'dark';
                      await saveThemePreference(themePreference);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                      );
                    } //TODO: debug printing
                    else {
                      setState(() {
                        _errorMessage =
                            'Invalid email or password. Please try again.';
                      });
                    }
                    debugPrint(
                        'Email: $_emailController.text, Password: $_passwordController.text');
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
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
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()),
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
                Text("Forgot your password?"),
                TextButton(
                  onPressed: () async {
                    if (_emailController.text.isEmpty) {
                      setState(() {
                        _errorMessage =
                            'Please enter your email to reset password.';
                      });
                      return;
                    }
                    try {
                      await dataManager.resetPassword(_emailController.text);
                      setState(() {
                        _errorMessage =
                            'Password reset email sent. Check your inbox.';
                      });
                    } catch (e) {
                      setState(() {
                        _errorMessage =
                            'Failed to send reset email. Please try again.';
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Reset password",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
