import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/main.dart';
import 'package:ambulo/utils/user_utils.dart';
import 'package:ambulo/views/pages/login_page.dart';
import 'package:ambulo/views/pages/profile_mobile_page.dart';
// import 'package:ambulo/views/pages/login_page.dart'; //TODO: make sure it works without this import
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController(); 

  @override
   Widget build(BuildContext context) {
    const TextStyle defaultTextStyle = TextStyle(
    color: Colors.black,
    fontSize: AppConstants.kFontSizeLarge,
    fontFamily: 'monospace',
  );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/roads/road_to_the_mountains_register.jpg'),
            fit: BoxFit.cover, // Adjust how the image fills the screen
          ),
        ),
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
                    Text('Welcome to', style: defaultTextStyle),
                      Text('Ambulo! ', 
                      textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppConstants.kFontSizeXXL,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1.0 // Outline thickness
                            ..color = Colors.amber, // Outline color
                        ),
                      ),
                      Text("Let's get you started.",
                      style: defaultTextStyle,
                      ),
                  AppConstants.kSizedBoxLarge,
                // Email field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          labelStyle: TextStyle(),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 0, 160, 5)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: TextStyle(),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 0, 160, 5)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppConstants.kSizedBoxMedium,
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
                    )
                  ),
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
                          return const Color.fromARGB(255, 40, 255, 115); // default
                        },
                      ),
                    ),
                    onPressed: () async {
                      final user = await createAndWrapUser(
                        dataManager, _emailController.text, _passwordController.text,
                         _firstNameController.text + " " + _lastNameController.text);
                      if (user != null) {
                        await user.load();
                        globalUser = user;
                         Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileMobilePage()),
                        );
                      }
                    },
                    child: const Text('Sign Up', style: TextStyle( color: Colors.white) ,),
                  ),
                  AppConstants.kSizedBoxMedium,
                  TextButton(
                    child: Text('Already have an account? Login here'),
                      onPressed: () { 
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                      },
                  ), 
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
                AppConstants.kSizedBoxMedium,
                Text("Area for the 3rd-party sign-in buttons"),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}