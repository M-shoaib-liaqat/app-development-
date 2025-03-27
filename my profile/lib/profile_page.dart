import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'register_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, String>? currentUser;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('currentUser');
    if (userData != null) {
      setState(() {
        currentUser = Map<String, String>.from(jsonDecode(userData));
        imagePath = currentUser!['imagePath'];
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currentUser!['imagePath'] = pickedFile.path;
      await prefs.setString('currentUser', jsonEncode(currentUser));

      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  // ✅ Improved Logout Function (Only Removes Login Data)
  Future<void> logout() async {
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // ❌ Cancel Logout
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // ✅ Confirm Logout
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // ✅ Remove ONLY login-related data, keeping registered users
      await prefs.remove('isLoggedIn'); // ✅ Removes login status
      await prefs.remove('currentUser'); // ✅ Removes only the current user data

      // ✅ Smooth Transition to Login Page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginPage()),
            (route) => false, // Removes all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: Center(
        child: currentUser == null
            ? CircularProgressIndicator()
            : Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: imagePath != null && imagePath!.isNotEmpty
                      ? FileImage(File(imagePath!))
                      : null,
                  child: imagePath == null || imagePath!.isEmpty
                      ? Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              Text('Email: ${currentUser!['email']}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Address: ${currentUser!['address']}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Gender: ${currentUser!['gender']}', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Profile Page
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
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
