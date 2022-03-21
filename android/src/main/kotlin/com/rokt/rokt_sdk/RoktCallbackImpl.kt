package com.rokt.rokt_sdk

import com.rokt.rokt_sdk.MethodCallHandlerImpl.Companion.TAG
import com.rokt.roktsdk.Rokt
import io.flutter.plugin.common.MethodChannel

class RoktCallbackImpl(
    private val channel: MethodChannel?, callbackId: Int): Rokt.RoktCallback {

    private val argumentMap: MutableMap<String, Any> = mutableMapOf()

    init {
        argumentMap["id"] = callbackId
    }

    override fun onLoad() {
        argumentMap["args"] = "load"
        channel?.invokeMethod("callListener", argumentMap)
        Logger.log(TAG, "loaded")
    }

    override fun onShouldHideLoadingIndicator() {
        argumentMap["args"] = "onShouldHideLoadingIndicator"
        channel?.invokeMethod("callListener", argumentMap)
        Logger.log(TAG, "onShouldHideLoadingIndicator")
    }

    override fun onShouldShowLoadingIndicator() {
        argumentMap["args"] = "onShouldShowLoadingIndicator"
        channel?.invokeMethod("callListener", argumentMap)
        Logger.log(TAG, "onShouldShowLoadingIndicator")
    }

    override fun onUnload(reason: Rokt.UnloadReasons) {
        argumentMap["args"] = "unload"
        channel?.invokeMethod("callListener", argumentMap)
        Logger.log(TAG, "onUnload")
    }
}