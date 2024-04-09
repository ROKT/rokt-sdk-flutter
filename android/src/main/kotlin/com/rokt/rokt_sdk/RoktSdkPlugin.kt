package com.rokt.rokt_sdk

import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterAssets
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.cancelChildren
import java.text.SimpleDateFormat
import java.util.Date


/** RoktSdkPlugin */
class RoktSdkPlugin : FlutterPlugin, ActivityAware {
    private var methodCallHandler: MethodCallHandlerImpl? = null
    lateinit var roktEventChannel: EventChannel
    lateinit var coroutineScope: CoroutineScope
    private val eventChannel = "timeHandlerEvent"
    private val handler = CoroutineExceptionHandler { _, exception ->
        Log.d("", "${exception.printStackTrace()}")
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val widgetFactory = RoktWidgetFactory(flutterPluginBinding.binaryMessenger)
        coroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate + handler)
        // Set up an EventChannel for sending rokt events to Flutter
        roktEventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "rokt_events"
        )
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            VIEW_TYPE, widgetFactory
        )
        setupMethodChannel(
            flutterPluginBinding.binaryMessenger,
            flutterPluginBinding.flutterAssets,
            widgetFactory
        )
        /*EventChannel(flutterPluginBinding.binaryMessenger, eventChannel).setStreamHandler(
            TimeHandler
        )*/
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        teardownMethodChannel()
        coroutineScope.coroutineContext.cancelChildren()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        methodCallHandler?.startListening(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }

    private fun setupMethodChannel(
        messenger: BinaryMessenger,
        flutterAssets: FlutterAssets,
        widgetFactory: RoktWidgetFactory
    ) {
        methodCallHandler = MethodCallHandlerImpl(messenger, flutterAssets, widgetFactory,
            roktEventChannel, coroutineScope)
    }

    private fun teardownMethodChannel() {
        methodCallHandler?.stopListening()
        methodCallHandler = null
    }

    companion object {
        private const val VIEW_TYPE = "rokt_sdk.rokt.com/rokt_widget"
    }

    object TimeHandler : EventChannel.StreamHandler {
        // Handle event in main thread.
        private var handler = Handler(Looper.getMainLooper())

        // Declare our eventSink later it will be initialized
        private var eventSink: EventChannel.EventSink? = null

        @SuppressLint("SimpleDateFormat")
        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            Log.d("Sahil", "onListen ???")
            eventSink = sink
            // every second send the time
            val r: Runnable = object : Runnable {
                override fun run() {
                    handler.post {
                        val dateFormat = SimpleDateFormat("HH:mm:ss")
                        val time = dateFormat.format(Date())
                        eventSink?.success(time)
                    }
                    handler.postDelayed(this, 1000)
                }
            }
            handler.postDelayed(r, 1000)
        }

        override fun onCancel(p0: Any?) {
            eventSink = null
        }
    }

}
