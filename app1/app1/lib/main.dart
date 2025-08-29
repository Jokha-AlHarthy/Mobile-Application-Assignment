// Importing the Flutter material design package for UI components
import 'package:flutter/material.dart';

// Importing the Firebase core package to initialize Firebase
import 'package:firebase_core/firebase_core.dart';

import 'login.dart';

// The main function is the entry point of the Flutter application
void main() async {
  // Ensures that widget binding is initialized before Firebase setup (required for async calls in main)
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes the Firebase app (must be done before using Firebase services)
  await Firebase.initializeApp();

  // Launches the Flutter application with a MaterialApp widget as the root
  runApp(
    const MaterialApp(
      // Title of the app (used in Android task switcher, etc.)
      title: 'Mulakhasy App',

      // Disables the debug banner in the top-right corner of the app
      debugShowCheckedModeBanner: false,

      // Sets the home screen of the app to be the Login widget
      home: Login(),
    ),
  );
}
