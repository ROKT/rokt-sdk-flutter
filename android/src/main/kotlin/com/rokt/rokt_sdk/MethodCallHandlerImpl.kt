package com.rokt.rokt_sdk

import android.app.Activity
import android.util.Log
import com.rokt.roktsdk.Rokt
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MethodCallHandlerImpl(private val messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private lateinit var activity: Activity

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            INIT_METHOD -> {
                init(call, result)
            }
            EXECUTE_METHOD -> {
                execute(call, result)
            }
            else -> result.notImplemented()
        }
    }

    fun startListening(activity: Activity) {
        this.activity = activity
        if (channel != null) {
            stopListening()
        }
        channel = MethodChannel(messenger, CHANNEL_NAME)
        channel?.setMethodCallHandler(this)
    }

    fun stopListening() {
        channel?.let { methodChannel ->
            methodChannel.setMethodCallHandler(null)
            channel = null
        }
    }

    private fun init(call: MethodCall, result: MethodChannel.Result) {
        val roktTagId = call.argument<String>("roktTagId")
        val appVersion = call.argument<String>("appVersion").orEmpty()
        Log.d(TAG, "init $roktTagId $appVersion")
        roktTagId?.let { roktTagId ->
            Rokt.setLoggingEnabled(true)
            Rokt.init(roktTagId, appVersion, activity)
            result.success("Initialized")
        } ?: result.error(
            "No_TAG_ID",
            "you must provide tag id.",
            null
        )
    }

    private fun execute(call: MethodCall, result: MethodChannel.Result) {
        val viewName = call.argument<String>("viewName").orEmpty()
        val attributes = call.argument<HashMap<String, String>>("attributes").orEmpty()
        val callBackId = call.argument<Int>("callbackId") ?: 0
        val map: MutableMap<String, Any> = mutableMapOf()
        map["id"] = callBackId
        Log.d(TAG, "execute $viewName $attributes ${map["id"]}")
        Rokt.execute(viewName, attributes, object : Rokt.RoktCallback {
            override fun onUnload(reason: Rokt.UnloadReasons) {
                map["args"] = "unload"
                channel?.invokeMethod("callListener", map)
                Log.d(TAG, "onUnLoad")
            }

            override fun onLoad() {
                map["args"] = "load"
                channel?.invokeMethod("callListener", map)
                Log.d(TAG, "loaded")
            }

            override fun onShouldHideLoadingIndicator() {
                map["args"] = "onShouldHideLoadingIndicator"
                channel?.invokeMethod("callListener", map)
                Log.d(TAG, "onShouldHideLoadingIndicator")
            }

            override fun onShouldShowLoadingIndicator() {
                map["args"] = "onShouldShowLoadingIndicator"
                channel?.invokeMethod("callListener", map)
                Log.d(TAG, "onShouldShowLoadingIndicator")
            }
        }, mapOf())
        result.success("Executed")
    }

    companion object {
        private const val CHANNEL_NAME = "rokt_sdk"
        private const val INIT_METHOD = "initialize"
        private const val EXECUTE_METHOD = "execute"
        private const val TAG = "Rokt_MethodCallHandler"
    }
}