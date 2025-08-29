import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home.dart';
import 'adminhome.dart';
import 'registration.dart';
import 'forgotpassword.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  String email = '';
  String password = '';
  bool _obscurePassword = true; // for password visibility toggle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MULAKHASY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF0E1B35),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/MULAKHASY.jpg', width: 250, height: 250),
            const SizedBox(height: 30),

            // Email Field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFF0E1B35)),
                prefixIcon: Icon(Icons.email),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0E1B35)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0E1B35), width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  email = value.trim();
                });
              },
            ),

            const SizedBox(height: 20),

            // Password Field
            TextField(
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Color(0xFF0E1B35)),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0E1B35)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0E1B35), width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  password = value.trim(); // ✅ Correct password assignment
                });
              },
            ),

            const SizedBox(height: 30),

            // Login Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E1B35),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () async {
                try {
                  final credential = await auth.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  final uid = credential.user!.uid;

                  final dbRef = FirebaseDatabase.instance.ref();
                  final snapshot = await dbRef.child('users/$uid').get();

                  if (snapshot.exists) {
                    final data = snapshot.value as Map<dynamic, dynamic>;
                    final fullName = data['fullName'] as String;
                    final admin = data['admin'] as String;

                    if (admin == 'Y') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminHome(fullName: fullName),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Home(fullName: fullName, email: email),
                        ),
                      );
                    }
                  } else {
                    throw Exception('User data not found.');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: ${e.toString()}')),
                  );
                }
              },
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Registration()),
                );
              },
              child: const Text('Register New User', style: TextStyle(color: Color(0xFF0E1B35))),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                );
              },
              child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF0E1B35))),
            ),
          ],
        ),
      ),
    );
  }
}
