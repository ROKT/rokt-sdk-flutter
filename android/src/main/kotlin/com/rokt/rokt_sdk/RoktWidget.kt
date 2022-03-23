package com.rokt.rokt_sdk

import android.content.Context
import android.content.res.Resources
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.rokt.rokt_sdk.MethodCallHandlerImpl.Companion.TAG
import com.rokt.roktsdk.Widget
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class RoktWidget(context: Context, messenger: BinaryMessenger, viewId: Int) : PlatformView {

    private val view =
        LayoutInflater.from(context).inflate(R.layout.layout_rokt_widget, null)

    val widget = view.findViewById<Widget>(R.id.rokt_widget)
    lateinit var parentLayout: View
    lateinit var offersContainer: View
    lateinit var footerLayout: View

    private val channel: MethodChannel = MethodChannel(messenger, "rokt_widget_$viewId")
    var isWidgetLoaded: Boolean = false

    init {
        setupListener()
    }

    private fun setupListener() {
        view.findViewById<Widget>(R.id.rokt_widget)
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
                        view.findViewById<Widget>(R.id.rokt_widget).findViewById(R.id.parentLayout)
                    if (view != null) {
                        /* send good amount of virtual height for the android view to lay out which has wrap content height,
                           Once we have a android view height, change the flutter view height to the same value
                         */
                        sendUpdatedHeight(INITIAL_VIRTUAL_HEIGHT)
                        isWidgetLoaded = true
                    }
                } else {
                    if (widget.height != (bottomWas - topWas) && (view.height.toDp - widget.height.toDp) > ORIENTATION_DIFF) {
                        sendUpdatedHeight((widget.height.toDp + widget.marginBottom.toDp + widget.marginTop.toDp).toDouble())
                    }
                }
            }
    }

    private fun setUpOffersContainer(view: View) {
        offersContainer = view
        offersContainer.addOnLayoutChangeListener { offerView, _, _, _, _, _, topWas, _, bottomWas ->
            if (offerView.height != (bottomWas - topWas)) {
                syncHeight()
            }
        }
    }

    private fun syncHeight() {
        if (isHeightOutOfSync()) {
            sendUpdatedHeight(INITIAL_VIRTUAL_HEIGHT)
        } else {
            sendUpdatedHeight((widget.height.toDp + widget.marginBottom.toDp + widget.marginTop.toDp).toDouble())
        }
    }

    private fun isHeightOutOfSync(): Boolean {
        return ::parentLayout.isInitialized && ::offersContainer.isInitialized && ::footerLayout.isInitialized &&
                ((offersContainer.height + footerLayout.height) - parentLayout.height > OUT_OF_SYNC_HEIGHT_DIFF)
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
        private const val INITIAL_VIRTUAL_HEIGHT = 550.0
        private const val VIEW_HEIGHT_LISTENER = "viewHeightListener"
        private const val VIEW_HEIGHT_LISTENER_PARAM = "size"
        private const val OUT_OF_SYNC_HEIGHT_DIFF = 8
        private const val ORIENTATION_DIFF = 50
    }
}

val Int.toDp: Int
    get() = (this / Resources.getSystem().displayMetrics.density).toInt()

val View.marginBottom: Int
    get() = (layoutParams as? ViewGroup.MarginLayoutParams)?.bottomMargin ?: 0

inline val View.marginTop: Int
    get() = (layoutParams as? ViewGroup.MarginLayoutParams)?.topMargin ?: 0