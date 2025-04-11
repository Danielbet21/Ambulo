import 'package:ambulo/data/database/data_manager.dart';
import 'package:ambulo/data/database/firebase_services.dart';
import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/data/styles/themes.dart';
import 'package:ambulo/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'shai_page.dart';
import 'daniel_page.dart';
import 'dataManagerManualTests.dart'; // Import the new page
import 'package:flutter/services.dart';

// Global DataManager instance for easy access throughout the app
late DataManager dataManager;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/shai': (context) => const ShaiPage(),
        '/daniel': (context) => const DanielPage(),
        '/dataManagerManualTests': (context) => const DataManagerManualTests(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/shai');
              },
              child: const Text('Shai'),
            ),
            AppConstants.kSizedBoxMedium,
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/daniel');
              },
              child: const Text('Daniel'),
            ),
            AppConstants.kSizedBoxMedium, // Add spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/dataManagerManualTests');
              },
              child: const Text('Data Manager Manual Tests'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
