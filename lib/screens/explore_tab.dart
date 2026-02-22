import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/alumni_model.dart';
import '../services/firebase_service.dart';
import '../widgets/shimmer_loading.dart';
import 'alumni_profile_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  List<AlumniModel> _searchResults = [];
  bool _isSearching = false;
  String _selectedFilter = 'All';
  List<String> _filters = ['All'];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    final depts = await FirebaseService.getDepartments();
    if (mounted) {
      setState(() {
        _filters = ['All', ...depts];
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }
    setState(() => _isSearching = true);
    final results = await FirebaseService.searchAlumni(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchHeader(),
            _buildFilterChips(),
            const Divider(height: 1, color: AppColors.borderDark),
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.elevatedDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Search alumni, departments, companies...',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.burgundyGradient : null,
                  color: isSelected ? null : AppColors.elevatedDark,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.borderDark),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid() {
    if (_searchController.text.isNotEmpty) {
      if (_isSearching) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.burgundyAccent),
        );
      }
      if (_searchResults.isEmpty) {
        return _buildEmptySearch();
      }
      return _buildAlumniGrid(_searchResults);
    }

    return StreamBuilder<List<AlumniModel>>(
      stream: FirebaseService.getAlumniStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildGridShimmer();
        }
        final alumni = snapshot.data ?? [];
        if (alumni.isEmpty) {
          return _buildEmptyState();
        }

        final filteredAlumni = _selectedFilter == 'All'
            ? alumni
            : alumni.where((a) => a.department == _selectedFilter).toList();

        if (filteredAlumni.isEmpty) {
          return _buildEmptyFilter();
        }

        return _buildAlumniGrid(filteredAlumni);
      },
    );
  }

  Widget _buildAlumniGrid(List<AlumniModel> alumni) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        childAspectRatio: 0.75,
      ),
      itemCount: alumni.length,
      itemBuilder: (context, index) {
        return _buildGridItem(alumni[index]);
      },
    );
  }

  Widget _buildGridItem(AlumniModel alumni) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlumniProfileScreen(alumni: alumni),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo
          if (alumni.photoUrl != null && alumni.photoUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: alumni.photoUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.elevatedDark,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.burgundyAccent,
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => _buildPlaceholderAvatar(alumni),
            )
          else
            _buildPlaceholderAvatar(alumni),
          // Gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    alumni.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (alumni.graduationYear != null)
                    Text(
                      "'${alumni.graduationYear!.substring(alumni.graduationYear!.length - 2)}",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar(AlumniModel alumni) {
    return Container(
      color: AppColors.burgundyDark.withOpacity(0.3),
      child: Center(
        child: Text(
          alumni.initials,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.burgundyAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildGridShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        childAspectRatio: 0.75,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return const ShimmerBox();
      },
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: AppColors.textMuted.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off_rounded,
            size: 48,
            color: AppColors.textMuted.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No alumni in $_selectedFilter',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
              Icons.explore_rounded,
              color: AppColors.burgundyAccent.withOpacity(0.5),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Explore Alumni',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Alumni profiles will appear here\nonce data is available.',
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
