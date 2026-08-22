import 'package:cloud_firestore/cloud_firestore.dart';

// ArticleModel - a published news article shown in the home feed.
class ArticleModel {
  final String id;
  final String title;
  final String content;
  final String category; // e.g. Local, Sports, Weather, Politics
  final String imageUrl;
  final String authorName;
  final String authorId;
  final DateTime timestamp;
  final int likesCount;
  final int views;
  final bool isVerified;
  final bool isSponsored; // true for inline ad cards

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'Local',
    this.imageUrl = '',
    this.authorName = 'BirtaKhabar Team',
    this.authorId = '',
    required this.timestamp,
    this.likesCount = 0,
    this.views = 0,
    this.isVerified = true,
    this.isSponsored = false,
  });

  factory ArticleModel.fromMap(Map<String, dynamic> map, String id) {
    return ArticleModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'Local',
      imageUrl: map['imageUrl'] ?? '',
      authorName: map['authorName'] ?? 'BirtaKhabar Team',
      authorId: map['authorId'] ?? '',
      timestamp: map['publishedAt'] is Timestamp
          ? (map['publishedAt'] as Timestamp).toDate()
          : DateTime.now(),
      likesCount: map['likesCount'] ?? 0,
      views: map['views'] ?? 0,
      isVerified: map['isVerified'] ?? true,
      isSponsored: map['isSponsored'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
      'authorName': authorName,
      'authorId': authorId,
      'publishedAt': Timestamp.fromDate(timestamp),
      'likesCount': likesCount,
      'views': views,
      'isVerified': isVerified,
      'isSponsored': isSponsored,
    };
  }
}
