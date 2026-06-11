import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/blog_post_model.dart';
import '../services/blog_service.dart';
import '../widgets/comment_sheet.dart';
import '../../group/models/group_model.dart';
import 'edit_blog_screen.dart';
import 'dart:math' show cos, sin, pi, pow;

class BlogDetailScreen extends StatefulWidget {
  final BlogPost  post;
  final String    groupId;
  final GroupRole myRole;
  final VoidCallback? onBookmarkChanged; 

  const BlogDetailScreen({
    super.key,
    required this.post,
    required this.groupId,
    required this.myRole,
    this.onBookmarkChanged,
  });

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  late BlogPost _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _handleLike() async {
    final prev = _post.isLiked;
    setState(() => _post = _post.copyWith(
          isLiked: !prev,
          likes: _post.likes + (prev ? -1 : 1),
        ));
    await BlogService.toggleLike(
      groupId: widget.groupId,
      postId: _post.id,
      currentlyLiked: prev,
    );
  }

  Future<void> _handleBookmark() async {
    final prev = _post.isBookmarked;
    setState(() => _post = _post.copyWith(
          isBookmarked: !prev,
          bookmarks: _post.bookmarks + (prev ? -1 : 1),
        ));
    await BlogService.toggleBookmark(
      groupId: widget.groupId,
      postId: _post.id,
      currentlyBookmarked: prev,
    );
    widget.onBookmarkChanged?.call();
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentSheet(
        groupId: widget.groupId,
        postId: _post.id,
        onCommentAdded: () => setState(
          () => _post = _post.copyWith(comments: _post.comments + 1),
        ),
      ),
    );
  }

  void _openEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditBlogScreen(
          groupId: widget.groupId,
          post: _post,
        ),
      ),
    );

    if (!mounted) return;
    final updated = await BlogService.getPost(
      groupId: widget.groupId,
      postId: _post.id,
    );
    if (updated != null && mounted) {
      setState(() => _post = updated);
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: const Color(0xFFE0F7FA),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline_rounded,
                  size: 60, color: Colors.redAccent),
              const SizedBox(height: 15),
              const Text('Delete post?',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF01579B))),
              const SizedBox(height: 10),
              const Text('This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF01579B))),
              const SizedBox(height: 25),
              Row(children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFC1E2FF),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                            color: Color(0xFF91B8F4), width: 1.5),
                      ),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0277BD))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color: Colors.redAccent.withOpacity(0.4),
                            width: 1.5),
                      ),
                    ),
                    child: const Text('Delete',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.redAccent)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );

    if (ok == true && mounted) {
      await BlogService.deletePost(
        groupId: widget.groupId,
        postId: _post.id,
        postAuthorId: _post.authorId,
      );
      Navigator.pop(context);
    }
  }

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final uid       = FirebaseAuth.instance.currentUser?.uid;
    final isAuthor  = _post.authorId == uid;
    final canDelete = BlogService.canDelete(widget.myRole, _post.authorId);

    return Scaffold(
      backgroundColor: Colors.white,

      // ── App bar cố định ──
      appBar: AppBar(
        elevation:        0,
        backgroundColor:  Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:        const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: Color(0xFF0277BD)),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/component/logo.png', height: 36),
            const SizedBox(width: 6),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF29B6F6),
                  Color(0xFF0288D1),
                ],
              ).createShader(bounds),
              child: const Text(
                'MOFU',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (isAuthor || canDelete)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded,
                  color: Color(0xFF6B7280)),
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onSelected: (val) {
                if (val == 'edit')   _openEdit();
                if (val == 'delete') _confirmDelete();
              },
              itemBuilder: (_) => [
                if (isAuthor)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined,
                          size: 18, color: Color(0xFF0277BD)),
                      SizedBox(width: 10),
                      Text('Edit post'),
                    ]),
                  ),
                if (canDelete)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text('Delete post',
                          style: TextStyle(color: Colors.redAccent)),
                    ]),
                  ),
              ],
            ),
          const SizedBox(width: 4),
        ],
      ),

      // ── Action bar cố định dưới ──
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(color: Colors.grey.shade200, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    _DetailLikeButton(
                      isLiked: _post.isLiked,
                      count: _post.likes,
                      onLike: _handleLike,
                      fmt: _fmt,
                    ),
                    const SizedBox(width: 4),
                    _ActionBtn(
                      icon:  Icons.chat_bubble_outline_rounded,
                      label: _fmt(_post.comments),
                      color: Colors.black45,
                      onTap: _showComments,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _handleBookmark,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _post.isBookmarked
                              ? const Color(0xFFEFF6FF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _post.isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size:  24,
                          color: _post.isBookmarked
                              ? const Color(0xFF3B82F6)
                              : Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Nội dung scroll ──
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Title ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                _post.title,
                style: const TextStyle(
                  fontSize:      26,
                  fontWeight:    FontWeight.w900,
                  color:         Color(0xFF0D1117),
                  height:        1.25,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // ── Author ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius:          18,
                    backgroundColor: const Color(0xFFDBEAFE),
                    backgroundImage: _post.authorAvatar.isNotEmpty
                        ? NetworkImage(_post.authorAvatar)
                        : null,
                    child: _post.authorAvatar.isEmpty
                        ? Text(
                            _post.authorName.isNotEmpty
                                ? _post.authorName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize:   13,
                              fontWeight: FontWeight.bold,
                              color:      Color(0xFF1D4ED8),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _post.authorName,
                        style: const TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.w700,
                          color:      Color(0xFF0D1117),
                        ),
                      ),
                      Text(
                        _post.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color:    Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Category pill ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:        const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Community',
                  style: TextStyle(
                    fontSize:   11,
                    fontWeight: FontWeight.w600,
                    color:      Color(0xFF0277BD),
                  ),
                ),
              ),
            ),

            // ── Divider ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Divider(color: Colors.grey.shade200, height: 1),
            ),

            // ── Hero image ──
            if (_post.imageUrl != null) ...[
              const SizedBox(height: 20),
              Image.network(
                _post.imageUrl!,
                width:  double.infinity,
                height: 240,
                fit:    BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 240,
                  color:  const Color(0xFFDBEAFE),
                  child:  const Icon(Icons.image_outlined,
                      size: 48, color: Colors.black26),
                ),
              ),
            ],

            // ── Content ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                _post.content,
                style: const TextStyle(
                  fontSize:      16,
                  color:         Color(0xFF374151),
                  height:        1.75,
                  letterSpacing: 0.1,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color:      color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Like Button với hiệu ứng ─────────────────────────────────────────────────

class _DetailLikeButton extends StatefulWidget {
  final bool isLiked;
  final int count;
  final VoidCallback onLike;
  final String Function(int) fmt;

  const _DetailLikeButton({
    required this.isLiked,
    required this.count,
    required this.onLike,
    required this.fmt,
  });

  @override
  State<_DetailLikeButton> createState() => _DetailLikeButtonState();
}

class _DetailLikeButtonState extends State<_DetailLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _particle;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.6)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 35),
      TweenSequenceItem(
          tween: Tween(begin: 1.6, end: 0.9)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 25),
      TweenSequenceItem(
          tween: Tween(begin: 0.9, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 40),
    ]).animate(_ctrl);

    _particle =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    widget.onLike();
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _HeartParticlePainter(
            progress: _particle.value,
            isLiked: widget.isLiked,
            isAnimating: _ctrl.isAnimating,
          ),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: _scale.value,
                    child: Icon(
                      widget.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border_rounded,
                      size: 22,
                      color: widget.isLiked
                          ? Colors.redAccent
                          : Colors.black45,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.fmt(widget.count),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.isLiked
                          ? Colors.redAccent
                          : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeartParticlePainter extends CustomPainter {
  final double progress;
  final bool isLiked;
  final bool isAnimating;

  _HeartParticlePainter({
    required this.progress,
    required this.isLiked,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isAnimating || progress == 0) return;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final opacity = (progress < 0.5
            ? progress * 2
            : (1.0 - progress) * 2)
        .clamp(0.0, 1.0);

    final easedProgress =
        1.0 - pow(1.0 - progress, 2).toDouble();

    const count = 8;
    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - pi / 2;
      final isLarge = i % 2 == 0;
      final maxDist = isLarge ? 26.0 : 20.0;
      final radius  = isLarge ? 3.5   : 2.2;

      final dist = maxDist * easedProgress;
      final x = cx + dist * cos(angle);
      final y = cy + dist * sin(angle);

      final color = isLiked
          ? (isLarge ? Colors.redAccent : Colors.pinkAccent)
          : (isLarge
              ? Colors.pink.shade200
              : Colors.pink.shade100);

      canvas.drawCircle(
        Offset(x, y),
        radius * (1.0 - progress * 0.3),
        Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.fill,
      );
    }

    // Ring
    if (progress < 0.6) {
      final ringR   = 20.0 * (progress / 0.6);
      final ringOpa = (1.0 - progress / 0.6).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(cx, cy),
        ringR,
        Paint()
          ..color =
              Colors.redAccent.withOpacity(ringOpa * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
  }

  @override
  bool shouldRepaint(_HeartParticlePainter old) =>
      old.progress != progress ||
      old.isAnimating != isAnimating;
}

