import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController passwordController = TextEditingController();
  List<Map<String, String>> users = [];
  String? selectedEmail;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? usersList = prefs.getStringList('users') ?? [];

    setState(() {
      users = usersList.map((user) => Map<String, String>.from(jsonDecode(user))).toList();
      if (users.isNotEmpty) selectedEmail = users.first['email'];
    });
  }

  Future<void> login() async {
    if (selectedEmail == null || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter email and password')));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String>? user = users.firstWhere(
          (user) => user['email'] == selectedEmail,
      orElse: () => {},
    );

    if (user.isNotEmpty && passwordController.text == user['password']) {
      await prefs.setString('currentUser', jsonEncode(user));
      await prefs.setBool('isLoggedIn', true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfilePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid credentials')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Page')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedEmail,
              hint: Text('Select User'),
              items: users.map((user) {
                return DropdownMenuItem(
                  value: user['email'],
                  child: Text(user['email']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedEmail = value;
                });
              },
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text('Submit')),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage())),
              child: Text('Register Now'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfilePage()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RegisterPage()));
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.app_registration), label: 'Register'),
        ],
      ),
    );
  }
}
