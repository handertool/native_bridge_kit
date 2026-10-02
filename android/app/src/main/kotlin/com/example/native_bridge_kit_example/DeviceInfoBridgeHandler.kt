package com.example.native_bridge_kit_example

import android.content.Context
import android.os.BatteryManager
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Runtime registration for the root DeviceInfoBridge contract. */
class DeviceInfoBridgeHandler(
    context: Context,
    flutterEngine: FlutterEngine,
) {
    private val batteryManager =
        context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
    private val methodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CHANNEL,
    )
    private val eventChannel = EventChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "$CHANNEL/battery_level",
    )
    private val mainHandler = Handler(Looper.getMainLooper())
    private var batterySink: EventChannel.EventSink? = null

    private val batteryEmitter = object : Runnable {
        override fun run() {
            batterySink?.success(batteryLevel().toDouble())
            if (batterySink != null) {
                mainHandler.postDelayed(this, BATTERY_UPDATE_INTERVAL_MS)
            }
        }
    }

    fun register() {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "get_model" -> result.success(android.os.Build.MODEL)
                "get_os_version" -> result.success(android.os.Build.VERSION.RELEASE)
                else -> result.notImplemented()
            }
        }

        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(
                arguments: Any?,
                events: EventChannel.EventSink?,
            ) {
                batterySink = events
                mainHandler.removeCallbacks(batteryEmitter)
                batteryEmitter.run()
            }

            override fun onCancel(arguments: Any?) {
                batterySink = null
                mainHandler.removeCallbacks(batteryEmitter)
            }
        })
    }

    private fun batteryLevel(): Int {
        val level = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        return level.coerceIn(0, 100)
    }

    private companion object {
        const val CHANNEL = "device_info"
        const val BATTERY_UPDATE_INTERVAL_MS = 5_000L
    }
}
