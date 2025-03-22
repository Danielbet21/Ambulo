import 'package:flutter/material.dart';

class ProfileWebPage extends StatefulWidget {
  const ProfileWebPage({Key? key}) : super(key: key);

  @override
  State<ProfileWebPage> createState() => _ProfileWebPageState();
}

class _ProfileWebPageState extends State<ProfileWebPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Welcome to your profile!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}