package com.rokt.rokt_sdk

import android.content.Context
import com.rokt.roktsdk.RoktWidgetDimensionCallBack
import com.rokt.roktsdk.Widget
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import kotlin.math.abs

class RoktWidget(context: Context?, messenger: BinaryMessenger, viewId: Int) : PlatformView,
    RoktWidgetDimensionCallBack {

    val widget: Widget? = if (context != null) Widget(context) else null
    private var lastHeight = 0
    private val channel: MethodChannel = MethodChannel(messenger, "rokt_widget_$viewId")

    init {
        widget?.registerDimensionListener(this)
    }

    private fun sendUpdatedHeight(height: Double) {
        val map: MutableMap<String, Any> = mutableMapOf()
        map[VIEW_HEIGHT_LISTENER_PARAM] = height
        channel.invokeMethod(VIEW_HEIGHT_LISTENER, map)
    }

    private fun sendUpdatedPadding(left: Double, top: Double, right: Double, bottom: Double) {
        val map: MutableMap<String, Any> = mutableMapOf()
        map[VIEW_PADDING_LEFT] = left
        map[VIEW_PADDING_TOP] = top
        map[VIEW_PADDING_RIGHT] = right
        map[VIEW_PADDING_BOTTOM] = bottom
        channel.invokeMethod(VIEW_PADDING_LISTENER, map)
    }

    override fun getView(): Widget? = widget

    override fun dispose() {
        widget?.unregisterDimensionListener(this)
    }

    companion object {
        private const val VIEW_HEIGHT_LISTENER = "viewHeightListener"
        private const val VIEW_PADDING_LISTENER = "viewPaddingListener"
        private const val VIEW_HEIGHT_LISTENER_PARAM = "size"
        private const val VIEW_PADDING_LEFT = "left"
        private const val VIEW_PADDING_TOP = "top"
        private const val VIEW_PADDING_RIGHT = "right"
        private const val VIEW_PADDING_BOTTOM = "bottom"
        private const val OUT_OF_SYNC_HEIGHT_DIFF = 8
    }

    override fun onHeightChanged(height: Int) {
        if (abs(lastHeight - height) >= OUT_OF_SYNC_HEIGHT_DIFF) {
            lastHeight = height
            sendUpdatedHeight(lastHeight.toDouble())
        }
    }

    override fun onMarginChanged(start: Int, top: Int, end: Int, bottom: Int) {
        sendUpdatedPadding(start.toDouble(), top.toDouble(), end.toDouble(), bottom.toDouble())
    }
}