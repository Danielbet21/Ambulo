// ignore_for_file: library_private_types_in_public_api, unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for Clipboard
import 'package:ambulo/main.dart';
import 'package:ambulo/dataManagerImageTests.dart'; // Import the new test page

class DataManagerManualTests extends StatefulWidget {
  const DataManagerManualTests({super.key});

  @override
  _DataManagerManualTestsState createState() => _DataManagerManualTestsState();
}

class _DataManagerManualTestsState extends State<DataManagerManualTests> {
  final ScrollController _scrollController = ScrollController();
  List<String> _logMessages = [];

  // Test credentials
  final String testEmail = "autoTest@gmail.com";
  final String testPassword = "TestPass123";

  String? _profilePictureUrl;

  // Test trail data
  final String testTrailId = "test_trail_123";
  final String trailUploadTestID = "test_trail_upload_123";

  // Function to add logs dynamically and auto-scroll
  void _addLog(String functionName, String message, {bool isSuccess = true}) {
    setState(() {
      _logMessages.add(
        isSuccess
            ? "✔️ [$functionName] $message"
            : "❌ [$functionName] $message",
      );
    });

    // Scroll to bottom after update
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // ✅ Function: Authentication Test (Register, Login, Logout, Delete)
  Future<void> _runAuthTest() async {
    _logMessages.clear();
    _addLog("TEST START", "Starting Authentication Test...");

    _addLog("TEST INFO", "Using Email: $testEmail");
    _addLog("TEST INFO", "Using Password: $testPassword");

    try {
      _addLog("register()", "Calling register($testEmail, $testPassword)");
      final userCredential = await dataManager.register(
        testEmail,
        testPassword,
      );
      if (userCredential != null) {
        _addLog(
          "register()",
          "Registration successful: ${userCredential.user?.email}",
        );
      } else {
        _addLog("register()", "Registration failed", isSuccess: false);
        return;
      }

      _addLog("getCurrentUser()", "Checking user authentication status...");
      final user = dataManager.getCurrentUser();
      if (user != null) {
        _addLog("getCurrentUser()", "User is logged in: ${user.email}");
      } else {
        _addLog(
          "getCurrentUser()",
          "User is not logged in after registration",
          isSuccess: false,
        );
        return;
      }

      _addLog("signOut()", "Calling signOut()");
      await dataManager.signOut();
      if (dataManager.getCurrentUser() == null) {
        _addLog("signOut()", "User successfully signed out");
      } else {
        _addLog("signOut()", "Sign out failed", isSuccess: false);
      }

      // check the login
      _addLog("signIn()", "Calling signIn($testEmail, $testPassword)");
      final userCredential2 = await dataManager.signIn(testEmail, testPassword);
      if (userCredential2 != null) {
        _addLog(
          "signIn()",
          "Sign in successful: ${userCredential2.user?.email}",
        );
      } else {
        _addLog("signIn()", "Sign in failed", isSuccess: false);
        return;
      }

      // delete the user
      _addLog("deleteUser()", "Calling deleteUser()");
      await dataManager.deleteUser();
      if (dataManager.getCurrentUser() == null) {
        _addLog("deleteUser()", "User successfully deleted");
      } else {
        _addLog("deleteUser()", "User deletion failed", isSuccess: false);
      }

      _addLog("TEST END", "Authentication Test Completed Successfully!");
    } catch (e) {
      _addLog("ERROR", "Exception caught: $e", isSuccess: false);
    }
  }

  // ✅ Function: Manually Delete Test User
  Future<void> _deleteTestUserManually() async {
    _logMessages.clear();
    _addLog("TEST START", "Manually Deleting Test User...");

    try {
      // login into the test user
      _addLog("signIn()", "Calling signIn($testEmail, $testPassword)");
      final userCredential = await dataManager.signIn(testEmail, testPassword);
      if (userCredential != null) {
        _addLog(
          "signIn()",
          "Sign in successful: ${userCredential.user?.email}",
        );
      } else {
        _addLog(
          "signIn()",
          "Sign in failed, user is not exist",
          isSuccess: false,
        );
        return;
      }

      // delete the user
      _addLog("deleteUser()", "Calling deleteUser()");
      await dataManager.deleteUser();
      if (dataManager.getCurrentUser() == null) {
        _addLog("deleteUser()", "User successfully deleted");
      } else {
        _addLog("deleteUser()", "User deletion failed", isSuccess: false);
      }
    } catch (e) {
      _addLog("ERROR", "Exception caught: $e", isSuccess: false);
    }
  }

  Future<void> _runUserTest() async {
    _logMessages.clear();
    _addLog("TEST START", "Starting User Test...");

    _addLog("TEST INFO", "Using Email: $testEmail");
    _addLog("TEST INFO", "Using Password: $testPassword");

    try {
      // register a new user
      _addLog("register()", "Calling register($testEmail, $testPassword)");
      final userCredential =
          await dataManager.register(testEmail, testPassword);
      if (userCredential != null) {
        _addLog(
          "register()",
          "Registration successful: ${userCredential.user?.email}",
        );
      } else {
        _addLog("register()", "Registration failed", isSuccess: false);
        return;
      }
      // creae a user profile
      _addLog("createUserProfile()", "Calling createUserProfile()");
      await dataManager.createUserProfile(
        userCredential.user!.uid,
        "Test User",
        testEmail,
      );
      _addLog("createUserProfile()", "User profile created successfully");

      // Get user profile
      _addLog("getUserProfile()", "Calling getUserProfile()");
      final userProfileStream =
          dataManager.getUserProfile(userCredential.user!.uid);
      userProfileStream.listen((event) {
        if (event.exists) {
          final userProfile = event.data() as Map<String, dynamic>?;
          _addLog("getUserProfile()", "User profile retrieved successfully");
          _addLog("getUserProfile()", "User Name: ${userProfile?['name']}");
          _addLog("getUserProfile()", "User Email: ${userProfile?['email']}");

          // Check if the user profile contains the expected data
          if (userProfile?['name'] == "Test User" &&
              userProfile?['email'] == testEmail) {
            _addLog(
              "getUserProfile()",
              "User profile data is correct",
            );
          } else {
            _addLog("getUserProfile()", "User profile data is incorrect",
                isSuccess: false);
          }
        } else {
          _addLog("getUserProfile()", " User profile does not exist",
              isSuccess: false);
        }
      });
      // get user preferences
      _addLog("getUserPreferences()", "Calling getUserPreferences()");
      final userPreferences =
          await dataManager.getUserPreferences(userCredential.user!.uid);
      if (userPreferences != null) {
        _addLog(
            "getUserPreferences()", "User preferences retrieved successfully");
        _addLog(
            "getUserPreferences()", "User Theme: ${userPreferences['theme']}");
        _addLog("getUserPreferences()",
            "User Notifications: ${userPreferences['notifications']}");
        _addLog("getUserPreferences()",
            "User Language: ${userPreferences['language']}");
      } else {
        _addLog("getUserPreferences()", "User preferences not found",
            isSuccess: false);
      }

      // update user preferences
      _addLog("updatePreferences()", "Calling updatePreferences()");
      await dataManager.updatePreferences(
          userCredential.user!.uid, "theme", "dark");
      await dataManager.updatePreferences(
          userCredential.user!.uid, "notifications", false);
      await dataManager.updatePreferences(
          userCredential.user!.uid, "language", "he");

      // show the user new preferences
      final updatedUserPreferences =
          await dataManager.getUserPreferences(userCredential.user!.uid);
      if (updatedUserPreferences != null) {
        _addLog("updatePreferences()", "User preferences updated successfully");
        _addLog("updatePreferences()",
            "User Theme: ${updatedUserPreferences['theme']}");
        _addLog("updatePreferences()",
            "User Notifications: ${updatedUserPreferences['notifications']}");
        _addLog("updatePreferences()",
            "User Language: ${updatedUserPreferences['language']}");

        // Check if the updated preferences are correct
        if (updatedUserPreferences['theme'] == "dark" &&
            updatedUserPreferences['notifications'] == false &&
            updatedUserPreferences['language'] == "he") {
          _addLog("updatePreferences()", "User preferences are correct");
        } else {
          _addLog("updatePreferences()", "User preferences are incorrect",
              isSuccess: false);
        }
      } else {
        _addLog("updatePreferences()", "User preferences not found",
            isSuccess: false);
      }

      _addLog("updatePreferences()", "User preferences updated successfully");

      // get a user hiking history need to be empty
      _addLog("showHikingHistory()", "Calling showHikingHistory()");

      final hikingHistory =
          await dataManager.showHikingHistory(userCredential.user!.uid);
      if (hikingHistory.isEmpty) {
        _addLog("showHikingHistory()", "Hiking history is empty");
      } else {
        _addLog("showHikingHistory()", "Hiking history is not empty",
            isSuccess: false);
      }

      // create a hike then add it to the user hiking history
      _addLog("createTrail()", "Creating a new trail");
      await dataManager.createTrail(testTrailId, {
        'trackId': 987654321,
        'trailDetails': {
          'name': 'Test Mountain Trail',
          'difficulty': 'Medium',
          'length': 12.5,
          'elevation': 450,
          'location': 'Test Mountain Range',
          'description': 'A beautiful test trail for hiking enthusiasts'
        },
        'gpx': 'sample_gpx_data_for_test'
      });
      _addLog("createTrail()", "Trail created successfully");

      // Add the trail to the user's hiking history
      _addLog("addTrailToHistory()", "Adding trail to user's hiking history");
      await dataManager.addTrailToHistory(
          userCredential.user!.uid, testTrailId);
      _addLog("addTrailToHistory()",
          "Trail added to user's hiking history successfully");

      // Verify the trail is in the user's hiking history
      _addLog("showHikingHistory()", "Retrieving user's hiking history");
      final updatedHikingHistory =
          await dataManager.showHikingHistory(userCredential.user!.uid);
      if (updatedHikingHistory.isNotEmpty) {
        _addLog("showHikingHistory()", "Hiking history retrieved successfully");
        _addLog("showHikingHistory()",
            "Trail ID: ${updatedHikingHistory[0]['trailId']}");
      } else {
        _addLog("showHikingHistory()", "Hiking history is empty",
            isSuccess: false);
      }

      // END PART
      // delete the user
      _addLog("deleteUser()", "Calling deleteUser()");
      await dataManager.deleteUser();
      if (dataManager.getCurrentUser() == null) {
        _addLog("deleteUser()", "User successfully deleted");
      } else {
        _addLog("deleteUser()", "User deletion failed", isSuccess: false);
      }
      _addLog("TEST END", "User Test Completed Successfully!");
    } catch (e) {
      _addLog("ERROR", "Exception caught: $e", isSuccess: false);
    }
  }

  Future<void> _runAdminUserTest() async {
    _logMessages.clear();
    _addLog("TEST START", "Starting Admin User Test...");

    String adminEmail = "adminAutoTest@example.com";
    String adminPassword = "123456@hacb";
    try {
      // login into admin account
      _addLog("signIn()", "Calling signIn($adminEmail, $adminPassword)");
      final adminUserCredential =
          await dataManager.signIn(adminEmail, adminPassword);
      if (adminUserCredential != null) {
        _addLog(
          "signIn()",
          "Sign in successful: ${adminUserCredential.user?.email}",
        );
      } else {
        _addLog(
          "signIn()",
          "Sign in failed, user is not exist",
          isSuccess: false,
        );
        return;
      }

      // check if is admin
      _addLog("isAdmin()", "Calling isAdmin()");
      if (dataManager.isAdmin()) {
        _addLog("isAdmin()", "User is an admin");
      } else {
        _addLog("isAdmin()", "User is not an admin", isSuccess: false);
        return;
      }

      // END PART
      _addLog("TEST END", "Amin User Test Completed Successfully!");
    } catch (e) {
      _addLog("ERROR", "Exception caught: $e", isSuccess: false);
    }
  }

//
//
//
//
//
//
//
//
//
//
//
//
//
//

// ✅ Function: Upload Profile Picture
  Future<void> _uploadProfilePictureTest() async {
    _logMessages.clear();
    _addLog("TEST START", "Starting Upload Profile Picture Test...");

    try {
      // Register a new user
      _addLog("register()", "Calling register($testEmail, $testPassword)");
      final userCredential =
          await dataManager.register(testEmail, testPassword);
      if (userCredential != null) {
        _addLog(
          "register()",
          "Registration successful: ${userCredential.user?.email}",
        );
      } else {
        _addLog("register()", "Registration failed", isSuccess: false);
        return;
      }

      // Create a user profile
      _addLog("createUserProfile()", "Creating user profile");
      await dataManager.createUserProfile(
        userCredential.user!.uid,
        "Test User",
        testEmail,
      );
      _addLog("createUserProfile()", "User profile created successfully");

      // Upload a profile picture
      // ----------------------------------------
      _addLog("uploadPicture()", "Uploading profile picture");
      final imageUrl = await dataManager
          .uploadProfilePictureManual(userCredential.user!.uid);
      if (imageUrl.isNotEmpty) {
        _addLog("uploadPicture()", "Profile picture uploaded successfully");
        setState(() {
          _profilePictureUrl =
              "https://www.pix-star.com/blog/wp-content/uploads/2021/05/digital-photo-frames.jpg";
        });
      } else {
        _addLog("uploadPicture()", "Profile picture upload failed",
            isSuccess: false);
        return;
      }

      print("Image URL: $_profilePictureUrl");

      //  ----------------------------------------
      // Delete the user
      _addLog("deleteUser()", "Cleaning up - deleting test user");
      try {
        await dataManager.deleteUser();
        _addLog("deleteUser()", "User deletion completed");
      } catch (e) {
        _addLog("deleteUser()", "Error during user deletion: $e",
            isSuccess: false);
        return;
      }

      if (dataManager.getCurrentUser() == null) {
        _addLog("deleteUser()", "User successfully deleted");
      } else {
        _addLog("deleteUser()", "User deletion failed", isSuccess: false);
      }

      _addLog(
          "TEST END", "Upload Profile Picture Test Completed Successfully!");
    } catch (e) {
      _addLog("ERROR", "Exception caught: $e", isSuccess: false);
    }
  }

  Future<void> _pickAndUploadProfilePicture() async {
    // register a new user
    _addLog("register()", "Calling register($testEmail, $testPassword)");
    final userCredential = await dataManager.register(testEmail, testPassword);
    if (userCredential != null) {
      _addLog(
        "register()",
        "Registration successful: ${userCredential.user?.email}",
      );
    } else {
      _addLog("register()", "Registration failed", isSuccess: false);
      return;
    }

    // use the data manager to pick an image and upload it dataMaget.uploadPicture
    _addLog("uploadPicture()", "Uploading profile picture");

    // TODO: Uncomment the following lines to test the upload functionality
    // // uploadPictureManual
    // final result = await dataManager.uploadPictureManual(
    //     UploadType.userPhoto, userCredential.user!.uid);
    // if (result) {
    //   _addLog("uploadPicture()", "Profile picture uploaded successfully");
    // } else {
    //   _addLog("uploadPicture()", "Profile picture upload failed",
    //       isSuccess: false);
    // }

    // // Get the user's profile picture
    // _addLog("getUserProfilePicture()", "Getting user profile picture");
    // final profilePictureUrl =
    //     await dataManager.getUserProfilePicture(userCredential.user!.uid);
    // if (profilePictureUrl.isNotEmpty) {
    //   _addLog(
    //       "getUserProfilePicture()", "Profile picture URL: $profilePictureUrl");
    //   setState(() {
    //     _profilePictureUrl = profilePictureUrl;
    //   });
    // } else {
    //   _addLog("getUserProfilePicture()", "Profile picture URL not found",
    //       isSuccess: false);
    // }

    // Delete the user profile picture
  }

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

  Future<void> _uploadTrailImageTest() async {
    _logMessages.clear();
    _addLog("TEST START", "Starting Upload Trail Image Test...");
    String userId = "trail_upload_images@gmail.com";
    String userPassword = "123456@hacb";

    try {
      // Register a new user
      // _addLog("register()", "Calling register($userId, $userPassword)");
      // final userCredential = await dataManager.register(userId, userPassword);
      // if (userCredential != null) {
      //   _addLog(
      //     "register()",
      //     "Registration successful: ${userCredential.user?.email}",
      //   );
      // } else {
      //   _addLog("register()", "Registration failed", isSuccess: false);
      //   return;
      // }

      // create trail
      // 1. Create a trail
      // _addLog("createTrail()", "Creating test trail");
      // await dataManager.createTrail(trailUploadTestID, {
      //   'trackId': 000000000,
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
      // _addLog("createTrail()", "Trail created successfully");

      // 2. Get the trail data
      _addLog("getTrail()", "Retrieving trail data");
      // Adding a listener for trail data
      var subscription =
          dataManager.getTrail(trailUploadTestID).listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          _addLog(
              "getTrail()", "Trail retrieved: ${data['trailDetails']['name']}");
          _addLog("getTrail()",
              "Trail difficulty: ${data['trailDetails']['difficulty']}");
          _addLog("getTrail()",
              "Trail length: ${data['trailDetails']['length']}km");
        } else {
          _addLog("getTrail()", "Trail not found", isSuccess: false);
        }
      });

