// Importing Firebase Realtime Database package for database operations
import 'package:firebase_database/firebase_database.dart';
// Importing Firebase Authentication package for user authentication
import 'package:firebase_auth/firebase_auth.dart';
// Importing crypto package to hash passwords
import 'package:crypto/crypto.dart';
// Importing dart:convert to handle encoding
import 'dart:convert';
// Importing Flutter foundation package for debugging
import 'package:flutter/foundation.dart';
// Importing intl package for date formatting
import 'package:intl/intl.dart';

// Defining a class to manage Firebase database operations
class Database {
  // Creating references to various database nodes
  final DatabaseReference db1 = FirebaseDatabase.instance.ref().child("users");
  final DatabaseReference db2 = FirebaseDatabase.instance.ref().child(
    "summaries",
  );
  final DatabaseReference db3 = FirebaseDatabase.instance.ref().child(
    "feedbacks",
  );
  final DatabaseReference db4 = FirebaseDatabase.instance.ref().child("orders");

  // Function to register a user and store their information in the database
  Future<void> registerUser(
    String fullName,
    String address,
    String contactNo,
    String email,
    String password,
    String admin,
  ) async {
    try {
      // Create a new user in Firebase Authentication
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final uid = userCredential.user!.uid;

      // Save user information in the Realtime Database
      await db1.child(uid).set({
        'fullName': fullName,
        'address': address,
        'contactNo': contactNo,
        'email': email,
        'passwordHash': sha256.convert(utf8.encode(password)).toString(),
        'admin': admin,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error registering user: $e'); // Print error if in debug mode
      }
      rethrow; // Re-throw the exception
    }
  }

  // Function to update user profile data
  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> updatedData,
  ) async {
    await db1.child(uid).update(updatedData);
  }

  // Function to fetch all users from the database
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final snapshot = await db1.get();
    if (snapshot.exists) {
      Map data = snapshot.value as Map;
      List<Map<String, dynamic>> userList = [];
      data.forEach((key, value) {
        userList.add({
          'uid': key,
          'fullName': value['fullName'] ?? '',
          'email': value['email'] ?? '',
          'admin': value['admin'] ?? 'N',
        });
      });
      return userList;
    } else {
      return []; // Return empty list if no users exist
    }
  }

  // Function to update admin status of a user
  Future<void> updateAdminStatus(String uid, String newValue) async {
    await db1.child(uid).update({'admin': newValue});
  }

  // Function to fetch all summaries from the database
  Future<List<Map<String, dynamic>>> fetchsummaries() async {
    DataSnapshot snapshot = await db2.get();

    if (snapshot.value != null) {
      Map<String, dynamic> summariesMap = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      return summariesMap.entries.map((entry) {
        var summary = Map<String, dynamic>.from(entry.value);
        summary['key'] = entry.key;
        return summary;
      }).toList();
    } else {
      return []; // Return empty list if no summaries exist
    }
  }

  // Function to delete a summary using its key
  Future<void> deletesummary(String key) async {
    await db2.child(key).remove();
  }

  // Function to update an existing summary's data
  Future<void> updatesummary(String key, Map<String, dynamic> summary) async {
    await db2.child(key).update(summary);
  }

  // Function to add a new summary
  Future<void> addsummary(Map<String, dynamic> summary) async {
    await db2.push().set(summary);
  }

  // Function to add feedback data
  Future<void> addFeedback(Map<String, dynamic> feedbackData) async {
    await db3.push().set(feedbackData);
  }

  // Function to fetch orders made by a specific user
  Future<List<Map<String, dynamic>>> fetchOrders(String userEmail) async {
    DataSnapshot snapshot =
        await db4.orderByChild('userEmail').equalTo(userEmail).get();
    if (snapshot.value == null) return [];
    Map data = snapshot.value as Map;
    return data.entries.map<Map<String, dynamic>>((e) {
      var v = Map<String, dynamic>.from(e.value);
      v['orderKey'] = e.key;
      print('Fetched order: ${jsonEncode(v)}');
      return v;
    }).toList();
  }

  // Function for buying a summary (adds an order and reduces available quantity)
  Future<void> buysummary({
    required String userFullName,
    required String userEmail,
    required Map<String, dynamic> summary,
    required int quantity,
  }) async {
    final summaryKey = summary['key'];
    final int available =
        (summary['quantity'] is int)
            ? summary['quantity']
            : int.tryParse(summary['quantity'].toString()) ?? 0;
    if (quantity <= 0 || quantity > available)
      throw Exception("Invalid quantity");
    final order = {
      'userFullName': userFullName,
      'userEmail': userEmail,
      'summaryKey': summaryKey,
      'summaryName': summary['course'],
      'summaryPrice': summary['price'],
      'summaryImage': summary['imageName'],
      'quantity': quantity,
      'orderDateTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    };
    await db4.push().set(order);
    await db2.child(summaryKey).update({'quantity': available - quantity});
  }

  // Function to fetch all orders (for admin view)
  Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    DataSnapshot snapshot = await db4.get();
    if (snapshot.value == null) return [];
    Map data = snapshot.value as Map;
    return data.entries.map<Map<String, dynamic>>((e) {
      var v = Map<String, dynamic>.from(e.value);
      v['orderKey'] = e.key;
      return v;
    }).toList();
  }

  // Function to fetch all the feedbacks (for admin view)
  Future<List<Map<String, dynamic>>> getAllFeedbacks() async {
    final snapshot = await db3.get(); // db3 points to "feedbacks" node

    if (snapshot.exists) {
      Map data = snapshot.value as Map;
      return data.entries.map<Map<String, dynamic>>((entry) {
        var feedback = Map<String, dynamic>.from(entry.value);
        feedback['key'] = entry.key;
        return feedback;
      }).toList();
    } else {
      return [];
    }
  }




}
