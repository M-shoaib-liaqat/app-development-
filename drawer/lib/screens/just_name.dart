import 'package:flutter/material.dart';

class JustNamePage extends StatelessWidget {
  const JustNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Just Name")),
      body: const Center(
        child: Text("My name is shoaib", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
