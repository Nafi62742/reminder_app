# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                 # install dependencies
flutter analyze                 # static analysis / lint (flutter_lints rules, see analysis_options.yaml)
flutter test                    # run all tests
flutter test test/widget_test.dart --plain-name "saves the entered name locally"  # run a single test
flutter run -d <device-id>      # run on a device/simulator (flutter devices to list)
flutter build apk               # debug APK
flutter build apk --release     # release APK (lib/app/build/outputs/flutter-apk/)
```

See `docs/ARCHITECTURE.md` for the app's layer structure and `docs/DEPLOYMENT.md` for build/release details.

## Architecture

This is an **offline-only** app — there is no backend, no Firebase, no network calls anywhere in `lib/`. All persistence is local via `shared_preferences`. Do not reintroduce cloud/auth dependencies (a commented-out Firebase block was deliberately removed from `pubspec.yaml`).

State management, DI, and routing all go through **GetX** (`package:get`), not Provider/Riverpod/Bloc. Most features live under `lib/modules/<feature>/` with the standard `bindings/`, `controllers/`, `views/` split — except `schedule/` and `profile/`, which skip `bindings/` (see below).

The app is a **bottom-nav shell with 4 tabs**, not a stack of independent routes — see `lib/modules/shell/`.

- `lib/app/` — app-wide wiring: `routes/app_routes.dart` (route name constants) + `routes/app_pages.dart` (the `GetPage` list mapping each route to its view and `Binding`), and `theme/app_theme.dart` (blue Material 3 seed theme, light + dark). Only 5 routes exist total (`onboarding`, `main`, `addReminder`, `editReminder`, `reminderHistory`) — the 4 tabs are not routes.
- `lib/core/services/` — `StorageService` is the single source of truth for local persistence (wraps `SharedPreferences`: name/email/weight/height, reminders, schedule items, and per-day completions); `NotificationService` wraps `flutter_local_notifications` + `timezone` for scheduling reminder alerts. Both are registered as permanent singletons in `main()` via `Get.putAsync` *before* `runApp`, so they're available everywhere via `Get.find()`.
- `lib/data/` — `ReminderModel` + `ReminderRepository`, and `ScheduleItemModel` + `ScheduleRepository` (daily-routine item definitions, drag-reorder, and per-day completion tracking). Both models' `copyWith` need an explicit `clear*` flag to null out an optional field — passing `field: null` alone falls back to the *existing* value (`field ?? this.field`), it doesn't clear it.
- `lib/modules/onboarding/` — first-run name capture. `main.dart` checks `StorageService.userName` at startup and only routes here if no name is saved yet; once saved, every later launch goes straight to `AppRoutes.main`.
- `lib/modules/shell/` — `MainShellBinding` is the one binding that matters most: because all 4 tabs live in an `IndexedStack` (mounted simultaneously, not pushed/popped), every tab's controller must be registered eagerly with `Get.put` here — `Get.lazyPut` in a per-tab binding would never fire, since tabs aren't routes. `MainShellController.changeTab` also manually reloads whichever tab's data another tab could have just changed (Schedule tab data, Profile stats).
- `lib/modules/reminders/` — tab 1: list (today+future only — `RemindersController` filters out past dates) + add/edit form + a pushed history route (`AppRoutes.reminderHistory`) showing all past reminders, completed or not. Re-syncs (reschedules) all pending reminders' notifications every time it loads, since there's no native boot-receiver rescheduling.
- `lib/modules/schedule/` — tabs 2 (`ScheduleController`/`ScheduleView`, today's checklist) and 3 (`CustomizeScheduleController`/`CustomizeScheduleView`, add/edit/delete/reorder the item definitions), both reading the same `ScheduleRepository`.
- `lib/modules/profile/` — tab 4: completion stats (today/week/month — sourced from `ScheduleRepository` only, reminders aren't counted) plus editable profile fields, combined in one screen because the product spec puts them on the same tab.
- `lib/widgets/` — shared widgets used across modules (e.g. `ReminderTile`, reused by both the reminders list and its history screen).

### Gotchas

- **Timezone handling**: there's no native timezone-detection plugin. `NotificationService` approximates the device's local zone from `DateTime.now().timeZoneOffset` (whole-hour precision only — half-hour/45-minute offset zones will be slightly off). This is a deliberate tradeoff to avoid adding a dependency, not an oversight.
- **`permission_handler` only supports Android/iOS/web/Windows** — not macOS/Linux. If you run this on the macOS/Linux desktop target for local testing, `NotificationService.requestPermissions()` will throw `MissingPluginException` on that specific call; this is expected and does not affect the real Android/iOS targets.
- **`flutter_local_notifications` requires per-platform init settings** — `InitializationSettings` needs `android`, `iOS`, *and* `macOS` all set if you touch the desktop target, or `initialize()` throws at runtime (not caught by `flutter analyze`).
- **A schedule item's `timeMinutes` only affects its initial position** — after creation, list order is driven entirely by the persisted `order` field (settable via drag-to-reorder in the Customize tab), independent of time.
