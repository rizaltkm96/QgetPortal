import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/post_model.dart';
import '../models/alumni_model.dart';
import '../providers/app_providers.dart';
import '../widgets/post_card.dart';
import '../widgets/story_circle.dart';
import '../widgets/shimmer_loading.dart';

class FeedTab extends ConsumerStatefulWidget {
  const FeedTab({super.key});

  @override
  ConsumerState<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<FeedTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final alumniAsync = ref.watch(alumniStreamProvider);
    final postsAsync = ref.watch(postsStreamProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: AppColors.burgundyAccent,
        backgroundColor: AppColors.cardDark,
        onRefresh: () async {
          ref.invalidate(alumniStreamProvider);
          ref.invalidate(postsStreamProvider);
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildStoriesSection(alumniAsync)),
            const SliverToBoxAdapter(
              child: Divider(height: 1, color: AppColors.borderDark),
            ),
            SliverToBoxAdapter(child: _buildFeed(postsAsync)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Qget Alumni',
        style: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          foreground: Paint()
            ..shader = const LinearGradient(
              colors: [AppColors.burgundyAccent, AppColors.gold],
            ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
        ),
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.favorite_border_rounded, size: 26),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.burgundyAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 24),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildStoriesSection(AsyncValue<List<AlumniModel>> alumniAsync) {
    return SizedBox(
      height: 110,
      child: alumniAsync.when(
        data: (alumni) {
          if (alumni.isEmpty) return _buildEmptyStories();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            physics: const BouncingScrollPhysics(),
            itemCount: alumni.length,
            itemBuilder: (context, index) => StoryCircle(alumni: alumni[index]),
          );
        },
        loading: () => _buildStoriesShimmer(),
        error: (_, __) => _buildEmptyStories(),
      ),
    );
  }

  Widget _buildStoriesShimmer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: 8,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: ShimmerCircle(size: 68),
        );
      },
    );
  }

  Widget _buildEmptyStories() {
    return Center(
      child: Text(
        'No alumni stories yet',
        style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
      ),
    );
  }

  Widget _buildFeed(AsyncValue<List<PostModel>> postsAsync) {
    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) return _buildEmptyFeed();
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) => PostCard(post: posts[index]),
        );
      },
      loading: () => _buildFeedShimmer(),
      error: (_, __) => _buildEmptyFeed(),
    );
  }

  Widget _buildFeedShimmer() {
    return Column(children: List.generate(3, (i) => const ShimmerPostCard()));
  }

  Widget _buildEmptyFeed() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.burgundy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.dynamic_feed_rounded,
              color: AppColors.burgundyAccent.withOpacity(0.5),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Posts Yet',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share updates\nwith the alumni community!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
