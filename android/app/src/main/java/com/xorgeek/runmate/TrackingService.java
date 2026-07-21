package com.xorgeek.runmate;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.IBinder;
import android.os.PowerManager;

/**
 * A location foreground service we fully control (Strava-style). It shows ONE
 * ongoing, silent (LOW-importance / "Silent" section), non-removable
 * notification with live distance + time, and — because it's typed "location"
 * and holds foreground state — keeps GPS delivering in the background on
 * Android 16. Started while the app is in the foreground (reliable), so it never
 * hits the background-FGS-start restriction, and stopped when the run ends.
 *
 * Replaces both geolocator's own foreground notification and
 * flutter_foreground_task (which times out on Android 16).
 */
public class TrackingService extends Service {
    public static final String CHANNEL_ID = "runmate_live_tracking";
    public static final int NOTIF_ID = 424242;
    public static final String ACTION_STOP = "com.xorgeek.runmate.STOP_TRACKING";
    public static final String EXTRA_TITLE = "title";
    public static final String EXTRA_TEXT = "text";

    private PowerManager.WakeLock _wakeLock;

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && ACTION_STOP.equals(intent.getAction())) {
            releaseWakeLock();
            stopForeground(true);
            stopSelf();
            return START_NOT_STICKY;
        }

        String title = intent != null ? intent.getStringExtra(EXTRA_TITLE) : null;
        String text = intent != null ? intent.getStringExtra(EXTRA_TEXT) : null;
        if (title == null) title = "RunMate";
        if (text == null) text = "";

        Notification notification = buildNotification(this, title, text);
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(NOTIF_ID, notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION);
            } else {
                startForeground(NOTIF_ID, notification);
            }
        } catch (Exception e) {
            // If startForeground is refused for any reason, don't crash — the run
            // still records; the notification just won't show.
        }
        // Hold a partial wakelock so the CPU keeps running with the screen off.
        // A foreground service alone does NOT prevent Doze from suspending the
        // Dart isolate — without this, the route stops drawing a couple of
        // minutes after the screen locks, then resumes when the screen turns on.
        acquireWakeLock();
        // START_STICKY so the OS tries to restart the service if it's killed.
        return START_STICKY;
    }

    private void acquireWakeLock() {
        try {
            if (_wakeLock == null) {
                PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
                _wakeLock = pm.newWakeLock(
                        PowerManager.PARTIAL_WAKE_LOCK, "RunMate::TrackingWakeLock");
                _wakeLock.setReferenceCounted(false);
            }
            if (!_wakeLock.isHeld()) {
                _wakeLock.acquire();
            }
        } catch (Exception e) {
            // never let a wakelock issue crash tracking
        }
    }

    private void releaseWakeLock() {
        try {
            if (_wakeLock != null && _wakeLock.isHeld()) {
                _wakeLock.release();
            }
        } catch (Exception e) {
            // ignore
        }
    }

    @Override
    public void onDestroy() {
        releaseWakeLock();
        super.onDestroy();
    }

    /** Creates the LOW-importance ("Silent" section) channel if needed. */
    public static void ensureChannel(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager nm =
                    (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            if (nm != null && nm.getNotificationChannel(CHANNEL_ID) == null) {
                NotificationChannel channel = new NotificationChannel(
                        CHANNEL_ID, "Live Run", NotificationManager.IMPORTANCE_LOW);
                channel.setDescription("Shows your live distance and time during a run");
                channel.setShowBadge(false);
                nm.createNotificationChannel(channel);
            }
        }
    }

    /** Builds the ongoing, silent, non-removable tracking notification. */
    @SuppressWarnings("deprecation")
    public static Notification buildNotification(Context context, String title, String text) {
        ensureChannel(context);

        Intent launch = context.getPackageManager()
                .getLaunchIntentForPackage(context.getPackageName());
        int piFlags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            piFlags |= PendingIntent.FLAG_IMMUTABLE;
        }
        PendingIntent contentIntent =
                PendingIntent.getActivity(context, 0, launch, piFlags);

        Notification.Builder builder;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder = new Notification.Builder(context, CHANNEL_ID);
        } else {
            builder = new Notification.Builder(context);
        }
        builder.setContentTitle(title)
                .setContentText(text)
                .setSmallIcon(R.drawable.ic_notification)
                .setOngoing(true)          // non-removable
                .setOnlyAlertOnce(true)    // no sound/heads-up on updates
                .setContentIntent(contentIntent);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            builder.setVisibility(Notification.VISIBILITY_PUBLIC);
            builder.setCategory("workout");
        }
        return builder.build();
    }

    /** Updates the (already-showing) notification without restarting the service. */
    public static void updateNotification(Context context, String title, String text) {
        NotificationManager nm =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        if (nm != null) {
            nm.notify(NOTIF_ID, buildNotification(context, title, text));
        }
    }
}
