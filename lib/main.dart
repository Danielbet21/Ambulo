import 'package:ambulo/data/database/data_manager.dart';
import 'package:ambulo/data/database/firebase_services.dart';
import 'package:ambulo/data/styles/themes.dart';
import 'package:ambulo/firebase_options.dart';
import 'package:ambulo/models/user.dart';
import 'package:ambulo/views/pages/loading_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

// Global DataManager & User instances for easy access throughout the app
late DataManager dataManager;
late User globalUser;
late bool isAdmin = false; // Default value for isAdmin
late ThemeData appTheme;   // Will be initialized in main

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Allow system bars (Home, Back, Status) to be visible
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
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

  // ✨ Now that appTheme is ready, update system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: appTheme.scaffoldBackgroundColor, // background of bottom buttons
      systemNavigationBarIconBrightness: 
          appTheme.brightness == Brightness.dark ? Brightness.light : Brightness.dark, // icon brightness based on theme
      statusBarColor: Colors.transparent, // make status bar transparent
      statusBarIconBrightness: 
          appTheme.brightness == Brightness.dark ? Brightness.light : Brightness.dark, // status bar icons
    ),
  );

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
    final brightness = Theme.of(context).brightness;

    // 🛠️ Correctly setting system UI
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false, // 🚨 important fix!
      ),
    );

    return MaterialApp(
      title: 'Ambulo',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const LoadingPage(),
    );
  }
}