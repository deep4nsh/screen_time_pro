package com.example.screen_time_pro

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "screen_time_pro/usage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "openUsageSettings" -> {
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(null)
                }
                "hasUsagePermission" -> {
                    val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
                    val mode = appOps.checkOpNoThrow(
                        "android:get_usage_stats",
                        Process.myUid(), packageName
                    )
                    result.success(mode == AppOpsManager.MODE_ALLOWED)
                }
                "fetchUsage" -> {
                    val interval = call.argument<String>("interval") ?: "daily"
                    val usageData = fetchUsageStats(interval)
                    result.success(usageData)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun fetchUsageStats(interval: String): List<Map<String, Any>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val pm = packageManager

        val end = System.currentTimeMillis()
        val start = when (interval) {
            "weekly" -> end - 7 * 24 * 60 * 60 * 1000L
            else -> end - 24 * 60 * 60 * 1000L
        }

        val stats: List<UsageStats> =
            usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, end)

        val list = mutableListOf<Map<String, Any>>()
        for (us in stats) {
            if (us.totalTimeInForeground > 0) {
                val appName = try {
                    val info = pm.getApplicationInfo(us.packageName, 0)
                    pm.getApplicationLabel(info).toString()
                } catch (e: Exception) {
                    us.packageName
                }

                val icon = try {
                    val drawable = pm.getApplicationIcon(us.packageName)
                    // Convert to Base64 to send to Dart
                    val bitmap = (drawable as android.graphics.drawable.BitmapDrawable).bitmap
                    val stream = java.io.ByteArrayOutputStream()
                    bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream)
                    android.util.Base64.encodeToString(stream.toByteArray(), android.util.Base64.DEFAULT)
                } catch (e: Exception) {
                    ""
                }

                list.add(
                    mapOf(
                        "packageName" to us.packageName,
                        "appName" to appName,
                        "timeHours" to us.totalTimeInForeground / 1000.0 / 3600.0,
                        "icon" to icon
                    )
                )
            }
        }
        return list
    }

}
