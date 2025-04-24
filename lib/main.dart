import 'package:ambulo/data/database/data_manager.dart';
import 'package:ambulo/data/database/firebase_services.dart';
import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/data/styles/themes.dart';
import 'package:ambulo/firebase_options.dart';
import 'package:ambulo/models/user.dart';
import 'package:ambulo/views/pages/loading_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shai_page.dart';
import 'daniel_page.dart';
import 'dataManagerManualTests.dart';
import 'package:flutter/services.dart';

// Global DataManager & User instances for easy access throughout the app
late DataManager dataManager;
late User globalUser;
late bool isAdmin = false; // Default value for isAdmin
late ThemeData appTheme; // Will be initialized in main

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  // Initialize theme from SharedPreferences
  try {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('themeMode') ?? 'light';
    print("Loading theme from SharedPreferences: $themeMode");
    appTheme = themeMode == 'dark' ? AppTheme.darkTheme : AppTheme.lightTheme;
  } catch (e) {
    print("Error loading theme from SharedPreferences: $e");
    appTheme = AppTheme.lightTheme; // Default to light theme on error
  }

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print("✔️ Firebase initialized successfully.");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  // Initialize services
  final firebaseServices = FirebaseFirestoreServices();
  dataManager = DataManager(
    authService: firebaseServices,
    databaseService: firebaseServices,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ambulo',
      debugShowCheckedModeBanner: false,
      theme: appTheme, // Use the global theme
      home: const LoadingPage(), // Start with loading page
    );
  }
}
