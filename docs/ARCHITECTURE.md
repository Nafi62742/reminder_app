# Architecture

`reminder_app` is an **offline-only** reminder app. There is no backend, no
Firebase, no accounts, and no network calls anywhere in `lib/`. Every piece of
data (the user's name/profile, every reminder, the daily schedule and its
completion history) lives on-device in `shared_preferences`. The app opens
straight to a name-capture screen on first launch and straight to the main
4-tab shell on every launch after that.

State management, dependency injection, and routing all go through
[GetX](https://pub.dev/packages/get) (`package:get`).

## Layers

```
lib/
├── main.dart                 # bootstraps services, picks the initial route
├── app/
│   ├── routes/                # route names + GetPage table
│   └── theme/                 # blue Material 3 theme (light + dark)
├── core/
│   ├── constants/              # SharedPreferences key names, app name
│   ├── services/                # StorageService, NotificationService
│   └── utils/                   # date/time + schedule-time formatting
├── data/
│   ├── models/                  # ReminderModel, ScheduleItemModel
│   └── repositories/             # ReminderRepository, ScheduleRepository
├── modules/
│   ├── onboarding/                 # first-run name capture
│   ├── shell/                      # bottom-nav shell hosting the 4 tabs
│   ├── reminders/                  # tab 1 — list, add/edit form, history
│   ├── schedule/                    # tab 2 (checklist) + tab 3 (customize)
│   └── profile/                      # tab 4 — stats + profile fields
└── widgets/                            # shared widgets (ReminderTile)
```

### `app/` — wiring

- `routes/app_routes.dart` — route name constants: `onboarding`, `main`
  (the shell), `addReminder`, `editReminder`, `reminderHistory`.
- `routes/app_pages.dart` — the `GetPage` list. Every route pairs a view with
  a `Bindings` subclass. Only five routes exist — the four tabs are **not**
  separate routes; they're all mounted inside the one `main` route's shell
  (see below).
- `theme/app_theme.dart` — a single `Color(0xFF1565C0)` seed color feeds
  `ColorScheme.fromSeed` for both light and dark `ThemeData`.

### `core/` — cross-cutting services

- `services/storage_service.dart` — the **only** place that touches
  `SharedPreferences`. Everything else in the app reads/writes local data
  through this service. It exposes:
  - `userName` / `userEmail` / `userWeightKg` / `userHeightCm` — profile
    fields (only `userName` is required; the rest are nullable/optional).
  - `getReminders` / `saveReminders` + `nextReminderId` — the reminder list,
    serialized as one JSON array under a single key, plus an
    auto-incrementing id counter (a reminder's id doubles as its
    notification id, since `flutter_local_notifications` requires ints).
  - `getScheduleItems` / `saveScheduleItems` + `nextScheduleItemId` — the
    daily-schedule item *definitions* (same one-JSON-array-per-key shape).
  - `getCompletions(dateKey)` / `saveCompletions(dateKey, ids)` — which
    schedule items were checked off on a given calendar day. All days are
    stored in one JSON map (`{"2026-07-20": [1,3,4], ...}`) under a single
    key; `dateKey` comes from `DateTimeFormatter.dateKey`.
- `services/notification_service.dart` — wraps `flutter_local_notifications`
  + `timezone`. Schedules/cancels one local notification per reminder.
  - There is no native timezone-detection plugin in this project. The local
    zone is approximated from `DateTime.now().timeZoneOffset` via
    `Etc/GMT±N` (whole-hour precision only) — a deliberate tradeoff to avoid
    an extra dependency for a personal offline app.
  - `permission_handler` is used for Android's notification + exact-alarm
    runtime permissions; the plugin's own Darwin permission API is used for
    iOS/macOS.
- `constants/app_constants.dart` — `StorageKeys` (the SharedPreferences key
  names) and `AppConstants.appName`.
- `utils/date_time_formatter.dart` — reminder display formatting, plus
  `dateKey`/`startOfDay` helpers shared by reminders and the schedule.
- `utils/schedule_time_formatter.dart` — converts between `TimeOfDay` and
  the minutes-since-midnight int a `ScheduleItemModel` persists.

Both `StorageService` and `NotificationService` are registered as permanent
singletons in `main()` via `Get.putAsync(...)` **before** `runApp` — every
module reaches them with `Get.find<StorageService>()` /
`Get.find<NotificationService>()`.

### `data/` — models + repositories

- `models/reminder_model.dart` — `ReminderModel { id, title, description?,
  dateTime, isCompleted }`. `copyWith` takes a `clearDescription` flag —
  passing `description: null` alone would *not* clear an existing value
  (`description ?? this.description` falls back to the old one), so
  explicitly clearing it needs the flag. `ScheduleItemModel.copyWith` follows
  the same `clearTime` pattern for the same reason.
- `models/schedule_item_model.dart` — `ScheduleItemModel { id, title,
  timeMinutes?, order }`. `timeMinutes` is optional and purely informational
  once an item exists; `order` is what actually drives display order.
- `repositories/reminder_repository.dart` — `getAll/create/update/delete`.
  Every write reads the full list, mutates it, and re-serializes the whole
  thing back through `StorageService.saveReminders`. Fine at personal-app
  scale; not designed for large reminder counts.
- `repositories/schedule_repository.dart` — item CRUD plus `reorder` (for
  drag-to-reorder in the Customize tab) and the completion-tracking methods
  (`completionsFor`, `toggleCompletion`, `completedCountFor`,
  `completedCountBetween`) used by both the Schedule tab and the Profile
  tab's stats.
  - **New items and time**: an item's `timeMinutes` is only used once, at
    creation, to pick a sensible initial position among existing items
    (inserted before the first item with a later or no time). After that,
    position is governed entirely by the persisted `order` field — dragging
    to reorder in the Customize tab is independent of an item's time from
    then on. `order` is always re-sequenced to match list position after
    any add/delete/reorder (`_reindexed`).

### `modules/` — features

- **`onboarding/`** — `OnboardingController` validates a non-empty name,
  saves it via `StorageService`, and navigates with
  `Get.offAllNamed(AppRoutes.main)`. `main.dart` decides whether to route
  here at all by checking `StorageService.userName == null` at startup —
  onboarding never re-appears once a name is saved.
- **`shell/`** — `MainShellView` is the single `main` route: a `Scaffold`
  with an `IndexedStack` body (all four tabs mounted at once, so switching
  tabs never re-runs `onInit`) and a Material 3 `NavigationBar`.
  `MainShellBinding` is the one binding that registers *every* tab's
  controller/repository up front with `Get.put` (not `Get.lazyPut` — lazy
  registration only works for routes that mount once when pushed; here all
  four tabs need to already exist when the shell builds). Because of this,
  `MainShellController.changeTab` also explicitly reloads whichever tab's
  data another tab could have just changed (e.g. switching to Schedule
  reloads it in case Customize just edited an item; switching to Profile
  recomputes its stats).
- **`reminders/`** — tab 1.
  - `RemindersController` shows only **today-and-future** reminders (past
    ones move to history). Every time it loads it also reschedules
    notifications for every pending (incomplete, future) reminder — this
    re-sync is how the app recovers scheduled alerts after a device reboot
    or reinstall, since there's no native boot-receiver wiring.
  - `ReminderFormController` is shared by both the add and edit routes; it
    checks `Get.arguments` for an existing `ReminderModel` to decide which
    mode it's in.
  - `ReminderHistoryController`/`ReminderHistoryView` (pushed route, not a
    tab) show **every** past reminder — completed or not — most recent
    first, reached via the history icon in the Reminders tab's app bar.
- **`schedule/`** — tabs 2 and 3, both reading/writing the same
  `ScheduleRepository`.
  - `ScheduleController` (tab 2, `ScheduleView`) shows today's checklist:
    the item definitions plus which ones are checked off *for today*.
  - `CustomizeScheduleController` (tab 3, `CustomizeScheduleView`) manages
    the item definitions themselves — add/edit (via an `AlertDialog`),
    delete, and drag-to-reorder (`ReorderableListView`).
- **`profile/`** — tab 4. `ProfileController` combines two unrelated
  concerns in one screen because the product spec put them on the same tab:
  completion stats (today/this-week/this-month counts, sourced from
  `ScheduleRepository` — reminders are *not* included in these stats) and
  the editable profile fields (name, email, weight, height) plus the app
  version (`package_info_plus`).

### `widgets/`

Shared, stateless presentation widgets used by more than one module (e.g.
`ReminderTile`, the swipe-to-delete list row used in both the reminders list
and its history screen).

## Data flow at a glance

```
main()
  → Get.putAsync(StorageService)       (SharedPreferences ready)
  → Get.putAsync(NotificationService)  (timezone + plugin ready)
  → initialRoute = userName == null ? onboarding : main
  → runApp(GetMaterialApp(...))

Onboarding → save name → offAllNamed(main)

MainShellView (route `main`)
  ├─ tab 0 Reminders  (today + future only)
  │    ├─ tap +             → push addReminder    → ReminderFormController.save() → back
  │    ├─ tap a reminder     → push editReminder    (arguments: ReminderModel) → save() → back
  │    ├─ toggle checkbox    → toggleComplete → repository.update + notification cancel/reschedule
  │    ├─ swipe/delete        → deleteReminder → repository.delete + notification cancel
  │    └─ tap history icon     → push reminderHistory (all past reminders, completed or not)
  ├─ tab 1 Schedule    — today's checklist; checking an item toggles today's completion
  ├─ tab 2 Customize   — add/edit/delete/reorder the schedule item definitions
  └─ tab 3 Profile     — stats (from ScheduleRepository) + name/email/weight/height form
```

## Platform notes

- `permission_handler` officially supports Android, iOS, web, and Windows —
  **not** macOS or Linux. Running the app on the macOS/Linux desktop target
  (useful for quick local UI checks) will throw `MissingPluginException`
  specifically from the permission-request call; this doesn't affect the
  real Android/iOS targets.
- `flutter_local_notifications`'s `InitializationSettings` needs `android`,
  `iOS`, and `macOS` settings all populated if the desktop target is ever
  exercised, or `initialize()` throws at runtime.
