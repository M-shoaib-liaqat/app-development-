import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'firebase_options.dart';

// Screens
import 'splash_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'verification_screen.dart';
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'notification_screen.dart';
import 'requests_screen.dart';
import 'event_form_screen.dart';
import 'form_to_local_storage_page.dart';
import 'all_events_page.dart';
import 'facility_management_page.dart';
import 'student_dashboard.dart';
import 'faculty_dashboard.dart';
import 'admin_dashboard.dart';
import 'organizer_dashboard.dart';
import 'campus_map.dart';
import 'settings.dart';
import 'rsvp_list.dart';

// Services
import 'auth_service.dart';
import 'user_model.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize OneSignal
  OneSignal.initialize('467a5557-c80c-47d4-b142-9f003547db13');

  // ✅ Request push permission
  OneSignal.Notifications.requestPermission(true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const UniversityEventsApp(),
    ),
  );
}

class UniversityEventsApp extends StatelessWidget {
  const UniversityEventsApp({super.key});

  /// ✅ Save OneSignal Player ID to Firestore
  static Future<void> saveOneSignalPlayerIdToFirestore(String userId) async {
    final playerId = OneSignal.User.pushSubscription.id;
    if (playerId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'onesignal_player_id': playerId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'University Events',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A),
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1E3A8A),
          secondary: Color(0xFF60A5FA),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF181824),
        cardColor: const Color(0xFF232336),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1E3A8A),
          secondary: Color(0xFF60A5FA),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/verify': (context) => const VerificationScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/requests': (context) => const RequestsScreen(),
        '/event_form': (context) => EventFormScreen(),
        '/local_form': (context) => const FormToLocalStoragePage(),
        '/all_events': (context) => const AllEventsPage(),
        '/facility_management': (context) => FacilityManagementPage(),
        '/student_dashboard': (context) => const StudentDashboard(),
        '/faculty_dashboard': (context) => const FacultyDashboard(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/organizer_dashboard': (context) => const OrganizerDashboard(),
        '/campus_map': (context) => const CampusMapPage(),
        '/settings': (context) => const SettingsPage(),
        '/rsvp_list': (context) => const RSVPListPage(),
      },
    );
  }
}
