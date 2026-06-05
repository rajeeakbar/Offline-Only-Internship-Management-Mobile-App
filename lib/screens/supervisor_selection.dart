import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/github_widgets.dart';
import '../utils/theme.dart';

class SupervisorSelectionScreen extends StatefulWidget {
  const SupervisorSelectionScreen({super.key});

  @override
  State<SupervisorSelectionScreen> createState() => _SupervisorSelectionScreenState();
}

class _SupervisorSelectionScreenState extends State<SupervisorSelectionScreen> {
  final _searchController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  List<Supervisor> _allSupervisors = [];
  List<Supervisor> _filteredSupervisors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSupervisors();
    _searchController.addListener(_filterSupervisors);
  }

  Future<void> _loadSupervisors() async {
    final supervisors = await _dbService.getSupervisors();
    setState(() {
      _allSupervisors = supervisors;
      _filteredSupervisors = supervisors;
      _isLoading = false;
    });
  }

  void _filterSupervisors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSupervisors = _allSupervisors.where((s) {
        return s.name.toLowerCase().contains(query) ||
               s.department.toLowerCase().contains(query) ||
               s.id.toString().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select your Supervisor'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search by Name, Department, or ID',
              style: TextStyle(color: GithubTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            GithubTextField(
              label: 'Search Directory',
              controller: _searchController,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSupervisors.isEmpty
                  ? const Center(child: Text('No supervisors found'))
                  : ListView.separated(
                      itemCount: _filteredSupervisors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final supervisor = _filteredSupervisors[index];
                        return GithubContainer(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: GithubTheme.bgLight,
                                child: Text(supervisor.name[0], style: const TextStyle(color: GithubTheme.accentColor)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(supervisor.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(supervisor.department, style: const TextStyle(color: GithubTheme.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              GithubButton(
                                label: 'Select',
                                onPressed: () async {
                                  await _dbService.linkStudentToSupervisor(
                                    auth.currentUser!.id!,
                                    supervisor.id
                                  );
                                  if (mounted) {
                                    Navigator.pushReplacementNamed(context, '/student_dashboard');
                                  }
                                },
                              ),
                            ],
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
