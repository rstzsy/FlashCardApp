import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  final String  id;
  final String  groupId;
  final String  authorId;
  final String  authorName;
  final String  authorAvatar;
  final DateTime createdAt;
  final String  title;
  final String  content;
  final String? imageUrl;
  final int     likes;
  final int     comments;
  final int     bookmarks;
  final bool    isLiked;
  final bool    isBookmarked;

  const BlogPost({
    required this.id,
    required this.groupId,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
    required this.title,
    required this.content,
    this.imageUrl,
    this.likes        = 0,
    this.comments     = 0,
    this.bookmarks    = 0,
    this.isLiked      = false,
    this.isBookmarked = false,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    if (diff.inDays    == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  BlogPost copyWith({
    int?  likes,
    int?  comments,
    int?  bookmarks,
    bool? isLiked,
    bool? isBookmarked,
  }) =>
      BlogPost(
        id:           id,
        groupId:      groupId,
        authorId:     authorId,
        authorName:   authorName,
        authorAvatar: authorAvatar,
        createdAt:    createdAt,
        title:        title,
        content:      content,
        imageUrl:     imageUrl,
        likes:        likes        ?? this.likes,
        comments:     comments     ?? this.comments,
        bookmarks:    bookmarks    ?? this.bookmarks,
        isLiked:      isLiked      ?? this.isLiked,
        isBookmarked: isBookmarked ?? this.isBookmarked,
      );

  Map<String, dynamic> toMap() => {
    'groupId':      groupId,
    'authorId':     authorId,
    'authorName':   authorName,
    'authorAvatar': authorAvatar,
    'createdAt':    FieldValue.serverTimestamp(),
    'title':        title,
    'content':      content,
    'imageUrl':     imageUrl,
    'likes':        0,
    'comments':     0,
    'bookmarks':    0,
  };

  factory BlogPost.fromFirestore(String id, Map<String, dynamic> d) {
    DateTime created = DateTime.now();
    final raw = d['createdAt'];
    if (raw is Timestamp) created = raw.toDate();
    if (raw is String)    created = DateTime.tryParse(raw) ?? DateTime.now();

    return BlogPost(
      id:           id,
      groupId:      d['groupId']      ?? '',
      authorId:     d['authorId']     ?? '',
      authorName:   d['authorName']   ?? '',
      authorAvatar: d['authorAvatar'] ?? '',
      createdAt:    created,
      title:        d['title']    ?? '',
      content:      d['content']  ?? '',
      imageUrl:     d['imageUrl'],
      likes:        (d['likes']     ?? 0) as int,
      comments:     (d['comments']  ?? 0) as int,
      bookmarks:    (d['bookmarks'] ?? 0) as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BlogPost &&
        other.id       == id       &&
        other.title    == title    &&
        other.content  == content  &&
        other.imageUrl == imageUrl &&
        other.likes    == likes    &&
        other.comments == comments;
  }

  @override
  int get hashCode => Object.hash(id, title, content, imageUrl, likes, comments);
}