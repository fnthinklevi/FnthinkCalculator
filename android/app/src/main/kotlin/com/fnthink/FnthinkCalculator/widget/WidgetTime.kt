package com.fnthink.FnthinkCalculator.widget

import java.util.Locale

data class TimeState(
    val values: List<Int> = emptyList(),
    val operators: List<String> = emptyList(),
    val hours: Int = 0,
    val minutes: Int = 0,
    val seconds: Int = 0,
    val active: Int = 0,
    val buffer: String = "",
    val negative: Boolean = false,
    val result: Int? = null,
    val evaluated: Boolean = false,
) {
    private val entrySeconds: Int
        get() {
            val value = hours * 3600 + minutes * 60 + seconds
            return if (negative) -value else value
        }

    val displayExpression: String
        get() = when {
            evaluated -> "${expressionParts(includeEntry = false).joinToString(" ")} ="
            values.isEmpty() -> ""
            else -> expressionParts(includeEntry = true).joinToString(" ")
        }

    val displayValue: String
        get() = formatDuration(if (evaluated) result ?: 0 else entrySeconds)

    fun onKey(key: String): TimeState = when (key) {
        "C" -> TimeState()
        "BS" -> backspace()
        ":" -> if (evaluated) this else copy(active = (active + 1) % 3, buffer = "")
        "+" -> operator("+")
        "−" -> operator("−")
        "SIGN" -> if (evaluated) this else copy(negative = !negative)
        "=" -> evaluate()
        "00" -> digit('0').digit('0')
        else -> if (key.length == 1 && key[0].isDigit()) digit(key[0]) else this
    }

    private fun digit(value: Char): TimeState {
        val base = if (evaluated) TimeState() else this
        var nextBuffer = base.buffer
        if (nextBuffer.isEmpty()) nextBuffer = "0"
        if (nextBuffer == "0") {
            if (value == '0') return base.copy(buffer = "0")
            nextBuffer = value.toString()
        } else {
            val maxLength = if (base.active == 0) 5 else 2
            if (nextBuffer.length >= maxLength) return base
            nextBuffer += value
        }
        val segmentValue = nextBuffer.toIntOrNull() ?: 0
        return base.withSegment(segmentValue)
    }

    private fun operator(value: String): TimeState {
        if (evaluated) {
            val total = result ?: return this
            return TimeState(values = listOf(total), operators = listOf(value))
        }
        if (operators.isNotEmpty() && values.size == operators.size && buffer.isEmpty()) {
            val next = operators.toMutableList()
            next[next.lastIndex] = value
            return copy(operators = next)
        }
        return TimeState(values = values + entrySeconds, operators = operators + value)
    }

    private fun evaluate(): TimeState {
        if (evaluated || values.isEmpty() || operators.isEmpty()) return this
        val nextValues = if (values.size == operators.size) values + entrySeconds else values
        var total = nextValues.first()
        for (index in operators.indices) {
            total = if (operators[index] == "+") {
                total + nextValues[index + 1]
            } else {
                total - nextValues[index + 1]
            }
        }
        return TimeState(
            values = nextValues,
            operators = operators,
            result = total,
            evaluated = true,
        )
    }

    private fun backspace(): TimeState {
        if (evaluated) return TimeState()
        if (buffer.isEmpty()) {
            return withSegment(0)
        }
        val next = buffer.dropLast(1)
        return withSegment(next.toIntOrNull() ?: 0)
    }

    private fun withSegment(value: Int): TimeState {
        val (h, m, s) = normalize(
            if (active == 0) value else hours,
            if (active == 1) value else minutes,
            if (active == 2) value else seconds,
        )
        return copy(
            hours = h,
            minutes = m,
            seconds = s,
            buffer = segmentInputText(active, h, m, s),
        )
    }

    private fun expressionParts(includeEntry: Boolean): List<String> {
        val parts = mutableListOf<String>()
        for (index in values.indices) {
            parts += formatDuration(values[index])
            if (index < operators.size) parts += operators[index]
        }
        if (
            includeEntry &&
            operators.isNotEmpty() &&
            values.size == operators.size &&
            buffer.isNotEmpty()
        ) {
            parts += formatDuration(entrySeconds)
        }
        return parts
    }

    companion object {
        private fun normalize(hours: Int, minutes: Int, seconds: Int): Triple<Int, Int, Int> {
            val total = hours * 3600 + minutes * 60 + seconds
            return Triple(total / 3600, (total % 3600) / 60, total % 60)
        }

        private fun segmentInputText(active: Int, hours: Int, minutes: Int, seconds: Int): String {
            return when (active) {
                0 -> hours.toString()
                1 -> minutes.toString()
                else -> seconds.toString()
            }
        }

        fun formatDuration(totalSeconds: Int): String {
            val negative = totalSeconds < 0
            val absolute = kotlin.math.abs(totalSeconds)
            val hours = absolute / 3600
            val minutes = (absolute % 3600) / 60
            val seconds = absolute % 60
            return String.format(
                Locale.US,
                "%s%02d:%02d:%02d",
                if (negative) "-" else "",
                hours,
                minutes,
                seconds,
            )
        }
    }
}
