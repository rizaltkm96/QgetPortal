import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alumni_model.dart';
import '../models/post_model.dart';
import '../services/firebase_service.dart';

/// Auth state stream. Use [currentUserProvider] for the latest user.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseService.authStateChanges;
});

/// Current Firebase Auth user (sync read from stream).
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateChangesProvider).valueOrNull;
});

/// Current signed-in user's alumni profile (from Firestore users collection, matched by email).
/// Invalidates when auth changes. Call ref.invalidate(currentAlumniProvider) after profile update.
final currentAlumniProvider = FutureProvider<AlumniModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return FirebaseService.getCurrentAlumni();
});

/// All alumni from Firestore (for feed stories, directory, explore).
final alumniStreamProvider = StreamProvider<List<AlumniModel>>((ref) {
  return FirebaseService.getAlumniStream();
});

/// All posts from Firestore (for feed).
final postsStreamProvider = StreamProvider<List<PostModel>>((ref) {
  return FirebaseService.getPostsStream();
});
