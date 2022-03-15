package com.rokt.rokt_sdk

import android.util.Log
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
        Log.d(TAG, "loaded")
    }

    override fun onShouldHideLoadingIndicator() {
        argumentMap["args"] = "onShouldHideLoadingIndicator"
        channel?.invokeMethod("callListener", argumentMap)
        Log.d(TAG, "onShouldHideLoadingIndicator")
    }

    override fun onShouldShowLoadingIndicator() {
        argumentMap["args"] = "onShouldShowLoadingIndicator"
        channel?.invokeMethod("callListener", argumentMap)
        Log.d(TAG, "onShouldShowLoadingIndicator")
    }

    override fun onUnload(reason: Rokt.UnloadReasons) {
        argumentMap["args"] = "unload"
        channel?.invokeMethod("callListener", argumentMap)
        Log.d(TAG, "onUnLoad")
    }

    companion object {
        private const val TAG = "Rokt_RoktCallback"
    }
}