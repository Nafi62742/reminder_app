# Deployment

`reminder_app` is a fully offline app — there's no backend or environment
config to provision. Deployment is just building and distributing the
Android/iOS binaries below.

## Prerequisites

- Flutter SDK matching the `environment.sdk` constraint in `pubspec.yaml`
  (`^3.5.2`).
- Android: Android Studio / command-line SDK tools, a configured
  `android/local.properties`.
- iOS: Xcode + CocoaPods, on macOS, with a valid Apple signing
  identity/provisioning profile for anything beyond a simulator build.

Before any build:

```bash
flutter pub get
flutter analyze   # optional but recommended — should report no issues
flutter test
```

## Android — APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

**Current signing state**: `android/app/build.gradle.kts` signs the
`release` build type with the **debug** signing config —
see the `TODO` comments there. That's fine for sideloading the APK onto
your own device, but **it is not suitable for the Play Store** or for
distributing a build you expect to update later (Android requires the same
signing key across updates).

To set up real release signing:

1. Generate a keystore:
   ```bash
   keytool -genkey -v -keystore ~/reminder-app-release.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias reminder_app
   ```
2. Create `android/key.properties` (do **not** commit this file):
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=reminder_app
   storeFile=/absolute/path/to/reminder-app-release.jks
   ```
3. Wire it into `android/app/build.gradle.kts` — load `key.properties`, add a
   `signingConfigs.create("release")` block reading those four values, and
   point `buildTypes.release.signingConfig` at it instead of
   `signingConfigs.getByName("debug")`.

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`. Requires the
same real signing config as above.

### Versioning

`pubspec.yaml`'s `version:` field (`0.1.0+1`) maps to Android's
`versionName+versionCode` and iOS's `CFBundleShortVersionString` /
`CFBundleVersion` automatically. Bump it before each release build, or pass
`--build-name`/`--build-number` to override without editing the file:

```bash
flutter build apk --release --build-name=0.2.0 --build-number=2
```

## iOS — IPA

```bash
flutter build ios --release          # unsigned build, or
open ios/Runner.xcworkspace           # then Product > Archive in Xcode
```

`flutter build ipa --release` produces a distributable `.ipa` once a signing
team/provisioning profile is configured in Xcode
(`ios/Runner.xcodeproj` → Signing & Capabilities). There is no CI/fastlane
config in this repo yet — distribution today is manual via Xcode Archive →
Distribute App (TestFlight or ad-hoc).

## Local notifications on release builds

Both platforms need the reminder feature's runtime permissions granted by
the user at first launch (handled by `NotificationService.requestPermissions()`
in `lib/core/services/notification_service.dart`):

- **Android**: `POST_NOTIFICATIONS` and `SCHEDULE_EXACT_ALARM`
  (declared in `android/app/src/main/AndroidManifest.xml`).
- **iOS**: alert/badge/sound permission, requested via the plugin's Darwin
  API.

No extra release-build configuration is needed for these beyond what's
already in the manifest — just confirm the permission prompt isn't denied
during manual testing before shipping a release build.
