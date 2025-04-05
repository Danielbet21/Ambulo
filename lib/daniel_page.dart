import 'package:ambulo/views/pages/profile_mobile_page.dart';
import 'package:ambulo/views/pages/profile_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as kIsWeb;



class DanielPage extends StatelessWidget {
  const DanielPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: kIsWeb.kIsWeb ? ProfileWebPage() : ProfileMobilePage(),
    );
  }
}