import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'database.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final addressController = TextEditingController();
  final contactNoController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  void _exit() {
    Navigator.of(context).pop(true);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  Future<void> loadUserProfile() async {
    if (uid != null) {
      final snapshot =
      await FirebaseDatabase.instance.ref().child('users/$uid').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        fullNameController.text = data['fullName'] ?? '';
        addressController.text = data['address'] ?? '';
        contactNoController.text = data['contactNo'] ?? '';
      }
    }
  }

  Future<void> updateProfile() async {
    if (formKey.currentState!.validate()) {
      await Database().updateUserProfile(uid!, {
        'fullName': fullNameController.text,
        'address': addressController.text,
        'contactNo': contactNoController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  Future<void> deleteProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email != null) {
      final passwordController = TextEditingController();
      final dialogFormKey = GlobalKey<FormState>();

      bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Re-enter Password"),
            content: Form(
              key: dialogFormKey,
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E1B35),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (dialogFormKey.currentState!.validate()) {
                    Navigator.of(context).pop(true);
                    _exit();
                  }
                },
                child: const Text("Confirm"),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      final password = passwordController.text;

      try {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        await user.reauthenticateWithCredential(credential);

        await FirebaseDatabase.instance.ref().child('users/$uid').remove();
        await user.delete();

        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect password. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0E1B35),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: Color(0xFF0E1B35))),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter full name' : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                    labelText: 'Address',
                    labelStyle: TextStyle(color: Color(0xFF0E1B35))),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter address' : null,
              ),
              TextFormField(
                controller: contactNoController,
                decoration: const InputDecoration(
                  labelText: 'Contact No',
                  labelStyle: TextStyle(color: Color(0xFF0E1B35)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter contact number';
                  } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Contact number must contain digits only';
                  } else if (value.length != 8) {
                    return 'Contact number must be exactly 8 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E1B35),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: updateProfile,
                child: const Text('Update Profile',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E1B35),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: deleteProfile,
                child: const Text('Delete Profile',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
