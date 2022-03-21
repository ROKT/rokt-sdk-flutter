package com.rokt.rokt_sdk

import android.util.Log
import com.rokt.roktsdk.BuildConfig

object Logger {
    internal var debugLogsEnabled: Boolean = BuildConfig.DEBUG

    fun log(tag: String? = null, message: String) {
        if (debugLogsEnabled) {
            Log.d(tag ?: BuildConfig.LIBRARY_PACKAGE_NAME, message)
        }
    }
}