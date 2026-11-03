package com.fnthink.FnthinkCalculator.widget

import android.content.Context

enum class WidgetMode {
    STANDARD,
    SCIENTIFIC,
    TIME,
}

class WidgetStateStore(context: Context) {
    private val prefs = context.applicationContext.getSharedPreferences(
        PREFERENCES,
        Context.MODE_PRIVATE,
    )

    fun loadMath(widgetId: Int): MathState {
        val parts = prefs.getString(mathKey(widgetId), null)?.split(SEP) ?: return MathState()
        if (parts.size != 5) return MathState()
        return MathState(
            expression = parts[0],
            result = parts[1],
            evaluated = parts[2] == "1",
            error = parts[3] == "1",
            page = parts[4].toIntOrNull() ?: 0,
        )
    }

    fun saveMath(widgetId: Int, state: MathState) {
        val raw = listOf(
            state.expression,
            state.result,
            if (state.evaluated) "1" else "0",
            if (state.error) "1" else "0",
            state.page.toString(),
        ).joinToString(SEP)
        prefs.edit().putString(mathKey(widgetId), raw).apply()
    }

    fun loadTime(widgetId: Int): TimeState {
        val parts = prefs.getString(timeKey(widgetId), null)?.split(SEP) ?: return TimeState()
        if (parts.size != 12) return TimeState()
        return TimeState(
            operands = parts[0].split(",").filter { it.isNotEmpty() },
            operators = parts[1].split(",").filter { it.isNotEmpty() },
            hours = parts[2].toIntOrNull() ?: 0,
            minutes = parts[3].toIntOrNull() ?: 0,
            seconds = parts[4].toIntOrNull() ?: 0,
            active = parts[5].toIntOrNull() ?: 0,
            buffer = parts[6],
            scalarBuffer = parts[7],
            negative = parts[8] == "1",
            result = parts[9].toIntOrNull(),
            evaluated = parts[10] == "1",
            error = parts[11] == "1",
        )
    }

    fun saveTime(widgetId: Int, state: TimeState) {
        val raw = listOf(
            state.operands.joinToString(","),
            state.operators.joinToString(","),
            state.hours.toString(),
            state.minutes.toString(),
            state.seconds.toString(),
            state.active.toString(),
            state.buffer,
            state.scalarBuffer,
            if (state.negative) "1" else "0",
            state.result?.toString() ?: "",
            if (state.evaluated) "1" else "0",
            if (state.error) "1" else "0",
        ).joinToString(SEP)
        prefs.edit().putString(timeKey(widgetId), raw).apply()
    }

    fun delete(widgetId: Int) {
        prefs.edit()
            .remove(mathKey(widgetId))
            .remove(timeKey(widgetId))
            .apply()
    }

    private fun mathKey(widgetId: Int) = "math_$widgetId"

    private fun timeKey(widgetId: Int) = "time_$widgetId"

    private companion object {
        const val PREFERENCES = "fnthink_widget_state"
        const val SEP = "\u001F"
    }
}
