// Import Flutter material package for UI components
import 'package:flutter/material.dart';
// Import Firebase Authentication package to handle user authentication
import 'package:firebase_auth/firebase_auth.dart';
// Import Email Validator package to validate email addresses
import 'package:email_validator/email_validator.dart';

// Import internal project files
import 'login.dart';
import 'database.dart';

// Define a StatefulWidget for Registration screen
class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  RegistrationState createState() => RegistrationState();
}

// State class for Registration widget
class RegistrationState extends State<Registration> {
  final formKey = GlobalKey<FormState>(); // Key to validate the form
  final auth = FirebaseAuth.instance; // Firebase Auth instance

  // Variables to store user input
  String fullName = '';
  String address = '';
  String contactNo = '';
  String email = '';
  String password = '';
  String admin = 'N'; // Default value for admin status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF0E1B35), // AppBar background color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Set arrow color to white
          onPressed: () {
            Navigator.pop(context); // Action on back button press
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the form
        child: Form(
          key: formKey, // Assign form key
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Align items to the start
              children: [
                Image.asset(
                  'images/MULAKHASY.jpg',
                  width: 250,
                  height: 250,
                ),
                const SizedBox(height: 20), // Spacer
                // Text field for full name input
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      fullName = value.trim(); // Update full name value
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Text field for address input
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      address = value.trim(); // Update address value
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Text field for contact number input
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your contact number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      contactNo = value.trim(); // Update contact number value
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Text field for email input
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!EmailValidator.validate(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      email = value.trim(); // Update email value
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Text field for password input
                TextFormField(
                  obscureText: true, // Hide password characters
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      password = value.trim(); // Update password value
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Button to register the user

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(0xFF0E1B35), // Change this to any color you want
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          25), // Optional: rounded corners
                    ),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // Validate form
                      await Database().registerUser(
                        // Call database method to register user
                        fullName,
                        address,
                        contactNo,
                        email,
                        password,
                        admin,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    }
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                // Text button to navigate back to Login screen
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: const Text('Already have an account? Login here.',
                  style: TextStyle(color: Color(0xFF0E1B35)),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
