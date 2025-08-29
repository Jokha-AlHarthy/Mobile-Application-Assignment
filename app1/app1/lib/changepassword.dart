// Importing Flutter material design package for UI components
import 'package:flutter/material.dart';
// Importing Firebase Authentication package for user management
import 'package:firebase_auth/firebase_auth.dart';
// Importing Firebase Database package for real-time database access
import 'package:firebase_database/firebase_database.dart';
// Importing crypto package for hashing passwords
import 'package:crypto/crypto.dart';
// Importing dart:convert package for UTF8 encoding
import 'dart:convert';

// Define a stateful widget for the Change Password screen
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => ChangePasswordScreenState();
}

// State class for ChangePasswordScreen
class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Key to identify the form and validate it
  final formKey = GlobalKey<FormState>();
  // Controller for the old password input
  final oldPasswordController = TextEditingController();
  // Controller for the new password input
  final newPasswordController = TextEditingController();
  // Controller for the confirm password input
  final confirmPasswordController = TextEditingController();

  // Variable to track loading state
  bool loading = false;

  // Function to handle password change process
  Future<void> changePassword() async {
    // Validate the form fields
    if (!formKey.currentState!.validate()) return;

    // Set loading to true to show progress indicator
    setState(() {
      loading = true;
    });

    try {
      // Get the current logged-in user
      final user = FirebaseAuth.instance.currentUser;
      // Get user's email
      final email = user?.email;
      // Get user's UID
      final uid = user?.uid;

      // Step 1: Re-authenticate the user with old password
      final cred = EmailAuthProvider.credential(
        email: email!,
        password: oldPasswordController.text.trim(),
      );
      await user!.reauthenticateWithCredential(cred);

      // Step 2: Update the user's password in Firebase Authentication
      await user.updatePassword(newPasswordController.text.trim());

      // Step 3: Hash the new password
      String passwordHash = sha256
          .convert(utf8.encode(newPasswordController.text.trim()))
          .toString();
      // Update the hashed password in Firebase Realtime Database
      await FirebaseDatabase.instance.ref().child('users/$uid').update({
        'passwordHash': passwordHash,
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );
      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      // Show an error message if password change fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password change failed: ${e.toString()}')),
      );
    } finally {
      // Set loading to false to stop progress indicator
      setState(() {
        loading = false;
      });
    }
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF0E1B35), // AppBar background color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // Set arrow color to white
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      // App bar title
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the form
        child: Form(
          key: formKey, // Assigning form key
          child: Column(
            children: [
              // Text field for entering old password
              TextFormField(
                controller: oldPasswordController,
                obscureText: true, // Hiding input for password field
                decoration: const InputDecoration(labelText: 'Old Password', labelStyle: TextStyle(color: Color(0xFF0E1B35)),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter old password'
                    : null,
              ),
              const SizedBox(height: 16), // Spacer between fields

              // Text field for entering new password
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password',                 labelStyle: TextStyle(color: Color(0xFF0E1B35)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Enter new password';
                  if (value.length < 6) return 'Password at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Text field for confirming new password
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm New Password',                 labelStyle: TextStyle(color: Color(0xFF0E1B35)),
                    ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Confirm password';
                  if (value != newPasswordController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 32), // Spacer before button

              // Show a loading spinner or Change Password button
              loading
                  ? const CircularProgressIndicator() // Show loading indicator if loading
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(
                            0xFF0E1B35), // Change this to any color you want
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              25), // Optional: rounded corners
                        ),
                      ),

                      onPressed:
                          changePassword, // Call _changePassword on button press
                      child: const Text(
                        'Change Password',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ), // Button text
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
