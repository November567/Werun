# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web

# Code quality
flutter analyze
dart format lib/

# Tests
flutter test
flutter test test/widget_test.dart   # Run single test file
```

## Architecture

**WeRun** is a social running activity sharing app built with Flutter and Firebase.

### Feature Structure

Code is organized under `lib/features/` by feature:

- `auth/` — Login/register screens, `AuthService` wrapping FirebaseAuth
- `view/` — Home feed, post creation, post detail; uses StreamBuilder for Firestore reactivity
- `map/` — Google Maps view with animated fake runners, custom avatar markers, runner profile sheet
- `run/` — GPS run tracking screen, simulation mode, post-run share sheet
- `profile/` — User profile, weekly stats chart, activity history
- `models/post.dart` — Core `Post` model; use `Post.fromFirestore(doc)` (sets `id` from `doc.id`); **never** use `Post.fromJson`/`fromMap` for Firestore documents as those lose the document ID
- `services/post_service.dart` — All Firestore writes for posts: `createPost`, `toggleLike`, `addComment`, `savePost`, `getUserData`

### Shared Code

`lib/core/constants/`:
- `app_colors.dart` — All color constants (`AppColors.accent`, `AppColors.surfaceBg`, etc.). Do not hardcode colors.
- `fake_route.dart` — `kFakeRoute`: the shared 29-point Bangkok loop used by both `RunTrackingService` (simulation) and `MapView` (fake runner animation).

`lib/shared/widgets/`:
- `run_stat_chip.dart` — `RunStatChip(label, value)`: lime-colored stat display. Replaces the private `_StatChip`/`_StatBox`/`_StatItem` pattern — do not create new private versions.
- `bottom_sheet_container.dart` — `BottomSheetContainer`: dark bottom sheet wrapper with handle bar. Use this for all modal bottom sheets.

`lib/shared/utils/`:
- `run_formatters.dart` — `formatDuration(Duration)` and `formatPace(double?)` for run display strings.

### State Management

No state management framework. Screens use `StatefulWidget`/`setState` for local state and `StreamBuilder` for reactive Firestore data. Services are instantiated per-screen.

### Backend

Firebase stack: Auth, Firestore (posts/users), Storage (run_maps/ images), Messaging. Firebase config is auto-generated in `lib/firebase_options.dart`. `.env` holds `GOOGLE_API_KEY` loaded via `flutter_dotenv`. The Google Maps Android key is also stored in `android/local.properties` as `GOOGLE_MAPS_API_KEY` and injected via `build.gradle.kts` manifestPlaceholders.

### Map / Run Features

- `MapView` shows 4 animated fake runners (Alex/Sam/Mia/Tom) moving along `kFakeRoute` every 1.5 s using `Timer.periodic`. Tapping a runner opens `RunnerProfileSheet`.
- `RunTrackingService` handles real GPS via `geolocator` and simulation via `kFakeRoute`. The `stop()` method sets `_isSimulating = false` **before** any `await` — preserve this ordering.
- After stopping a run, `RunTrackingScreen` captures a map snapshot and uploads it to Firebase Storage in the background while `PostRunSheet` is already open.

### UI Conventions

- Dark theme: `AppColors.scaffoldBg` (`#0E0E0E`) / `AppColors.surfaceBg` (`#1A1A1A`) backgrounds with `AppColors.accent` (`Colors.lime`) highlights.
- Firestore security rules: `firestore.rules` and `storage.rules`.
