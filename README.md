# Qget Alumni Portal 🎓

A premium college alumni portal built with **Flutter** and **Firebase**, featuring an Instagram-inspired UI design with a stunning **burgundy** color theme.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- **Instagram-inspired UI** — Story circles, post feed, explore grid, profile pages
- **Burgundy Dark Theme** — Premium dark mode with carefully curated burgundy color palette
- **Alumni Directory** — Search, filter, sort alumni by name/year/department
- **Alumni Profiles** — Detailed profiles with photo, bio, skills, social links
- **Post Feed** — Instagram-style posts with double-tap heart animation
- **Explore Grid** — Photo grid with department filter chips
- **Firebase Backend** — Real-time data with Firestore streams
- **Smooth Animations** — Splash screen, list animations, page transitions
- **Shimmer Loading** — Beautiful loading states
- **Responsive Design** — Works on Android, iOS, and Web

## 📱 Screens

| Screen | Description |
|--------|-------------|
| **Splash** | Animated logo with burgundy gradient |
| **Feed** | Instagram-style post feed with stories |
| **Explore** | Grid view with search & filter |
| **Directory** | Alumni list/grid toggle with sorting |
| **Profile** | Detailed alumni profile view |
| **My Profile** | User account & settings |

## 🚀 Getting Started

### Prerequisites

- Flutter 3.x or later
- Firebase account & project
- Dart SDK

### 1. Clone & Install Dependencies

```bash
cd Qget_portal
flutter pub get
```

### 2. Configure Firebase

#### Option A: Using FlutterFire CLI (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

#### Option B: Manual Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project
3. Add Android/iOS/Web apps
4. Download config files:
   - **Android**: `google-services.json` → `android/app/`
   - **iOS**: `GoogleService-Info.plist` → `ios/Runner/`
5. Update `lib/firebase_options.dart` with your project values

### 3. Setup Firestore

Create a Firebase Firestore database with these collections:

#### `alumni` collection
```json
{
  "name": "string",
  "email": "string",
  "photoUrl": "string (URL)",
  "bio": "string",
  "graduationYear": "string (e.g. '2020')",
  "department": "string",
  "degree": "string",
  "currentCompany": "string",
  "currentPosition": "string",
  "location": "string",
  "phone": "string",
  "linkedIn": "string",
  "instagram": "string",
  "github": "string",
  "skills": ["string"],
  "isVerified": "boolean",
  "createdAt": "timestamp",
  "lastActive": "timestamp"
}
```

#### `posts` collection
```json
{
  "authorUid": "string",
  "authorName": "string",
  "authorPhotoUrl": "string",
  "content": "string",
  "imageUrl": "string",
  "likes": ["string (userId)"],
  "commentCount": "number",
  "createdAt": "timestamp",
  "authorDepartment": "string",
  "authorGraduationYear": "string"
}
```

### 4. Seed Sample Data (Optional)

After Firebase is configured, seed sample data by calling:

```dart
import 'package:qget_portal/services/seed_data.dart';

// Call this once (e.g., from a button or initState)
await SeedData.seedAll();
```

### 5. Run the App

```bash
# Android/iOS
flutter run

# Web
flutter run -d chrome

# Web (specific port)
flutter run -d chrome --web-port=8080
```

## 🏗 Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── theme/
│   └── app_theme.dart           # Burgundy dark theme & colors
├── models/
│   ├── alumni_model.dart        # Alumni data model
│   └── post_model.dart          # Post data model
├── services/
│   ├── firebase_service.dart    # Firebase CRUD operations
│   └── seed_data.dart           # Sample data seeder
├── screens/
│   ├── splash_screen.dart       # Animated splash
│   ├── home_screen.dart         # Bottom nav + PageView
│   ├── feed_tab.dart            # Instagram-style feed
│   ├── explore_tab.dart         # Grid explore view
│   ├── alumni_directory_tab.dart # Searchable directory
│   ├── alumni_profile_screen.dart # Detailed profile
│   └── profile_tab.dart         # User profile & settings
└── widgets/
    ├── story_circle.dart        # Story ring widget
    ├── post_card.dart           # Post card with animations
    ├── alumni_card.dart         # Alumni list card
    └── shimmer_loading.dart     # Loading skeletons
```

## 🎨 Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Burgundy | `#800020` | Primary |
| Burgundy Dark | `#5C0015` | Gradient start |
| Burgundy Light | `#A3294A` | Secondary |
| Burgundy Accent | `#D4466B` | Highlights |
| Gold | `#D4A574` | Accent |
| Scaffold | `#0A0A0A` | Background |
| Card | `#1A1A1A` | Card surface |

## 📦 Dependencies

- `firebase_core` — Firebase initialization
- `firebase_auth` — Authentication
- `cloud_firestore` — Firestore database
- `firebase_storage` — File storage
- `cached_network_image` — Image caching
- `google_fonts` — Typography (Inter, Outfit)
- `shimmer` — Loading animations
- `flutter_staggered_grid_view` — Grid layouts

## 📄 License

This project is licensed under the MIT License.
