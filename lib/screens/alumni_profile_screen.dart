import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/alumni_model.dart';
import '../widgets/member_avatar.dart';

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
          if (_hasChildren) SliverToBoxAdapter(child: _buildChildrenSection()),
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.burgundy.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: MemberAvatar(alumni: widget.alumni, size: 110),
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
          Text(
            widget.alumni.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat(widget.alumni.year ?? '—', 'Year'),
              Container(
                width: 1,
                height: 30,
                color: AppColors.borderDark,
              ),
              _buildStat(widget.alumni.branchName ?? '—', 'Branch'),
              Container(
                width: 1,
                height: 30,
                color: AppColors.borderDark,
              ),
              _buildStat(widget.alumni.companyName ?? '—', 'Company'),
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
                if (widget.alumni.contactNumber != null &&
                    widget.alumni.contactNumber!.isNotEmpty)
                  _buildInfoRow(Icons.phone_outlined, 'Contact',
                      widget.alumni.contactNumber!),
                if (widget.alumni.whatsappNumber != null &&
                    widget.alumni.whatsappNumber!.isNotEmpty)
                  _buildInfoRow(Icons.chat_rounded, 'WhatsApp',
                      widget.alumni.whatsappNumber!),
                if (widget.alumni.bloodGroup != null &&
                    widget.alumni.bloodGroup!.isNotEmpty)
                  _buildInfoRow(Icons.bloodtype_outlined, 'Blood Group',
                      widget.alumni.bloodGroup!),
                if (widget.alumni.spouseName != null &&
                    widget.alumni.spouseName!.isNotEmpty)
                  _buildInfoRow(Icons.favorite_outline_rounded, 'Spouse',
                      widget.alumni.spouseName!),
                if (widget.alumni.branchName != null &&
                    widget.alumni.branchName!.isNotEmpty)
                  _buildInfoRow(Icons.business_outlined, 'Branch',
                      widget.alumni.branchName!),
                if (widget.alumni.companyName != null &&
                    widget.alumni.companyName!.isNotEmpty)
                  _buildInfoRow(Icons.work_outline_rounded, 'Company',
                      widget.alumni.companyName!),
                if (widget.alumni.position != null &&
                    widget.alumni.position!.isNotEmpty)
                  _buildInfoRow(Icons.badge_outlined, 'Position',
                      widget.alumni.position!),
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

  bool get _hasChildren {
    return (widget.alumni.child1Name != null && widget.alumni.child1Name!.isNotEmpty) ||
        (widget.alumni.child2Name != null && widget.alumni.child2Name!.isNotEmpty) ||
        (widget.alumni.child3Name != null && widget.alumni.child3Name!.isNotEmpty) ||
        (widget.alumni.child4Name != null && widget.alumni.child4Name!.isNotEmpty);
  }

  Widget _buildChildrenSection() {
    final children = <MapEntry<String, String?>>[];
    if (widget.alumni.child1Name != null && widget.alumni.child1Name!.isNotEmpty) {
      children.add(MapEntry(widget.alumni.child1Name!, widget.alumni.child1Dob));
    }
    if (widget.alumni.child2Name != null && widget.alumni.child2Name!.isNotEmpty) {
      children.add(MapEntry(widget.alumni.child2Name!, widget.alumni.child2Dob));
    }
    if (widget.alumni.child3Name != null && widget.alumni.child3Name!.isNotEmpty) {
      children.add(MapEntry(widget.alumni.child3Name!, widget.alumni.child3Dob));
    }
    if (widget.alumni.child4Name != null && widget.alumni.child4Name!.isNotEmpty) {
      children.add(MapEntry(widget.alumni.child4Name!, widget.alumni.child4Dob));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Children',
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
              children: children.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.child_care_rounded,
                          size: 20, color: AppColors.burgundyAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.key,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (e.value != null && e.value!.isNotEmpty)
                        Text(
                          e.value!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    if (widget.alumni.socialMediaLink == null ||
        widget.alumni.socialMediaLink!.trim().isEmpty) {
      return const SizedBox(height: 24);
    }
    final url = widget.alumni.socialMediaLink!.trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Social',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
                    color: AppColors.burgundy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    size: 18,
                    color: AppColors.burgundyAccent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    url,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.open_in_new_rounded,
                    size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
