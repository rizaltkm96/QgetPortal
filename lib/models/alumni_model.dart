import 'package:cloud_firestore/cloud_firestore.dart';

/// Member model mapped from Firestore "users" collection.
/// All fields correspond to real document fields.
class AlumniModel {
  final String uid;
  final String name;
  final String email;
  /// Member photo. From Firestore field [ImgURL] only; it loads the image.
  final String? photoUrl;
  final String? year;
  final String? branchName;
  final String? companyName;
  final String? position;
  final String? contactNumber;
  final String? whatsappNumber;
  final String? bloodGroup;
  final String? spouseName;
  final String? spouseIsMember;
  final String? socialMediaLink;
  final int? numericUid;
  final String? efNumber;
  final String? child1Name;
  final String? child1Dob;
  final String? child2Name;
  final String? child2Dob;
  final String? child3Name;
  final String? child3Dob;
  final String? child4Name;
  final String? child4Dob;

  AlumniModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.year,
    this.branchName,
    this.companyName,
    this.position,
    this.contactNumber,
    this.whatsappNumber,
    this.bloodGroup,
    this.spouseName,
    this.spouseIsMember,
    this.socialMediaLink,
    this.numericUid,
    this.efNumber,
    this.child1Name,
    this.child1Dob,
    this.child2Name,
    this.child2Dob,
    this.child3Name,
    this.child3Dob,
    this.child4Name,
    this.child4Dob,
  });

  factory AlumniModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    String? photoUrl = data['ImgURL'] as String?;
    if (photoUrl != null && photoUrl.isEmpty) photoUrl = null;
    String? socialLink = data['Social_Media_Link'] as String?;
    if (socialLink != null && socialLink.isEmpty) socialLink = null;

    return AlumniModel(
      uid: doc.id,
      name: (data['Member_Name'] as String? ?? '').trim(),
      email: (data['Email'] as String? ?? '').trim(),
      photoUrl: photoUrl,
      year: data['Year'] as String?,
      branchName: data['Branch_Name'] as String?,
      companyName: data['Company_Name'] as String?,
      position: data['Position'] as String?,
      contactNumber: data['Contact_Number'] as String?,
      whatsappNumber: data['Whatsapp_Number'] as String?,
      bloodGroup: data['Blood_Group'] as String?,
      spouseName: data['Spouse_Name'] as String?,
      spouseIsMember: data['Spouse_Is_Member'] as String?,
      socialMediaLink: socialLink,
      numericUid: data['UID'] is int ? data['UID'] as int : null,
      efNumber: data['EF_Number'] as String?,
      child1Name: data['Child1_Name'] as String?,
      child1Dob: data['Child1_DOB'] as String?,
      child2Name: data['Child2_Name'] as String?,
      child2Dob: data['Child2_DOB'] as String?,
      child3Name: data['Child3_Name'] as String?,
      child3Dob: data['Child3_DOB'] as String?,
      child4Name: data['Child4_Name'] as String?,
      child4Dob: data['Child4_DOB'] as String?,
    );
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Subtitle for list/grid: Position at Company, or Branch · Year.
  String get displaySubtitle {
    if (position != null && position!.isNotEmpty && companyName != null && companyName!.isNotEmpty) {
      return '$position at $companyName';
    }
    if (branchName != null && branchName!.isNotEmpty && year != null && year!.isNotEmpty) {
      return '$branchName · $year';
    }
    return branchName ?? year ?? '';
  }

  /// For backward compatibility where graduationYear is used.
  String? get graduationYear => year;

  /// For backward compatibility where department is used.
  String? get department => branchName;

  /// For backward compatibility where currentCompany is used.
  String? get currentCompany => companyName;

  /// For backward compatibility where currentPosition is used.
  String? get currentPosition => position;
}
