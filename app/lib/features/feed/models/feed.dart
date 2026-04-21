class FeedAuthor {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? role;
  final String? city;
  const FeedAuthor({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.role,
    this.city,
  });

  factory FeedAuthor.fromJson(Map<String, dynamic> j) => FeedAuthor(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? 'Unknown').toString(),
        avatarUrl: j['avatarUrl'] as String?,
        role: j['role'] as String?,
        city: j['city'] as String?,
      );
}

class FeedPost {
  final String id;
  final String type; // 'post' | 'blog'
  final String? title;
  final String body;
  final String? imageUrl;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool liked;
  final bool saved;
  final FeedAuthor author;

  const FeedPost({
    required this.id,
    required this.type,
    required this.body,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.liked,
    required this.saved,
    required this.author,
    this.title,
    this.imageUrl,
  });

  bool get isBlog => type == 'blog';

  factory FeedPost.fromJson(Map<String, dynamic> j) {
    final counts = (j['counts'] as Map?)?.cast<String, dynamic>() ?? const {};
    final viewer = (j['viewer'] as Map?)?.cast<String, dynamic>() ?? const {};
    return FeedPost(
      id: (j['id'] ?? '').toString(),
      type: (j['type'] ?? 'post').toString(),
      title: j['title'] as String?,
      body: (j['body'] ?? '').toString(),
      imageUrl: j['imageUrl'] as String?,
      createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      likesCount: (counts['likes'] as num?)?.toInt() ?? 0,
      commentsCount: (counts['comments'] as num?)?.toInt() ?? 0,
      liked: viewer['liked'] == true,
      saved: viewer['saved'] == true,
      author: FeedAuthor.fromJson(
          (j['author'] as Map?)?.cast<String, dynamic>() ?? const {}),
    );
  }

  FeedPost copyWith({
    int? likesCount,
    int? commentsCount,
    bool? liked,
    bool? saved,
  }) =>
      FeedPost(
        id: id,
        type: type,
        title: title,
        body: body,
        imageUrl: imageUrl,
        createdAt: createdAt,
        likesCount: likesCount ?? this.likesCount,
        commentsCount: commentsCount ?? this.commentsCount,
        liked: liked ?? this.liked,
        saved: saved ?? this.saved,
        author: author,
      );
}

class FeedPage {
  final List<FeedPost> items;
  final String? nextCursor;
  const FeedPage({required this.items, this.nextCursor});

  factory FeedPage.fromJson(Map<String, dynamic> j) => FeedPage(
        items: (j['items'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => FeedPost.fromJson(e.cast<String, dynamic>()))
            .toList(),
        nextCursor: j['nextCursor'] as String?,
      );
}

class FeedComment {
  final String id;
  final String postId;
  final String text;
  final DateTime createdAt;
  final FeedAuthor author;
  const FeedComment({
    required this.id,
    required this.postId,
    required this.text,
    required this.createdAt,
    required this.author,
  });

  factory FeedComment.fromJson(Map<String, dynamic> j) => FeedComment(
        id: (j['id'] ?? '').toString(),
        postId: (j['postId'] ?? '').toString(),
        text: (j['text'] ?? '').toString(),
        createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()) ??
            DateTime.now(),
        author: FeedAuthor.fromJson(
            (j['author'] as Map?)?.cast<String, dynamic>() ?? const {}),
      );
}

String relativeTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
  return '${(diff.inDays / 365).floor()}y ago';
}
