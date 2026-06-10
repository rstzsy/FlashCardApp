import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/blog_service.dart';

class CommentSheet extends StatefulWidget {
  final String       groupId;
  final String       postId;
  final VoidCallback onCommentAdded;

  const CommentSheet({
    super.key,
    required this.groupId,
    required this.postId,
    required this.onCommentAdded,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final _controller = TextEditingController();
  bool  _sending    = false;

  // Reply state
  String? _replyingToCommentId;
  String? _replyingToName;

  GroupRole _myRole = GroupRole.none;

  @override
  void initState() {
    super.initState();
    BlogService.getMyRole(widget.groupId).then((r) {
      if (mounted) setState(() => _myRole = r);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startReply(String commentId, String authorName) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToName      = authorName;
    });
    _controller.clear();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToName      = null;
    });
    _controller.clear();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    if (_replyingToCommentId != null) {
      await BlogService.addReply(
        groupId:   widget.groupId,
        postId:    widget.postId,
        commentId: _replyingToCommentId!,
        text:      text,
      );
      _cancelReply();
    } else {
      await BlogService.addComment(
        groupId: widget.groupId,
        postId:  widget.postId,
        text:    text,
      );
      widget.onCommentAdded();
    }

    _controller.clear();
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize:     0.92,
      minChildSize:     0.4,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color:        Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Comments',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w700,
                color:      Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),

            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: BlogService.getCommentsStream(
                  groupId: widget.groupId,
                  postId:  widget.postId,
                ),
                builder: (context, snap) {
                  final comments = snap.data ?? [];

                  if (comments.isEmpty) {
                    return const Center(
                      child: Text(
                        'No comments yet.\nBe the first!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black38),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount:   comments.length,
                    itemBuilder: (_, i) => _CommentTile(
                      comment:   comments[i],
                      groupId:   widget.groupId,
                      postId:    widget.postId,
                      myRole:    _myRole,
                      onReply:   _startReply,
                      onDeleted: () {},
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Reply indicator
            if (_replyingToName != null)
              Container(
                color: const Color(0xFFE0F7FA),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.reply,
                        size: 14, color: Color(0xFF0277BD)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Replying to $_replyingToName',
                        style: const TextStyle(
                          fontSize:   12,
                          color:      Color(0xFF0277BD),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.black45),
                    ),
                  ],
                ),
              ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left:   16,
                  right:  16,
                  top:    10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF4DD9F5).withOpacity(0.4),
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: _replyingToName != null
                                ? 'Write a reply…'
                                : 'Write a comment…',
                            hintStyle: const TextStyle(
                                fontSize: 14, color: Colors.black38),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color:        const Color(0xFF0277BD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: _sending
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  color:       Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_rounded,
                                size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Comment tile ───────────────────────────────────────────────────────────────

class _CommentTile extends StatefulWidget {
  final Map<String, dynamic>                         comment;
  final String                                       groupId;
  final String                                       postId;
  final GroupRole                                    myRole;
  final void Function(String commentId, String name) onReply;
  final VoidCallback                                 onDeleted;

  const _CommentTile({
    required this.comment,
    required this.groupId,
    required this.postId,
    required this.myRole,
    required this.onReply,
    required this.onDeleted,
  });

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _showReplies = false;

  String _timeAgo(dynamic raw) {
    if (raw == null) return '';
    DateTime dt;
    if (raw is Timestamp)   dt = raw.toDate();
    else if (raw is String) dt = DateTime.tryParse(raw) ?? DateTime.now();
    else return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    if (diff.inDays    == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final name            = (widget.comment['authorName']   ?? '') as String;
    final avatar          = (widget.comment['authorAvatar'] ?? '') as String;
    final text            = (widget.comment['text']         ?? '') as String;
    final time            = _timeAgo(widget.comment['createdAt']);
    final commentId       = (widget.comment['id']           ?? '') as String;
    final commentAuthorId = (widget.comment['authorId']     ?? '') as String;
    final currentUid      = FirebaseAuth.instance.currentUser?.uid ?? '';
    final canDelete       = widget.myRole == GroupRole.admin ||
                            widget.myRole == GroupRole.moderator ||
                            currentUid == commentAuthorId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius:          18,
                backgroundColor: const Color(0xFFDBEAFE),
                backgroundImage:
                    avatar.isNotEmpty ? NetworkImage(avatar) : null,
                child: avatar.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize:   14,
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
                    // Bubble
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color:        const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                    fontSize:   13,
                                    fontWeight: FontWeight.w700,
                                    color:      Color(0xFF0277BD),
                                  )),
                              const Spacer(),
                              if (time.isNotEmpty)
                                Text(time,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color:    Colors.black38)),
                              if (canDelete) ...[
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        backgroundColor:
                                            const Color(0xFFE0F7FA),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25, vertical: 30),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                  Icons.delete_outline_rounded,
                                                  size:  60,
                                                  color: Colors.redAccent),
                                              const SizedBox(height: 15),
                                              const Text(
                                                'Delete comment?',
                                                style: TextStyle(
                                                  fontSize:   22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF01579B),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'This comment and all replies will be permanently deleted.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color(0xFF01579B)),
                                              ),
                                              const SizedBox(height: 25),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      style: TextButton.styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                                0xFFC1E2FF),
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                                vertical: 13),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          side: const BorderSide(
                                                            color: Color(
                                                                0xFF91B8F4),
                                                            width: 1.5,
                                                          ),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          fontSize:   14,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Color(
                                                              0xFF0277BD),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Colors
                                                            .redAccent
                                                            .withOpacity(0.1),
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                                vertical: 13),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          side: BorderSide(
                                                            color: Colors
                                                                .redAccent
                                                                .withOpacity(
                                                                    0.4),
                                                            width: 1.5,
                                                          ),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          fontSize:   14,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              Colors.redAccent,
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
                                    if (confirm == true) {
                                      await BlogService.deleteComment(
                                        groupId:         widget.groupId,
                                        postId:          widget.postId,
                                        commentId:       commentId,
                                        commentAuthorId: commentAuthorId,
                                      );
                                      widget.onDeleted();
                                    }
                                  },
                                  child: const Icon(Icons.more_horiz,
                                      size: 16, color: Colors.black38),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(text,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87)),
                        ],
                      ),
                    ),

                    // Reply button
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: GestureDetector(
                        onTap: () => widget.onReply(commentId, name),
                        child: const Text(
                          'Reply',
                          style: TextStyle(
                            fontSize:   12,
                            fontWeight: FontWeight.w600,
                            color:      Color(0xFF0277BD),
                          ),
                        ),
                      ),
                    ),

                    // Show/hide replies
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: BlogService.getRepliesStream(
                        groupId:   widget.groupId,
                        postId:    widget.postId,
                        commentId: commentId,
                      ),
                      builder: (context, snap) {
                        final replies = snap.data ?? [];
                        if (replies.isEmpty) return const SizedBox();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => setState(
                                  () => _showReplies = !_showReplies),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 4, top: 4, bottom: 4),
                                child: Text(
                                  _showReplies
                                      ? 'Hide replies'
                                      : 'View ${replies.length} repl${replies.length == 1 ? 'y' : 'ies'}',
                                  style: const TextStyle(
                                    fontSize:   12,
                                    fontWeight: FontWeight.w600,
                                    color:      Colors.black45,
                                  ),
                                ),
                              ),
                            ),
                            if (_showReplies)
                              ...replies.map((r) => _ReplyTile(
                                    reply:     r,
                                    groupId:   widget.groupId,
                                    postId:    widget.postId,
                                    commentId: commentId,
                                    myRole:    widget.myRole,
                                  )),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Reply tile ─────────────────────────────────────────────────────────────────

