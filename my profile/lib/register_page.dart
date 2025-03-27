import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? gender;
  String? imagePath;
  String addressWarning = ''; // To show word count warning

  @override
  void initState() {
    super.initState();
    addressController.addListener(_updateAddressWarning);
  }

  @override
  void dispose() {
    addressController.removeListener(_updateAddressWarning);
    emailController.dispose();
    passwordController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // 📌 Email Validation
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // 📌 Password Validation
  bool isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{6,}$');
    return passwordRegex.hasMatch(password);
  }

  // 📌 Address Validation (Live Word Counter)
  void _updateAddressWarning() {
    String address = addressController.text;
    int wordCount = address.trim().split(RegExp(r'\s+')).length;
    if (address.isEmpty) {
      setState(() => addressWarning = '');
      return;
    }
    if (wordCount < 5) {
      setState(() => addressWarning = 'Words left: ${5 - wordCount} (Min: 5 words)');
    } else if (wordCount > 15) {
      setState(() => addressWarning = 'Word limit exceeded! (Max: 15 words)');
    } else {
      setState(() => addressWarning = 'Words left: ${15 - wordCount}');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<void> register() async {
    String email = emailController.text.trim();
    String password = passwordController.text;
    String address = addressController.text.trim();
    int wordCount = address.split(RegExp(r'\s+')).length;

    // 📌 Validation Checks
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid email format')));
      return;
    }
    if (!isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password must be at least 6 characters, include 1 uppercase, 1 lowercase, 1 number, and 1 special character'),
      ));
      return;
    }
    if (address.length < 10 || wordCount < 5) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Address must be at least 10 characters and contain at least 5 words'),
      ));
      return;
    }
    if (address.length > 150 || wordCount > 15) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Address must be at most 150 characters and contain at most 15 words'),
      ));
      return;
    }
    if (gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a gender')));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? usersList = prefs.getStringList('users') ?? [];

    Map<String, String> newUser = {
      'email': email,
      'password': password,
      'address': address,
      'gender': gender!,
      'imagePath': imagePath ?? '',
    };

    usersList.add(jsonEncode(newUser));
    await prefs.setStringList('users', usersList);
    await prefs.setString('currentUser', jsonEncode(newUser));
    await prefs.setBool('isLoggedIn', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Page')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
                child: imagePath == null ? Icon(Icons.camera_alt, size: 40) : null,
              ),
            ),
            SizedBox(height: 10),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            TextField(controller: addressController, decoration: InputDecoration(labelText: 'Address')),

            // 📌 Show live word count
            if (addressWarning.isNotEmpty)
              Text(
                addressWarning,
                style: TextStyle(color: wordCountError() ? Colors.red : Colors.green),
              ),

            SizedBox(height: 10),

            // 📌 Gender Selection
            Text('Select Gender:', style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Radio(
                  value: 'Male',
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value.toString();
                    });
                  },
                ),
                Text('Male'),
                SizedBox(width: 20),
                Radio(
                  value: 'Female',
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value.toString();
                    });
                  },
                ),
                Text('Female'),
              ],
            ),

            SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: Text('Register')),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfilePage()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
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

  // Helper function to check if word count error exists
  bool wordCountError() {
    int wordCount = addressController.text.trim().split(RegExp(r'\s+')).length;
    return wordCount < 5 || wordCount > 15;
  }
}
