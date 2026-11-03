package com.fnthink.FnthinkCalculator.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import com.fnthink.FnthinkCalculator.R

private data class WidgetKey(
    val label: String,
    val token: String,
    val accent: Boolean = false,
)

private fun key(label: String, token: String, accent: Boolean = false) =
    WidgetKey(label, token, accent)

private val STANDARD_KEYS = listOf(
    key("7", "7"), key("8", "8"), key("9", "9"), key("÷", "÷", true),
    key("4", "4"), key("5", "5"), key("6", "6"), key("×", "×", true),
    key("1", "1"), key("2", "2"), key("3", "3"), key("−", "−", true),
    key("0", "0"), key(".", "."), key("+", "+", true), key("=", "=", true),
)

private val TIME_KEYS = listOf(
    key("7", "7"), key("8", "8"), key("9", "9"), key(":", ":", true),
    key("4", "4"), key("5", "5"), key("6", "6"), key("+", "+", true),
    key("1", "1"), key("2", "2"), key("3", "3"), key("−", "−", true),
    key("0", "0"), key("×", "×", true), key("÷", "÷", true), key("=", "=", true),
)

private val SCIENTIFIC_FUNCTION_PAGES = listOf(
    listOf(
        key("sin", "sin(", true), key("cos", "cos(", true),
        key("tan", "tan(", true), key("ln", "ln(", true),
    ),
    listOf(
        key("lg", "lg(", true), key("√", "√(", true),
        key("x²", "²", true), key("^", "^", true),
    ),
    listOf(
        key("π", "π", true), key("e", "e", true),
        key("(", "(", true), key(")", ")", true),
    ),
)

private fun scientificKeys(page: Int): List<WidgetKey> {
    return SCIENTIFIC_FUNCTION_PAGES[page % SCIENTIFIC_FUNCTION_PAGES.size] + STANDARD_KEYS
}

