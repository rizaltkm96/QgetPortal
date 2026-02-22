import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alumni_model.dart';
import '../models/post_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Alumni Collection ──────────────────────────────

  static Stream<List<AlumniModel>> getAlumniStream() {
    return _firestore
        .collection('alumni')
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AlumniModel.fromFirestore(doc)).toList());
  }

  static Future<List<AlumniModel>> getAlumniList() async {
    final snapshot =
        await _firestore.collection('alumni').orderBy('name').get();
    return snapshot.docs.map((doc) => AlumniModel.fromFirestore(doc)).toList();
  }

  static Future<AlumniModel?> getAlumniById(String uid) async {
    final doc = await _firestore.collection('alumni').doc(uid).get();
    if (doc.exists) {
      return AlumniModel.fromFirestore(doc);
    }
    return null;
  }

  static Future<List<AlumniModel>> searchAlumni(String query) async {
    final snapshot =
        await _firestore.collection('alumni').orderBy('name').get();
    final alumni =
        snapshot.docs.map((doc) => AlumniModel.fromFirestore(doc)).toList();
    final lowerQuery = query.toLowerCase();
    return alumni.where((a) {
      return a.name.toLowerCase().contains(lowerQuery) ||
          (a.department?.toLowerCase().contains(lowerQuery) ?? false) ||
          (a.graduationYear?.contains(lowerQuery) ?? false) ||
          (a.currentCompany?.toLowerCase().contains(lowerQuery) ?? false) ||
          (a.location?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  static Future<List<AlumniModel>> getAlumniByDepartment(
      String department) async {
    final snapshot = await _firestore
        .collection('alumni')
        .where('department', isEqualTo: department)
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) => AlumniModel.fromFirestore(doc)).toList();
  }

  static Future<List<AlumniModel>> getAlumniByYear(String year) async {
    final snapshot = await _firestore
        .collection('alumni')
        .where('graduationYear', isEqualTo: year)
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) => AlumniModel.fromFirestore(doc)).toList();
  }

  static Future<void> addAlumni(AlumniModel alumni) async {
    await _firestore
        .collection('alumni')
        .doc(alumni.uid)
        .set(alumni.toFirestore());
  }

  static Future<void> updateAlumni(
      String uid, Map<String, dynamic> data) async {
    await _firestore.collection('alumni').doc(uid).update(data);
  }

  // ─── Posts Collection ───────────────────────────────

  static Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  static Future<void> createPost(PostModel post) async {
    await _firestore.collection('posts').add(post.toFirestore());
  }

  static Future<void> toggleLike(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final doc = await postRef.get();
    if (doc.exists) {
      final likes = List<String>.from(doc.data()?['likes'] ?? []);
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }
      await postRef.update({'likes': likes});
    }
  }

  // ─── Auth ───────────────────────────────────────────

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─── Stats ──────────────────────────────────────────

  static Future<Map<String, int>> getStats() async {
    final alumniCount =
        await _firestore.collection('alumni').count().get();
    final postsCount =
        await _firestore.collection('posts').count().get();
    return {
      'alumni': alumniCount.count ?? 0,
      'posts': postsCount.count ?? 0,
    };
  }

  // ─── Departments ────────────────────────────────────

  static Future<List<String>> getDepartments() async {
    final snapshot = await _firestore.collection('alumni').get();
    final departments = snapshot.docs
        .map((doc) => doc.data()['department'] as String?)
        .where((d) => d != null && d.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    departments.sort();
    return departments;
  }
}
