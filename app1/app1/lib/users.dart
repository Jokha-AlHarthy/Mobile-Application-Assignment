import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'database.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => UsersState();
}

class UsersState extends State<Users> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users');
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  // ✅ Fixed: Now updates the class-level 'users' list properly
  Future<void> loadUsers() async {
    List<Map<String, dynamic>> fetchedUsers = await Database().fetchUsers();
    setState(() {
      users = fetchedUsers;
    });
  }

  Future<void> changeAdminStatus(String uid, String newValue) async {
    await Database().updateAdminStatus(uid, newValue);
    loadUsers(); // Reload after update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF0E1B35),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['fullName'] ?? 'No Name'),
            subtitle: Text(user['email'] ?? 'No Email'),
            trailing: DropdownButton<String>(
              value: user['admin'],
              items: const [
                DropdownMenuItem(value: 'Y', child: Text('Admin')),
                DropdownMenuItem(value: 'N', child: Text('User')),
              ],
              onChanged: (value) {
                if (value != null) {
                  changeAdminStatus(user['uid'], value);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
