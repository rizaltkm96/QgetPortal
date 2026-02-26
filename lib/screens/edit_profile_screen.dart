import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/alumni_model.dart';
import '../services/firebase_service.dart';

class EditProfileScreen extends StatefulWidget {
  final AlumniModel? alumni;

  const EditProfileScreen({super.key, this.alumni});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _yearController;
  late TextEditingController _deptController;
  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _skillsController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.alumni?.name);
    _bioController = TextEditingController(text: widget.alumni?.bio);
    _yearController = TextEditingController(
      text: widget.alumni?.graduationYear,
    );
    _deptController = TextEditingController(text: widget.alumni?.department);
    _companyController = TextEditingController(
      text: widget.alumni?.currentCompany,
    );
    _positionController = TextEditingController(
      text: widget.alumni?.currentPosition,
    );
    _skillsController = TextEditingController(
      text: widget.alumni?.skills.join(', '),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _yearController.dispose();
    _deptController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final data = {
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'graduationYear': _yearController.text.trim(),
        'department': _deptController.text.trim(),
        'currentCompany': _companyController.text.trim(),
        'currentPosition': _positionController.text.trim(),
        'skills': skills,
        'lastActive': DateTime.now(),
      };

      if (widget.alumni == null) {
        // Create new alumni doc if it doesn't exist
        final newAlumni = AlumniModel(
          uid: user.uid,
          name: _nameController.text.trim(),
          email: user.email ?? '',
          bio: _bioController.text.trim(),
          graduationYear: _yearController.text.trim(),
          department: _deptController.text.trim(),
          currentCompany: _companyController.text.trim(),
          currentPosition: _positionController.text.trim(),
          skills: skills,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        await FirebaseService.addAlumni(newAlumni);
      } else {
        await FirebaseService.updateAlumni(user.uid, data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            onPressed: _isLoading ? null : _saveProfile,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildField(
              'Full Name',
              _nameController,
              Icons.person_outline_rounded,
            ),
            const SizedBox(height: 20),
            _buildField(
              'Bio',
              _bioController,
              Icons.info_outline_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    'Batch (Year)',
                    _yearController,
                    Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    'Department',
                    _deptController,
                    Icons.school_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildField(
              'Current Company',
              _companyController,
              Icons.work_outline_rounded,
            ),
            const SizedBox(height: 20),
            _buildField(
              'Current Position',
              _positionController,
              Icons.badge_outlined,
            ),
            const SizedBox(height: 20),
            _buildField(
              'Skills (comma separated)',
              _skillsController,
              Icons.bolt_rounded,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.burgundyAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.inter(color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
