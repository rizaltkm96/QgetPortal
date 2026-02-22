import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/alumni_model.dart';

class AlumniProfileScreen extends StatefulWidget {
  final AlumniModel alumni;

  const AlumniProfileScreen({super.key, required this.alumni});

  @override
  State<AlumniProfileScreen> createState() => _AlumniProfileScreenState();
}

class _AlumniProfileScreenState extends State<AlumniProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildProfileInfo()),
          SliverToBoxAdapter(child: _buildActionButtons()),
          SliverToBoxAdapter(child: _buildInfoSection()),
          if (widget.alumni.skills.isNotEmpty)
            SliverToBoxAdapter(child: _buildSkillsSection()),
          SliverToBoxAdapter(child: _buildSocialLinks()),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.scaffoldDark,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.more_horiz_rounded,
                color: Colors.white, size: 22),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover / gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.burgundyDark,
                    AppColors.burgundy.withOpacity(0.6),
                    AppColors.scaffoldDark,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Decorative elements
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.burgundyAccent.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.burgundy.withOpacity(0.15),
                ),
              ),
            ),
            // Profile picture
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Hero(
                  tag: 'avatar_${widget.alumni.uid}',
                  child: Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.storyRingGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.burgundy.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: AppColors.scaffoldDark,
                        backgroundImage: widget.alumni.photoUrl != null &&
                                widget.alumni.photoUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(
                                widget.alumni.photoUrl!)
                            : null,
                        child: widget.alumni.photoUrl == null ||
                                widget.alumni.photoUrl!.isEmpty
                            ? Text(
                                widget.alumni.initials,
                                style: GoogleFonts.outfit(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.burgundyAccent,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.alumni.name,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (widget.alumni.isVerified) ...[
                const SizedBox(width: 8),
                const Icon(Icons.verified_rounded,
                    color: AppColors.burgundyAccent, size: 22),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.alumni.displaySubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (widget.alumni.bio != null && widget.alumni.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.alumni.bio!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat(widget.alumni.graduationYear ?? '—', 'Batch'),
              Container(
                width: 1,
                height: 30,
                color: AppColors.borderDark,
              ),
              _buildStat(widget.alumni.department ?? '—', 'Dept'),
              Container(
                width: 1,
                height: 30,
                color: AppColors.borderDark,
              ),
              _buildStat(
                  widget.alumni.location ?? '—', 'Location'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.burgundyGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.burgundy.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {},
                  child: Center(
                    child: Text(
                      'Connect',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {},
                  child: Center(
                    child: Text(
                      'Message',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: const Icon(Icons.share_rounded,
                color: AppColors.textSecondary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDark, width: 0.5),
            ),
            child: Column(
              children: [
                if (widget.alumni.email.isNotEmpty)
                  _buildInfoRow(Icons.email_outlined, 'Email',
                      widget.alumni.email),
                if (widget.alumni.phone != null)
                  _buildInfoRow(Icons.phone_outlined, 'Phone',
                      widget.alumni.phone!),
                if (widget.alumni.degree != null)
                  _buildInfoRow(Icons.school_outlined, 'Degree',
                      widget.alumni.degree!),
                if (widget.alumni.department != null)
                  _buildInfoRow(Icons.business_outlined, 'Department',
                      widget.alumni.department!),
                if (widget.alumni.currentCompany != null)
                  _buildInfoRow(Icons.work_outline_rounded, 'Company',
                      widget.alumni.currentCompany!),
                if (widget.alumni.currentPosition != null)
                  _buildInfoRow(Icons.badge_outlined, 'Position',
                      widget.alumni.currentPosition!),
                if (widget.alumni.location != null)
                  _buildInfoRow(Icons.location_on_outlined, 'Location',
                      widget.alumni.location!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.burgundy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.burgundyAccent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.alumni.skills.map((skill) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.burgundy.withOpacity(0.2),
                      AppColors.burgundyDark.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.burgundy.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  skill,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.burgundyAccent,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    final links = <Map<String, dynamic>>[];
    if (widget.alumni.linkedIn != null) {
      links.add({
        'icon': Icons.link_rounded,
        'label': 'LinkedIn',
        'url': widget.alumni.linkedIn,
        'color': const Color(0xFF0077B5),
      });
    }
    if (widget.alumni.instagram != null) {
      links.add({
        'icon': Icons.camera_alt_outlined,
        'label': 'Instagram',
        'url': widget.alumni.instagram,
        'color': const Color(0xFFE1306C),
      });
    }
    if (widget.alumni.github != null) {
      links.add({
        'icon': Icons.code_rounded,
        'label': 'GitHub',
        'url': widget.alumni.github,
        'color': const Color(0xFFCCCCCC),
      });
    }

    if (links.isEmpty) return const SizedBox(height: 24);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Social Links',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...links.map((link) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderDark, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                          (link['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      link['icon'] as IconData,
                      size: 18,
                      color: link['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          link['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          link['url'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new_rounded,
                      size: 16, color: AppColors.textMuted),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
