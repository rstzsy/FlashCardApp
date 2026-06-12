import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../blog/models/blog_post_model.dart';
import '../../blog/services/blog_service.dart';
import '../../blog/screens/blog_detail_screen.dart';
import '../../blog/widgets/like_button.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  late Future<List<BlogPost>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchSavedPosts();
  }

  Future<List<BlogPost>> _fetchSavedPosts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final db = FirebaseFirestore.instance;

    final groupsSnap = await db.collection('groups').get();

    final groupResults = await Future.wait(
      groupsSnap.docs.map((groupDoc) async {
        final memberDoc = await db
            .collection('groups')
            .doc(groupDoc.id)
            .collection('members')
            .doc(uid)
            .get();
        if (!memberDoc.exists) return <BlogPost>[];

        final postsSnap = await db
            .collection('groups')
            .doc(groupDoc.id)
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .get();

        final posts = await Future.wait(
          postsSnap.docs.map((postDoc) async {
            final results = await Future.wait([
              db.collection('groups').doc(groupDoc.id)
                  .collection('posts').doc(postDoc.id)
                  .collection('bookmarks').doc(uid).get(),
              db.collection('groups').doc(groupDoc.id)
                  .collection('posts').doc(postDoc.id)
                  .collection('likes').doc(uid).get(),
            ]);

            final bmDoc   = results[0];
            final likeDoc = results[1];

            if (!bmDoc.exists) return null;

            return BlogPost.fromFirestore(postDoc.id, postDoc.data())
                .copyWith(
                  isLiked:      likeDoc.exists,
                  isBookmarked: true,
                );
          }),
        );

        return posts.whereType<BlogPost>().toList();
      }),
    );

    final saved = groupResults.expand((e) => e).toList();
    saved.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return saved;
  }

  // Toggle + refresh
  Future<void> _unbookmark(BlogPost post) async {
    await BlogService.toggleBookmark(
      groupId: post.groupId,
      postId: post.id,
      currentlyBookmarked: true,
    );
    _refreshList();
  }

  // Chỉ refresh, không toggle
  void _refreshList() {
    setState(() {
      _future = _fetchSavedPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved Posts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<BlogPost>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border_rounded,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No saved posts yet',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bookmark posts in groups to see them here',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _SavedPostCard(
                post:        post,
                onUnbookmark: () => _unbookmark(post), // toggle + refresh
                onRefresh:    _refreshList,             // chỉ refresh
              );
            },
          );
        },
      ),
    );
  }
}

// ── Saved Post Card ───────────────────────────────────────────────────────────

class _SavedPostCard extends StatefulWidget {
  final BlogPost     post;
  final VoidCallback onUnbookmark;
  final VoidCallback onRefresh;

  const _SavedPostCard({
    required this.post,
    required this.onUnbookmark,
    required this.onRefresh,
  });

  @override
  State<_SavedPostCard> createState() => _SavedPostCardState();
}

class _SavedPostCardState extends State<_SavedPostCard> {
  late BlogPost _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  Future<void> _handleLike() async {
    final prev = _post.isLiked;
    setState(() => _post = _post.copyWith(
          isLiked: !prev,
          likes: _post.likes + (prev ? -1 : 1),
        ));
    await BlogService.toggleLike(
      groupId: _post.groupId,
      postId: _post.id,
      currentlyLiked: prev,
    );
  }

  void _confirmUnbookmark() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remove from saved?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          'This post will be removed from your saved list.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey.shade500)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onUnbookmark(); // toggle + refresh
            },
            child: const Text('Remove',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlogDetailScreen(
            post:              _post,
            groupId:           _post.groupId,
            myRole:            GroupRole.member,
            onBookmarkChanged: widget.onRefresh, // chỉ refresh, không toggle
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4DD9F5).withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            if (_post.imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  _post.imageUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDBEAFE),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: const Icon(Icons.image_outlined,
                        size: 40, color: Colors.black26),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: author + unbookmark ──
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D4ED8),
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
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              _post.timeAgo,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black45),
                            ),
                          ],
                        ),
                      ),

                      // Unbookmark button
                      GestureDetector(
                        onTap: _confirmUnbookmark,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bookmark_rounded,
                            size: 18,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Title ──
                  Text(
                    _post.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // ── Content preview ──
                  Text(
                    _post.content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 14),

                  // ── Action bar ──
                  Row(
                    children: [
                      LikeButton(
                        isLiked: _post.isLiked,
                        count: _post.likes,
                        onLike: _handleLike,
                        fmt: _fmt,
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 18, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text(
                        _fmt(_post.comments),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}