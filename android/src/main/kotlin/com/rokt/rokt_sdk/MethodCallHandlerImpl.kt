package com.rokt.rokt_sdk

import android.app.Activity
import android.util.Log
import com.rokt.roktsdk.Rokt
import com.rokt.roktsdk.Widget
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

class MethodCallHandlerImpl(
    private val messenger: BinaryMessenger,
    private val widgetFactory: RoktWidgetFactory
) :
    MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private lateinit var activity: Activity
    private val roktCallbacks: MutableSet<Rokt.RoktCallback> = mutableSetOf()
    private val roktMap: MutableMap<String, Rokt.Event> = mutableMapOf()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            INIT_METHOD -> {
                init(call, result)
            }
            EXECUTE_METHOD -> {
                execute(call, result)
            }
            LOGGING_METHOD -> {
                logging(call, result)
            }
            WIDGET_ADDED -> {
                widgetAdded(call, result)
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
        roktCallbacks.clear()
        channel?.let { methodChannel ->
            methodChannel.setMethodCallHandler(null)
            channel = null
        }
    }

    private fun logging(call: MethodCall, result: MethodChannel.Result) {
        val enable: Boolean = call.argument<Boolean?>("enable") ?: false
        Rokt.setLoggingEnabled(enable)
        Logger.debugLogsEnabled = enable
        result.success("enable")
    }

    private fun init(call: MethodCall, result: MethodChannel.Result) {
        val roktTagId = call.argument<String>("roktTagId")
        val appVersion = call.argument<String>("appVersion").orEmpty()
        roktTagId?.let { tagId ->
            Rokt.init(tagId, appVersion, activity)
            result.success("Initialized")
        } ?: result.error(
            "No_TAG_ID",
            "you must provide tag id.",
            null
        )
    }


    private fun widgetAdded(call: MethodCall, result: MethodChannel.Result) {
        val targetName = call.argument<String>("targetName").orEmpty()
        val viewId = call.argument<Int>("viewId")
        Log.d("_Sahil", "widgetAdded $targetName $viewId")
        roktMap[targetName]?.let {
            Log.d("_Sahil", "widget with same name already added, calling update widget")
            val widget = widgetFactory.nativeViews[viewId]
            Rokt.updateEmbeddedWidget(it.executeId, it.placementId1, targetName, WeakReference(widget))
        }
        result.success("Success")
    }

    private fun execute(call: MethodCall, result: MethodChannel.Result) {
        val viewName = call.argument<String>("viewName").orEmpty()
        val attributes = call.argument<HashMap<String, String>>("attributes").orEmpty()
        val callBackId = call.argument<Int>("callbackId") ?: 0
        val placeHolders: MutableMap<String, WeakReference<Widget>> = mutableMapOf()
        call.argument<HashMap<Int, String>>("placeholders")?.entries?.forEach {
            if (widgetFactory.nativeViews[it.key] != null) {
                placeHolders[it.value] = WeakReference(widgetFactory.nativeViews[it.key])
            }
            roktMap.remove(it.value)
        }
        val roktCallback = RoktCallbackImpl(channel, callBackId).also { callback ->
            roktCallbacks.add(callback)
        }
        val map: MutableMap<String, Any> = mutableMapOf()
        map["id"] = callBackId
        Logger.log(TAG, "execute $viewName $attributes $placeHolders}")
        Rokt.execute2Step(viewName, attributes, roktCallback, placeHolders, object : Rokt.RoktEventCallback {
            override fun onEvent(
                event: Rokt.Event,
                roktEventHandler: Rokt.RoktEventHandler
            ) {
                Logger.log(TAG, "**** $event $roktEventHandler.")
                if (event.targetElement.isNotEmpty()) {
                    roktMap[event.targetElement] = event
                }
            }

        })
        result.success("Executed")
    }

    companion object {
        private const val CHANNEL_NAME = "rokt_sdk"
        private const val INIT_METHOD = "initialize"
        private const val EXECUTE_METHOD = "execute"
        private const val LOGGING_METHOD = "logging"
        private const val WIDGET_ADDED = "widgetAdded"
        const val TAG = "_Sahil"
    }
}