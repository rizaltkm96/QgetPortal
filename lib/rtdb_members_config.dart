/// Realtime Database path for the alumni roster (members).
///
/// Member reads/writes go under this root (see `FirebaseService`).
/// [kFirebaseRealtimeDatabaseUrl] is the RTDB instance URL from the Firebase Console.
const String kRtdbMembersRoot = 'QGETmembersData';

/// Default Realtime Database URL for project [databaseqget].
/// Matches `databaseURL` in `firebase_options.dart`.
const String kFirebaseRealtimeDatabaseUrl =
    'https://databaseqget-default-rtdb.firebaseio.com';
