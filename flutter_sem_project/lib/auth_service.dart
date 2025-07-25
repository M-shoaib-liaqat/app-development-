import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Import your model file where UserRole and AppUser are declared
import 'user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register new user with email & password and save extra data in Firestore
  static Future<void> register(
      String email,
      String password, {
        required String name,
        required UserRole role,
      }) async {
    try {
      // Create Firebase user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;

      if (user == null) {
        throw Exception('User creation failed');
      }

      // Save additional info in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'name': name,
        'role': role.name,
        'verified': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send email verification
      try {
        await user.sendEmailVerification();
        print('Verification email sent to: \\${user.email}');
      } catch (e) {
        print('Failed to send verification email: \\${e.toString()}');
        throw Exception('Failed to send verification email: \\${e.toString()}');
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase specific errors
      String msg = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        msg = 'Email is already in use';
      } else if (e.code == 'weak-password') {
        msg = 'Password is too weak';
      }
      throw Exception(msg);
    } catch (e) {
      // General error
      throw Exception('Registration failed: $e');
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = result.user;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && (userDoc.data()?['verified'] ?? false) == true) {
          return true;
        }
      }
    } catch (e) {
      // You can log error here if needed
    }
    return false;
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Future<UserRole> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return UserRole.student;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        final roleString = data['role'];
        if (roleString is String) {
          return AppUser.roleFromString(roleString);
        }
      }
    }
    // Default to student if no valid role found
    return UserRole.student;
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName ?? '',
          'role': UserRole.student.name, // Default role
          'verified': true, // Google sign-in users considered verified
        });
      }
      return userCredential;
    } catch (e) {
      // Optionally log error here
      return null;
    }
  }
}
