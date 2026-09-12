package com.nada.zikrakanm

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val batteryChannel = "com.nada.zikrakanm/battery"

    override fun onStart() {
        super.onStart()
        // On Android 8.1+ (API 27+), manifest attributes showWhenLocked and turnScreenOn
        // are not sufficient on their own — window flags must be set in code as well.
        // These allow the Azan fullScreenIntent to visually wake the locked screen.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            batteryChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestIgnoreBatteryOptimizations" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val pm = getSystemService(POWER_SERVICE) as PowerManager
                            if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                                // Show the targeted system dialog for this specific app.
                                // This is the least invasive and most reliable approach —
                                // it only appears if optimization is NOT already disabled.
                                val intent = Intent(
                                    Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                    Uri.parse("package:$packageName")
                                )
                                startActivity(intent)
                                result.success(false) // false = dialog shown, user must act
                            } else {
                                result.success(true) // already whitelisted
                            }
                        } else {
                            result.success(true) // API < 23: no battery optimization
                        }
                    } catch (e: Exception) {
                        // Fallback: open general battery optimization settings page
                        try {
                            val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                            startActivity(intent)
                            result.success(false)
                        } catch (e2: Exception) {
                            result.error("BATTERY_OPT_ERROR", e2.message, null)
                        }
                    }
                }
                "isBatteryOptimizationIgnored" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val pm = getSystemService(POWER_SERVICE) as PowerManager
                            result.success(pm.isIgnoringBatteryOptimizations(packageName))
                        } else {
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
