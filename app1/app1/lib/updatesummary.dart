// Import Flutter's material design library for UI components
import 'package:flutter/material.dart';
// Import custom database class to handle Firebase operations
import 'database.dart';

// Define a stateful widget for updating summary details
class Updatesummary extends StatefulWidget {
  // The unique key for the summary (used to locate it in the database)
  final String summaryKey;
  // The summary details passed from the previous screen
  final Map<String, dynamic> summaryDetails;

  // Constructor for Updatesummary with required summaryKey and summaryDetails
  const Updatesummary({
    super.key,
    required this.summaryKey,
    required this.summaryDetails,
  });

  @override
  UpdatesummaryState createState() => UpdatesummaryState();
}

// State class to handle the update logic and UI
class UpdatesummaryState extends State<Updatesummary> {
  // Global key to manage and validate the form
  final formKey = GlobalKey<FormState>();

  // Controllers to manage and retrieve user inputs
  final desController = TextEditingController();
  final courseController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  // Initialize the form fields with the current summary details
  @override
  void initState() {
    super.initState();
    courseController.text = widget.summaryDetails["course"] ?? "";
    quantityController.text =
        widget.summaryDetails["quantity"]?.toString() ?? "0";
    priceController.text =
        widget.summaryDetails["price"]?.toString() ?? "0.0";
    desController.text = widget.summaryDetails["description"] ?? "";
  }

  // Dispose controllers to free memory when screen is destroyed
  @override
  void dispose() {
    courseController.dispose();
    quantityController.dispose();
    priceController.dispose();
    desController.dispose();
    super.dispose();
  }

  // Function to update summary record in the Firebase database
  Future<void> updatesummary(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      var updatedsummary = {
        "course": courseController.text,
        "quantity": int.tryParse(quantityController.text) ?? 0,
        "price": double.tryParse(priceController.text) ?? 0.0,
        "description": desController.text,
      };

      await Database().updatesummary(widget.summaryKey, updatedsummary);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  // Build the update form UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Summary',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0E1B35),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Image.asset('images/MULAKHASY.jpg', width: 150, height: 150),
            const SizedBox(height: 30),

            TextFormField(
              controller: courseController,
              decoration: const InputDecoration(labelText: 'Course'),
              validator: (value) =>
              value == null || value.isEmpty ? 'Please enter a course' : null,
            ),
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              validator: (value) =>
              value == null || value.isEmpty ? 'Please enter a quantity' : null,
            ),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) =>
              value == null || value.isEmpty ? 'Please enter a price' : null,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: desController,
              decoration: const InputDecoration(
                labelText: 'Update the Description',
                labelStyle: TextStyle(color: Color(0xFF0E1B35)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0E1B35)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0E1B35), width: 2.0),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E1B35),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () => updatesummary(context),
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E1B35),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
