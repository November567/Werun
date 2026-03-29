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
- `map/` — Interactive map using `flutter_map` with location search
- `profile/` — User profile, weekly stats chart, activity history
- `models/post.dart` — Core `Post` model with Firestore serialization
- `services/post_service.dart` — Firestore CRUD for posts (create, stream, like, save)

`lib/components/` holds shared UI (bottom nav bar). `lib/core/`, `lib/routes/`, and `lib/shared/` are currently empty placeholders.

### State Management

No state management framework is used. Screens use `StatefulWidget`/`setState` for local state and `StreamBuilder` for reactive Firestore data. Services are instantiated per-screen (no global state container).

### Backend

Firebase stack: Auth, Firestore (posts/users), Storage (images), Messaging (push notifications). Firebase config is auto-generated in `lib/firebase_options.dart`. The `.env` file holds `API_URL` loaded via `flutter_dotenv`.

### UI Conventions

- Dark theme: black background (`#000000`) with green accents (`Colors.green` / `#00FF00`)
- Material Design components throughout
- Modal bottom sheets for image picking
- Firestore security rules are in `firestore.rules`