      // Upload a profile picture
      String? image1URL = "";

      // Upload a trail image
      _addLog("uploadTrailImage()", "Uploading trail image");
      image1URL = await dataManager.uploadTrailImageManual(trailUploadTestID);
      if (image1URL != null) {
        _addLog("uploadTrailImage()", "Trail image uploaded successfully");
      } else {
        _addLog("uploadTrailImage()", "Trail image upload failed",
            isSuccess: false);
        return;
      }

      // delay for 10 seconds to make sure the image is uploaded
      await Future.delayed(const Duration(seconds: 10));
      // delete the trail images
      _addLog("deleteTrailImage()", "Deleting trail images");
      await dataManager.deleteTrailImage(trailUploadTestID, image1URL);
      _addLog("deleteTrailImage()", "Trail images deleted successfully");

      // delete the trail
      _addLog("TEST END", "Upload Trail Image Test Completed Successfully!");
    } catch (e) {
      _addLog("ERROR", "Exception caught: $e", isSuccess: false);
    }
  }

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

  // ✅ Function: Trail Management Test
  Future<void> _runTrailTest() async {
    _logMessages.clear();
    _addLog("TEST START", "Starting Trail Management Test...");

    try {
      // Register a test user first
      _addLog("signIn()", "Calling signIn($testEmail, $testPassword)");
      var userCredential = await dataManager.signIn(testEmail, testPassword);

      if (userCredential == null) {
        _addLog("register()", "No user account, creating one");
        userCredential = await dataManager.register(testEmail, testPassword);
        if (userCredential == null) {
          _addLog("register()", "Failed to create test user", isSuccess: false);
          return;
        }
      }

      // 1. Create a trail
      _addLog("createTrail()", "Creating test trail");
      await dataManager.createTrail(testTrailId, {
        'trackId': 987654321,
        'trailDetails': {
          'name': 'Test Mountain Trail',
          'difficulty': 'Medium',
          'length': 12.5,
          'elevation': 450,
          'location': 'Test Mountain Range',
          'description': 'A beautiful test trail for hiking enthusiasts'
        },
        'gpx': 'sample_gpx_data_for_test'
      });
      _addLog("createTrail()", "Trail created successfully");

      // 2. Get the trail data
      _addLog("getTrail()", "Retrieving trail data");
      // Adding a listener for trail data
      var subscription = dataManager.getTrail(testTrailId).listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          _addLog(
              "getTrail()", "Trail retrieved: ${data['trailDetails']['name']}");
          _addLog("getTrail()",
              "Trail difficulty: ${data['trailDetails']['difficulty']}");
          _addLog("getTrail()",
              "Trail length: ${data['trailDetails']['length']}km");
        } else {
          _addLog("getTrail()", "Trail not found", isSuccess: false);
        }
      });

      // Wait a moment to ensure the listener has received data
      await Future.delayed(const Duration(seconds: 2));

      // 3. Edit trail details
      _addLog("editTrailDetails()", "Updating trail difficulty");
      bool success =
          await dataManager.editTrailDetails(testTrailId, 'difficulty', 'Hard');

      if (success) {
        _addLog("editTrailDetails()", "Trail difficulty updated successfully");
      } else {
        _addLog("editTrailDetails()", "Failed to update trail difficulty",
            isSuccess: false);
      }

      // 4. Update trail description
      _addLog("writeDescription()", "Updating trail description");
      success = await dataManager.writeDescription(testTrailId,
          'This trail has been updated with a new detailed description for testing purposes.');

      if (success) {
        _addLog("writeDescription()", "Trail description updated successfully");
      } else {
        _addLog("writeDescription()", "Failed to update trail description",
            isSuccess: false);
      }

      // 5. Test trail ratings
      _addLog("updateTrailRating()", "Setting trail rating");
      await dataManager.updateTrailRating(testTrailId, 4.5);
      _addLog("updateTrailRating()", "Trail rating set successfully");

      // 6. Test mosquito ratings
      _addLog("updateMosquitoRating()", "Setting mosquito rating");
      await dataManager.updateMosquitoRating(testTrailId, 2.5);
      _addLog("updateMosquitoRating()", "Mosquito rating set successfully");

      // Wait a moment to ensure updated data is available
      await Future.delayed(const Duration(seconds: 2));
      // Cancel subscription to avoid memory leaks
      subscription.cancel();

      // Clean up - delete the trail
      _addLog("Cleanup", "Deleting test trail");
      await dataManager.deleteTrail(testTrailId);
      _addLog("Cleanup", "Test trail deleted");

      // Final cleanup - sign out
      await dataManager.signOut();
      _addLog("signOut()", "User signed out");

      _addLog("TEST END", "Trail Management Test Completed Successfully!");
    } catch (e) {
      _addLog("ERROR", "Exception caught: $e", isSuccess: false);
    }
  }

  // ✅ List of Test Functions (Dynamically Generate Buttons)
  final List<Map<String, dynamic>> _tests = [];

  @override
  void initState() {
    super.initState();
    _tests.addAll([
      {"name": "Run Authentication Test", "function": _runAuthTest},
      {"name": "Run User Test", "function": _runUserTest},
      {"name": "Run Admin User Test", "function": _runAdminUserTest},
      {"name": "Upload Profile Picture", "function": _uploadProfilePictureTest},
      {"name": "Upload Trail Images", "function": _uploadTrailImageTest},
      {"name": "Run Trail Management Test", "function": _runTrailTest},
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DataManager Manual Tests"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteTestUserManually,
          ),
          IconButton(
            icon: const Icon(Icons.image, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DataManagerImageTests(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAndUploadProfilePicture,
              child: _profilePictureUrl != null
                  ? Image.network(
                      _profilePictureUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.black,
                          child: const Icon(Icons.error, color: Colors.red),
                        );
                      },
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      color: Colors.black,
                    ),
            ),
            const Text(
              "🔍 Automatic Tests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Generate buttons dynamically
            Expanded(
              child: ListView.builder(
                itemCount: _tests.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: _tests[index]["function"],
                      child: Text(_tests[index]["name"]),
                    ),
                  );
                },
              ),
            ),
            const Divider(),

            // Log Section with "Copy All" button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "📜 Test Log",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final allLogs = _logMessages.join('\n');
                    Clipboard.setData(ClipboardData(text: allLogs));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('All logs copied to clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text("Copy All"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Single SelectableText for multi-line selection
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity, // Make the container take full width
                constraints: BoxConstraints(
                  maxHeight: 300, // Set a fixed height for the log container
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: SelectableText(
                      _logMessages.join('\n'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: "monospace",
                        color: Color.fromARGB(
                            255, 12, 181, 38), // Keep log text white
                        height: 1.2, // Adjust line height for terminal look
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
