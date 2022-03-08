package com.rokt.rokt_sdk

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class RoktWidgetFactory: PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    val nativeViews = mutableMapOf<Int, RoktWidget>()

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val roktWidget = RoktWidget(context)
        nativeViews[viewId] = roktWidget
        return roktWidget
    }
}