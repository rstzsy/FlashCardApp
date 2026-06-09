import 'package:flutter/material.dart';
import '../models/blog_post_model.dart';

class BlogPostCard extends StatefulWidget {
  final BlogPost post;

  const BlogPostCard({super.key, required this.post});

  @override
  State<BlogPostCard> createState() => _BlogPostCardState();
}

class _BlogPostCardState extends State<BlogPostCard> {
  late bool _isLiked;
  late bool _isBookmarked;
  late int _likes;
  late int _bookmarks;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _isBookmarked = widget.post.isBookmarked;
    _likes = widget.post.likes;
    _bookmarks = widget.post.bookmarks;
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4DD9F5).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Avatar + Name + Time/Badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar — ảnh thật, fallback chữ cái
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFDBEAFE),
                backgroundImage: widget.post.authorAvatar.isNotEmpty
                    ? NetworkImage(widget.post.authorAvatar)
                    : null,
                child: widget.post.authorAvatar.isEmpty
                    ? Text(
                        widget.post.authorName[0],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D4ED8),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),

              // Name & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Just shared a new moment',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ],
                ),
              ),

              // Time + notification badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.post.timeAgo,
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Title ──
          Text(
            widget.post.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          // ── Content ──
          Text(
            widget.post.content,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.5,
            ),
          ),

          // ── Image (nếu có) ──
          if (widget.post.imageUrl != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              // Bo TẤT CẢ 4 góc — đúng như trong ảnh
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.post.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Colors.black26,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── Action bar — luôn nằm DƯỚI ảnh, không đè lên ──
          _ActionBar(
            likes: _likes,
            comments: widget.post.comments,
            bookmarks: _bookmarks,
            isLiked: _isLiked,
            isBookmarked: _isBookmarked,
            onLike: () => setState(() {
              _isLiked = !_isLiked;
              _likes += _isLiked ? 1 : -1;
            }),
            onBookmark: () => setState(() {
              _isBookmarked = !_isBookmarked;
              _bookmarks += _isBookmarked ? 1 : -1;
            }),
            formatCount: _formatCount,
          ),
        ],
      ),
    );
  }
}

// ── Action bar ────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final int likes, comments, bookmarks;
  final bool isLiked, isBookmarked;
  final VoidCallback onLike, onBookmark;
  final String Function(int) formatCount;

  const _ActionBar({
    required this.likes,
    required this.comments,
    required this.bookmarks,
    required this.isLiked,
    required this.isBookmarked,
    required this.onLike,
    required this.onBookmark,
    required this.formatCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: formatCount(likes),
          iconColor: isLiked ? Colors.redAccent : Colors.black54,
          onTap: onLike,
        ),
        const SizedBox(width: 8),
        _Pill(
          icon: Icons.chat_bubble_outline_rounded,
          label: formatCount(comments),
          iconColor: Colors.black54,
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _Pill(
          icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          label: formatCount(bookmarks),
          iconColor: isBookmarked ? const Color(0xFF3B82F6) : Colors.black54,
          onTap: onBookmark,
        ),
      ],
    );
  }
}

// ── Pill button ───────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _Pill({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF), // blue-50
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}