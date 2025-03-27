import 'package:flutter/material.dart';
import 'screens/calculatorPage.dart';
import 'screens/gradeBook.dart';
import 'screens/just_name.dart';
import 'screens/just_button.dart';
import 'screens/text_field_button.dart';
import 'screens/form.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BGNU Portal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.deepPurple,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/uni_logo.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text(
              'Home Page',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calculate, color: Colors.deepPurple),
              title: const Text("Calculator"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalculatorPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.deepPurple),
              title: const Text("Grade Book"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GradeBook()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.label, color: Colors.deepPurple),
              title: const Text("Just Name"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JustNamePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.touch_app, color: Colors.deepPurple),
              title: const Text("Just Button"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JustButtonPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields, color: Colors.deepPurple),
              title: const Text("Text Field & Button"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TextFieldButtonPage()),
                );
              },
            ), ListTile(
              leading: const Icon(Icons.text_fields, color: Colors.deepPurple),
              title: const Text("Form"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserForm()),
                );
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 600; // Mobile detection

                  return Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: isMobile ? 0 : 2,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Baba Guru Nanak University (BGNU) is a Public sector university located in District Nankana Sahib, Punjab, Pakistan. It aims to accommodate 10,000 to 15,000 students from around the world. The foundation stone of the university was laid on October 28, 2019, ahead of the 550th Guru Nanak Gurpurab by the Prime Minister of Pakistan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20, height: 20),
                      Expanded(
                        flex: isMobile ? 0 : 1,
                        child: Image.asset(
                          'assets/vc01.jpg',
                          width: isMobile ? 250 : 300, // Enlarged for better view
                          height: isMobile ? 180 : 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        color: Colors.deepPurple,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '© 2025 Baba Guru Nanak University. All rights reserved.',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 5),
            const Text(
              'Contact us: info@bgnu.edu.pk | Phone: +92 123 456789',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
