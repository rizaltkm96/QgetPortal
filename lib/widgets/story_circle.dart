import 'package:flutter/material.dart';

import 'package:qget_portal/models/alumni_model.dart';
import 'package:qget_portal/widgets/member_avatar.dart';
import 'package:qget_portal/theme/theme_extensions.dart';

/// Compact circular avatar row (stories-style).
class StoryCircle extends StatelessWidget {
  const StoryCircle({
    super.key,
    required this.alumni,
    this.onTap,
    this.label,
  });

  final AlumniModel alumni;
  final VoidCallback? onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final ring = context.appStyle.storyRingGradient;
    return SizedBox(
      width: 72,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: ring,
              ),
              child: MemberAvatar(alumni: alumni, radius: 28),
            ),
            const SizedBox(height: 6),
            Text(
              label ??
                  (alumni.memberName.isNotEmpty
                      ? alumni.memberName.split(' ').first
                      : '?'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
