import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/alumni_model.dart';
import '../providers/app_providers.dart';
import '../services/firebase_service.dart';

/// Add (`alumni == null`) or edit an alumni row in Firestore `users`.
class AlumniMemberFormScreen extends ConsumerStatefulWidget {
  const AlumniMemberFormScreen({super.key, this.alumni});

  final AlumniModel? alumni;

  bool get isEditing => alumni != null;

  @override
  ConsumerState<AlumniMemberFormScreen> createState() =>
      _AlumniMemberFormScreenState();
}

class _AlumniMemberFormScreenState extends ConsumerState<AlumniMemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  late final TextEditingController _yearController;
  late final TextEditingController _branchController;
  late final TextEditingController _companyController;
  late final TextEditingController _positionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final a = widget.alumni;
    _emailController = TextEditingController(text: a?.email ?? '');
    _nameController = TextEditingController(text: a?.name ?? '');
    _yearController = TextEditingController(text: a?.year ?? '');
    _branchController = TextEditingController(text: a?.branchName ?? '');
    _companyController = TextEditingController(text: a?.companyName ?? '');
    _positionController = TextEditingController(text: a?.position ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _yearController.dispose();
    _branchController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (FirebaseService.currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in to manage members', style: GoogleFonts.inter()),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isEditing) {
        final data = <String, dynamic>{
          'Member_Name': _nameController.text.trim(),
          'Year': _yearController.text.trim(),
          'Branch_Name': _branchController.text.trim(),
          'Company_Name': _companyController.text.trim(),
          'Position': _positionController.text.trim(),
        };
        await FirebaseService.updateUserProfile(widget.alumni!.uid, data);

        final current = await FirebaseService.getCurrentAlumni();
        if (current != null && current.uid == widget.alumni!.uid) {
          ref.invalidate(currentAlumniProvider);
        }
      } else {
        try {
          await FirebaseService.createAlumniMember(
            memberName: _nameController.text.trim(),
            email: _emailController.text.trim().toLowerCase(),
            year: _yearController.text.trim(),
            branchName: _branchController.text.trim(),
            companyName: _companyController.text.trim(),
            position: _positionController.text.trim(),
          );
        } on StateError catch (e) {
          if (e.message == 'email-already-exists') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'That email is already registered',
                    style: GoogleFonts.inter(),
                  ),
                ),
              );
            }
            return;
          }
          rethrow;
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing ? 'Member updated' : 'Member added',
              style: GoogleFonts.inter(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.inter()),
          ),
        );
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
          widget.isEditing ? 'Edit member' : 'Add member',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            onPressed: _isLoading ? null : _save,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildField(
              'Email',
              _emailController,
              Icons.email_outlined,
              readOnly: widget.isEditing,
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return 'Required';
                if (!s.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildField(
              'Full name',
              _nameController,
              Icons.person_outline_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildField(
                    'Batch (year)',
                    _yearController,
                    Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    'Branch',
                    _branchController,
                    Icons.school_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildField(
              'Company',
              _companyController,
              Icons.work_outline_rounded,
            ),
            const SizedBox(height: 20),
            _buildField(
              'Position',
              _positionController,
              Icons.badge_outlined,
            ),
            const SizedBox(height: 32),
            if (!widget.isEditing)
              Text(
                'After adding, the member can sign up with this email (same as directory record).',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
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
    bool readOnly = false,
    String? Function(String?)? validator,
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
            color: readOnly ? AppColors.elevatedDark.withOpacity(0.6) : AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            validator: validator,
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
