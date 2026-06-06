import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/providers/app_providers.dart';
import 'package:qget_portal/widgets/post_card.dart';
import 'package:qget_portal/widgets/shimmer_loading.dart';
import 'package:qget_portal/widgets/story_circle.dart';

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsStreamProvider);
    final alumniAsync = ref.watch(alumniStreamProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(postsStreamProvider);
        ref.invalidate(alumniStreamProvider);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 102,
              child: alumniAsync.when(
                data: (list) {
                  final top = list.take(16).toList();
                  if (top.isEmpty) {
                    return const Center(
                      child: Text('Directory appears empty — add alumni in Firebase.'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: top.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) => StoryCircle(alumni: top[i]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Stories: $e')),
              ),
            ),
          ),
          postsAsync.when(
            data: (posts) {
              if (posts.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No posts yet. Tap + to share.')),
                );
              }
              return SliverList.separated(
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PostCard(post: posts[i]),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ShimmerLoading(count: 4),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load posts: $e'),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),
    );
  }
}
