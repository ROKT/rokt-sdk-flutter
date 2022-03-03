package com.rokt.rokt_sdk

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger


/** RoktSdkPlugin */
class RoktSdkPlugin: FlutterPlugin, ActivityAware {
  private var methodCallHandler: MethodCallHandlerImpl? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    setupMethodChannel(flutterPluginBinding.binaryMessenger)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
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

  private fun setupMethodChannel(messenger: BinaryMessenger) {
    methodCallHandler = MethodCallHandlerImpl(messenger)
  }

  private fun teardownMethodChannel() {
    methodCallHandler?.stopListening()
    methodCallHandler = null
  }

}
