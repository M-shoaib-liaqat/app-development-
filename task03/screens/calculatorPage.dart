import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // Controllers for text fields
  final TextEditingController firstNumberController = TextEditingController();
  final TextEditingController secondNumberController = TextEditingController();

  // Selected operation
  String selectedOperation = '+'; // Default operation
  String result = ''; // Store the result as a string

  // Function to perform calculation
  void _calculateResult() {
    double num1 = double.tryParse(firstNumberController.text) ?? 0;
    double num2 = double.tryParse(secondNumberController.text) ?? 0;
    double calcResult = 0;

    switch (selectedOperation) {
      case '+':
        calcResult = num1 + num2;
        break;
      case '-':
        calcResult = num1 - num2;
        break;
      case '*':
        calcResult = num1 * num2;
        break;
      case '/':
        if (num2 != 0) {
          calcResult = num1 / num2;
        } else {
          result = 'Error'; // Handle division by zero
          setState(() {});
          return;
        }
        break;
    }

    setState(() {
      result = calcResult.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Calculator',
          style: TextStyle(color: Colors.white),
        ),
      ),
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to the Calculator Page!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 20),

              // First number input
              SizedBox(
                width: 200,
                child: TextField(
                  controller: firstNumberController, // Attach controller
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter first number',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(height: 20),

              // Second number input
              SizedBox(
                width: 200,
                child: TextField(
                  controller: secondNumberController, // Attach controller
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter second number',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(height: 20),

              // Row of operation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedOperation = '+';
                      });
                      _calculateResult();
                    },
                    child: const Text('+'),
                  ),
                  const SizedBox(width: 10),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedOperation = '-';
                      });
                      _calculateResult();
                    },
                    child: const Text('-'),
                  ),
                  const SizedBox(width: 10),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedOperation = '*';
                      });
                      _calculateResult();
                    },
                    child: const Text('*'),
                  ),
                  const SizedBox(width: 10),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedOperation = '/';
                      });
                      _calculateResult();
                    },
                    child: const Text('/'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Result display
              SizedBox(
                width: 200,
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Result',
                  ),
                  readOnly: true,
                  controller: TextEditingController(text: result), // Show result
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
