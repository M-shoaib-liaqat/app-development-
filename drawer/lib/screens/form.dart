import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cellController = TextEditingController();

  String _isActive = 'Inactive'; // Default status
  List<Map<String, String>> _userList = []; // Store multiple records

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Function to save multiple user records
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve existing data
    List<String> storedUsers = prefs.getStringList('users') ?? [];

    // Create a new user record
    Map<String, String> newUser = {
      'email': _emailController.text,
      'password': _passwordController.text,
      'cell': _cellController.text,
      'status': _isActive,
    };

    // Convert map to JSON string and add to list
    storedUsers.add(jsonEncode(newUser));

    // Save updated list back to SharedPreferences
    await prefs.setStringList('users', storedUsers);

    _emailController.clear();
    _passwordController.clear();
    _cellController.clear();
    setState(() {
      _isActive = 'Inactive'; // Reset status
    });

    _loadData(); // Reload data to refresh UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User added successfully!')),
    );
  }

  // Function to load stored user records
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedUsers = prefs.getStringList('users') ?? [];

    List<Map<String, String>> users = storedUsers.map((userJson) {
      return Map<String, String>.from(jsonDecode(userJson));
    }).toList();

    setState(() {
      _userList = users;
    });
  }

  // Function to delete a user
  Future<void> _deleteUser(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedUsers = prefs.getStringList('users') ?? [];

    if (index >= 0 && index < storedUsers.length) {
      storedUsers.removeAt(index);
      await prefs.setStringList('users', storedUsers);
      _loadData(); // Refresh UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Form'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Input Fields
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _cellController,
              decoration: const InputDecoration(labelText: 'Cell Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Radio Buttons for Status
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Radio(
                  value: 'Active',
                  groupValue: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value.toString();
                    });
                  },
                ),
                const Text('Active'),
                const SizedBox(width: 20),
                Radio(
                  value: 'Inactive',
                  groupValue: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value.toString();
                    });
                  },
                ),
                const Text('Inactive'),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveData,
              child: const Text('Save'),
            ),

            const SizedBox(height: 20),
            const Text('Stored Users:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Display Stored Users in a List
            Expanded(
              child: _userList.isEmpty
                  ? const Center(child: Text('No users stored yet.'))
                  : ListView.builder(
                itemCount: _userList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    child: ListTile(
                      title: Text('Email: ${_userList[index]['email']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cell: ${_userList[index]['cell']}'),
                          Text('Password: ${_userList[index]['password']}'),
                          Text(
                            'Status: ${_userList[index]['status']}',
                            style: TextStyle(
                              color: _userList[index]['status'] == 'Active'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
