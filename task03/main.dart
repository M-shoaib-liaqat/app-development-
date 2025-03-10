import 'package:flutter/material.dart';
import 'screens/calculatorPage.dart'; 
import 'screens/gradeBook.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(), // Home Page
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
          mainAxisAlignment: MainAxisAlignment.center, // Center content
          children: [
            const Text(
              'Home Page',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(width: 10), // Spacing between text and logo
            Image.asset(
              'assets/uni_logo.png', // Centered Logo
              width: 55, // Adjusted size to fit AppBar
              height: 55,
              fit: BoxFit.contain,
            ),
          ],
        ),
        centerTitle: true, // Ensures title is centered
      ),

      // Drawer widget to show side menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text("Calculator"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalculatorPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text("Grade Book"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GradeBook(),
                  ),
                );
              },
            )
          ],
        ),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Paragraph text with reduced width
                  Container(
                    width: 750, // Reduced width for better readability
                    padding: EdgeInsets.only(right: 140),
                    child: Text(
                      'Baba Guru Nanak University BGNU is a Public sector university located in District Nankana Sahib, in the Punjab region of Pakistan. It plans to facilitate between 10,000 to 15,000 students from all over the world at the university. The foundation stone of the university was laid on October 28, 2019 ahead of 550th of Guru Nanak Gurpurab by the Prime Minister of Pakistan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),

                  const SizedBox(width: 20), // Space between text and image

                  // Image moved slightly left and made larger
                  Padding(
                    padding: EdgeInsets.all(0), // Move image slightly left
                    child: Image.asset(
                      'assets/vc01.jpg',
                      width: 300, // Increased size for better visibility
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer Section
          Container(
             width: double.infinity,
            color: Colors.deepPurple,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '© 2025 Baba Guru Nanak University. All rights reserved.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                SizedBox(height: 5),
                Text(
                  'Contact us: info@bgnu.edu.pk | Phone: +92 123 456789',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
