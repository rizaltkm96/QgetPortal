import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/models/post_model.dart';
import 'package:qget_portal/providers/app_providers.dart';
import 'package:qget_portal/services/firebase_service.dart';
import 'package:qget_portal/widgets/member_avatar.dart';
import 'package:qget_portal/models/alumni_model.dart';
import 'package:qget_portal/widgets/glass.dart';

class PostCard extends ConsumerWidget {
  const PostCard({
    super.key,
    required this.post,
  });

  final PostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final liked =
        user != null && post.likes.contains(user.uid);
    Future<void> onLike() async {
      if (user == null) return;
      try {
        await FirebaseService.toggleLike(post.id, user.uid);
      } on Object catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not update like')),
          );
        }
      }
    }

    final headerAlum = AlumniModel.fromMemberMap({
      'Member_Name': post.authorName,
      'Email': '',
      'ImgURL': post.authorPhotoUrl,
    }, post.authorUid);

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MemberAvatar(alumni: headerAlum, radius: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (post.authorDepartment.isNotEmpty ||
                          post.authorGraduationYear.isNotEmpty)
                        Text(
                          [
                            post.authorDepartment,
                            if (post.authorGraduationYear.isNotEmpty)
                              'Class of ${post.authorGraduationYear}',
                          ].where((e) => e.isNotEmpty).join(' · '),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _formatTime(post.createdAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(post.content),
            ],
            if (post.imageUrl.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: user == null ? null : onLike,
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                  ),
                ),
                Text('${post.likes.length}'),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, size: 22),
                const SizedBox(width: 6),
                Text('${post.commentCount}'),
                const Spacer(),
                if (user?.uid == post.authorUid)
                  Text(
                    'Your post',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
