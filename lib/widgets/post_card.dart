import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1.4), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0), weight: 30),
    ]).animate(_heartController);
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    setState(() => _isLiked = true);
    _heartController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: AppColors.scaffoldDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          // Image / Content
          if (widget.post.imageUrl != null) _buildImage(),
          // Action bar
          _buildActionBar(),
          // Likes
          _buildLikes(),
          // Caption
          if (widget.post.content != null) _buildCaption(),
          // Time
          _buildTime(),
          const Divider(height: 1, color: AppColors.borderDark),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Avatar with story ring
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.storyRingGradient,
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.elevatedDark,
                backgroundImage: widget.post.authorPhotoUrl != null
                    ? CachedNetworkImageProvider(widget.post.authorPhotoUrl!)
                    : null,
                child: widget.post.authorPhotoUrl == null
                    ? Text(
                        widget.post.authorName.isNotEmpty
                            ? widget.post.authorName[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.burgundyAccent,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.post.authorName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded,
                        size: 14, color: AppColors.burgundyAccent),
                  ],
                ),
                if (widget.post.authorDepartment != null)
                  Text(
                    widget.post.authorDepartment!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.more_horiz_rounded,
              color: AppColors.textSecondary, size: 22),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl!,
            width: double.infinity,
            height: 380,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              height: 380,
              color: AppColors.elevatedDark,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.burgundyAccent,
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              height: 380,
              color: AppColors.elevatedDark,
              child: const Icon(Icons.broken_image_rounded,
                  color: AppColors.textMuted, size: 40),
            ),
          ),
          // Double tap heart animation
          AnimatedBuilder(
            listenable: _heartController,
            builder: (context, _) {
              return Transform.scale(
                scale: _heartScale.value,
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 80,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isLiked = !_isLiked),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                _isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(_isLiked),
                color: _isLiked ? AppColors.burgundyAccent : AppColors.textPrimary,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.chat_bubble_outline_rounded,
              color: AppColors.textPrimary, size: 24),
          const SizedBox(width: 14),
          const Icon(Icons.send_outlined,
              color: AppColors.textPrimary, size: 24),
          const Spacer(),
          const Icon(Icons.bookmark_border_rounded,
              color: AppColors.textPrimary, size: 26),
        ],
      ),
    );
  }

  Widget _buildLikes() {
    final likeCount =
        widget.post.likes.length + (_isLiked ? 1 : 0);
    if (likeCount <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(
        '$likeCount ${likeCount == 1 ? 'like' : 'likes'}',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      child: RichText(
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: '${widget.post.authorName} ',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextSpan(
              text: widget.post.content,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTime() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
      child: Text(
        widget.post.timeAgo,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
