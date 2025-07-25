import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize(BuildContext context) async {
    // Request permissions
    await _messaging.requestPermission();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final notification = message.notification!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(notification.title ?? 'New Event', style: const TextStyle(fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
