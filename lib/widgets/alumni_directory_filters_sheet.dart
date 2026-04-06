import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// How to compare member [CreatedAt] to the chosen calendar day.
enum AlumniCreatedDateRelation {
  /// Ignore created date.
  none,
  /// Member created strictly before the reference day.
  before,
  /// Member created strictly after the reference day.
  after,
  /// Member created on the same calendar day.
  sameDay,
}

class AlumniDirectoryAppliedFilters {
  const AlumniDirectoryAppliedFilters({
    this.createdRelation = AlumniCreatedDateRelation.none,
    this.createdReferenceDate,
  });

  final AlumniCreatedDateRelation createdRelation;
  final DateTime? createdReferenceDate;

  static const clear = AlumniDirectoryAppliedFilters();

  bool get hasAny =>
      createdRelation != AlumniCreatedDateRelation.none &&
      createdReferenceDate != null;
}

class AlumniDirectoryFiltersSheet extends StatefulWidget {
  const AlumniDirectoryFiltersSheet({
    super.key,
    required this.applied,
  });

  final AlumniDirectoryAppliedFilters applied;

  @override
  State<AlumniDirectoryFiltersSheet> createState() =>
      _AlumniDirectoryFiltersSheetState();
}

class _AlumniDirectoryFiltersSheetState
    extends State<AlumniDirectoryFiltersSheet> {
  late AlumniCreatedDateRelation _createdRelation;
  DateTime? _createdDate;

  @override
  void initState() {
    super.initState();
    _createdRelation = widget.applied.createdRelation;
    _createdDate = widget.applied.createdReferenceDate;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _createdDate ?? DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year + 1, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.burgundyAccent,
              surface: AppColors.cardDark,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.cardDark,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _createdDate = picked);
  }

  void _submit() {
    if (_createdRelation != AlumniCreatedDateRelation.none &&
        _createdDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pick a reference date',
            style: GoogleFonts.inter(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      AlumniDirectoryAppliedFilters(
        createdRelation: _createdRelation,
        createdReferenceDate: _createdRelation == AlumniCreatedDateRelation.none
            ? null
            : _createdDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text(
            'Created At',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Firestore field Created At (dd-MM-yyyy). Rows without a value are hidden while a comparison is active.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          _dropdown(
            label: 'Created At',
            value: _createdRelation,
            items: const [
              DropdownMenuItem(
                value: AlumniCreatedDateRelation.none,
                child: Text('No restriction'),
              ),
              DropdownMenuItem(
                value: AlumniCreatedDateRelation.before,
                child: Text('Before (less than)'),
              ),
              DropdownMenuItem(
                value: AlumniCreatedDateRelation.after,
                child: Text('After (greater than)'),
              ),
              DropdownMenuItem(
                value: AlumniCreatedDateRelation.sameDay,
                child: Text('On this date'),
              ),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() => _createdRelation = v);
            },
          ),
          if (_createdRelation != AlumniCreatedDateRelation.none) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text(
                _createdDate == null
                    ? 'Pick Created At reference date'
                    : '${_createdDate!.day.toString().padLeft(2, '0')}-'
                        '${_createdDate!.month.toString().padLeft(2, '0')}-'
                        '${_createdDate!.year}',
                style: GoogleFonts.inter(),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.borderDark),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _createdRelation = AlumniCreatedDateRelation.none;
                    _createdDate = null;
                  });
                },
                child: Text(
                  'Clear',
                  style: GoogleFonts.inter(color: AppColors.textMuted),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.burgundyAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _submit,
                child: Text(
                  'Apply',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required AlumniCreatedDateRelation value,
    required List<DropdownMenuItem<AlumniCreatedDateRelation>> items,
    required ValueChanged<AlumniCreatedDateRelation?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.elevatedDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AlumniCreatedDateRelation>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.elevatedDark,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
