# Firebase setup commands

Run these in order from your project root (`Qget_portal`).

## 1. Install FlutterFire CLI

```powershell
dart pub global activate flutterfire_cli
```

**Optional (if `flutterfire` is not found):** Add Pub’s bin folder to your PATH:

- Path: `%LOCALAPPDATA%\Pub\Cache\bin`
- Or: `C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin`

## 2. Log in to Firebase (if needed)

```powershell
firebase login
```

If the Firebase CLI is not installed:

```powershell
npm install -g firebase-tools
firebase login
```

## 3. Configure Firebase for this project

From the project folder:

```powershell
cd E:\AI_projects\Qget_portal
flutterfire configure
```

If `flutterfire` is not in PATH, use:

```powershell
dart pub global run flutterfire_cli:flutterfire configure
```

This will:

- Let you pick or create a Firebase project
- Create/update `lib/firebase_options.dart`
- Add Android: `android/app/google-services.json`
- Add iOS: `ios/Runner/GoogleService-Info.plist`
- Add Web config in `lib/firebase_options.dart`

## 4. Get Flutter dependencies

```powershell
flutter pub get
```

## 5. Fix "permission-denied" (Firestore rules)

If you see **`cloud_firestore/permission-denied`** or "Missing or insufficient permissions":

1. Open [Firebase Console](https://console.firebase.google.com) → your project.
2. Go to **Build** → **Firestore Database** → **Rules**.
3. Replace the rules with the following (allows read on `users` and `posts`):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if true;
      allow write: if false;
    }
    match /posts/{postId} {
      allow read: if true;
      allow create, update, delete: if true;
    }
  }
}
```

4. Click **Publish**. Reload your app; the permission error should be gone.

- For production, restrict `read` (e.g. `if request.auth != null`) and limit who can write.
- The project root also has `firestore.rules`; you can deploy it with `firebase deploy --only firestore:rules` if you use Firebase CLI in this project.

### Storage (alumni images)

The app uses **qget-db** for Firestore; image URLs in your data often point to **databaseqget**’s bucket. Deploy Storage rules to the project that owns the bucket (usually databaseqget):

```powershell
firebase deploy --only storage --project databaseqget
```

Rules are in `storage.rules` (allow read for all paths in the bucket).

**Check that rules are active**

1. Open [Firebase Console](https://console.firebase.google.com) → project **databaseqget** (or the project that owns your image bucket).
2. Go to **Build** → **Storage** → **Rules**.
3. You should see the deployed rules (e.g. `allow read: if true` for `/{allPaths=**}`).
4. In **Storage** → **Files**, open a file under `Images/` and check its URL: the host should match the bucket (e.g. `databaseqget.appspot.com` or `databaseqget.firebasestorage.app`). Your Firestore `ImgURL` values must use that same bucket.

**If you see "blocked by CORS policy" on web** (e.g. from `http://localhost:49875`): the Storage bucket must have CORS configured. The config file is in the repo; you must apply it **once** with Google Cloud:

1. **Install Google Cloud SDK** (includes `gsutil`): https://cloud.google.com/sdk/docs/install  
   Or with Chocolatey: `choco install gcloudsdk`

2. **Open PowerShell**, go to the project folder (where `storage.cors.json` is), then run:
   ```powershell
   gcloud auth login
   gcloud config set project databaseqget
   gsutil cors set storage.cors.json gs://databaseqget.appspot.com
   ```
   You should see: `Setting CORS on gs://databaseqget.appspot.com/...`

3. **Hard-refresh the app** (Ctrl+Shift+R) or restart `flutter run -d chrome`.  
   CORS can be cached; if it still fails, wait a minute and try again.

**If `gsutil` is not found:** install the full [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) and restart the terminal.  
**If you get permission errors:** use an account that has Storage Admin (or Owner) on the **databaseqget** project.

The repo’s `storage.cors.json` allows GET from any origin and from `localhost` so Flutter web (e.g. `http://localhost:53851`) can load images. For production, restrict `"origin"` to your real app URL.

## 6. Enable Email/Password sign-in (required for app login)

1. Open [Firebase Console](https://console.firebase.google.com) and select the **qget-db** project (the one used by the app).
2. Go to **Build** → **Authentication** → **Sign-in method**.
3. Click **Email/Password**, turn **Enable** on, then **Save**.

Without this, sign-in and sign-up in the app will fail. Google sign-in can be added later from the same Sign-in method page.

**Sign-up is restricted to existing alumni:** the app only allows creating an account if the email exists in the Firestore `users` collection (field `Email`). Ensure each alumni who should be able to sign in has a `users` document with their login email in the `Email` field (use lowercase for reliable matching).

## 7. (Optional) Create Firestore and Auth in Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com) and select your project.
2. **Firestore:** Build → Firestore Database → Create database (start in test mode for dev).
3. **Authentication:** Build → Authentication → Get started (and enable Email/Password as in section 6).

---

**Quick copy-paste (PowerShell, from project root):**

```powershell
dart pub global activate flutterfire_cli
cd E:\AI_projects\Qget_portal
dart pub global run flutterfire_cli:flutterfire configure
flutter pub get
```

After this, your app will be connected to your Firebase project.
