import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, faculty, organizer, student }

class AppUser {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final bool verified;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.verified,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: roleFromString(data['role'] ?? 'student'),
      verified: data['verified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role.name,
      'verified': verified,
    };
  }

  static UserRole roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'faculty':
        return UserRole.faculty;
      case 'organizer':
        return UserRole.organizer;
      case 'student':
      default:
        return UserRole.student;
    }
  }
}
