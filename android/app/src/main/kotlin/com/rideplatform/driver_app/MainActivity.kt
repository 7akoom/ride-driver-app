package com.rideplatform.driver_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    // The channels pushes are shown on (Android 8 and newer). A channel's sound and
    // importance cannot change once it exists: a new sound needs a new channel id.
    //  - trip_offers: a trip offer rings like a call and shows over other apps, with the
    //    phone's ringtone, so a captain with the app closed does not miss it. The backend
    //    sends offers on it (android_channel) at high priority.
    //  - general: everything else (review decisions, documents, the wallet).
    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = getSystemService(NotificationManager::class.java) ?: return

        val offers = NotificationChannel(
            OFFERS_CHANNEL,
            getString(R.string.channel_trip_offers),
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = getString(R.string.channel_trip_offers_description)
            setSound(
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE),
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
            enableVibration(true)
            vibrationPattern = longArrayOf(0, 800, 400, 800, 400, 800)
            lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
        }

        val general = NotificationChannel(
            GENERAL_CHANNEL,
            getString(R.string.channel_general),
            NotificationManager.IMPORTANCE_DEFAULT,
        )

        manager.createNotificationChannels(listOf(offers, general))
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Lets screens with sensitive content (one-time codes, documents) block
        // screenshots and screen recording. See lib/core/security/secure_window.dart.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURE_WINDOW_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enable" -> {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    "disable" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // Keeps the screen on while the captain drives with the map (turn-by-turn
        // navigation). See lib/core/screen/keep_screen_on.dart.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "keepOn" -> {
                        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        result.success(null)
                    }
                    "allowOff" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    companion object {
        private const val SECURE_WINDOW_CHANNEL = "driver_app/secure_window"
        private const val SCREEN_CHANNEL = "driver_app/screen"
        private const val OFFERS_CHANNEL = "trip_offers"
        private const val GENERAL_CHANNEL = "general"
    }
}
