// ignore_for_file: unused_local_variable

import 'package:ambulo/helpers/image_helper.dart';
import 'package:ambulo/main.dart';
import 'package:flutter/material.dart';

final String userEmail = "imageTest@gmail.com";
final String userPassword = "imageTest1234";
final String testTrailID = "Trail Image Test";

class DataManagerImageTests extends StatefulWidget {
  const DataManagerImageTests({super.key});

  @override
  State<DataManagerImageTests> createState() => _DataManagerImageTestsState();
}

class _DataManagerImageTestsState extends State<DataManagerImageTests> {
  String? profileImageUrl;
  List<String> trailPhotoUrls = [];

  late final ImageHelpers imageHelpers;

  @override
  void initState() {
    super.initState();

    imageHelpers = ImageHelpers(dataManager: dataManager);

    dataManager.signIn(userEmail, userPassword).then((userCredential) {
      if (userCredential != null) {
        debugPrint(
            "✅ User signed in successfully: ${userCredential.user?.uid}");
        _loadImages(); // Load images after successful sign-in
      } else {
        debugPrint("❌ Error: User sign-in failed.");
      }
    }).catchError((error) {
      debugPrint("❌ Error signing in: $error");
    });
  }

  Future<void> _loadImages() async {
    final currentUser = dataManager.getCurrentUser();
    if (currentUser == null) {
      debugPrint("Error: No user is signed in yet. Skipping image loading.");
      return;
    }

    final profile = await imageHelpers.getCurrentUserProfileImage();
    final trailPhotos = await imageHelpers.getTrailPhotos(testTrailID);

    setState(() {
      profileImageUrl = profile;
      trailPhotoUrls = trailPhotos;
    });
  }

  Future<void> _initUser() async {
//
    // final userCredential = await dataManager.register(userEmail, userPassword);

    // // create a new user
    // dataManager.createUserProfile(
    //     userCredential!.user!.uid, "Profile Image Test User", userEmail);

    //
    // final userCredential = await dataManager.register(userEmail, userPassword);

    // // create a new user
    // dataManager.createUserProfile(
    //     userCredential!.user!.uid, "Profile Image Test User", userEmail);

    final userCredential = await dataManager.signIn(userEmail, userPassword);

    // upload profile image
    final imageUrl =
        await dataManager.uploadProfilePictureManual(userCredential!.user!.uid);

    // Refresh the profile image
    final profile = await imageHelpers.getCurrentUserProfileImage();
    setState(() {
      profileImageUrl = profile;
    });
  }

  Future<void> _initTrail() async {
// 1. Create a trail
    // await dataManager.createTrail(testTrailID, {
    //   'trackId': 1231875,
    //   'trailDetails': {
    //     'name': 'Test Mountain Trail',
    //     'difficulty': 'Medium',
    //     'length': 12.5,
    //     'elevation': 450,
    //     'location': 'Test Mountain Range',
    //     'description': 'A beautiful test trail for hiking enthusiasts'
    //   },
    //   'gpx': 'sample_gpx_data_for_test'
    // });

    // 2. Upload trail image
// 1. Create a trail
    // await dataManager.createTrail(testTrailID, {
    //   'trackId': 1231875,
    //   'trailDetails': {
    //     'name': 'Test Mountain Trail',
    //     'difficulty': 'Medium',
    //     'length': 12.5,
    //     'elevation': 450,
    //     'location': 'Test Mountain Range',
    //     'description': 'A beautiful test trail for hiking enthusiasts'
    //   },
    //   'gpx': 'sample_gpx_data_for_test'
    // });

    // 2. Upload trail image
    final imageUrl = await dataManager.uploadTrailImageManual(testTrailID);

    // Reload all trail images after upload
    final trailPhotos = await imageHelpers.getTrailPhotos(testTrailID);

    setState(() {
      trailPhotoUrls = trailPhotos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DataManager Image Tests"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.blue),
            onPressed: _initUser,
          ),
          IconButton(
            icon: const Icon(Icons.terrain, color: Colors.green),
            onPressed: _initTrail,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Profile Image",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            profileImageUrl != null
                ? Image.network(
                    profileImageUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error,
                          color: Colors.red, size: 50);
                    },
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 30),
            const Text(
              "Trail Photos",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            trailPhotoUrls.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: trailPhotoUrls.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Image.network(
                            trailPhotoUrls[index],
                            width: 100, // Reduced width
                            height: 100, // Reduced height
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error,
                                  color: Colors.red, size: 50);
                            },
                          ),
                        );
                      },
                    ),
                  )
                : const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
