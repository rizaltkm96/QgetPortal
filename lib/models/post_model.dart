import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  PostModel({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.content,
    required this.imageUrl,
    required this.likes,
    required this.commentCount,
    required this.createdAt,
    required this.authorDepartment,
    required this.authorGraduationYear,
  });

  final String id;
  final String authorUid;
  final String authorName;
  final String authorPhotoUrl;
  final String content;
  final String imageUrl;
  final List<String> likes;
  final int commentCount;
  final DateTime? createdAt;
  final String authorDepartment;
  final String authorGraduationYear;

  factory PostModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    final likesRaw = d['likes'];
    final likes = <String>[];
    if (likesRaw is List) {
      for (final e in likesRaw) {
        likes.add(e.toString());
      }
    }
    final ts = d['createdAt'];
    DateTime? created;
    if (ts is Timestamp) created = ts.toDate();

    return PostModel(
      id: doc.id,
      authorUid: d['authorUid']?.toString() ?? '',
      authorName: d['authorName']?.toString() ?? '',
      authorPhotoUrl: d['authorPhotoUrl']?.toString() ?? '',
      content: d['content']?.toString() ?? '',
      imageUrl: d['imageUrl']?.toString() ?? '',
      likes: likes,
      commentCount: (d['commentCount'] is int)
          ? d['commentCount'] as int
          : int.tryParse(d['commentCount']?.toString() ?? '') ?? 0,
      createdAt: created,
      authorDepartment: d['authorDepartment']?.toString() ?? '',
      authorGraduationYear: d['authorGraduationYear']?.toString() ?? '',
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
}
