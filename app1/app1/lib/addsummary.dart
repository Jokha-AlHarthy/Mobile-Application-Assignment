// Import Flutter material design library for UI components
import 'package:flutter/material.dart';
// Import custom database handler to interact with Firebase
import 'database.dart';

// Define a stateful widget to add a new summary
class Addsummary extends StatefulWidget {
  // Constructor with optional key
  const Addsummary({super.key});

  // Create the mutable state for this widget
  @override
  AddsummaryState createState() => AddsummaryState();
}

// Define the state class for Addsummary
class AddsummaryState extends State<Addsummary> {
  // GlobalKey used to manage and validate the form state
  final formKey = GlobalKey<FormState>();

  // Text controllers to retrieve user input from the form fields
  final descriptionController = TextEditingController();
  final courseController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final imageNameController =
      TextEditingController(); // Controller for local image file name

  // Dispose controllers when the widget is removed from the widget tree to free up resources
  @override
  void dispose() {
    descriptionController.dispose();
    courseController.dispose();
    priceController.dispose();
    quantityController.dispose();
    imageNameController.dispose();
    super.dispose();
  }

  // Build the UI of the Addsummary screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar at the top with title
      appBar: AppBar(title: const Text('Add New Summary',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF0E1B35), // AppBar background color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Set arrow color to white
          onPressed: () {
            Navigator.pop(context);},
        ),
      ),

      // Form widget that wraps all input fields
      body: Form(
        key: formKey, // Assign the form key for validation
        child: ListView(
          padding: const EdgeInsets.all(16), // Add padding around form fields
          children: <Widget>[
            // Input field for summary course
            TextFormField(
              controller: courseController,
              decoration: const InputDecoration(labelText: 'Course', labelStyle: TextStyle(color: Color(0xFF0E1B35)),),

              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Please enter a course'
                          : null,
            ),
            // Input field for summary price
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price', labelStyle: TextStyle(color: Color(0xFF0E1B35)),),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Please enter the price'
                          : null,
            ),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Color(0xFF0E1B35)),),
              validator:
                  (value) =>
              value == null || value.isEmpty
                  ? 'Please enter the Description of your summary!'
                  : null,
            ),
            // Input field for summary quantity
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity', labelStyle: TextStyle(color: Color(0xFF0E1B35)),),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Please enter a quantity'
                          : null,
            ),
            // Input field for image file name (stored in assets)
            TextFormField(
              controller: imageNameController,
              decoration: const InputDecoration(
                labelText: 'Image Name (assets folder)',
                  labelStyle: TextStyle(color: Color(0xFF0E1B35)),
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Please enter the image name'
                          : null,
            ),
            // Button to submit and register the summary
            const SizedBox(height: 20,),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E1B35),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                // Validate all form fields before proceeding
                if (formKey.currentState!.validate()) {
                  // Create a new summary map with all input values
                  var newsummary = {
                    'description': descriptionController.text,
                    'course': courseController.text,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'quantity': int.tryParse(quantityController.text) ?? 0,
                    'imageName': imageNameController.text, // Include image name
                  };
                  // Call register function to save summary in Firebase
                  registersummary(newsummary, context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), // Button label
            ),
            // Button to cancel and go back to the previous screen

            const SizedBox(height: 20,),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E1B35),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () => Navigator.pop(context), // Navigate back// Set button color
              child: const Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), // Button label
            ),
          ],
        ),
      ),
    );
  }

  // Function to add a new summary to Firebase using the database class
  Future<void> registersummary(
    Map<String, dynamic> newsummary,
    BuildContext context,
  ) async {
    await Database().addsummary(
      newsummary,
    ); // Call database method to save summary
    if (mounted) {
      Navigator.pop(context); // Navigate back to summary list screen
    }
  }
}
