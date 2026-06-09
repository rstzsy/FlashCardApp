import '../models/blog_post_model.dart';

class BlogService {
  static List<BlogPost> getDummyPosts() {
    return [
      const BlogPost(
        id: '1',
        authorName: 'Emma Carter',
        authorAvatar: '',
        timeAgo: '12:30PM',
        title: "Today's Thought",
        content:
            'Some moments fly by, yet their emotions linger. I took a moment to soak in the tranquil beauty surrounding me, understanding that choosing peace is in our hands.',
        imageUrl: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=600',
        likes: 2500,
        comments: 1500,
        bookmarks: 99,
      ),
      const BlogPost(
        id: '2',
        authorName: 'James Liu',
        authorAvatar: '',
        timeAgo: '10:15AM',
        title: 'Learning Journey',
        content:
            'Every word I learn opens a new door. Flashcards have changed the way I study — repetition becomes rhythm, and rhythm becomes memory.',
        imageUrl: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=600',
        likes: 1800,
        comments: 940,
        bookmarks: 210,
      ),
      const BlogPost(
        id: '3',
        authorName: 'Sofia Nguyen',
        authorAvatar: '',
        timeAgo: 'Yesterday',
        title: 'Morning Vocabulary',
        content:
            'Started my day with 20 new words. The morning light and a warm cup of tea — the perfect study companion. Small steps every day lead to big progress.',
        imageUrl: null,
        likes: 3200,
        comments: 760,
        bookmarks: 145,
      ),
      const BlogPost(
        id: '4',
        authorName: 'Lucas Park',
        authorAvatar: '',
        timeAgo: '2 days ago',
        title: 'Consistency is Key',
        content:
            'Day 30 of my streak! What started as a challenge has become a habit I genuinely enjoy. The community here keeps me going every single day.',
        imageUrl: 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=600',
        likes: 4100,
        comments: 1200,
        bookmarks: 380,
      ),
    ];
  }
}