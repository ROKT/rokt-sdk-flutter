package com.rokt.rokt_sdk

import android.app.Activity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.rokt.roktsdk.CacheConfig
import com.rokt.roktsdk.Rokt
import com.rokt.roktsdk.RoktConfig
import com.rokt.roktsdk.RoktEvent
import com.rokt.roktsdk.Widget
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterAssets
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch
import java.lang.ref.WeakReference

class MethodCallHandlerImpl(
    private val messenger: BinaryMessenger,
    private val flutterAssets: FlutterAssets,
    private val widgetFactory: RoktWidgetFactory
) :
    MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private lateinit var activity: Activity
    private val roktCallbacks: MutableSet<Rokt.RoktCallback> = mutableSetOf()
    private val eventListeners = mutableSetOf<EventChannel.EventSink>()
    private val eventSubscriptions = mutableMapOf<String, Job?>()

    init {
        setupEventChannel()
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
            eventSubscriptions.clear()
            subscribeToEvents(Rokt.globalEvents())
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
        val configMap = call.argument<HashMap<String, Any>>("config")
        val config = configMap?.let { buildRoktConfig(it) }
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
        subscribeToEvents(Rokt.events(viewName), viewName)
        Rokt.execute(
            viewName = viewName,
            attributes = attributes,
            callback = roktCallback,
            placeholders = placeHolders,
            config = config
        )
        result.success("Executed")
    }

    private fun setupEventChannel() {
        EventChannel(messenger, EVENT_CHANNEL_NAME).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    if (sink != null) {
                        eventListeners.add(sink)
                    }
                }

                override fun onCancel(arguments: Any?) {
                }
            }
        )
    }

    private fun String.toColorMode(): RoktConfig.ColorMode {
        return when (this) {
            "dark" -> RoktConfig.ColorMode.DARK
            "light" -> RoktConfig.ColorMode.LIGHT
            else -> RoktConfig.ColorMode.SYSTEM
        }
    }

    private fun buildRoktConfig(configMap: Map<String, Any>): RoktConfig {
        val builder = RoktConfig.Builder()
        (configMap["colorMode"] as? String)?.let {
            builder.colorMode(it.toColorMode())
        }
        (configMap["cacheConfig"] as? Map<String, Any>)?.let { cacheConfig ->
            val cacheDurationInSeconds = cacheConfig["cacheDurationInSeconds"] as? Int ?: 0
            val cacheAttributes = cacheConfig["cacheAttributes"] as? Map<String, String> ?: null
            builder.cacheConfig(CacheConfig(cacheDurationInSeconds.toLong(), cacheAttributes))
        }

        return builder.build()
    }

    private fun subscribeToEvents(flow: Flow<RoktEvent>, viewName: String? = null) {
        val activeJob = eventSubscriptions[viewName.orEmpty()]?.takeIf { it.isActive }
        if (activeJob != null) {
            return
        }
        val job = (activity as? LifecycleOwner)?.lifecycleScope?.launch {
            (activity as LifecycleOwner).lifecycle.repeatOnLifecycle(Lifecycle.State.CREATED) {
                flow.collect { event ->
                    val params: MutableMap<String, String> = mutableMapOf()
                    var eventName = ""
                    val placementId: String? = when (event) {
                        is RoktEvent.HideLoadingIndicator -> {
                            eventName = "HideLoadingIndicator"
                            null
                        }

                        is RoktEvent.FirstPositiveEngagement -> {
                            eventName = "FirstPositiveEngagement"
                            event.id
                        }

                        is RoktEvent.OfferEngagement -> {
                            eventName = "OfferEngagement"
                            event.id
                        }

                        is RoktEvent.PlacementClosed -> {
                            eventName = "PlacementClosed"
                            event.id
                        }

                        is RoktEvent.PlacementCompleted -> {
                            eventName = "PlacementCompleted"
                            event.id
                        }

                        is RoktEvent.PlacementFailure -> {
                            eventName = "PlacementFailure"
                            event.id
                        }

                        is RoktEvent.PlacementInteractive -> {
                            eventName = "PlacementInteractive"
                            event.id
                        }

                        is RoktEvent.PlacementReady -> {
                            eventName = "PlacementReady"
                            event.id
                        }

                        is RoktEvent.PositiveEngagement -> {
                            eventName = "PositiveEngagement"
                            event.id
                        }

                        RoktEvent.ShowLoadingIndicator -> {
                            eventName = "ShowLoadingIndicator"
                            null
                        }

                        is RoktEvent.InitComplete -> {
                            eventName = "InitComplete"
                            params["status"] = event.success.toString()
                            null
                        }
                    }
                    viewName?.let { params["viewName"] = viewName }
                    placementId?.let { params["placementId"] = it }
                    params["event"] = eventName
                    eventListeners.forEach { listener -> listener.success(params) }
                }
            }
        }
        eventSubscriptions[viewName.orEmpty()] = job
    }

    companion object {
        private const val CHANNEL_NAME = "rokt_sdk"
        private const val INIT_METHOD = "initialize"
        private const val EXECUTE_METHOD = "execute"
        private const val LOGGING_METHOD = "logging"
        private const val EVENT_CHANNEL_NAME = "RoktEvents"
        const val TAG = "ROKTSDK_FLUTTER"
    }
}
