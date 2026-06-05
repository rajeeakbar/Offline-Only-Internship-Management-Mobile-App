import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/sync_provider.dart';
import 'utils/theme.dart';
import 'screens/auth_screens.dart';
import 'screens/profile_setup.dart';
import 'screens/supervisor_selection.dart';
import 'screens/student_dashboard.dart';
import 'screens/supervisor_dashboard.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: const InternshipApp(),
    ),
  );
}

class InternshipApp extends StatelessWidget {
  const InternshipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internship Manager',
      theme: GithubTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile_setup': (context) => const ProfileSetupScreen(),
        '/supervisor_selection': (context) => const SupervisorSelectionScreen(),
        '/student_dashboard': (context) => const StudentDashboard(),
        '/supervisor_dashboard': (context) => const SupervisorDashboard(),
      },
    );
  }
}
