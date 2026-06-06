# Recreate Qget Alumni Portal in another folder (code only — no Firebase project yet)

This file is for when you run the **master prompt** yourself in a **different directory** (new Cursor window / new repo). The result should match **this** app’s structure and behavior while **not** being tied to any real Firebase project. You connect Firebase **later** from the terminal with FlutterFire (see [Connect Firebase (terminal, later)](#connect-firebase-terminal-later)).

**What “no Firebase configuration” means here**

- Keep Firebase packages in `pubspec.yaml` and all Dart code (`FirebaseService`, models, etc.).
- **Do not** ship real API keys, real `projectId`, `google-services.json`, `GoogleService-Info.plist`, or `.firebaserc` pointing at a live project.
- **Do not** apply the Android **`com.google.gms.google-services`** plugin until after `flutterfire configure` (otherwise Gradle requires `google-services.json`).
- Use a **placeholder** `lib/firebase_options.dart` and leave `kFirebaseRealtimeDatabaseUrl` empty unless you already know the URL.
- **Target:** `flutter pub get` and **`flutter analyze`** with zero issues; **`flutter build apk`** (and ideally **`flutter build ios`**) without adding any files from the Firebase Console.

---

## How to use the master prompt (independent directory)

1. Create a **new empty folder** and open it as the workspace (do not mix with this repo if you want a clean tree).
2. Copy everything from **BEGIN MASTER PROMPT** through **END MASTER PROMPT** (below).
3. Paste into your assistant and **append** this single instruction (or equivalent):

   ```text
   Implement in THIS workspace only. Match behavior and file layout to the spec. Deliver NO real Firebase project configuration: no google-services.json, no GoogleService-Info.plist, no real firebase_options values, no .firebaserc with a real project id, and do NOT apply com.google.gms.google-services in Android Gradle (FlutterFire will add it later). Use placeholder firebase_options.dart. Ensure flutter analyze passes. Add a short CONNECT_FIREBASE.md at repo root with terminal commands to run flutterfire configure when ready.
   ```

4. Copy **font files** into `assets/fonts/` as listed in the prompt (or adjust `pubspec.yaml` if you use different assets).
5. When you are ready for a real backend, follow [Connect Firebase (terminal, later)](#connect-firebase-terminal-later).

---

## Connect Firebase (terminal, later)

Run these from **the new project root** after your Firebase project exists and **Android / iOS / Web** apps are registered with the same package/bundle ids as in the prompt.

1. **Install CLIs**

   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   ```

2. **Wire the app to your Firebase project** (replace `YOUR_PROJECT_ID`):

   ```bash
   dart pub global run flutterfire_cli:flutterfire configure -p YOUR_PROJECT_ID -y --platforms=android,ios,web
   ```

   When asked about reusing `firebase.json`, **Yes** is usually fine (local rule paths stay the same).

3. **Confirm**

   - `lib/firebase_options.dart` is regenerated with real values.
   - `android/app/google-services.json` exists.
   - `ios/Runner/GoogleService-Info.plist` exists (if iOS enabled).
   - `android/app/build.gradle.kts` applies `id("com.google.gms.google-services")`.
   - `android/settings.gradle.kts` includes the Google Services plugin line (FlutterFire usually restores both).

4. **Optional:** set `kFirebaseRealtimeDatabaseUrl` in `lib/rtdb_members_config.dart` if Web or your RTDB URL is not picked up automatically.

5. **Deploy rules** (if you use CLI) or paste **`database.rules.json`**, Firestore, and Storage rules in the Firebase Console.

6. **Rebuild**

   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## BEGIN MASTER PROMPT

You are building a Flutter application called **“Qget Alumni Portal”** (internal package name `qget_portal`). Match the architecture, features, and data model described below. Prefer clean separation: `models/`, `services/`, `providers/`, `screens/`, `widgets/`, `theme/`, `utils/`.

### CRITICAL — Deliverable without Firebase project configuration

This milestone must **not** depend on any real Firebase project or Console downloads.

- Provide **`lib/firebase_options.dart`** using **obvious placeholders only** (`REPLACE_ME`, `replace-with-your-project-id`, dummy `appId` strings). Top-of-file comment: *Replace by running `flutterfire configure`.*
- **Do not** add **`android/app/google-services.json`**, **`ios/Runner/GoogleService-Info.plist`**, or **`.firebaserc`** with a real project id. Omit **`.firebaserc`** entirely or use a stub like `{"projects":{"default":"REPLACE_WITH_FLUTTERFIRE"}}`.
- **Android Gradle:** **Do not** apply **`com.google.gms.google-services`** in `android/app/build.gradle.kts`. **Do not** add the `com.google.gms.google-services` plugin line in **`android/settings.gradle.kts`**. (FlutterFire will add these when the developer runs `flutterfire configure`.) Without this plugin, Gradle does **not** require `google-services.json`.
- **`firebase.json`:** May include only **`database`**, **`firestore`**, **`storage`**, **`hosting`** entries pointing at local rule files. **Do not** include a **`flutter`** block with real Firebase app ids (omit it or leave a comment that FlutterFire regenerates it).
- **`flutter analyze`** must report **no issues**.
- Add **`CONNECT_FIREBASE.md`** at the repo root listing: install `firebase-tools`, `firebase login`, `dart pub global activate flutterfire_cli`, and `dart pub global run flutterfire_cli:flutterfire configure -p YOUR_PROJECT_ID ...`.

**Note:** `Firebase.initializeApp` with placeholders may fail at **runtime** until the developer runs FlutterFire; that is acceptable for this phase. Static analysis and Android builds without secrets are the priority.

### Environment and tooling

- **Dart SDK:** `>=3.8.0 <4.0.0`
- **Framework:** Flutter with **Material 3** (or Material with custom theme)
- **State management:** `flutter_riverpod` (^2.6.x)
- **Linting:** `flutter_lints` (^5.x) with `analysis_options.yaml` that `include: package:flutter_lints/flutter.yaml` and sets `analyzer.errors.deprecated_member_use: ignore`

### App identity and platforms

- **App title (MaterialApp):** `Qget Alumni Portal`
- **Android:** `applicationId` and `namespace` = `com.qget.qget_portal`
- **iOS:** `PRODUCT_BUNDLE_IDENTIFIER` = `com.qget.qgetPortal`
- Target **Android, iOS, and Web** where applicable; use `kIsWeb` where file saving or paths differ

### Pub dependencies (match versions closely)

Add to `pubspec.yaml`:

- `cupertino_icons`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_database`, `firebase_storage`, `cached_network_image`, `google_fonts`, `flutter_riverpod`, `flutter_staggered_grid_view`, `shimmer`, `excel`, `file_saver`

**Assets:** register folder `assets/fonts/` (Outfit + Inter `.ttf` files; use **Google Fonts runtime fetching** via `GoogleFonts.config.allowRuntimeFetching = true` in `main.dart`).

### Firebase behavior (implementation requirements)

Centralize access in a **`FirebaseService`** class with static methods:

1. **Realtime Database — alumni “members” roster**  
   - Root path constant, e.g. `users` (in **`rtdb_members_config.dart`**: `kRtdbMembersRoot`, optional `kFirebaseRealtimeDatabaseUrl` — leave URL empty string by default).  
   - **Stream** of all members; **get** list; **get by id**; **get current member** by normalizing auth email and querying RTDB `orderByChild('Email').equalTo(...)`.  
   - **Sign-up gate:** before `createUserWithEmailAndPassword`, require that the email exists as a member in RTDB; if not, throw a distinct error (e.g. `no-alumni-email`).  
   - **CRUD:** update profile map on child path; create member with **push** key; delete member by key; **search** in Dart; **getByDepartment** / **getByYear** via `orderByChild` on `Branch_Name` / `Year`.  
   - **Stats:** alumni count from RTDB children; posts count from Firestore `posts` collection count.

2. **Firestore — social posts**  
   - Collection `posts`, ordered by `createdAt` descending.  
   - **createPost**, **toggleLike** (array of user id strings).

3. **Auth**  
   - Email/password sign-in, sign-up (with allowlist), sign-out, `authStateChanges` stream.

### Data models

**AlumniModel:**

- **uid:** string; fields: `Member_Name`, `Email`, `ImgURL`, `Year`, `Branch_Name`, `Company_Name`, `Position`, `Contact_Number`, `Whatsapp_Number`, `Blood_Group`, `Spouse_Name`, `Spouse_Is_Member`, `Social_Media_Link`, `UID`, `EF_Number`, `Child1_Name` … `Child4_DOB`, `CreatedAt` (`dd-MM-yyyy`)
- Factories: **`fromFirestore`**, **`fromRtdb`**, shared **`fromMemberMap`**
- Helpers: **`createdAtStringNow()`**, **`initials`**, **`displaySubtitle`**, backward-compat getters **`graduationYear`**, **`department`**, **`currentCompany`**, **`currentPosition`**

**PostModel:** `id`, `authorUid`, `authorName`, `authorPhotoUrl`, `content`, `imageUrl`, `likes`, `commentCount`, `createdAt`, `authorDepartment`, `authorGraduationYear` — **`fromFirestore`**, **`toFirestore`**

### Riverpod providers

- `authStateChangesProvider`, `currentUserProvider`, `currentAlumniProvider`, `alumniStreamProvider`, `postsStreamProvider` (as in reference architecture)

### Navigation and screens

- **`main.dart`:** binding init, `GoogleFonts.config.allowRuntimeFetching`, `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`, `ProviderScope`, `MaterialApp` dark theme, `home: SplashScreen`
- **`SplashScreen`**, **`LoginScreen`**, **`HomeScreen`** (PageView: Feed, Explore, Alumni Directory, Profile; FAB → **`CreatePostScreen`** on Feed only)
- **`FeedTab`**, **`ExploreTab`**, **`AlumniDirectoryTab`** (filters + **`AlumniExcelExportService`**, **`alumni_created_at_parse`**), **`ProfileTab`**, **`AlumniProfileScreen`**, **`EditProfileScreen`**, **`AlumniMemberFormScreen`**, **`CreatePostScreen`**

### Widgets and theme

- **`AlumniCard`**, **`MemberAvatar`**, **`PostCard`**, **`StoryCircle`**, **`ShimmerLoading`**, **`AlumniDirectoryFiltersSheet`**
- **`app_theme.dart`:** dark theme, **Outfit** / **Inter** via `GoogleFonts`

### Android Gradle (Kotlin DSL)

- **Java 11**, `namespace` / `applicationId` as above
- **Without** `com.google.gms.google-services` until FlutterFire (see CRITICAL section)

### Root-level Firebase CLI templates

- **`firebase.json`**, **`database.rules.json`**, **`firestore.rules`**, **`storage.rules`** — templates only; no production rules implied

### Quality bar

- **`flutter analyze`**: no issues  
- No production secrets  
- **`rtdb_members_config.dart`** comments explain FlutterFire and optional RTDB URL

### Explicit non-goals

- Full i18n, push notifications, full comment threads on posts

END MASTER PROMPT

---

## Reference file tree (checklist)

```text
lib/
  main.dart
  firebase_options.dart          # placeholders until flutterfire configure
  rtdb_members_config.dart
  models/
    alumni_model.dart
    post_model.dart
  services/
    firebase_service.dart
    alumni_excel_export_service.dart
  providers/
    app_providers.dart
  theme/
    app_theme.dart
  utils/
    alumni_created_at_parse.dart
  screens/
    splash_screen.dart
    login_screen.dart
    home_screen.dart
    feed_tab.dart
    explore_tab.dart
    alumni_directory_tab.dart
    profile_tab.dart
    alumni_profile_screen.dart
    edit_profile_screen.dart
    alumni_member_form_screen.dart
    create_post_screen.dart
  widgets/
    alumni_card.dart
    member_avatar.dart
    post_card.dart
    story_circle.dart
    shimmer_loading.dart
    alumni_directory_filters_sheet.dart
CONNECT_FIREBASE.md              # added by prompt / template
assets/fonts/                    # Outfit + Inter .ttf
```

---

## Optional: duplicate this Git repo instead

If you prefer not to regenerate from the prompt, copy this repository to a new folder, delete `google-services.json` / plist / real `firebase_options`, remove the Google Services Gradle plugin lines, then run **`flutterfire configure`** when ready (same as [Connect Firebase](#connect-firebase-terminal-later)).
