import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/alumni_model.dart';
import '../providers/app_providers.dart';
import '../services/alumni_excel_export_service.dart';
import '../services/firebase_service.dart';
import '../utils/alumni_created_at_parse.dart';
import '../widgets/alumni_directory_filters_sheet.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/member_avatar.dart';
import 'alumni_member_form_screen.dart';
import 'alumni_profile_screen.dart';

class AlumniDirectoryTab extends ConsumerStatefulWidget {
  const AlumniDirectoryTab({super.key});

  @override
  ConsumerState<AlumniDirectoryTab> createState() => _AlumniDirectoryTabState();
}

class _AlumniDirectoryTabState extends ConsumerState<AlumniDirectoryTab>
    with AutomaticKeepAliveClientMixin {
  String _sortBy = 'name';
  bool _isGridView = false;
  bool _exportInProgress = false;
  AlumniDirectoryAppliedFilters _filters = AlumniDirectoryAppliedFilters.clear;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final alumniAsync = ref.watch(alumniStreamProvider);
    final canManageRoster = ref.watch(currentUserProvider) != null;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(alumniAsync),
            const Divider(height: 1, color: AppColors.borderDark),
            Expanded(child: _buildAlumniList(alumniAsync)),
          ],
        ),
      ),
      floatingActionButton: canManageRoster
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AlumniMemberFormScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.burgundyAccent,
              foregroundColor: Colors.white,
              child: const Icon(Icons.person_add_rounded),
            )
          : null,
    );
  }

  bool _passesFilters(AlumniModel a) {
    final rel = _filters.createdRelation;
    final ref = _filters.createdReferenceDate;
    if (rel != AlumniCreatedDateRelation.none && ref != null) {
      final aDay = parseAlumniCreatedAtDay(a.createdAt);
      if (aDay == null) return false;
      final ad = DateTime(aDay.year, aDay.month, aDay.day);
      final rd = DateTime(ref.year, ref.month, ref.day);
      switch (rel) {
        case AlumniCreatedDateRelation.none:
          break;
        case AlumniCreatedDateRelation.before:
          if (!ad.isBefore(rd)) return false;
          break;
        case AlumniCreatedDateRelation.after:
          if (!ad.isAfter(rd)) return false;
          break;
        case AlumniCreatedDateRelation.sameDay:
          if (ad.year != rd.year ||
              ad.month != rd.month ||
              ad.day != rd.day) {
            return false;
          }
          break;
      }
    }

    return true;
  }

  void _openFiltersSheet() {
    showDialog<AlumniDirectoryAppliedFilters>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: AlumniDirectoryFiltersSheet(applied: _filters),
        ),
      ),
    ).then((v) {
      if (v != null && mounted) setState(() => _filters = v);
    });
  }

  Widget _buildHeader(AsyncValue<List<AlumniModel>> alumniAsync) {
    final all = alumniAsync.valueOrNull;
    final total = all?.length ?? 0;
    final shown =
        all == null ? 0 : all.where(_passesFilters).length;
    final canOpenFilters = alumniAsync.hasValue && total > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alumni Directory',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Tooltip(
                    message: 'Created At',
                    child: GestureDetector(
                      onTap: canOpenFilters ? _openFiltersSheet : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.elevatedDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _filters.hasAny && canOpenFilters
                                ? AppColors.burgundyAccent.withOpacity(0.5)
                                : AppColors.borderDark,
                          ),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: canOpenFilters
                              ? (_filters.hasAny
                                  ? AppColors.burgundyAccent
                                  : AppColors.textSecondary)
                              : AppColors.textMuted,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _isGridView = !_isGridView),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.elevatedDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Icon(
                        _isGridView
                            ? Icons.view_list_rounded
                            : Icons.grid_view_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sort menu
                  PopupMenuButton<String>(
                    tooltip: 'Sort',
                    color: AppColors.cardDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.borderDark),
                    ),
                    onSelected: (value) => setState(() => _sortBy = value),
                    itemBuilder: (context) => [
                      _buildSortItem('name', 'Name', Icons.sort_by_alpha_rounded),
                      _buildSortItem('year', 'Year', Icons.calendar_today_rounded),
                      _buildSortItem('department', 'Branch', Icons.school_rounded),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.elevatedDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: const Icon(
                        Icons.sort_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Export Excel',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _exportInProgress ? null : _openExportColumnsDialog,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.elevatedDark,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: Icon(
                            Icons.table_chart_outlined,
                            color: _exportInProgress
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _filters.hasAny && total > 0
                ? '$shown of $total members'
                : '$total members',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _exportFileNameStamp() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${two(n.month)}${two(n.day)}_${two(n.hour)}${two(n.minute)}';
  }

  Future<void> _openExportColumnsDialog() async {
    final selected = await showDialog<Set<String>>(
      context: context,
      builder: (ctx) => const _AlumniExportColumnsDialog(),
    );
    if (!mounted || selected == null || selected.isEmpty) return;
    await _performAlumniExport(selected);
  }

  Future<void> _performAlumniExport(Set<String> selectedColumnIds) async {
    if (_exportInProgress) return;
    setState(() => _exportInProgress = true);

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context, rootNavigator: true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Material(
          color: Colors.black54,
          child: Center(
            child: Card(
              color: AppColors.cardDark,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.burgundyAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Exporting…',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final list = await FirebaseService.getAlumniList();
      if (!mounted) return;

      if (list.isEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'No members to export',
              style: GoogleFonts.inter(),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final filtered = list.where(_passesFilters).toList();
      if (filtered.isEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'No members match Created At filter to export',
              style: GoogleFonts.inter(),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final bytes = AlumniExcelExportService.buildWorkbookBytes(
        filtered,
        selectedColumnIds,
      );
      await FileSaver.instance.saveFile(
        name: 'alumni_directory_${_exportFileNameStamp()}',
        bytes: Uint8List.fromList(bytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Excel export saved',
            style: GoogleFonts.inter(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Export failed: $e',
              style: GoogleFonts.inter(),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (nav.mounted && nav.canPop()) nav.pop();
      if (mounted) setState(() => _exportInProgress = false);
    }
  }

  PopupMenuItem<String> _buildSortItem(
      String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color:
                  isSelected ? AppColors.burgundyAccent : AppColors.textMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color:
                  isSelected ? AppColors.burgundyAccent : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlumniList(AsyncValue<List<AlumniModel>> alumniAsync) {
    return alumniAsync.when(
      data: (alumni) {
        if (alumni.isEmpty) return _buildEmptyState();

        final filtered = alumni.where(_passesFilters).toList();
        if (filtered.isEmpty) return _buildNoFilterMatchesState();

        final sorted = List<AlumniModel>.from(filtered);
        switch (_sortBy) {
          case 'year':
            sorted.sort((a, b) =>
                (b.graduationYear ?? '').compareTo(a.graduationYear ?? ''));
            break;
          case 'department':
            sorted.sort((a, b) =>
                (a.department ?? '').compareTo(b.department ?? ''));
            break;
          default:
            sorted.sort((a, b) => a.name.compareTo(b.name));
        }

        if (_isGridView) return _buildGridLayout(sorted);
        return _buildListLayout(sorted);
      },
      loading: () => _buildListShimmer(),
      error: (_, __) => _buildEmptyState(),
    );
  }

  Widget _buildListLayout(List<AlumniModel> alumni) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: alumni.length,
      itemBuilder: (context, index) {
        return _buildListItem(alumni[index], index);
      },
    );
  }

  Future<void> _confirmDeleteAlumni(AlumniModel alumni) async {
    final label =
        alumni.name.trim().isEmpty ? 'this member' : alumni.name.trim();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark),
        ),
        title: Text(
          'Remove member?',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Remove $label from the directory? This cannot be undone.',
          style: GoogleFonts.inter(
            color: AppColors.textMuted,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textMuted),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await FirebaseService.deleteAlumniMember(alumni.uid);
      if (mounted) {
        ref.invalidate(currentAlumniProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Member removed', style: GoogleFonts.inter()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.inter()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openEditMember(AlumniModel alumni) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AlumniMemberFormScreen(alumni: alumni),
      ),
    );
  }

  Widget _alumniOverflowMenu(AlumniModel alumni) {
    return PopupMenuButton<String>(
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      icon: Icon(
        Icons.more_vert_rounded,
        color: AppColors.textSecondary,
        size: 22,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      onSelected: (value) {
        if (value == 'edit') {
          _openEditMember(alumni);
        } else if (value == 'delete') {
          _confirmDeleteAlumni(alumni);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined,
                  size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 10),
              Text('Edit', style: GoogleFonts.inter()),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline_rounded,
                  size: 20, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(
                'Delete',
                style: GoogleFonts.inter(color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(AlumniModel alumni, int index) {
    final canManage = ref.watch(currentUserProvider) != null;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 500)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => AlumniProfileScreen(alumni: alumni),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        MemberAvatar(alumni: alumni, size: 52),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alumni.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                alumni.displaySubtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.burgundy.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.burgundyAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (canManage) _alumniOverflowMenu(alumni),
          ],
        ),
      ),
    );
  }

  Widget _buildGridLayout(List<AlumniModel> alumni) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: alumni.length,
      itemBuilder: (context, index) {
        return _buildGridCard(alumni[index]);
      },
    );
  }

  Widget _buildGridCard(AlumniModel alumni) {
    final canManage = ref.watch(currentUserProvider) != null;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => AlumniProfileScreen(alumni: alumni),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDark, width: 0.5),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                MemberAvatar(alumni: alumni, size: 72),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              alumni.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alumni.branchName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (alumni.year != null && alumni.year!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.burgundy.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            alumni.year!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.burgundyAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (canManage)
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(10),
              elevation: 0,
              child: _alumniOverflowMenu(alumni),
            ),
          ),
      ],
    );
  }

  Widget _buildListShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ShimmerBox(height: 76, borderRadius: 16),
        );
      },
    );
  }

  Widget _buildNoFilterMatchesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No matching Created At',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Change the Created At rule or clear it to see all members.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () =>
                  setState(() => _filters = AlumniDirectoryAppliedFilters.clear),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.burgundyAccent,
                side: const BorderSide(color: AppColors.burgundyAccent),
              ),
              child: Text(
                'Clear Created At',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.burgundy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.people_rounded,
              color: AppColors.burgundyAccent.withOpacity(0.5),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Alumni Found',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Alumni profiles will appear here\nonce they are added to the database.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlumniExportColumnsDialog extends StatefulWidget {
  const _AlumniExportColumnsDialog();

  @override
  State<_AlumniExportColumnsDialog> createState() =>
      _AlumniExportColumnsDialogState();
}

class _AlumniExportColumnsDialogState extends State<_AlumniExportColumnsDialog> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected =
        AlumniExcelExportService.allColumns.map((c) => c.id).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.72;

    return Dialog(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: SizedBox(
        width: 400,
        height: maxH.clamp(320.0, 620.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Export to Excel',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Uncheck any field to leave it out of the spreadsheet.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 8),
                  children: [
                    for (final col in AlumniExcelExportService.allColumns)
                      CheckboxListTile(
                        value: _selected.contains(col.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selected.add(col.id);
                            } else {
                              _selected.remove(col.id);
                            }
                          });
                        },
                        title: Text(
                          col.headerLabel,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.burgundyAccent,
                        checkColor: Colors.white,
                        side: const BorderSide(color: AppColors.borderDark),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.borderDark),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.burgundyAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (_selected.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Select at least one column',
                              style: GoogleFonts.inter(),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context, Set<String>.from(_selected));
                    },
                    child: Text(
                      'Export',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
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
