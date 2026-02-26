import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/alumni_model.dart';
import '../widgets/member_avatar.dart';
import '../screens/alumni_profile_screen.dart';

class StoryCircle extends StatelessWidget {
  final AlumniModel alumni;

  const StoryCircle({super.key, required this.alumni});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlumniProfileScreen(alumni: alumni),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MemberAvatar(alumni: alumni, size: 60),
            const SizedBox(height: 6),
            SizedBox(
              width: 68,
              child: Text(
                alumni.name.split(' ').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
