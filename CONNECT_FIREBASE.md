# Connect Firebase (after your project exists)

Run these from the **project root** once the Firebase project is created and Android / iOS / Web apps are registered with the same ids as in this app (`com.qget.qget_portal` / `com.qget.qgetPortal`).

## 1. Install CLIs

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

## 2. Wire the app

Replace `YOUR_PROJECT_ID` with your Firebase project id:

```bash
dart pub global run flutterfire_cli:flutterfire configure -p YOUR_PROJECT_ID -y --platforms=android,ios,web
```

FlutterFire will regenerate `lib/firebase_options.dart`, add `google-services.json` / `GoogleService-Info.plist`, and apply the Google Services Gradle plugin where needed.

## 3. Optional: Realtime Database URL

If Web or a custom RTDB URL is required, set `kFirebaseRealtimeDatabaseUrl` in `lib/rtdb_members_config.dart`.

## 4. Deploy rules (optional)

Use the Firebase Console or CLI to deploy `database.rules.json`, `firestore.rules`, and `storage.rules` after you replace them with real rules.

## 5. Rebuild

```bash
flutter clean
flutter pub get
flutter run
```
