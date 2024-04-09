package com.rokt.rokt_sdk

import android.app.Activity
import android.graphics.Typeface
import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.rokt.roktsdk.Rokt
import com.rokt.roktsdk.Widget
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterAssets
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import java.lang.ref.WeakReference

class MethodCallHandlerImpl(
    private val messenger: BinaryMessenger,
    private val flutterAssets: FlutterAssets,
    private val widgetFactory: RoktWidgetFactory,
    private val roktEventChannel: EventChannel,
    private val coroutineScope: CoroutineScope,
) :
    MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private lateinit var activity: Activity
    private val roktCallbacks: MutableSet<Rokt.RoktCallback> = mutableSetOf()
    private val roktEventSinkMap: MutableMap<String, EventChannel.EventSink> = mutableMapOf()

    init {
        setupEventChannel("PizzaHutLayout")
    }

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
        result.success("enable")
    }

    private fun init(call: MethodCall, result: MethodChannel.Result) {
        val roktTagId = call.argument<String>("roktTagId")
        val appVersion = call.argument<String>("appVersion").orEmpty()
        val fontFileMap = call.argument<HashMap<String, String>>("fontFilePathMap").orEmpty()
            .mapValues { flutterAssets.getAssetFilePathByName(it.value) }
        roktTagId?.let { tagId ->
            Rokt.setFrameworkType(Rokt.SdkFrameworkType.Flutter)
            Rokt.init(
                roktTagId = tagId,
                appVersion = appVersion,
                activity = activity,
                fontFilePathMap = fontFileMap,
            )
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
        val placeHolders: MutableMap<String, WeakReference<Widget>> = mutableMapOf()
        call.argument<HashMap<Int, String>>("placeholders")?.entries?.forEach {
            if (widgetFactory.nativeViews[it.key] != null) {
                placeHolders[it.value] = WeakReference(widgetFactory.nativeViews[it.key])
            }
        }
        val roktCallback = RoktCallbackImpl(channel, callBackId).also { callback ->
            roktCallbacks.add(callback)
        }
        val map: MutableMap<String, Any> = mutableMapOf()
        map["id"] = callBackId
        (activity as? LifecycleOwner)?.lifecycleScope?.launch {
            (activity as LifecycleOwner).lifecycle.repeatOnLifecycle(Lifecycle.State.CREATED) {
                Log.d("Sahil", "repeatOnLifeCycle ${(activity as LifecycleOwner).lifecycle.currentState}")
                Rokt.roktEvents(viewName).collect { event ->
                    Log.d("Sahil", "collecting *** $event")
                    val params: Map<String, String> = mapOf("event" to event.javaClass.simpleName, "viewName" to viewName )
                    roktEventSinkMap[viewName]?.success(params)
                }
            }
        }
        Rokt.execute(
            viewName = viewName,
            attributes = attributes,
            callback = roktCallback,
            placeholders = placeHolders,
        )
        result.success("Executed")
    }

    private fun setupEventChannel(viewName: String) {
        EventChannel(messenger, EVENT_CHANNEL_NAME).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    Log.d("Sahil", "setupEventChannel $arguments")
                    if (sink != null) {
                        roktEventSinkMap[viewName] = sink
                    }
                }

                override fun onCancel(arguments: Any?) {
                    roktEventSinkMap.remove(viewName)
                }
            }
        )
    }

    companion object {
        private const val CHANNEL_NAME = "rokt_sdk"
        private const val INIT_METHOD = "initialize"
        private const val EXECUTE_METHOD = "execute"
        private const val LOGGING_METHOD = "logging"
        const val TAG = "ROKTSDK_FLUTTER"
        private const val EVENT_CHANNEL_NAME = "rokt_event"
    }
}
