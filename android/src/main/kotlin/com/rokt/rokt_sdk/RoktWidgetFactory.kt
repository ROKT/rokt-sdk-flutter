package com.rokt.rokt_sdk

import android.content.Context
import com.rokt.roktsdk.Widget
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class RoktWidgetFactory(private val messenger: BinaryMessenger): PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    val nativeViews = mutableMapOf<Int, Widget>()

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val roktWidget = RoktWidget(context!!, messenger, viewId)
        nativeViews[viewId] = roktWidget.widget
        return roktWidget
    }
}