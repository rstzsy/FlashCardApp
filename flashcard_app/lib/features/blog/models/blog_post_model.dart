class BlogPost {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String timeAgo;
  final String title;
  final String content;
  final String? imageUrl;
  final int likes;
  final int comments;
  final int bookmarks;
  final bool isLiked;
  final bool isBookmarked;

  const BlogPost({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.timeAgo,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.bookmarks,
    this.isLiked = false,
    this.isBookmarked = false,
  });
}