import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/models/alumni_model.dart';
import 'package:qget_portal/models/post_model.dart';
import 'package:qget_portal/services/firebase_service.dart';

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateChangesProvider).when(
        data: (u) => u,
        loading: () => null,
        error: (_, __) => null,
      );
});

final currentAlumniProvider = FutureProvider<AlumniModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  final email = user?.email;
  if (email == null) return null;
  return FirebaseService.getCurrentMember(email);
});

final alumniStreamProvider = StreamProvider<List<AlumniModel>>((ref) {
  return FirebaseService.membersStream();
});

final postsStreamProvider = StreamProvider<List<PostModel>>((ref) {
  return FirebaseService.postsStream();
});
