import 'package:flutter/material.dart';
import 'vertical_page.dart';
import 'horizontal_page.dart';
import 'dynamic_page.dart';
import 'myData.dart';
import 'stack_image_slider.dart';
import 'login_page.dart'; // Import the login page
import 'profile_page.dart'; // Import the login page
import 'AddSubjectPage.dart'; // Import the login page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Vertical'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VerticalPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Horizontal'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HorizontalPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Dynamic'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DynamicPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('My Data'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JsonDataScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Image Slider'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StackedImageSlider(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Login'), // New Login Item
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('profile'), // New Login Item
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Subject Marks'), // New Login Item
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSubjectPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Open the drawer to navigate!'),
      ),
    );
  }
}
