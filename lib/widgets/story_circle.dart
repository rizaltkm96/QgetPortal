import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/alumni_model.dart';
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
            // Story ring
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.storyRingGradient,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.scaffoldDark,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 29,
                      backgroundColor: AppColors.elevatedDark,
                      backgroundImage:
                          alumni.photoUrl != null && alumni.photoUrl!.isNotEmpty
                              ? CachedNetworkImageProvider(alumni.photoUrl!)
                              : null,
                      child:
                          alumni.photoUrl == null || alumni.photoUrl!.isEmpty
                              ? Text(
                                  alumni.initials,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
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
