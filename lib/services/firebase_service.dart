import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alumni_model.dart';
import '../models/post_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Users Collection (real Firestore data) ──────────
  // Maps to AlumniModel for display across Feed, Directory, Explore, Profile.

  static Stream<List<AlumniModel>> getAlumniStream() {
    return _firestore
        .collection('users')
        .orderBy('Member_Name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlumniModel.fromFirestore(doc))
            .toList());
  }

  static Future<List<AlumniModel>> getAlumniList() async {
    final snapshot =
        await _firestore.collection('users').orderBy('Member_Name').get();
    return snapshot.docs
        .map((doc) => AlumniModel.fromFirestore(doc))
        .toList();
  }

  static Future<AlumniModel?> getAlumniById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return AlumniModel.fromFirestore(doc);
    }
    return null;
  }

  /// Update existing user profile in Firestore (users collection). [data] must use Firestore field names (e.g. Member_Name, Year, Branch_Name, Company_Name, Position).
  static Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  static Future<List<AlumniModel>> searchAlumni(String query) async {
    final snapshot =
        await _firestore.collection('users').orderBy('Member_Name').get();
    final alumni = snapshot.docs
        .map((doc) => AlumniModel.fromFirestore(doc))
        .toList();
    final lowerQuery = query.toLowerCase();
    return alumni.where((a) {
      return a.name.toLowerCase().contains(lowerQuery) ||
          (a.branchName?.toLowerCase().contains(lowerQuery) ?? false) ||
          (a.year?.contains(lowerQuery) ?? false) ||
          (a.companyName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  static Future<List<AlumniModel>> getAlumniByDepartment(
      String department) async {
    final snapshot = await _firestore
        .collection('users')
        .where('Branch_Name', isEqualTo: department)
        .orderBy('Member_Name')
        .get();
    return snapshot.docs
        .map((doc) => AlumniModel.fromFirestore(doc))
        .toList();
  }

  static Future<List<AlumniModel>> getAlumniByYear(String year) async {
    final snapshot = await _firestore
        .collection('users')
        .where('Year', isEqualTo: year)
        .orderBy('Member_Name')
        .get();
    return snapshot.docs
        .map((doc) => AlumniModel.fromFirestore(doc))
        .toList();
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
    final usersCount =
        await _firestore.collection('users').count().get();
    final postsCount =
        await _firestore.collection('posts').count().get();
    return {
      'alumni': usersCount.count ?? 0,
      'posts': postsCount.count ?? 0,
    };
  }

  // ─── Departments (Branch_Name from users) ────────────

  static Future<List<String>> getDepartments() async {
    final snapshot = await _firestore.collection('users').get();
    final departments = snapshot.docs
        .map((doc) => doc.data()['Branch_Name'] as String?)
        .where((d) => d != null && d.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    departments.sort();
    return departments;
  }
}
