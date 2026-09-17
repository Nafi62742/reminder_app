# Notification System — Local, Offline, and Push

There are **three separate notification mechanisms** in this app, and they're easy to conflate
because two of them share the same underlying plugin. This doc exists to keep them straight:

| Mechanism | Class / file | Channel | Offline at fire time? |
|---|---|---|---|
| Event reminders + countdown alarm | `EventNotificationService` (`lib/services/notification/event_notification_service.dart`) | `event_reminders_v2` | **Yes** — genuinely local |
| FCM push rendering | `NotificationService` (`lib/services/notification/notification_service.dart`) | `runmate_channel` | **No** — requires an incoming FCM message |
| Persistent run-tracking notification | `TrackingService.java` (native Android) via `NativeTrackingService` | `runmate_live_tracking_v2` | Yes, but it's a different mechanism entirely (not `flutter_local_notifications`) |

Only the first is what "local offline notifications" usually means. The other two are documented
here anyway because they use adjacent-sounding infrastructure and are easy to mix up with it.

Companion docs: [live_tracking_architecture.md](live_tracking_architecture.md) (the tracking
service this doc's §3 only summarizes).

---

## 1. Event reminders & countdown alarm — the genuinely offline one

`EventNotificationService` (singleton, `lib/services/notification/event_notification_service.dart`)
schedules notifications ahead of time using `flutter_local_notifications`' `zonedSchedule`, backed
by Android's `AlarmManager` (`AndroidScheduleMode.alarmClock`) and iOS's local notification
framework. **Once scheduled, firing needs no network at all** — it's driven purely by the device's
clock. The only network dependency is upstream of scheduling: the event data itself comes from
Firebase RTDB, so a device that has never once been online has no events to schedule reminders
for. After that, the device can go fully offline and reminders still fire correctly.

### Setup (`init()`, lines 25-67)

- `tzdata.initializeTimeZones()` (line 29) — required because scheduling uses the `timezone`
  package's `tz.TZDateTime` for `zonedSchedule`.
- Loads `SharedPreferences` for the enabled flag and a one-time "have we asked about exact alarms
  yet" flag.
- iOS: requests all three `DarwinInitializationSettings` permission flags (`true` — lines 33-37).
  This is a **separate** `UNUserNotificationCenter` prompt from the one `NotificationService` (§2)
  triggers via `FirebaseMessaging.requestPermission` — the user may see two distinct permission
  asks for what looks like "notifications" in general.
- Android channel: `event_reminders_v2` at `Importance.max`, vibration/sound/badge all on (lines
  49-56). The old `event_reminders` channel (no `_v2` suffix) is explicitly deleted first (line
  47) — **Android caches a channel's importance by its id once created**, so bumping importance
  later requires a new id, not just changing the `Importance` value on the existing one. Samsung
  devices in particular wouldn't pick up the new `Importance.max` without this rename.
- Requests Android 13+ `POST_NOTIFICATIONS` via `_android?.requestNotificationsPermission()` (line
  60) — described in the code as "a standard one-tap system dialog."
- Deliberately does **not** request exact-alarm permission or battery-optimization exemption at
  init (lines 62-66) — both are deferred to `maybePromptForReminders`, so the app doesn't front-load
  every possible permission ask on first launch.

### The exact-alarm / battery-optimization prompt

`maybePromptForReminders(context)` (lines 75-107), called from
`lib/screens/home/mobile_events_screen.dart:82`. Only shows if reminders are enabled, exact-alarm
isn't already granted, and the user hasn't been asked before (tracked via a prefs flag). On accept:
- `_android?.requestExactAlarmsPermission()` (line 102) — opens Android's "Alarms & reminders"
  system settings page (Android 12+ requires this for precise scheduling; without it, reminders
  would be subject to OS batching/delay).
- `FlutterForegroundTask.requestIgnoreBatteryOptimization()` (lines 104-106) — yes, the
  `flutter_foreground_task` package's static helper is reused here purely for its
  battery-optimization-exemption API, even though this feature has nothing to do with that
  package's actual foreground-service functionality (see §3 for why that distinction matters).

### What actually gets scheduled

**Per-event reminders** — `_scheduleEvent` (lines 177-260), called from `scheduleForEvents(events)`
(lines 120-128), which is itself invoked from `lib/controllers/map_controller.dart:100` inside the
RTDB `events` listener. Three notifications per event, each via `_plugin.zonedSchedule(...)`:

| Reminder | Notification id | Condition |
|---|---|---|
| 24 hours before | `base*2` | always |
| 5 minutes before | `base*2+1` | always |
| Event started | `base*2+2` | only if `event.startTime` is non-empty |

IDs derive from `event.id.hashCode.abs() % 500000` (line 181) so rescheduling the same event
reliably replaces rather than duplicates its notifications.

**Countdown auto-start alarm** — `scheduleCountdownAutoStart(eventStartMs)` (lines 140-169), called
from `beginCountdown()` in `lib/controllers/kml_map_controller.dart:528-529`. A single
`zonedSchedule` at the exact event start time (fixed id `999998`), with `fullScreenIntent: true` —
the point being that it can bring the app to the foreground even from a locked device, so the
app's `didChangeAppLifecycleState(resumed)` handler can auto-start run tracking right at the gun.
Cancelled via `cancelCountdownAutoStart()` from `kml_map_controller.dart:541, 562, 1724` (user
cancels the countdown, or leaves the screen). A Dart `Timer` (`_countdownTimer`,
`kml_map_controller.dart:545-555`) runs alongside as a redundant backup trigger — the code
explicitly does **not** also start a `flutter_foreground_task` service for this anymore, per a
comment at `kml_map_controller.dart:532-537` noting it hangs ~5s then throws
`ServiceTimeoutException` on Android 16 (targetSdk 36).

### Toggling off

`setEnabled(false)` (lines 111-118) immediately calls `_plugin.cancelAll()` (line 117) — no stray
`AlarmManager` entries are left behind once reminders are turned off.

---

## 2. FCM push rendering — NOT offline, included for contrast

`NotificationService` (`lib/services/notification/notification_service.dart`) is the client side of
the broadcast-notification feature covered in
[ADMIN_NOTIFICATIONS_TESTING.md](../testing/admin_notifications/ADMIN_NOTIFICATIONS_TESTING.md) —
it exists to **render an incoming FCM push while the app is foregrounded**
(`FirebaseMessaging.onMessage.listen(_showLocalNotification)`, line 70), using
`flutter_local_notifications` purely as a rendering layer. It fundamentally **requires network
delivery of an FCM message to fire at all** — nothing about it works offline, despite using the
same plugin as §1.

- Channel: `runmate_channel` / "RunMate Notifications", `Importance.high` (lines 19-20, 53-61) —
  this exact channel id is also set server-side in `functions/index.js` (`channelId:
  'runmate_channel'`, lines 56, 120, 260), so the Cloud Function's Android payload and this
  client-side channel are intentionally paired.
- `init()` (lines 27-78) requests FCM permission first (`_fcm.requestPermission`, lines 29-33 —
  this also covers the Android 13+ `POST_NOTIFICATIONS` prompt under the hood), subscribes to the
  `all_users` topic (line 36), *then* initializes `flutter_local_notifications` with iOS permission
  flags all `false` (lines 43-46) — deliberately, since the FCM permission request just above
  already asked iOS for alert/badge/sound.
- Tap handling: `_onLocalTap` (line 125) decodes a JSON payload and routes via `_navigate` (line
  135) — the same table used for `_onRemoteTap` (line 133) when the app was backgrounded/killed
  and the OS delivered the notification directly.
- Also does an FCM token save to RTDB (`_saveToken`, lines 96-102) — another networked side effect
  unrelated to §1's offline scheduling.

`NotificationService` and `EventNotificationService` are **entirely separate singletons** — no
shared state, no shared `FlutterLocalNotificationsPlugin` instance, no shared channel. Both are
independently initialized back-to-back in `main.dart`/`main_live.dart`
(`NotificationService.instance.init()` then `EventNotificationService.instance.init()`, un-awaited).
The only things they share are the plugin package itself and nothing else — `EventNotificationService`
doesn't even wire up a tap-navigation handler (its `_plugin.initialize` call passes no
`onDidReceiveNotificationResponse`), so tapping an event reminder just opens the app wherever it
last was, no deep link.

