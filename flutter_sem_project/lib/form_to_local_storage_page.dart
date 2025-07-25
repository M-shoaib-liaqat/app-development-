import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormToLocalStoragePage extends StatefulWidget {
  const FormToLocalStoragePage({super.key});

  @override
  _FormToLocalStoragePageState createState() => _FormToLocalStoragePageState();
}

class _FormToLocalStoragePageState extends State<FormToLocalStoragePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _saveDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('age', _ageController.text);
    await prefs.setString('email', _emailController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data saved locally')),
    );

    _formKey.currentState!.reset();
    _nameController.clear();
    _ageController.clear();
    _emailController.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form to Local Storage')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter age' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveDataLocally();
                  }
                },
                child: const Text('Save Locally'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
