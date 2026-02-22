import 'package:cloud_firestore/cloud_firestore.dart';

class AlumniModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bio;
  final String? graduationYear;
  final String? department;
  final String? degree;
  final String? currentCompany;
  final String? currentPosition;
  final String? location;
  final String? phone;
  final String? linkedIn;
  final String? instagram;
  final String? github;
  final List<String> skills;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? lastActive;

  AlumniModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    this.graduationYear,
    this.department,
    this.degree,
    this.currentCompany,
    this.currentPosition,
    this.location,
    this.phone,
    this.linkedIn,
    this.instagram,
    this.github,
    this.skills = const [],
    this.isVerified = false,
    this.createdAt,
    this.lastActive,
  });

  factory AlumniModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlumniModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      graduationYear: data['graduationYear'],
      department: data['department'],
      degree: data['degree'],
      currentCompany: data['currentCompany'],
      currentPosition: data['currentPosition'],
      location: data['location'],
      phone: data['phone'],
      linkedIn: data['linkedIn'],
      instagram: data['instagram'],
      github: data['github'],
      skills: List<String>.from(data['skills'] ?? []),
      isVerified: data['isVerified'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      lastActive: data['lastActive'] != null
          ? (data['lastActive'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'graduationYear': graduationYear,
      'department': department,
      'degree': degree,
      'currentCompany': currentCompany,
      'currentPosition': currentPosition,
      'location': location,
      'phone': phone,
      'linkedIn': linkedIn,
      'instagram': instagram,
      'github': github,
      'skills': skills,
      'isVerified': isVerified,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    };
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get displaySubtitle {
    if (currentPosition != null && currentCompany != null) {
      return '$currentPosition at $currentCompany';
    }
    if (department != null && graduationYear != null) {
      return '$department · Class of $graduationYear';
    }
    return department ?? degree ?? '';
  }
}
