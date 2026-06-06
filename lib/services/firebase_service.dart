import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:qget_portal/models/alumni_model.dart';
import 'package:qget_portal/models/post_model.dart';
import 'package:qget_portal/rtdb_members_config.dart';

/// Thrown when sign-up email is not present in the RTDB alumni roster.
const String kNoAlumniEmailCode = 'no-alumni-email';

class FirebaseService {
  FirebaseService._();

  /// Millisecond timestamps from the Realtime Database server clock.
  /// Use these keys in RTDB: `createdAt`, `updatedAt`.
  static Map<String, dynamic> _withCreateTimestamps(Map<String, dynamic> data) {
    return {
      ...data,
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    };
  }

  static Map<String, dynamic> _withUpdateTimestamp(Map<String, dynamic> patch) {
    return {
      ...patch,
      'updatedAt': ServerValue.timestamp,
    };
  }

  static FirebaseDatabase get _db {
    if (kFirebaseRealtimeDatabaseUrl.isNotEmpty) {
      return FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: kFirebaseRealtimeDatabaseUrl,
      );
    }
    return FirebaseDatabase.instance;
  }

  static DatabaseReference get _membersRef =>
      _db.ref().child(kRtdbMembersRoot);

  static FirebaseAuth get auth => FirebaseAuth.instance;

  static Stream<User?> get authStateChanges => auth.authStateChanges();

  static Future<void> signOut() => auth.signOut();

  static Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  static Future<bool> alumniEmailExistsInRoster(String email) async {
    final n = normalizeEmail(email);
    var snap = await _membersRef
        .orderByChild('Email')
        .equalTo(n)
        .limitToFirst(1)
        .get();
    if (snap.exists && snap.value != null) return true;
    snap = await _membersRef
        .orderByChild('Email')
        .equalTo(email.trim())
        .limitToFirst(1)
        .get();
    return snap.exists && snap.value != null;
  }

  static Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final ok = await alumniEmailExistsInRoster(email);
    if (!ok) {
      throw FirebaseAuthException(
        code: kNoAlumniEmailCode,
        message: 'This email is not listed as an alum. Contact admin.',
      );
    }
    return auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static AlumniModel? _parseFirstMemberSnapshot(DataSnapshot snap) {
    if (!snap.exists || snap.value == null) return null;
    final v = snap.value;
    if (v is! Map) return null;
    if (v.isEmpty) return null;
    final e = v.entries.first;
    final id = e.key.toString();
    final data = e.value;
    if (data is! Map) return null;
    return AlumniModel.fromRtdb(id, data);
  }

  static List<AlumniModel> _parseMembersMap(Object? value) {
    if (value == null || value is! Map) return [];
    final out = <AlumniModel>[];
    value.forEach((key, val) {
      if (val is Map) {
        out.add(AlumniModel.fromRtdb(key.toString(), val));
      }
    });
    return out;
  }

  static Future<AlumniModel?> getCurrentMember(String? email) async {
    if (email == null || email.isEmpty) return null;
    final n = normalizeEmail(email);
    var snap = await _membersRef
        .orderByChild('Email')
        .equalTo(n)
        .limitToFirst(1)
        .get();
    var m = _parseFirstMemberSnapshot(snap);
    if (m != null) return m;
    snap = await _membersRef
        .orderByChild('Email')
        .equalTo(email.trim())
        .limitToFirst(1)
        .get();
    return _parseFirstMemberSnapshot(snap);
  }

  static Stream<List<AlumniModel>> membersStream() {
    return _membersRef.onValue.map((e) => _parseMembersMap(e.snapshot.value));
  }

  static Future<List<AlumniModel>> getMembersList() async {
    final snap = await _membersRef.get();
    return _parseMembersMap(snap.value);
  }

  static Future<AlumniModel?> getMemberById(String id) async {
    final snap = await _membersRef.child(id).get();
    if (!snap.exists || snap.value is! Map) return null;
    return AlumniModel.fromRtdb(id, Map<dynamic, dynamic>.from(snap.value as Map));
  }

  static Future<void> updateMemberProfile(String id, Map<String, dynamic> patch) {
    return _membersRef.child(id).update(_withUpdateTimestamp(patch));
  }

  static Future<String> createMember(Map<String, dynamic> data) async {
    final ref = _membersRef.push();
    await ref.set(_withCreateTimestamps(data));
    return ref.key!;
  }

  static Future<void> deleteMember(String id) {
    return _membersRef.child(id).remove();
  }

  static List<AlumniModel> searchMembers(
    List<AlumniModel> all,
    String query,
  ) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((a) {
      return a.memberName.toLowerCase().contains(q) ||
          a.email.toLowerCase().contains(q) ||
          a.companyName.toLowerCase().contains(q) ||
          a.branchName.toLowerCase().contains(q);
    }).toList();
  }

  static Future<List<AlumniModel>> getByDepartment(String branchName) async {
    final snap = await _membersRef
        .orderByChild('Branch_Name')
        .equalTo(branchName)
        .get();
    final map = snap.value;
    return _parseMembersMap(map);
  }

  static Future<List<AlumniModel>> getByYear(String year) async {
    final snap =
        await _membersRef.orderByChild('Year').equalTo(year).get();
    return _parseMembersMap(snap.value);
  }

  static Future<int> getAlumniCount() async {
    final snap = await _membersRef.get();
    final v = snap.value;
    if (v is Map) return v.length;
    return 0;
  }

  static Future<int> getPostsCount() async {
    final q = await FirebaseFirestore.instance
        .collection('posts')
        .count()
        .get();
    return q.count ?? 0;
  }

  static CollectionReference<Map<String, dynamic>> get _postsCol =>
      FirebaseFirestore.instance.collection('posts');

  static Stream<List<PostModel>> postsStream() {
    return _postsCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (q) => q.docs.map(PostModel.fromFirestore).toList(),
        );
  }

  static Future<void> createPost({
    required String content,
    String imageUrl = '',
  }) async {
    final user = auth.currentUser;
    if (user == null) throw StateError('Not signed in');
    final alum = await getCurrentMember(user.email);
    final doc = PostModel(
      id: '',
      authorUid: user.uid,
      authorName: alum?.memberName ?? user.displayName ?? user.email ?? 'Alum',
      authorPhotoUrl: alum?.imgUrl ?? user.photoURL ?? '',
      content: content,
      imageUrl: imageUrl,
      likes: const [],
      commentCount: 0,
      createdAt: DateTime.now(),
      authorDepartment: alum?.department ?? '',
      authorGraduationYear: alum?.graduationYear ?? '',
    );
    await _postsCol.add(doc.toFirestore());
  }

  static Future<void> toggleLike(String postId, String userId) {
    final ref = _postsCol.doc(postId);
    return FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final d = snap.data() ?? {};
      final raw = d['likes'];
      final likes = <String>[
        ...?((raw as List?)?.map((e) => e.toString())),
      ];
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }
      tx.update(ref, {'likes': likes});
    });
  }
}
