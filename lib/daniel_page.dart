import 'package:ambulo/views/pages/login_page.dart';
import 'package:flutter/material.dart';



class DanielPage extends StatelessWidget {
  const DanielPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body is now the login content
      body: const LoginPage(),
    );
  }
}