abstract class BaseCalculatorWidgetProvider : AppWidgetProvider() {
    protected abstract val mode: WidgetMode

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { render(context, it) }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        render(context, appWidgetId)
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        val store = WidgetStateStore(context)
        appWidgetIds.forEach { store.delete(it) }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action != ACTION_KEY) return
        val widgetId = intent.getIntExtra(EXTRA_WIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
        val token = intent.getStringExtra(EXTRA_KEY) ?: return
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) return
        val store = WidgetStateStore(context)
        when (mode) {
            WidgetMode.TIME -> store.saveTime(widgetId, store.loadTime(widgetId).onKey(token))
            else -> store.saveMath(
                widgetId,
                store.loadMath(widgetId).onKey(token, useDegrees(context)),
            )
        }
        render(context, widgetId)
    }

    private fun render(context: Context, widgetId: Int) {
        AppWidgetManager.getInstance(context)
            .updateAppWidget(widgetId, buildViews(context, widgetId))
    }

    private fun buildViews(context: Context, widgetId: Int): RemoteViews {
        val scientific = mode == WidgetMode.SCIENTIFIC
        val layout = if (scientific) {
            R.layout.widget_calculator_scientific
        } else {
            R.layout.widget_calculator
        }
        val views = RemoteViews(context.packageName, layout)
        val store = WidgetStateStore(context)
        val primary = context.getColor(R.color.widget_text_primary)
        val secondary = context.getColor(R.color.widget_text_secondary)
        val accent = context.getColor(R.color.widget_key_accent)
        val onAccent = context.getColor(R.color.widget_text_on_accent)

        val page = if (mode == WidgetMode.SCIENTIFIC) store.loadMath(widgetId).page else 0
        val expression: String
        val display: String
        val error: Boolean
        if (mode == WidgetMode.TIME) {
            val state = store.loadTime(widgetId)
            expression = state.displayExpression
            display = state.displayValue
            error = false
        } else {
            val state = store.loadMath(widgetId)
            expression = state.displayExpression
            display = state.displayValue
            error = state.error
        }

        views.setTextViewText(R.id.widget_expression, expression)
        views.setTextViewText(R.id.widget_display, display)
        views.setTextColor(R.id.widget_expression, secondary)
        views.setTextColor(R.id.widget_display, if (error) accent else primary)
        views.setTextColor(R.id.widget_clear, accent)
        views.setTextColor(R.id.widget_back, accent)
        views.setTextColor(R.id.widget_page, accent)

        val keys = when (mode) {
            WidgetMode.STANDARD -> STANDARD_KEYS
            WidgetMode.TIME -> TIME_KEYS
            WidgetMode.SCIENTIFIC -> scientificKeys(page)
        }
        val keyIds = if (scientific) SCIENTIFIC_KEY_IDS else KEY_IDS
        for (index in keys.indices) {
            val spec = keys[index]
            val id = keyIds[index]
            views.setTextViewText(id, spec.label)
            views.setContentDescription(id, spec.label)
            views.setTextColor(id, if (spec.accent) accent else primary)
            views.setInt(
                id,
                "setBackgroundResource",
                if (spec.token == "=") R.drawable.widget_key_accent else R.drawable.widget_key_background,
            )
            if (spec.token == "=") views.setTextColor(id, onAccent)
            views.setOnClickPendingIntent(id, keyIntent(context, widgetId, index, spec.token))
        }

        views.setOnClickPendingIntent(
            R.id.widget_clear,
            keyIntent(context, widgetId, SLOT_CLEAR, "C"),
        )
        views.setOnClickPendingIntent(
            R.id.widget_back,
            keyIntent(context, widgetId, SLOT_BACK, "BS"),
        )
        when (mode) {
            WidgetMode.SCIENTIFIC -> {
                views.setViewVisibility(R.id.widget_page, View.VISIBLE)
                views.setTextViewText(R.id.widget_page, "f${page + 1}")
                views.setContentDescription(
                    R.id.widget_page,
                    "函数页 ${page + 1}/3，点击切换",
                )
                views.setOnClickPendingIntent(
                    R.id.widget_page,
                    keyIntent(context, widgetId, SLOT_PAGE, "PAGE"),
                )
            }
            WidgetMode.TIME -> {
                views.setViewVisibility(R.id.widget_page, View.VISIBLE)
                views.setTextViewText(R.id.widget_page, "±")
                views.setContentDescription(R.id.widget_page, "正负号")
                views.setOnClickPendingIntent(
                    R.id.widget_page,
                    keyIntent(context, widgetId, SLOT_PAGE, "SIGN"),
                )
            }
            WidgetMode.STANDARD -> views.setViewVisibility(R.id.widget_page, View.GONE)
        }
        return views
    }

    private fun keyIntent(
        context: Context,
        widgetId: Int,
        slot: Int,
        token: String,
    ): PendingIntent {
        val intent = Intent(context, javaClass).apply {
            action = ACTION_KEY
            putExtra(EXTRA_WIDGET_ID, widgetId)
            putExtra(EXTRA_KEY, token)
        }
        return PendingIntent.getBroadcast(
            context,
            widgetId * 100 + slot,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun useDegrees(context: Context): Boolean {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        return prefs.getString("flutter.settings.angleUnit.v1", "degrees") != "radians"
    }

    companion object {
        const val ACTION_KEY = "com.fnthink.FnthinkCalculator.widget.KEY"
        const val EXTRA_WIDGET_ID = "widget_id"
        const val EXTRA_KEY = "key"
        private const val SLOT_CLEAR = 90
        private const val SLOT_BACK = 91
        private const val SLOT_PAGE = 92

        private val KEY_IDS = intArrayOf(
            R.id.widget_key_0,
            R.id.widget_key_1,
            R.id.widget_key_2,
            R.id.widget_key_3,
            R.id.widget_key_4,
            R.id.widget_key_5,
            R.id.widget_key_6,
            R.id.widget_key_7,
            R.id.widget_key_8,
            R.id.widget_key_9,
            R.id.widget_key_10,
            R.id.widget_key_11,
            R.id.widget_key_12,
            R.id.widget_key_13,
            R.id.widget_key_14,
            R.id.widget_key_15,
        )

        private val SCIENTIFIC_KEY_IDS = intArrayOf(
            R.id.widget_sci_key_0,
            R.id.widget_sci_key_1,
            R.id.widget_sci_key_2,
            R.id.widget_sci_key_3,
            R.id.widget_sci_key_4,
            R.id.widget_sci_key_5,
            R.id.widget_sci_key_6,
            R.id.widget_sci_key_7,
            R.id.widget_sci_key_8,
            R.id.widget_sci_key_9,
            R.id.widget_sci_key_10,
            R.id.widget_sci_key_11,
            R.id.widget_sci_key_12,
            R.id.widget_sci_key_13,
            R.id.widget_sci_key_14,
            R.id.widget_sci_key_15,
            R.id.widget_sci_key_16,
            R.id.widget_sci_key_17,
            R.id.widget_sci_key_18,
            R.id.widget_sci_key_19,
        )
    }
}

class StandardWidgetProvider : BaseCalculatorWidgetProvider() {
    override val mode = WidgetMode.STANDARD
}

class ScientificWidgetProvider : BaseCalculatorWidgetProvider() {
    override val mode = WidgetMode.SCIENTIFIC
}

class TimeWidgetProvider : BaseCalculatorWidgetProvider() {
    override val mode = WidgetMode.TIME
}
