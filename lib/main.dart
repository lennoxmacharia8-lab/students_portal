import 'package:flutter/material.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/course_screen.dart';
import 'screens/assignment_screen.dart';
import 'screens/result_screen.dart';
import 'screens/event_screen.dart';
import 'screens/student_list_screen.dart';
import 'screens/users_screen.dart'; // 🌐 NEW API SCREEN

// Database
import 'databases/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseService.instance.database;

  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management App',

      home: const LoginScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/dashboard': (context) => const DashboardScreen(),

        '/courses': (context) => const CoursesScreen(),
        '/assignments': (context) => const AssignmentsScreen(),
        '/results': (context) => const ResultsScreen(),
        '/events': (context) => const EventsScreen(),

        // 👤 Local CRUD
        '/students': (context) => const StudentListScreen(),

        // 🌐 API USERS (NEW)
        '/users': (context) => const UsersScreen(),
      },
    );
  }
}
