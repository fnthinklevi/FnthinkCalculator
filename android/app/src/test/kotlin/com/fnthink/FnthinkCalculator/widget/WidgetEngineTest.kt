package com.fnthink.FnthinkCalculator.widget

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class WidgetEngineTest {
    private fun math(keys: List<String>, degrees: Boolean = true): MathState {
        return keys.fold(MathState()) { state, key -> state.onKey(key, degrees) }
    }

    private fun time(keys: List<String>): TimeState {
        return keys.fold(TimeState()) { state, key -> state.onKey(key) }
    }

    @Test
    fun mathBasics() {
        assertEquals("3", math(listOf("1", "+", "2", "=")).result)
        assertEquals("0.3", math(listOf("0", ".", "1", "+", "0", ".", "2", "=")).result)
        assertEquals("8", math(listOf("2", "+", "3", "×", "2", "=")).result)
        assertEquals("2.5", math(listOf("1", "0", "÷", "4", "=")).result)
        assertEquals("9", math(listOf("(", "1", "+", "2", ")", "×", "3", "=")).result)
        assertEquals("-3", math(listOf("−", "5", "+", "2", "=")).result)
        assertEquals("0.5", math(listOf("5", "0", "%", "=")).result)
        assertEquals("1,024", math(listOf("2", "^", "1", "0", "=")).result)
    }

    @Test
    fun mathFunctions() {
        assertEquals("3", math(listOf("√(", "9", ")", "=")).result)
        assertEquals("0.5", math(listOf("sin(", "3", "0", ")", "=")).result)
        assertEquals("2", math(listOf("lg(", "1", "0", "0", ")", "=")).result)
        assertEquals("1", math(listOf("ln(", "e", ")", "=")).result)
        assertEquals("1", math(listOf("sin(", "π", "÷", "2", ")", "="), degrees = false).result)
        assertEquals("0.5", math(listOf("sin(", "3", "0", "=")).result)
        assertEquals("0.5", math(listOf("5", "0", "%", "=")).result)
        assertEquals("120", math(listOf("5", "!", "=")).result)
        assertEquals("0.25", math(listOf("1", "÷", "(", "4", "=")).result)
    }

    @Test
    fun mathStateTransitions() {
        val evaluated = math(listOf("1", "+", "2", "="))
        assertEquals("3", evaluated.displayValue)
        assertEquals("1+2 =", evaluated.displayExpression)

        val fresh = evaluated.onKey("4", true)
        assertEquals("4", fresh.expression)
        assertEquals(false, fresh.evaluated)

        val chained = evaluated.onKey("+", true)
        assertEquals("3+", chained.expression)

        val paged = MathState().onKey("PAGE", true)
        assertEquals(1, paged.page)
        assertEquals(2, paged.onKey("PAGE", true).page)
        assertEquals(3, paged.onKey("PAGE", true).onKey("PAGE", true).page)
        assertEquals(
            0,
            paged.onKey("PAGE", true).onKey("PAGE", true).onKey("PAGE", true).page,
        )
    }

    @Test
    fun mathErrors() {
        assertNull(WidgetMath.evaluate("1÷0", true))
        assertNull(WidgetMath.evaluate("1+", true))
        assertEquals("错误", math(listOf("1", "÷", "0", "=")).displayValue)
    }

    @Test
    fun timeAdditionAndChain() {
        assertEquals(
            "02:15:00",
            time(listOf("1", ":", "3", "0", "+", ":", "4", "5", "=")).displayValue,
        )
        val chained = time(
            listOf(
                "1", "2", ":", "0", "0", "+",
                "1", "2", ":", "0", "1", "+",
                "1", "3", ":", "0", "1", "=",
            ),
        )
        assertEquals("37:02:00", chained.displayValue)
        assertEquals(
            "12:00:00 + 12:01:00 + 13:01:00 =",
            chained.displayExpression,
        )
    }

    @Test
    fun timeSubtractionCanBeNegative() {
        assertEquals(
            "-00:30:00",
            time(listOf("0", ":", "3", "0", "−", "1", ":", "0", "=")).displayValue,
        )
    }

    @Test
    fun timeNormalizesSixty() {
        assertEquals(
            "97:04:00",
            time(listOf("9", "6", ":", "6", "4")).displayValue,
        )
    }

    @Test
    fun timeMultiplyAndDivide() {
        assertEquals(
            "02:00:00",
            time(listOf("1", ":", "0", "0", "×", "2", "=")).displayValue,
        )
        assertEquals(
            "00:15:00",
            time(listOf("1", ":", "0", "0", "÷", "4", "=")).displayValue,
        )
        assertEquals(
            "02:00:00",
            time(listOf("1", ":", "0", "0", "+", "0", ":", "3", "0", "×", "2", "="))
                .displayValue,
        )
        assertEquals(
            "01:30:00",
            time(listOf("1", ":", "0", "0", "×", "1", ":", "5", "=")).displayValue,
        )
    }

    @Test
    fun timeDivideByZeroShowsError() {
        assertEquals(
            "错误",
            time(listOf("1", ":", "0", "0", "÷", "0", "=")).displayValue,
        )
    }

    @Test
    fun timeDivideRoundsHalfUp() {
        assertEquals(
            "00:00:01",
            time(listOf("0", ":", "0", ":", "2", "÷", "3", "=")).displayValue,
        )
    }

    @Test
    fun timeResultCanContinueMultiply() {
        val first = time(listOf("1", ":", "0", "0", "×", "2", "="))
        assertEquals("02:00:00", first.displayValue)
        val second = first.onKey("×").onKey("3").onKey("=")
        assertEquals("06:00:00", second.displayValue)
    }

    @Test
    fun timeBackspace() {
        val state = time(listOf("3", "2", "BS"))
        assertEquals("03:00:00", state.displayValue)
        assertEquals("3", state.buffer)
    }
}
