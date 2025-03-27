import 'package:flutter/material.dart';

class HorizontalPage extends StatelessWidget {
  const HorizontalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horizontal Images'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: List.generate(10, (index) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      'assets/image01.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    Text('Image ${index + 1}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
