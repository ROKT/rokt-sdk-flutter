package com.rokt.rokt_sdk

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import io.flutter.plugin.platform.PlatformView

class RoktWidget(context: Context): PlatformView {

    private val view: View = LayoutInflater.from(context).inflate(R.layout.layout_rokt_widget, null)

    override fun getView() = view

    override fun dispose() {
    }
}