class _ReplyTile extends StatelessWidget {
  final Map<String, dynamic> reply;
  final String    groupId;
  final String    postId;
  final String    commentId;
  final GroupRole myRole;

  const _ReplyTile({
    required this.reply,
    required this.groupId,
    required this.postId,
    required this.commentId,
    required this.myRole,
  });

  String _timeAgo(dynamic raw) {
    if (raw == null) return '';
    DateTime dt;
    if (raw is Timestamp)   dt = raw.toDate();
    else if (raw is String) dt = DateTime.tryParse(raw) ?? DateTime.now();
    else return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    if (diff.inDays    == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final name          = (reply['authorName']   ?? '') as String;
    final avatar        = (reply['authorAvatar'] ?? '') as String;
    final text          = (reply['text']         ?? '') as String;
    final time          = _timeAgo(reply['createdAt']);
    final replyId       = (reply['id']           ?? '') as String;
    final replyAuthorId = (reply['authorId']      ?? '') as String;
    final currentUid    = FirebaseAuth.instance.currentUser?.uid ?? '';
    final canDelete     = myRole == GroupRole.admin ||
                          myRole == GroupRole.moderator ||
                          currentUid == replyAuthorId;

    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius:          14,
            backgroundColor: const Color(0xFFDBEAFE),
            backgroundImage:
                avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.bold,
                      color:      Color(0xFF1D4ED8),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:        const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name,
                          style: const TextStyle(
                            fontSize:   12,
                            fontWeight: FontWeight.w700,
                            color:      Color(0xFF0277BD),
                          )),
                      const Spacer(),
                      if (time.isNotEmpty)
                        Text(time,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black38)),
                      if (canDelete) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
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
                                      const Icon(
                                          Icons.delete_outline_rounded,
                                          size:  60,
                                          color: Colors.redAccent),
                                      const SizedBox(height: 15),
                                      const Text(
                                        'Delete reply?',
                                        style: TextStyle(
                                          fontSize:   22,
                                          fontWeight: FontWeight.bold,
                                          color:      Color(0xFF01579B),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'This reply will be permanently deleted.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF01579B)),
                                      ),
                                      const SizedBox(height: 25),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, false),
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFC1E2FF),
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                  color: Color(0xFF0277BD),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, true),
                                              style: TextButton.styleFrom(
                                                backgroundColor: Colors
                                                    .redAccent
                                                    .withOpacity(0.1),
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                  color: Colors.redAccent,
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
                            if (confirm == true) {
                              await BlogService.deleteReply(
                                groupId:       groupId,
                                postId:        postId,
                                commentId:     commentId,
                                replyId:       replyId,
                                replyAuthorId: replyAuthorId,
                              );
                            }
                          },
                          child: const Icon(Icons.more_horiz,
                              size: 14, color: Colors.black38),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(text,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}