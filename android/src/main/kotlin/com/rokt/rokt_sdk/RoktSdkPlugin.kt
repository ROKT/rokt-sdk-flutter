package com.rokt.rokt_sdk

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterAssets
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger

/** RoktSdkPlugin */
class RoktSdkPlugin :
    FlutterPlugin,
    ActivityAware {
    private var methodCallHandler: MethodCallHandlerImpl? = null

    override fun onAttachedToEngine(
        @NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    ) {
        val widgetFactory = RoktWidgetFactory(flutterPluginBinding.binaryMessenger)
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            VIEW_TYPE,
            widgetFactory,
        )
        setupMethodChannel(
            flutterPluginBinding.binaryMessenger,
            flutterPluginBinding.flutterAssets,
            widgetFactory,
        )
    }

    override fun onDetachedFromEngine(
        @NonNull binding: FlutterPlugin.FlutterPluginBinding,
    ) {
        teardownMethodChannel()
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
        widgetFactory: RoktWidgetFactory,
    ) {
        methodCallHandler = MethodCallHandlerImpl(messenger, flutterAssets, widgetFactory)
    }

    private fun teardownMethodChannel() {
        methodCallHandler?.stopListening()
        methodCallHandler = null
    }

    companion object {
        private const val VIEW_TYPE = "rokt_sdk.rokt.com/rokt_widget"
    }
}
