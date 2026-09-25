# Getting Started

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>= 3.2.0`
- [Dart SDK](https://dart.dev/get-started) `>= 3.2.0 < 4.0.0`
- Android Studio / VS Code with the Flutter extension
- Android device or emulator for mobile testing
- Windows C++ Build Tools for desktop builds

> Verified on Flutter 3.47.2 (Dart 3.13.2).

## Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/Eliasilyz/Money-Manager.git
   cd "Money Manager"
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate code** (Drift database classes + localizations)

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

   This produces `lib/database/database.g.dart`, the DAO `.g.dart` files, and the generated `lib/l10n/app_localizations*.dart` files. Generated files are committed, so this step is only needed after schema or `.arb` changes.

4. **Run the app**

   ```bash
   flutter run
   ```

## Google Drive backup (optional)

Drive integration needs OAuth credentials. Two things to know:

- `android/app/google-services.json` must contain a valid OAuth 2.0 client configuration for your Google Cloud project (currently it holds a desktop-style `installed` client entry — see [Known Issues](Known-Issues)).
- The Google Services Gradle plugin is **not** applied in `android/app/build.gradle.kts`; `google_sign_in` obtains tokens through the plugin-free flow, so no `default_web_client_id` resource is generated. Test Drive features end-to-end on a real device before releasing.

Without this, everything except cloud backup works normally.

## Building for release

```bash
# Android APK (per-ABI splits enabled)
flutter build apk --release

# Windows
flutter build windows --release
```

> The Android release build currently signs with the **debug** key (`android/app/build.gradle.kts`). Add a real `signingConfig` before publishing to an app store.

## Project commands cheat sheet

| Task | Command |
|---|---|
| Install deps | `flutter pub get` |
| Codegen (Drift + l10n) | `dart run build_runner build --delete-conflicting-outputs` |
| Regenerate localizations only | `flutter gen-l10n` |
| Static analysis | `flutter analyze` |
| All tests | `flutter test` |
| Unit tests only | `flutter test test/unit` |
| Screen matrix | `flutter test test/ui/screen_matrix_test.dart --timeout 60s` |
| Run on device | `flutter run` |
