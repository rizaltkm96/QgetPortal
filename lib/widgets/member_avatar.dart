import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/alumni_model.dart';

/// Circle avatar for a member. [ImgURL] (as [AlumniModel.photoUrl]) loads the
/// image. Shows [initials] when url is null, empty, or when the image fails.
class MemberAvatar extends StatelessWidget {
  final AlumniModel alumni;
  final double size;
  final bool showRing;

  const MemberAvatar({
    super.key,
    required this.alumni,
    required this.size,
    this.showRing = true,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = alumni.photoUrl;
    final hasUrl = imageUrl != null && imageUrl.isNotEmpty;
    final content = hasUrl
        ? ClipOval(
            child: CachedNetworkImage(
              width: size,
              height: size,
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => _buildInitials(size),
              errorWidget: (_, __, ___) => _buildInitials(size),
            ),
          )
        : _buildInitials(size);

    if (!showRing) {
      return content;
    }
    return Container(
      width: size + 4,
      height: size + 4,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.storyRingGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.scaffoldDark,
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildInitials(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.elevatedDark,
      ),
      alignment: Alignment.center,
      child: Text(
        alumni.initials,
        style: GoogleFonts.outfit(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: AppColors.burgundyAccent,
        ),
      ),
    );
  }
}
