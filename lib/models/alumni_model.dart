import 'package:cloud_firestore/cloud_firestore.dart';

/// Alumni / member record (Firestore or Realtime Database).
class AlumniModel {
  AlumniModel({
    required this.id,
    required this.raw,
  });

  /// Document / RTDB child key.
  final String id;

  /// Underlying field map (preserves extra keys).
  final Map<String, dynamic> raw;

  String _str(String k) => (raw[k]?.toString() ?? '').trim();

  String get memberName => _str('Member_Name');
  String get email => _str('Email');
  String get imgUrl => _str('ImgURL');
  String get year => _str('Year');
  String get branchName => _str('Branch_Name');
  String get companyName => _str('Company_Name');
  String get position => _str('Position');
  String get contactNumber => _str('Contact_Number');
  String get whatsappNumber => _str('Whatsapp_Number');
  String get bloodGroup => _str('Blood_Group');
  String get spouseName => _str('Spouse_Name');
  String get spouseIsMember => _str('Spouse_Is_Member');
  String get socialMediaLink => _str('Social_Media_Link');
  String get uidField => _str('UID');
  String get efNumber => _str('EF_Number');
  String get child1Name => _str('Child1_Name');
  String get child2Name => _str('Child2_Name');
  String get child3Name => _str('Child3_Name');
  String get child4Name => _str('Child4_Name');
  String get child1Dob => _str('Child1_DOB');
  String get child2Dob => _str('Child2_DOB');
  String get child3Dob => _str('Child3_DOB');
  String get child4Dob => _str('Child4_DOB');
  String get createdAtLegacy => _str('CreatedAt');
  String get imageName => _str('ImageName');

  /// Server timestamp (ms) from RTDB [createdAt]; null for legacy rows.
  int? get createdAtMillis => _asMillis(raw['createdAt']);

  /// Server timestamp (ms) from RTDB [updatedAt]; null if never updated via app.
  int? get updatedAtMillis => _asMillis(raw['updatedAt']);

  /// Human-readable date: prefers [createdAt] server ms, else legacy [CreatedAt] string.
  String get createdAt {
    final ms = createdAtMillis;
    if (ms != null) {
      return _formatDdMmYyyy(DateTime.fromMillisecondsSinceEpoch(ms));
    }
    return createdAtLegacy;
  }

  /// Human-readable last-update date from [updatedAt] server ms.
  String get updatedAtFormatted {
    final ms = updatedAtMillis;
    if (ms == null) return '';
    return _formatDdMmYyyy(DateTime.fromMillisecondsSinceEpoch(ms));
  }

  static int? _asMillis(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString());
  }

  static String _formatDdMmYyyy(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d-$m-$y';
  }

  /// Backward-compatible getters
  String get graduationYear => year;
  String get department => branchName;
  String get currentCompany => companyName;
  String get currentPosition => position;

  String get displaySubtitle {
    final parts = <String>[];
    if (department.isNotEmpty) parts.add(department);
    if (graduationYear.isNotEmpty) parts.add('Class of $graduationYear');
    return parts.join(' · ');
  }

  String get initials {
    final n = memberName.trim();
    if (n.isEmpty) {
      final e = email;
      if (e.isNotEmpty) return e[0].toUpperCase();
      return '?';
    }
    final parts = n.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  static String createdAtStringNow() {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    final y = now.year.toString();
    return '$d-$m-$y';
  }

  factory AlumniModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return AlumniModel.fromMemberMap(data, doc.id);
  }

  factory AlumniModel.fromRtdb(String id, Map<dynamic, dynamic> data) {
    final map = <String, dynamic>{};
    data.forEach((k, v) {
      map[k.toString()] = v;
    });
    return AlumniModel.fromMemberMap(map, id);
  }

  factory AlumniModel.fromMemberMap(Map<String, dynamic> map, String id) {
    return AlumniModel(id: id, raw: Map<String, dynamic>.from(map));
  }

  Map<String, dynamic> toRtdbUpdateMap() => Map<String, dynamic>.from(raw);

  AlumniModel copyWithMerged(Map<String, dynamic> patch) {
    return AlumniModel(
      id: id,
      raw: {...raw, ...patch},
    );
  }
}
