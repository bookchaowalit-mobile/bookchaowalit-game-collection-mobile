# Game Collection — Mobile

Track the games you own, what you are playing and what you have finished.

Part of [Chaowalit Greepoke](https://bookchaowalit.com)'s 101 Portfolio Projects.

## Features

- Add games with platform, status (backlog/playing/completed) and rating
- Filter by status and search by title
- Collection stats: totals per status and average rating

Data lives in memory for the current session only; there is no account,
backend, analytics or network access.

## Tech Stack

- **Framework:** Flutter (CI pinned to 3.47.5) + Material 3
- **Language:** Dart
- **State:** `StatefulWidget` / `setState`; the core logic is pure Dart in
  `lib/logic/` and unit-tested without widgets

## Develop and verify

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter run
```

CI (`.github/workflows/build.yml`) runs the same format/analyze/test checks
and fails closed; a debug APK is built on pushes to `main`.

## Build

```bash
# Android
flutter build apk --debug
```

Release signing is not configured yet (see `docs/UPGRADE-PLAN.md`).

## Related

- **Frontend:** [bookchaowalit-website/game-collection-frontend](https://github.com/bookchaowalit-website/game-collection-frontend)
- **Portfolio:** [bookchaowalit.com](https://bookchaowalit.com)

## License

MIT
