import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/alumni_model.dart';
import '../services/firebase_service.dart';
import '../widgets/shimmer_loading.dart';
import 'alumni_profile_screen.dart';

class AlumniDirectoryTab extends StatefulWidget {
  const AlumniDirectoryTab({super.key});

  @override
  State<AlumniDirectoryTab> createState() => _AlumniDirectoryTabState();
}

class _AlumniDirectoryTabState extends State<AlumniDirectoryTab>
    with AutomaticKeepAliveClientMixin {
  String _sortBy = 'name';
  bool _isGridView = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: AppColors.borderDark),
            Expanded(child: _buildAlumniList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                  // Toggle view
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
                    color: AppColors.cardDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.borderDark),
                    ),
                    onSelected: (value) => setState(() => _sortBy = value),
                    itemBuilder: (context) => [
                      _buildSortItem('name', 'Name', Icons.sort_by_alpha_rounded),
                      _buildSortItem('year', 'Graduation Year', Icons.calendar_today_rounded),
                      _buildSortItem('department', 'Department', Icons.school_rounded),
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
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<AlumniModel>>(
            stream: FirebaseService.getAlumniStream(),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return Text(
                '$count members',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              );
            },
          ),
        ],
      ),
    );
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

  Widget _buildAlumniList() {
    return StreamBuilder<List<AlumniModel>>(
      stream: FirebaseService.getAlumniStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildListShimmer();
        }
        final alumni = snapshot.data ?? [];
        if (alumni.isEmpty) {
          return _buildEmptyState();
        }

        // Sort
        final sorted = List<AlumniModel>.from(alumni);
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

        if (_isGridView) {
          return _buildGridLayout(sorted);
        }
        return _buildListLayout(sorted);
      },
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

  Widget _buildListItem(AlumniModel alumni, int index) {
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
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlumniProfileScreen(alumni: alumni),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDark, width: 0.5),
          ),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(alumni, 52),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            alumni.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (alumni.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.burgundyAccent,
                            size: 16,
                          ),
                        ],
                      ],
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
                    if (alumni.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            alumni.location!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow
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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
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
            _buildAvatar(alumni, 72),
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
                      if (alumni.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded,
                            color: AppColors.burgundyAccent, size: 14),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alumni.department ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (alumni.graduationYear != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.burgundy.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Class of ${alumni.graduationYear}",
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
    );
  }

  Widget _buildAvatar(AlumniModel alumni, double size) {
    return Container(
      width: size + 4,
      height: size + 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.storyRingGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: CircleAvatar(
          radius: size / 2,
          backgroundColor: AppColors.cardDark,
          backgroundImage: alumni.photoUrl != null && alumni.photoUrl!.isNotEmpty
              ? CachedNetworkImageProvider(alumni.photoUrl!)
              : null,
          child: alumni.photoUrl == null || alumni.photoUrl!.isEmpty
              ? Text(
                  alumni.initials,
                  style: GoogleFonts.outfit(
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.w700,
                    color: AppColors.burgundyAccent,
                  ),
                )
              : null,
        ),
      ),
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
