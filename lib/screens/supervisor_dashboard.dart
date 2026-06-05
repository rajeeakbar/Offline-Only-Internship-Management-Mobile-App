import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/github_widgets.dart';
import '../utils/theme.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  final DatabaseService _dbService = DatabaseService();
  List<User> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Note: For this mock, we use the pre-populated supervisor IDs or the current user's ID
    // In a real app, supervisors would also be in the 'users' table or linked.
    final students = await _dbService.getAssignedStudents(auth.currentUser!.id ?? 101);
    setState(() {
      _students = students;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Cohort'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assigned Students (${_students.length})',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                const SizedBox(height: 16),
                Expanded(
                  child: _students.isEmpty
                    ? const Center(child: Text('No students assigned yet.'))
                    : ListView.separated(
                        itemCount: _students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return GithubContainer(
                            padding: const EdgeInsets.all(16),
                            child: InkWell(
                              onTap: () => _viewStudentDetails(student),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: GithubTheme.bgLight,
                                    child: Text(student.name[0]),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(student.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Text(student.email, style: const TextStyle(color: GithubTheme.textSecondary, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: GithubTheme.textSecondary),
                                ],
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

  void _viewStudentDetails(User student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDetailView(student: student),
      ),
    );
  }
}

class StudentDetailView extends StatefulWidget {
  final User student;
  const StudentDetailView({super.key, required this.student});

  @override
  State<StudentDetailView> createState() => _StudentDetailViewState();
}

class _StudentDetailViewState extends State<StudentDetailView> {
  final DatabaseService _dbService = DatabaseService();
  List<Activity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final activities = await _dbService.getStudentActivities(widget.student.id!);
    setState(() {
      _activities = activities;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.student.name)),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _activities.length,
            itemBuilder: (context, index) {
              final activity = _activities[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GithubContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(activity.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(activity.status, style: TextStyle(
                            color: activity.status == 'Approved' ? Colors.green : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(activity.description),
                      const SizedBox(height: 12),
                      if (activity.status == 'Pending')
                        Row(
                          children: [
                            Expanded(
                              child: GithubButton(
                                label: 'Approve',
                                isPrimary: true,
                                onPressed: () async {
                                  await _dbService.updateActivityStatus(activity.id!, 'Approved', 'Good work!');
                                  _loadActivities();
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
