class NewsModel {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final DateTime publishedAt;
  final String author;

  NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.publishedAt,
    required this.author,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      publishedAt: DateTime.parse(json['publishedAt']),
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'author': author,
    };
  }
}
