import 'package:flutter/material.dart';
import 'package:qget_portal/models/alumni_model.dart';
import 'package:qget_portal/widgets/member_avatar.dart';
import 'package:qget_portal/widgets/glass.dart';

class AlumniCard extends StatelessWidget {
  const AlumniCard({
    super.key,
    required this.alumni,
    this.onTap,
  });

  final AlumniModel alumni;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = alumni.displaySubtitle;
    return GlassCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            MemberAvatar(alumni: alumni, radius: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alumni.memberName.isNotEmpty
                        ? alumni.memberName
                        : alumni.email,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (alumni.companyName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${alumni.position.isNotEmpty ? '${alumni.position}, ' : ''}'
                      '${alumni.companyName}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
