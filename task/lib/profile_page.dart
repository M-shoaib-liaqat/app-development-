import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Database? _database;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  /// Initialize SQLite Database and Load Users
  Future<void> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'users.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, password TEXT)',
        );
      },
    );

    _loadUserData();
  }

  /// Load All Users from SQLite
  Future<void> _loadUserData() async {
    if (_database == null) {
      await _initializeDatabase();
    }

    final List<Map<String, dynamic>> users = await _database!.query('users');

    setState(() {
      _users = users;
    });
  }

  /// Delete a User from SQLite
  Future<void> _deleteUser(int id) async {
    await _database!.delete('users', where: 'id = ?', whereArgs: [id]);
    _loadUserData(); // Reload users after deletion
  }

  /// Logout and Navigate to Login Page
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _users.isEmpty
          ? const Center(child: Text("No Users Found"))
          : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                child: Text(_users[index]['email'][0].toUpperCase()),
              ),
              title: Text(_users[index]['email']),
              subtitle: Text("Password: ${_users[index]['password']}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteUser(_users[index]['id']),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        child: const Icon(Icons.logout),
      ),
    );
  }
}
