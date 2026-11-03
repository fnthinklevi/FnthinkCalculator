package com.fnthink.FnthinkCalculator.widget

import java.math.BigDecimal
import java.math.MathContext
import java.math.RoundingMode
import java.util.Locale

data class TimeState(
    val operands: List<String> = emptyList(),
    val operators: List<String> = emptyList(),
    val hours: Int = 0,
    val minutes: Int = 0,
    val seconds: Int = 0,
    val active: Int = 0,
    val buffer: String = "",
    val scalarBuffer: String = "",
    val negative: Boolean = false,
    val result: Int? = null,
    val evaluated: Boolean = false,
    val error: Boolean = false,
) {
    private val entrySeconds: Int
        get() {
            val value = hours * 3600 + minutes * 60 + seconds
            return if (negative) -value else value
        }

    private val isScalarEntry: Boolean
        get() = !evaluated && !error && operators.isNotEmpty() &&
            (operators.last() == "×" || operators.last() == "÷")

    val displayExpression: String
        get() {
            val parts = expressionParts(includeEntry = !evaluated)
            return when {
                error -> "${parts.joinToString(" ")} =".trim()
                evaluated -> "${parts.joinToString(" ")} ="
                else -> parts.joinToString(" ")
            }
        }

    val displayValue: String
        get() = when {
            error -> "错误"
            evaluated -> formatDuration(result ?: 0)
            isScalarEntry -> scalarBuffer.ifEmpty { "0" }
            else -> formatDuration(entrySeconds)
        }

    fun onKey(key: String): TimeState = when (key) {
        "C" -> TimeState()
        "BS" -> backspace()
        ":" -> colonOrDot()
        "+" -> operator("+")
        "−" -> operator("−")
        "×" -> operator("×")
        "÷" -> operator("÷")
        "SIGN" -> sign()
        "=" -> evaluate()
        "00" -> digit('0').digit('0')
        else -> if (key.length == 1 && key[0].isDigit()) digit(key[0]) else this
    }

    private fun digit(value: Char): TimeState {
        val base = if (evaluated || error) TimeState() else this
        if (base.isScalarEntry) {
            return base.copy(scalarBuffer = appendScalarDigit(base.scalarBuffer, value))
        }
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

    private fun appendScalarDigit(buffer: String, value: Char): String {
        if (buffer.length >= 12) return buffer
        if (buffer.isEmpty()) return if (value == '0') "0" else value.toString()
        if (buffer == "0") return if (value == '0') buffer else value.toString()
        return buffer + value
    }

    private fun colonOrDot(): TimeState {
        if (evaluated || error) return TimeState(active = 1)
        if (isScalarEntry) {
            if (scalarBuffer.contains('.') || scalarBuffer.length >= 12) return this
            return copy(
                scalarBuffer = if (scalarBuffer.isEmpty()) "0." else "$scalarBuffer.",
            )
        }
        return copy(active = (active + 1) % 3, buffer = "")
    }

    private fun operator(value: String): TimeState {
        if (error) {
            return TimeState(
                operands = listOf(durationToken(0)),
                operators = listOf(value),
            )
        }
        if (evaluated) {
            val total = result ?: return this
            return TimeState(
                operands = listOf(durationToken(total)),
                operators = listOf(value),
            )
        }
        val emptyEntry = if (isScalarEntry) scalarBuffer.isEmpty() else buffer.isEmpty()
        if (operators.isNotEmpty() && operands.size == operators.size && emptyEntry) {
            val next = operators.toMutableList()
            next[next.lastIndex] = value
            return copy(operators = next)
        }
        return TimeState(
            operands = operands + currentOperand(),
            operators = operators + value,
        )
    }

    private fun currentOperand(): String {
        if (isScalarEntry) {
            val text = scalarBuffer.ifEmpty { "0" }
            val value = text.toBigDecimalOrNull()
            return scalarToken(value ?: BigDecimal.ZERO)
        }
        return durationToken(entrySeconds)
    }

    private fun evaluate(): TimeState {
        if (evaluated || error || operands.isEmpty() || operators.isEmpty()) return this
        val values = operands.toMutableList()
        val pending = operators.toMutableList()
        if (values.size == pending.size) {
            values.add(currentOperand())
        }
        if (values.size != pending.size + 1) return copy(error = true, evaluated = true)

        val working = values.toMutableList()
        var index = 0
        while (index < pending.size) {
            val symbol = pending[index]
            if (symbol != "×" && symbol != "÷") {
                index++
                continue
            }
            val left = parseDuration(working[index]) ?: return copy(error = true, evaluated = true)
            val right = parseScalar(working[index + 1])
                ?: return copy(error = true, evaluated = true)
            if (right.signum() < 0) return copy(error = true, evaluated = true)
            if (symbol == "÷" && right.signum() == 0) {
                return copy(error = true, evaluated = true)
            }
            val seconds = if (symbol == "×") {
                left.multiply(right)
            } else {
                left.divide(right, MathContext(20, RoundingMode.HALF_UP))
            }
            working[index] = durationToken(seconds)
            working.removeAt(index + 1)
            pending.removeAt(index)
        }

        var total = parseDuration(working.first()) ?: return copy(error = true, evaluated = true)
        for (i in pending.indices) {
            val right = parseDuration(working[i + 1])
                ?: return copy(error = true, evaluated = true)
            total = if (pending[i] == "+") total.add(right) else total.subtract(right)
        }
        val rounded = total.setScale(0, RoundingMode.HALF_UP)
        if (rounded.abs() > BigDecimal("1000000000000")) {
            return copy(error = true, evaluated = true)
        }
        return TimeState(
            operands = values,
            operators = operators,
            result = rounded.toInt(),
            evaluated = true,
        )
    }

    private fun backspace(): TimeState {
        if (evaluated || error) return TimeState()
        if (isScalarEntry) {
            val next = scalarBuffer.dropLast(1).ifEmpty { "0" }
            return copy(scalarBuffer = next)
        }
        if (buffer.isEmpty()) return withSegment(0)
        val next = buffer.dropLast(1)
        return withSegment(next.toIntOrNull() ?: 0)
    }

    private fun sign(): TimeState {
        if (isScalarEntry) return this
        if (evaluated || error) return TimeState(negative = true)
        return copy(negative = !negative)
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
        for (index in operands.indices) {
            parts += displayOperand(operands[index])
            if (index < operators.size) parts += operators[index]
        }
        if (includeEntry && operators.isNotEmpty() && operands.size == operators.size) {
            if (isScalarEntry) {
                if (scalarBuffer.isNotEmpty()) parts += scalarBuffer
            } else if (buffer.isNotEmpty()) {
                parts += formatDuration(entrySeconds)
            }
        }
        return parts
    }

    private fun displayOperand(token: String): String {
        val seconds = parseDuration(token)
        if (seconds != null) {
            return formatDuration(seconds.setScale(0, RoundingMode.HALF_UP).toInt())
        }
        parseScalar(token)?.let { return it.stripTrailingZeros().toPlainString() }
        return "0"
    }

    companion object {
        private const val DURATION_PREFIX = "D:"
        private const val SCALAR_PREFIX = "S:"

        fun durationToken(seconds: Int): String = "$DURATION_PREFIX$seconds"

        fun durationToken(seconds: BigDecimal): String = "$DURATION_PREFIX$seconds"

        fun scalarToken(value: BigDecimal): String = "$SCALAR_PREFIX$value"

        private fun parseDuration(token: String): BigDecimal? {
            return if (token.startsWith(DURATION_PREFIX)) {
                token.removePrefix(DURATION_PREFIX).toBigDecimalOrNull()
            } else {
                null
            }
        }

        private fun parseScalar(token: String): BigDecimal? {
            return if (token.startsWith(SCALAR_PREFIX)) {
                token.removePrefix(SCALAR_PREFIX).toBigDecimalOrNull()
            } else {
                null
            }
        }

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
