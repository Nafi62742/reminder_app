package com.xorgeek.runmate;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String DEEP_LINK_CHANNEL = "app/deep_link";
    private static final String TRACKING_CHANNEL = "runmate/tracking";
    private String initialLink = null;
    private EventChannel.EventSink linkSink = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initialLink = extractLink(getIntent());
    }

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // One-shot: return the link that launched the app
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), DEEP_LINK_CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("getInitialLink")) {
                    result.success(initialLink);
                } else {
                    result.notImplemented();
                }
            });

        // Native tracking foreground service (Strava-style live notification).
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), TRACKING_CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "start": {
                        Intent i = new Intent(this, TrackingService.class);
                        i.putExtra(TrackingService.EXTRA_TITLE, (String) call.argument("title"));
                        i.putExtra(TrackingService.EXTRA_TEXT, (String) call.argument("text"));
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(i);
                        } else {
                            startService(i);
                        }
                        result.success(true);
                        break;
                    }
                    case "update": {
                        TrackingService.updateNotification(this,
                            (String) call.argument("title"), (String) call.argument("text"));
                        result.success(true);
                        break;
                    }
                    case "stop": {
                        Intent i = new Intent(this, TrackingService.class);
                        i.setAction(TrackingService.ACTION_STOP);
                        startService(i);
                        result.success(true);
                        break;
                    }
                    default:
                        result.notImplemented();
                }
            });

        // Stream: forward links that arrive while app is running
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), DEEP_LINK_CHANNEL + "/events")
            .setStreamHandler(new EventChannel.StreamHandler() {
                @Override
                public void onListen(Object args, EventChannel.EventSink events) {
                    linkSink = events;
                }
                @Override
                public void onCancel(Object args) {
                    linkSink = null;
                }
            });
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        final String link = extractLink(intent);
        if (link != null && linkSink != null) {
            linkSink.success(link);
        }
    }

    private String extractLink(Intent intent) {
        if (intent == null) return null;
        final Uri data = intent.getData();
        if (data == null) return null;
        final String scheme = data.getScheme();
        if (scheme != null && scheme.equals("marathon-map")) return data.toString();
        return null;
    }
}
