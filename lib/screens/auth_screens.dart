import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/github_widgets.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'student_dashboard.dart';
import 'supervisor_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.code, size: 64, color: GithubTheme.accentColor),
              const SizedBox(height: 16),
              Text('Sign in to Internship Manager',
                style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 32),
              GithubContainer(
                child: Column(
                  children: [
                    GithubTextField(label: 'Email address', controller: _emailController),
                    const SizedBox(height: 16),
                    GithubTextField(label: 'Password', controller: _passwordController, isPassword: true),
                    const SizedBox(height: 24),
                    GithubButton(
                      label: auth.isLoading ? 'Signing in...' : 'Sign in',
                      isPrimary: true,
                      isFullWidth: true,
                      onPressed: () async {
                        final success = await auth.login(_emailController.text, _passwordController.text);
                        if (success && mounted) {
                          _navigateHome(context, auth.currentUser!);
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid credentials')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GithubContainer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('New here? '),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Create an account.',
                        style: TextStyle(color: GithubTheme.accentColor, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateHome(BuildContext context, User user) {
    if (user.role == 'student') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentDashboard()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SupervisorDashboard()));
    }
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'student';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GithubContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GithubTextField(label: 'Full Name', controller: _nameController),
                  const SizedBox(height: 16),
                  GithubTextField(label: 'Email address', controller: _emailController),
                  const SizedBox(height: 16),
                  GithubTextField(label: 'Password', controller: _passwordController, isPassword: true),
                  const SizedBox(height: 16),
                  const Text('I am a:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'student',
                        groupValue: _selectedRole,
                        onChanged: (v) => setState(() => _selectedRole = v!),
                        activeColor: GithubTheme.accentColor,
                      ),
                      const Text('Student'),
                      const SizedBox(width: 20),
                      Radio<String>(
                        value: 'supervisor',
                        groupValue: _selectedRole,
                        onChanged: (v) => setState(() => _selectedRole = v!),
                        activeColor: GithubTheme.accentColor,
                      ),
                      const Text('Supervisor'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GithubButton(
                    label: auth.isLoading ? 'Creating account...' : 'Create account',
                    isPrimary: true,
                    isFullWidth: true,
                    onPressed: () async {
                      final user = User(
                        name: _nameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        role: _selectedRole,
                      );
                      final success = await auth.register(user);
                      if (success && mounted) {
                        if (_selectedRole == 'student') {
                          Navigator.pushReplacementNamed(context, '/profile_setup');
                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SupervisorDashboard()));
                        }
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registration failed')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
