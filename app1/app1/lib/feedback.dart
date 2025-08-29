// Import necessary Flutter material design package
import 'package:flutter/material.dart';
// Import Firebase authentication package to get current user info
import 'package:firebase_auth/firebase_auth.dart';
// Import intl package for date formatting
import 'package:intl/intl.dart';
// Importing the Database class that handles Firebase operations
import 'database.dart';

// Define a stateful widget for FeedbackScreen
class FeedbackScreen extends StatefulWidget {
  final String fullName; // fullName of the user submitting feedback

  // Constructor requires fullName as a parameter
  const FeedbackScreen({super.key, required this.fullName});

  @override
  State<FeedbackScreen> createState() => FeedbackScreenState();
}

// State class for FeedbackScreen
class FeedbackScreenState extends State<FeedbackScreen> {
  int rating = 0; // Rating value (1 to 5 stars)
  final TextEditingController feedbackController = TextEditingController(); // Controller for feedback text
  bool isSubmitting = false; // Tracks if the form is submitting

  // Function to submit feedback
  void submitFeedback() async {
    // Check if rating and feedback text are provided
    if (rating == 0 || feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter feedback and select a rating!')),
      );
      return;
    }

    // Set submitting state to true to show loading indicator
    setState(() => isSubmitting = true);

    // Get the current user's UID
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Prepare feedback data to be sent to the database
    final feedbackData = {
      'userId': uid,
      'fullName': widget.fullName,
      'feedback': feedbackController.text.trim(),
      'rating': rating,
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    };

    // Add feedback data to the database
    await Database().addFeedback(feedbackData);

    // Reset submitting state and show confirmation
    setState(() => isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your feedback!')),
    );

    // Navigate back to the previous screen
    Navigator.pop(context);
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF0E1B35), // AppBar background color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Set arrow color to white
          onPressed: () {
            Navigator.pop(context);},
        ),
      ), // AppBar with title
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: Column(
          children: [
            Image.asset('images/MULAKHASY.jpg', width: 250, height: 250,),

            const Text('How would you rate the app?', style: TextStyle(fontSize: 18)), // Instruction text

            // Row for star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border, // Filled or empty star
                    color:  Color(0xFF0E1B35),
                    size: 36,
                  ),
                  onPressed: () => setState(() => rating = index + 1), // Update rating when star clicked
                );
              }),
            ),

            const SizedBox(height: 16), // Spacing

            // TextField for writing feedback
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                labelText: ('Write your feedback'),
                labelStyle: TextStyle(color: Color(0xFF0E1B35)),
                border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0E1B35)),
      ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF0E1B35), width: 2.0),
        ),
              ),

              maxLines: 4, // Allow multiple lines
            ),

            const SizedBox(height: 24), // Spacing before button

            // Submit button or loading indicator
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0E1B35), // Change this to any color you want
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Optional: rounded corners
                ),
              ),// Optional: rounded corners
              onPressed: isSubmitting ? null : submitFeedback, // Disable button if submitting
              child: isSubmitting
                  ? const CircularProgressIndicator() // Show loading if submitting
                  : const Text('Submit',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ), // Show Submit text if not submitting
            ),
          ],
        ),
      ),
    );
  }
}