---

## 3. The persistent run-tracking notification — a third, unrelated mechanism

Worth knowing about mainly to avoid confusing it with either of the above: the "Strava-style"
ongoing notification shown while actively tracking a run is **neither** `flutter_local_notifications`
**nor** `flutter_foreground_task` — it's a hand-written native Android foreground service,
`android/app/src/main/java/com/xorgeek/runmate/TrackingService.java`, driven from Dart through
`lib/services/tracking/native_tracking_service.dart` over a `MethodChannel('runmate/tracking')`.

- Native channel `runmate_live_tracking_v2` / "Live Run", `IMPORTANCE_DEFAULT`, no sound/vibration/
  lights/badge — created in `ensureChannel()` (`TrackingService.java:378-392`), a completely
  separate channel from both `runmate_channel` and `event_reminders_v2` above.
- Built with plain `Notification.Builder`, `setOngoing(true)` (non-swipe-away) and
  `setOnlyAlertOnce(true)` (silent on the frequent live distance/time updates).
- `NativeTrackingService.start(title, text)` invokes `'start'` over the channel, then confirms via
  `'isForegroundActive'` — this is what lets the app detect a refused `startForeground()` call
  (Android's background-start restrictions) and warn the user
  (`_warnIfUnprotected`, `lib/controllers/free_run_controller.dart:655-663`).
- Also delivers location fixes via `EventChannel('runmate/tracking/location')`, buffering to disk
  while the Dart isolate is dead — the mechanism that survives OEM process kills during a run.

**`flutter_foreground_task` itself is initialized but never actually started as a service** in the
current code (confirmed via a repo-wide grep — `FlutterForegroundTask.startService(...)` has zero
call sites; only `.stopService()` appears, as defensive no-op cleanup). It's retained purely for
its static helper APIs:
- `isIgnoringBatteryOptimizations` / `requestIgnoreBatteryOptimization()` — reused by
  `EventNotificationService` (§1), `free_run_controller.dart`, `kml_map_controller.dart`, and shown
  as a status row in `lib/screens/admin/.../permissions_screen.dart` (organizer-facing permissions
  checklist, despite the name this screen isn't admin-only).
- `checkNotificationPermission()` / `requestNotificationPermission()` — a *third*, separate
  `POST_NOTIFICATIONS` request path, tied specifically to starting a run
  (`free_run_controller.dart:670-673`), alongside the two other places this same OS permission
  gets requested (§1 and §2 above).

Its own channel, `runmate_tracking_v5`, is declared at boot (`lib/main.dart:130-158`,
`lib/main_live.dart:138-156`) but nothing ever posts to it.

---

## Permission requests — all the places `POST_NOTIFICATIONS` gets asked for

Yes, there are three separate request paths for what is, on Android, the same OS permission:

1. `_fcm.requestPermission(...)` in `notification_service.dart:29-33` (§2 — covers it implicitly
   via Firebase Messaging).
2. `_android?.requestNotificationsPermission()` in `event_notification_service.dart:60` (§1).
3. `FlutterForegroundTask.checkNotificationPermission()`/`requestNotificationPermission()` in
   `free_run_controller.dart:670-673` (tied to run start, §3's leftover helper API).

In practice the OS only prompts once per install regardless of which code path asks first — but
if you're debugging "why didn't this permission request fire," check whether one of the *other*
two already resolved it earlier in the session.

## Channel summary

| Channel id | Owner | Importance | Purpose |
|---|---|---|---|
| `event_reminders_v2` | `EventNotificationService` | `max` | Offline event reminders + countdown alarm |
| `runmate_channel` | `NotificationService` (+ server: `functions/index.js`) | `high` | Foregrounded FCM push rendering |
| `runmate_live_tracking_v2` | `TrackingService.java` (native) | `default` | Persistent run-tracking notification |
| `runmate_tracking_v5` | `flutter_foreground_task` init | n/a | Declared at boot, currently unused — no service ever starts on it |

## Non-obvious things worth remembering

- Bumping a channel's `Importance` after the fact does nothing on Android unless you also change
  its id — Android caches importance per channel id permanently once a user has seen it. This is
  why `event_reminders_v2` exists (see §1).
- Exact-alarm and battery-optimization permissions are deliberately **not** requested at app boot
  for event reminders — they're deferred to an explicit in-app prompt so first launch doesn't
  front-load every possible permission dialog at once.
- `flutter_foreground_task` looks like it should own the persistent run-tracking notification, and
  used to conceptually — but the actual notification today comes from hand-written native code
  (`TrackingService.java`), not this plugin. The plugin is kept around only for its permission
  helper methods.
- There is no proximity-based, milestone-based, GPS-loss, or low-battery *system* notification
  anywhere in the run-tracking path — those conditions surface as in-app snackbars
  (`free_run_controller.dart`) or `VoiceCoachService` TTS audio cues, never as a
  `flutter_local_notifications` call.
