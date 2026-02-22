import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorUid;
  final String authorName;
  final String? authorPhotoUrl;
  final String? content;
  final String? imageUrl;
  final List<String> likes;
  final int commentCount;
  final DateTime? createdAt;
  final String? authorDepartment;
  final String? authorGraduationYear;

  PostModel({
    required this.id,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoUrl,
    this.content,
    this.imageUrl,
    this.likes = const [],
    this.commentCount = 0,
    this.createdAt,
    this.authorDepartment,
    this.authorGraduationYear,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      content: data['content'],
      imageUrl: data['imageUrl'],
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      authorDepartment: data['authorDepartment'],
      authorGraduationYear: data['authorGraduationYear'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorUid': authorUid,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'commentCount': commentCount,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'authorDepartment': authorDepartment,
      'authorGraduationYear': authorGraduationYear,
    };
  }

  String get timeAgo {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}
