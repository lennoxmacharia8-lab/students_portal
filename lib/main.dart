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
import 'screens/users_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/attendance_report_screen.dart';

// Database (ONLY ONE SOURCE)
import 'databases/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database safely
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

      // Start screen
      home: const LoginScreen(),

      // Routes
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/dashboard': (context) => const DashboardScreen(),

        '/courses': (context) => const CoursesScreen(),
        '/assignments': (context) => const AssignmentsScreen(),
        '/results': (context) => const ResultsScreen(),
        '/events': (context) => const EventsScreen(),

        '/students': (context) => const StudentListScreen(),

        '/users': (context) => const UsersScreen(),

        '/attendance': (context) => const AttendanceScreen(),
        '/attendance-report': (context) => const AttendanceReportScreen(),
      },
    );
  }
}
