import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';
import '../widgets/github_widgets.dart';
import '../utils/theme.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final DatabaseService _dbService = DatabaseService();
  List<Activity> _activities = [];
  Supervisor? _supervisor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final studentId = auth.currentUser!.id!;

    final activities = await _dbService.getStudentActivities(studentId);
    final supervisor = await _dbService.getAssignedSupervisor(studentId);

    setState(() {
      _activities = activities;
      _supervisor = supervisor;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.book_outlined, size: 20),
            const SizedBox(width: 8),
            Text('${user.name.toLowerCase().replaceAll(' ', '-')}/internship'),
          ],
        ),
        actions: [
          Consumer<SyncProvider>(
            builder: (context, sync, child) {
              return IconButton(
                icon: Icon(
                  sync.isSyncing ? Icons.sync : Icons.cloud_done_outlined,
                  size: 20,
                  color: sync.isSyncing ? GithubTheme.accentColor : GithubTheme.textSecondary,
                ),
                onPressed: () => sync.syncData(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusOverview(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      GithubButton(
                        label: 'New Log',
                        isPrimary: true,
                        onPressed: () => _showAddActivityDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_activities.isEmpty)
                    const GithubContainer(
                      child: Center(child: Text('No activities recorded yet.')),
                    )
                  else
                    ..._activities.map((activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildActivityItem(activity),
                    )),
                ],
              ),
            ),
          ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: GithubTheme.accentColor,
        unselectedItemColor: GithubTheme.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.feed_outlined), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatusOverview() {
    return GithubContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: GithubTheme.textSecondary),
              const SizedBox(width: 8),
              const Text('Internship Status', style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              _buildBadge('Active', Colors.green),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Supervisor', _supervisor?.name ?? 'Not assigned'),
          _buildInfoRow('Total Logs', _activities.length.toString()),
          _buildInfoRow('Pending Approval', _activities.where((a) => a.status == 'Pending').length.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: GithubTheme.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActivityItem(Activity activity) {
    Color statusColor = activity.status == 'Approved' ? Colors.green : (activity.status == 'Pending' ? Colors.orange : Colors.grey);

    return GithubContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.commit, size: 16, color: GithubTheme.textSecondary),
              const SizedBox(width: 8),
              Expanded(child: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.w600))),
              _buildBadge(activity.status, statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(activity.description, style: const TextStyle(fontSize: 13, color: GithubTheme.textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 12, color: GithubTheme.textSecondary),
              const SizedBox(width: 4),
              Text(activity.date, style: const TextStyle(fontSize: 11, color: GithubTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Log Entry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GithubTextField(label: 'Title', controller: titleController),
            const SizedBox(height: 16),
            GithubTextField(label: 'Description', controller: descController),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          GithubButton(
            label: 'Submit',
            isPrimary: true,
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final newActivity = Activity(
                  studentId: auth.currentUser!.id!,
                  title: titleController.text,
                  description: descController.text,
                  status: 'Pending',
                  date: DateFormat('MMM dd, yyyy').format(DateTime.now()),
                );
                await _dbService.addActivity(newActivity);
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
