package com.example.screen_time_pro

import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Handler
import android.os.Looper
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.*
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {

    private val METHOD_CHANNEL = "screen_time_pro/usage"
    private val EVENT_CHANNEL = "screen_time_pro/usage_stream"
    private var eventSink: EventChannel.EventSink? = null
    private var timer: Timer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkPermission" -> result.success(hasUsageStatsPermission())
                    "openUsageSettings" -> {
                        startActivity(Intent(android.provider.Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    "getUsageStats" -> {
                        thread {
                            try {
                                val json = fetchUsageStatsJson()
                                Handler(Looper.getMainLooper()).post { result.success(json) }
                            } catch (e: Exception) {
                                Handler(Looper.getMainLooper()).post {
                                    result.error("ERROR", "Failed to fetch usage stats: ${e.message}", null)
                                }
                            }
                        }
                    }
                    "getUsageStatsForRange" -> {
                        thread {
                            try {
                                val startTime = call.argument<Long>("startTime") ?: 0L
                                val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                                val json = fetchUsageStatsForRange(startTime, endTime)
                                Handler(Looper.getMainLooper()).post { result.success(json) }
                            } catch (e: Exception) {
                                Handler(Looper.getMainLooper()).post {
                                    result.error("ERROR", "Failed to fetch usage stats for range: ${e.message}", null)
                                }
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    startUsageUpdates()
                }

                override fun onCancel(arguments: Any?) {
                    stopUsageUpdates()
                }
            })
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as android.app.AppOpsManager
        val mode = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                android.app.AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        } else {
            appOps.checkOpNoThrow(
                android.app.AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        }
        return mode == android.app.AppOpsManager.MODE_ALLOWED
    }

    private fun startUsageUpdates() {
        timer = Timer()
        timer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                thread {
                    try {
                        val json = fetchUsageStatsJson()
                        Handler(Looper.getMainLooper()).post {
                            eventSink?.success(json)
                        }
                    } catch (e: Exception) {
                        Handler(Looper.getMainLooper()).post {
                            eventSink?.error("ERROR", "Stream error: ${e.message}", null)
                        }
                    }
                }
            }
        }, 0, 5000) // every 5 seconds
    }

    private fun stopUsageUpdates() {
        timer?.cancel()
        timer = null
    }

    private fun fetchUsageStatsJson(): String {
        val endTime = System.currentTimeMillis()
        val startTime = endTime - 1000L * 60 * 60 * 24 // last 24h
        return fetchUsageStatsForRange(startTime, endTime)
    }

    private fun fetchUsageStatsForRange(startTime: Long, endTime: Long): String {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )
        val pm = packageManager
        val jsonArray = JSONArray()

        // ISO 8601 date format for Flutter DateTime.parse()
        val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
        dateFormat.timeZone = TimeZone.getTimeZone("UTC")

        // Merge duplicates by packageName
        val mergedStats = mutableMapOf<String, Long>()
        stats?.forEach { usage ->
            val currentTime = mergedStats[usage.packageName] ?: 0L
            mergedStats[usage.packageName] = currentTime + usage.totalTimeInForeground
        }

        // Create JSON from merged stats
        mergedStats.forEach { (packageName, totalTime) ->
            try {
                if (totalTime > 0) {
                    val appInfo = pm.getApplicationInfo(packageName, 0)
                    val appName = pm.getApplicationLabel(appInfo).toString()
                    val drawable = pm.getApplicationIcon(packageName)
                    val bitmap = drawableToBitmap(drawable)
                    val iconBase64 = bitmapToBase64(bitmap)

                    val obj = org.json.JSONObject()
                    obj.put("appName", appName)
                    obj.put("packageName", packageName)
                    obj.put("iconBase64", iconBase64)
                    obj.put("usageMillis", totalTime)
                    obj.put("timeInForeground", totalTime)
                    obj.put("category", getCategoryForPackage(packageName))
                    obj.put("date", dateFormat.format(Date(startTime)))
                    jsonArray.put(obj)
                }
            } catch (e: PackageManager.NameNotFoundException) {
                // skip missing apps
            } catch (e: Exception) {
                // skip apps with errors
            }
        }

        return jsonArray.toString()
    }

    private fun getCategoryForPackage(packageName: String): String {
        // Try to use Android's built-in category first (API 26+)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            try {
                val appInfo = packageManager.getApplicationInfo(packageName, 0)
                when (appInfo.category) {
                    android.content.pm.ApplicationInfo.CATEGORY_GAME -> return "Games"
                    android.content.pm.ApplicationInfo.CATEGORY_AUDIO,
                    android.content.pm.ApplicationInfo.CATEGORY_VIDEO -> return "Entertainment"
                    android.content.pm.ApplicationInfo.CATEGORY_SOCIAL -> return "Communication"
                    android.content.pm.ApplicationInfo.CATEGORY_PRODUCTIVITY -> return "Learning"
                }
            } catch (e: Exception) {
                // Fall through to package name matching
            }
        }

        // Fallback to package name matching
        return when {
            packageName.contains("youtube") || packageName.contains("netflix") ||
                    packageName.contains("prime") || packageName.contains("hotstar") ||
                    packageName.contains("spotify") || packageName.contains("music") ||
                    packageName.contains("hulu") || packageName.contains("disney") -> "Entertainment"

            packageName.contains("game") || packageName.contains("play.games") ||
                    packageName.contains("pubg") || packageName.contains("freefire") ||
                    packageName.contains("candy") || packageName.contains("clash") -> "Games"

            packageName.contains("whatsapp") || packageName.contains("telegram") ||
                    packageName.contains("messenger") || packageName.contains("instagram") ||
                    packageName.contains("facebook") || packageName.contains("twitter") ||
                    packageName.contains("snapchat") || packageName.contains("discord") ||
                    packageName.contains("reddit") -> "Communication"

            packageName.contains("duolingo") || packageName.contains("coursera") ||
                    packageName.contains("udemy") || packageName.contains("khan") ||
                    packageName.contains("education") || packageName.contains("learning") ||
                    packageName.contains("kindle") || packageName.contains("medium") -> "Learning"

            else -> "Other"
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        return if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            // Use smaller size for memory efficiency
            val width = drawable.intrinsicWidth.takeIf { it > 0 } ?: 96
            val height = drawable.intrinsicHeight.takeIf { it > 0 } ?: 96
            val b = Bitmap.createBitmap(
                minOf(width, 96),  // Cap at 96x96
                minOf(height, 96),
                Bitmap.Config.ARGB_8888
            )
            val canvas = android.graphics.Canvas(b)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            b
        }
    }

    private fun bitmapToBase64(bitmap: Bitmap): String {
        val outputStream = ByteArrayOutputStream()
        // Scale down if too large
        val scaledBitmap = if (bitmap.width > 96 || bitmap.height > 96) {
            Bitmap.createScaledBitmap(bitmap, 96, 96, true)
        } else {
            bitmap
        }
        scaledBitmap.compress(Bitmap.CompressFormat.PNG, 80, outputStream)
        return Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)
    }
}