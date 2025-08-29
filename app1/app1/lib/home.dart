// Import Flutter material package for building UI
import 'package:flutter/material.dart';
// Import intl package for date formatting
import 'package:intl/intl.dart';
// Import custom pages for navigation
import 'profile.dart';
import 'login.dart';
import 'feedback.dart';
import 'orders.dart';
import 'changepassword.dart';

// Define a StatefulWidget called Home
class Home extends StatefulWidget {
  final String fullName; // User's full name
  final String email;    // User's email

  const Home({super.key, required this.fullName, required this.email});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    // Get formatted current date
    String formattedDate = DateFormat('EEEE dd-MM-yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1B35), // Dark blue
        iconTheme: const IconThemeData(color: Colors.white), // Hamburger icon color
        title: const Text(
          'MULAKHASY',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),

      // Side drawer with user name and icon
      drawer: SizedBox(
        width: 190,
        child: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: const Color(0xFF0E1B35),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Menu items
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('Orders'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrdersScreen(
                        fullName: widget.fullName,
                        email: widget.email,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Profile()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback),
                title: const Text('Feedback'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FeedbackScreen(fullName: widget.fullName),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
              ),
            ],
          ),
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'images/MULAKHASY.jpg',
                width: 300,
                height: 300,
              ),
            ),
            Text(
              'Welcome ${widget.fullName}!\n Today is: $formattedDate',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7E6C65)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
