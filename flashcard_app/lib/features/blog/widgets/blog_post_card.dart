import 'package:flutter/material.dart';
import '../models/blog_post_model.dart';
import '../services/blog_service.dart';
import 'comment_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/edit_blog_screen.dart';
import '../../../core/widgets/app_popup.dart'; 

class BlogPostCard extends StatefulWidget {
  final BlogPost  post;
  final String    groupId;
  final GroupRole myRole;

  const BlogPostCard({
    super.key,
    required this.post,
    required this.groupId,
    required this.myRole,
  });

  @override
  State<BlogPostCard> createState() => _BlogPostCardState();
}

class _BlogPostCardState extends State<BlogPostCard> {
  late BlogPost _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  void didUpdateWidget(BlogPostCard oldWidget) { 
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post != widget.post) {
      setState(() => _post = widget.post);
    }
  }

  Future<void> _handleLike() async {
    final prev = _post.isLiked;
    setState(() => _post = _post.copyWith(
          isLiked: !prev,
          likes:   _post.likes + (prev ? -1 : 1),
        ));
    await BlogService.toggleLike(
      groupId:        widget.groupId,
      postId:         _post.id,
      currentlyLiked: prev,
    );
  }

  Future<void> _handleBookmark() async {
    final prev = _post.isBookmarked;
    setState(() => _post = _post.copyWith(
          isBookmarked: !prev,
          bookmarks:    _post.bookmarks + (prev ? -1 : 1),
        ));
    await BlogService.toggleBookmark(
      groupId:             widget.groupId,
      postId:              _post.id,
      currentlyBookmarked: prev,
    );
  }

  void _showComments() {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => CommentSheet(
        groupId: widget.groupId,
        postId:  _post.id,
        onCommentAdded: () => setState(
          () => _post = _post.copyWith(
              comments: _post.comments + 1),
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
          post:    _post,
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    AppPopup.show(
      context: context,
      icon:      Icons.delete_outline_rounded,
      iconColor: Colors.redAccent,
      title:     'Delete post?',
      message:   'This action cannot be undone.',
      buttonText: 'Cancel',
      onPressed: null,
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25)),
        backgroundColor: const Color(0xFFE0F7FA),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 25, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline_rounded,
                  size: 60, color: Colors.redAccent),
              const SizedBox(height: 15),
              const Text(
                'Delete post?',
                style: TextStyle(
                  fontSize:   22,
                  fontWeight: FontWeight.bold,
                  color:      Color(0xFF01579B),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Color(0xFF01579B)),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFC1E2FF),
                        padding: const EdgeInsets.symmetric(
                            vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                          side: const BorderSide(
                            color: Color(0xFF91B8F4),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.w700,
                          color:      Color(0xFF0277BD),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Colors.redAccent.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(
                            vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.redAccent
                                .withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.w700,
                          color:      Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true) {
      await BlogService.deletePost(
        groupId:      widget.groupId,
        postId:       _post.id,
        postAuthorId: _post.authorId,
      );
    }
  }

  Future<void> _showLikers() async {
    final snap = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('posts')
        .doc(_post.id)
        .collection('likes')
        .get();

    // Lấy uid từ doc.id, rồi fetch tên
    final names = await Future.wait(snap.docs.map((d) async {
      final u = await FirebaseFirestore.instance
          .collection('users').doc(d.id).get();
      return u.data()?['name'] ?? 'Unknown';
    }));

    final users = await Future.wait(
      snap.docs.map((d) async {
        final u = await FirebaseFirestore.instance
            .collection('users')
            .doc(d.id)
            .get();

        return {
          'name': u.data()?['name'] ?? 'Unknown',
          'avatar': u.data()?['photoUrl'] ?? '',
        };
      }),
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.55,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Handle
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${users.length} Likes',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: users.isEmpty
                    ? const Center(
                        child: Text(
                          'No likes yet ❤️',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        itemCount: users.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final user = users[index];

                          final avatar =
                              user['avatar'] as String? ?? '';

                          final name =
                              user['name'] as String? ?? 'Unknown';

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      const Color(0xFFDBEAFE),
                                  backgroundImage:
                                      avatar.isNotEmpty
                                          ? NetworkImage(avatar)
                                          : null,
                                  child: avatar.isEmpty
                                      ? Text(
                                          name[0].toUpperCase(),
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            color: Color(
                                                0xFF2563EB),
                                          ),
                                        )
                                      : null,
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Text(
                                    name,
                                    style:
                                        const TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ),

                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.red.shade50,
                                    borderRadius:
                                        BorderRadius
                                            .circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        color:
                                            Colors.redAccent,
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Liked',
                                        style: TextStyle(
                                          color: Colors
                                              .redAccent,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  @override
  Widget build(BuildContext context) {
    final canDelete =
        BlogService.canDelete(widget.myRole, _post.authorId);

    return Container(
      margin:  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:      const Color(0xFF4DD9F5).withOpacity(0.15),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius:          22,
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
                          fontSize:   18,
                          fontWeight: FontWeight.bold,
                          color:      Color(0xFF1D4ED8),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize:   15,
                        color:      Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _post.timeAgo,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              if (_post.authorId == FirebaseAuth.instance.currentUser?.uid || canDelete)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black45),
                  color: const Color.fromARGB(255, 232, 250, 252).withOpacity(0.95), 
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  onSelected: (val) {
                    if (val == 'edit')   _openEdit();
                    if (val == 'delete') _confirmDelete();
                  },
                  itemBuilder: (_) => [
                    if (_post.authorId == FirebaseAuth.instance.currentUser?.uid)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 18, color: Color(0xFF0277BD)),
                            SizedBox(width: 10),
                            Text('Edit post'),
                          ],
                        ),
                      ),
                    if (canDelete)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 18, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Text('Delete post',
                                style: TextStyle(color: Colors.redAccent)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Title ──
          Text(
            _post.title,
            style: const TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w800,
              color:      Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          // ── Content ──
          Text(
            _post.content,
            style: const TextStyle(
              fontSize: 13,
              color:    Colors.black54,
              height:   1.5,
            ),
          ),

          // ── Image ──
          if (_post.imageUrl != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                _post.imageUrl!,
                width:  double.infinity,
                height: 200,
                fit:    BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color:        const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 48, color: Colors.black26,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── Action bar ──
          Row(
            children: [
              GestureDetector(
                onTap: _handleLike,
                child: Icon(
                  _post.isLiked ? Icons.favorite : Icons.favorite_border,
                  size:  20,
                  color: _post.isLiked ? Colors.redAccent : Colors.black54,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _showLikers,   
                child: Text(
                  _fmt(_post.likes),
                  style: const TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                    color:      Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _Pill(
                icon:      Icons.chat_bubble_outline_rounded,
                label:     _fmt(_post.comments),
                iconColor: Colors.black54,
                onTap:     _showComments,
              ),
              const SizedBox(width: 8),
              _Pill(
                icon: _post.isBookmarked
                    ? Icons.bookmark : Icons.bookmark_border,
                label:     _fmt(_post.bookmarks),
                iconColor: _post.isBookmarked
                    ? const Color(0xFF3B82F6) : Colors.black54,
                onTap: _handleBookmark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Pill ───────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        iconColor;
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
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:        const Color(0xFFEFF6FF),
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
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color:      Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}