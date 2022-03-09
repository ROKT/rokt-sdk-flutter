package com.rokt.rokt_sdk

import android.content.Context
import android.view.LayoutInflater
import com.rokt.roktsdk.Widget
import io.flutter.plugin.platform.PlatformView

class RoktWidget(context: Context): PlatformView {

    private val view: Widget =
        LayoutInflater.from(context).inflate(R.layout.layout_rokt_widget, null) as Widget

    override fun getView() = view

    override fun dispose() {
    }
}