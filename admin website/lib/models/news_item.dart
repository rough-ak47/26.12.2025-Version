class NewsItem {
  final String id;
  final String title;
  final String body;
  final String audience; // e.g., 'all', 'users', 'volunteers'
  final DateTime createdAt;

  NewsItem({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    required this.createdAt,
  });
}

