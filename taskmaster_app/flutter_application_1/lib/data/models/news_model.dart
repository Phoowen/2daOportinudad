import 'dart:convert';

class NewsArticle {
  final String? author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final DateTime publishedAt;
  final String content;
  final String sourceName;

  NewsArticle({
    this.author,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.content,
    required this.sourceName,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      author: json['author'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ??
          'https://via.placeholder.com/300x200?text=No+Image',
      publishedAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toIso8601String()),
      content: json['content'] ?? '',
      sourceName: json['source']['name'] ?? 'Unknown Source',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt.toIso8601String(),
      'content': content,
      'source': {'name': sourceName},
    };
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${publishedAt.day}/${publishedAt.month}/${publishedAt.year}';
    }
  }

  String get shortDescription {
    if (description.length > 100) {
      return '${description.substring(0, 100)}...';
    }
    return description;
  }
}

class NewsResponse {
  final String status;
  final int totalResults;
  final List<NewsArticle> articles;

  NewsResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    final articles = (json['articles'] as List)
        .map((article) => NewsArticle.fromJson(article))
        .where((article) => article.title.isNotEmpty) // Filtrar noticias sin título
        .toList();

    return NewsResponse(
      status: json['status'] ?? 'error',
      totalResults: json['totalResults'] ?? 0,
      articles: articles,
    );
  }
}