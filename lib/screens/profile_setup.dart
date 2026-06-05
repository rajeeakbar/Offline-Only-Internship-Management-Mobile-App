import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/resume_parser.dart';
import '../widgets/github_widgets.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _skillsController = TextEditingController();
  final _eduController = TextEditingController();
  bool _isParsing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  Future<void> _pickAndParse() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isParsing = true);
      final info = await ResumeParser.parseResume(result.files.single.path!);
      setState(() {
        if (info.containsKey('name')) _nameController.text = info['name']!;
        if (info.containsKey('email')) _emailController.text = info['email']!;
        if (info.containsKey('skills')) _skillsController.text = info['skills']!;
        if (info.containsKey('education')) _eduController.text = info['education']!;
        _isParsing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume parsed successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GithubContainer(
              child: Column(
                children: [
                  const Icon(Icons.upload_file, size: 48, color: GithubTheme.textSecondary),
                  const SizedBox(height: 12),
                  const Text('Speed up setup by uploading your resume',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  GithubButton(
                    label: _isParsing ? 'Parsing...' : 'Upload PDF Resume',
                    onPressed: _isParsing ? () {} : _pickAndParse,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GithubContainer(
              child: Column(
                children: [
                  GithubTextField(label: 'Full Name', controller: _nameController),
                  const SizedBox(height: 16),
                  GithubTextField(label: 'Email', controller: _emailController),
                  const SizedBox(height: 16),
                  GithubTextField(label: 'Skills', controller: _skillsController),
                  const SizedBox(height: 16),
                  GithubTextField(label: 'Education', controller: _eduController),
                  const SizedBox(height: 24),
                  GithubButton(
                    label: 'Save Profile',
                    isPrimary: true,
                    isFullWidth: true,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/supervisor_selection');
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
