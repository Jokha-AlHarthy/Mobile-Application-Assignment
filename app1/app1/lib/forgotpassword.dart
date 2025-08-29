// Import Flutter material package for UI components
import 'package:flutter/material.dart';
// Import Firebase authentication package to reset user password
import 'package:firebase_auth/firebase_auth.dart';

// Define a stateful widget for the Forgot Password screen
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => ForgotPasswordScreenState();
}

// State class for ForgotPasswordScreen
class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controller to handle email input field
  final TextEditingController emailController = TextEditingController();
  // Form key to validate the form
  final formKey = GlobalKey<FormState>();
  // Boolean to track if loading spinner should be shown
  bool loading = false;

  // Function to send password reset email
  Future<void> resetPassword() async {
    // Validate the form; if invalid, exit function
    if (!formKey.currentState!.validate()) return;

    // Set loading state to true
    setState(() {
      loading = true;
    });

    try {
      // Attempt to send a password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      // Show success message if email is sent
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent! Check your inbox.'),
        ),
      );

      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      // Show error message if sending email failed
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      // Set loading state back to false
      setState(() {
        loading = false;
      });
    }
  }

  // Building the UI of the screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF0E1B35), // AppBar background color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // Set arrow color to white
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ), // App bar title
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adding padding around form
        child: Form(
          key: formKey, // Assign form key to Form widget
          child: Column(
            children: [
              const Text(
                'Enter your email to receive password reset link',
                style: TextStyle(fontSize: 16, color: Color(0xFF0E1B35)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20), // Spacer
              // Text field to input email
              TextFormField(
                controller: emailController,
                keyboardType:
                    TextInputType.emailAddress, // Set type course to email
                decoration: const InputDecoration(
                  labelText: ('Email'),
                  labelStyle: TextStyle(color: Color(0xFF0E1B35)),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20), // Spacer
              // Show loading indicator or reset button based on loading state
              loading
                  ? const CircularProgressIndicator() // Show loading spinner if loading
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
                          resetPassword, // Call resetPassword on button press
                      child: const Text('Send Reset Email', style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      ), ),
            ],
          ),
        ),
      ),
    );
  }
}
