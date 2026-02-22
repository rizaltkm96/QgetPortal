import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              _buildQuickStats(),
              _buildMenuSection(),
              _buildAboutSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = FirebaseService.currentUser;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.elevatedDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: const Icon(Icons.settings_outlined,
                        color: AppColors.textSecondary, size: 22),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Profile avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.storyRingGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.burgundy.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: CircleAvatar(
                radius: 47,
                backgroundColor: AppColors.cardDark,
                backgroundImage: user?.photoURL != null
                    ? CachedNetworkImageProvider(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 44,
                        color: AppColors.burgundyAccent.withOpacity(0.5),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'Alumni User',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'Sign in to access your profile',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          // Edit profile button
          Container(
            width: double.infinity,
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
                    user != null ? 'Edit Profile' : 'Sign In',
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
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('0', 'Connections', Icons.people_outline_rounded),
            Container(width: 1, height: 36, color: AppColors.borderDark),
            _buildStatItem('0', 'Posts', Icons.article_outlined),
            Container(width: 1, height: 36, color: AppColors.borderDark),
            _buildStatItem('0', 'Events', Icons.event_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.burgundyAccent, size: 22),
        const SizedBox(height: 6),
        Text(
          count,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
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

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDark, width: 0.5),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  Icons.person_outline_rounded,
                  'My Profile',
                  'View and edit your profile',
                ),
                _menuDivider(),
                _buildMenuItem(
                  Icons.bookmark_border_rounded,
                  'Saved',
                  'Your saved posts and events',
                ),
                _menuDivider(),
                _buildMenuItem(
                  Icons.notifications_none_rounded,
                  'Notifications',
                  'Manage your notifications',
                ),
                _menuDivider(),
                _buildMenuItem(
                  Icons.privacy_tip_outlined,
                  'Privacy',
                  'Control your privacy settings',
                ),
                _menuDivider(),
                _buildMenuItem(
                  Icons.help_outline_rounded,
                  'Help & Support',
                  'Get help with your account',
                ),
                _menuDivider(),
                _buildMenuItem(
                  Icons.logout_rounded,
                  'Sign Out',
                  'Sign out of your account',
                  isDestructive: true,
                  onTap: () async {
                    await FirebaseService.signOut();
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuDivider() {
    return const Divider(
      height: 1,
      indent: 60,
      color: AppColors.borderDark,
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle,
      {bool isDestructive = false, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.burgundy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive
                      ? AppColors.error
                      : AppColors.burgundyAccent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDestructive
                            ? AppColors.error
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textMuted.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.burgundyGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Qget Alumni Portal',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'v1.0.0',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
