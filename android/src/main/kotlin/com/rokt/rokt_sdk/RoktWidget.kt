package com.rokt.rokt_sdk

import android.content.Context
import android.content.res.Resources
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.rokt.roktsdk.Widget
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import kotlin.math.abs

class RoktWidget(context: Context, messenger: BinaryMessenger, viewId: Int) : PlatformView {

    private val view =
        LayoutInflater.from(context).inflate(R.layout.layout_rokt_widget, null)

    val widget = view.findViewById<Widget>(R.id.widget1)
    lateinit var parentLayout: View
    lateinit var offersContainer: View
    lateinit var footerLayout: View

    private val channel: MethodChannel = MethodChannel(messenger, "rokt_widget_$viewId")
    var isWidgetLoaded: Boolean = false

    init {
        setupListener()
    }

    private fun setupListener() {
        view.findViewById<Widget>(R.id.widget1)
            .addOnLayoutChangeListener { widget, _, _, _, _, _, topWas, _, bottomWas ->
                if (!::parentLayout.isInitialized) {
                    view.findViewById<View?>(R.id.parentLayout)?.let {
                        parentLayout = it
                    }
                }

                if (!::offersContainer.isInitialized) {
                    view.findViewById<View?>(R.id.offers_container)?.let {
                        setUpOffersContainer(it)
                    }
                }

                if (!::footerLayout.isInitialized) {
                    view.findViewById<View?>(R.id.footerView)?.let {
                        footerLayout = it
                    }
                }

                if (!isWidgetLoaded) {
                    val view: View? =
                        view.findViewById<Widget>(R.id.widget1).findViewById(R.id.parentLayout)
                    Log.d(TAG, "isWidgetLoaded ?? $isWidgetLoaded")
                    if (view != null) {
                        /* send good amount of virtual height for the android view to lay out which has wrap content height,
                           Once we have a android view height, change the flutter view height to the same value
                         */
                        sendUpdatedHeight(INITIAL_VIRTUAL_HEIGHT)
                        isWidgetLoaded = true
                    }
                } else if (abs(widget.height - (bottomWas - topWas)) >= MINIMUM_HEIGHT_CHANGE) {
                    Log.d(
                        TAG, "widget height has changed !! " +
                                "${widget.height.toDp} ${widget.marginBottom.toDp} ${widget.marginTop.toDp}}"
                    )
                    Log.d(TAG, "send updated height")
                    sendUpdatedHeight((widget.height.toDp + widget.marginBottom.toDp + widget.marginTop.toDp).toDouble())
                }
            }
    }

    private fun setUpOffersContainer(view: View) {
        offersContainer = view
        offersContainer.addOnLayoutChangeListener { view, _, _, _, _, _, topWas, _, bottomWas ->
            if (view.height != (bottomWas - topWas)) {
                Log.d(TAG, "change in offer container height ${view.height}")
                syncHeight()
            }
        }
    }

    private fun syncHeight() {
        if (::parentLayout.isInitialized && ::offersContainer.isInitialized && ::footerLayout.isInitialized) {
            if (abs(parentLayout.height - (offersContainer.height + footerLayout.height)) > OUT_OF_SYNC_HEIGHT_DIFF) {
                Log.d(TAG, "send virtual updated height ${parentLayout.height} ${offersContainer.height} ${footerLayout.height}")
                sendUpdatedHeight(INITIAL_VIRTUAL_HEIGHT)
            }
        }
    }

    private fun sendUpdatedHeight(height: Double) {
        val map: MutableMap<String, Any> = mutableMapOf()
        map[VIEW_HEIGHT_LISTENER_PARAM] = height
        channel.invokeMethod(VIEW_HEIGHT_LISTENER, map)
    }

    override fun getView() = view

    override fun dispose() {
    }

    companion object {
        private const val INITIAL_VIRTUAL_HEIGHT = 450.0
        private const val VIEW_HEIGHT_LISTENER = "viewHeightListener"
        private const val VIEW_HEIGHT_LISTENER_PARAM = "size"
        private const val MINIMUM_HEIGHT_CHANGE = 8
        private const val OUT_OF_SYNC_HEIGHT_DIFF = 40
        private const val TAG = "RoktWidget"
    }
}

val Int.toDp: Int
    get() = (this / Resources.getSystem().displayMetrics.density).toInt()

val View.marginBottom: Int
    get() = (layoutParams as? ViewGroup.MarginLayoutParams)?.bottomMargin ?: 0

inline val View.marginTop: Int
    get() = (layoutParams as? ViewGroup.MarginLayoutParams)?.topMargin ?: 0