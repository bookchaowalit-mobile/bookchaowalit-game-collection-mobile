# Upgrade Plan — Game Collection Mobile

## Current state

Score: 7/10 — collection tracker with tested pure-Dart logic, games persist on device behind a tested repository, honest CI and fail-closed release signing; still no app icon or E2E flow.

## Backlog

### P0
- None open. (Release signing now fails closed without `android/key.properties`.)

### P1
- Edit a game's title/platform and add optional notes or play time.
- Export/import the collection as JSON.
- Replace the template launcher icon with a real app icon (the application ID `com.bookchaowalit.*` is already set).
- Add a Maestro smoke flow for the main journey.
- Add a CI job that builds a signed release bundle from repository secrets (keystore decoded at runtime, never committed).

### P2
- Tablet layout (NavigationRail) and 130% text-scale widget test.
- Localisation (Thai/English) for UI strings.

## Done in this pass (pass 2)

- Release builds no longer sign with the debug key: `android/app/build.gradle.kts` reads the ignored `android/key.properties` and a Gradle guard fails any release assemble/bundle without it (pattern from `bookchaowalit-goal-tracker-mobile`). Root `.gitignore` also ignores `key.properties`, `*.jks`, `*.keystore`; README documents the setup. Not build-verified here (no Android SDK/Gradle in this environment).
- Games now persist on device: `lib/data/list_repository.dart` (`ListRepository` interface, `shared_preferences` JSON store that skips malformed records such as unknown status or out-of-range rating, in-memory store for tests); the home screen loads on start, saves after add/status/rating/delete and shows an error line when storage fails.
- Added repository tests (round trip, empty, malformed records, non-list payload) and widget tests for restore/save and load failure.

## Done in pass 1

- Replaced the Expo/npm CI (which could never fail) with fail-closed Flutter CI: `dart format` check, `flutter analyze`, `flutter test`, debug APK on `main`.
- Implemented the core feature (track the games you own, what you are playing and what you have finished) with pure-Dart logic in `lib/logic/`.
- Replaced placeholder Explore/Profile tabs with an About screen describing features and privacy.
- Added unit tests for the logic and widget tests for the main journey.
- Removed unused `go_router` / `flutter_riverpod` dependencies; README now matches the code.
