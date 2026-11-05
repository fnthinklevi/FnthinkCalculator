package com.fnthink.FnthinkCalculator.widget

import java.math.BigDecimal
import java.math.MathContext
import java.math.RoundingMode

object WidgetMath {
    private val MC = MathContext(16, RoundingMode.HALF_UP)
    private val PI = BigDecimal(Math.PI).round(MC)
    private val E = BigDecimal(Math.E).round(MC)

    fun evaluate(expression: String, degrees: Boolean): BigDecimal? {
        if (expression.isBlank()) return null
        return try {
            Parser(expression, degrees).parse()
        } catch (_: Exception) {
            null
        }
    }

    fun format(value: BigDecimal): String {
        var rounded = value.round(MC).stripTrailingZeros()
        if (rounded.scale() < 0) rounded = rounded.setScale(0)
        if (rounded.scale() > 10) {
            rounded = rounded.setScale(10, RoundingMode.HALF_UP).stripTrailingZeros()
        }
        var plain = rounded.toPlainString()
        if (plain.length > 20) {
            plain = rounded.round(MathContext(10, RoundingMode.HALF_UP)).toString()
        }
        val negative = plain.startsWith("-")
        val body = if (negative) plain.substring(1) else plain
        val dot = body.indexOf('.')
        val integer = if (dot >= 0) body.substring(0, dot) else body
        val fraction = if (dot >= 0) body.substring(dot) else ""
        val grouped = integer.reversed().chunked(3).joinToString(",").reversed()
        return (if (negative) "-" else "") + grouped + fraction
    }

    private class Parser(private val source: String, private val degrees: Boolean) {
        private var index = 0

        fun parse(): BigDecimal {
            val value = expression()
            skipSpaces()
            require(index == source.length)
            return value
        }

        private fun expression(): BigDecimal {
            var value = term()
            while (true) {
                skipSpaces()
                when (peek()) {
                    '+' -> {
                        index++
                        value = value.add(term(), MC)
                    }
                    '-', '−' -> {
                        index++
                        value = value.subtract(term(), MC)
                    }
                    else -> return value
                }
            }
        }

        private fun term(): BigDecimal {
            var value = unary()
            while (true) {
                skipSpaces()
                when (peek()) {
                    '×', '*' -> {
                        index++
                        value = value.multiply(unary(), MC)
                    }
                    '÷', '/' -> {
                        index++
                        val divisor = unary()
                        if (divisor.signum() == 0) throw ArithmeticException("div0")
                        value = value.divide(divisor, MC)
                    }
                    else -> return value
                }
            }
        }

        private fun unary(): BigDecimal {
            skipSpaces()
            return when (peek()) {
                '-', '−' -> {
                    index++
                    unary().negate()
                }
                '+' -> {
                    index++
                    unary()
                }
                else -> power()
            }
        }

        private fun power(): BigDecimal {
            val base = postfix()
            skipSpaces()
            if (peek() != '^') return base
            index++
            return pow(base, unary())
        }

        private fun postfix(): BigDecimal {
            var value = primary()
            while (true) {
                skipSpaces()
                when (peek()) {
                    '%' -> {
                        index++
                        value = value.divide(BigDecimal(100), MC)
                    }
                    '²' -> {
                        index++
                        value = value.multiply(value, MC)
                    }
                    '!' -> {
                        index++
                        value = factorial(value)
                    }
                    else -> return value
                }
            }
        }

        private fun primary(): BigDecimal {
            skipSpaces()
            if (index >= source.length) throw IllegalArgumentException("missing")
            return when (val c = source[index]) {
                '(' -> {
                    index++
                    val value = expression()
                    expect(')')
                    value
                }
                'π' -> {
                    index++
                    PI
                }
                'e' -> {
                    index++
                    E
                }
                '√' -> {
                    index++
                    val value = unary()
                    if (value.signum() < 0) throw ArithmeticException("sqrt")
                    BigDecimal(Math.sqrt(value.toDouble())).round(MC)
                }
                else -> {
                    if (c.isDigit() || c == '.') return number()
                    for (name in FUNCTIONS) {
                        if (source.startsWith(name, index)) {
                            index += name.length
                            skipSpaces()
                            val value = if (peek() == '(') {
                                index++
                                val inner = expression()
                                expect(')')
                                inner
                            } else {
                                unary()
                            }
                            return function(name, value)
                        }
                    }
                    throw IllegalArgumentException("bad token")
                }
            }
        }

        private fun number(): BigDecimal {
            val start = index
            var hasDot = false
            while (index < source.length) {
                val c = source[index]
                if (c.isDigit()) {
                    index++
                } else if (c == '.' && !hasDot) {
                    hasDot = true
                    index++
                } else {
                    break
                }
            }
            if (start == index) throw IllegalArgumentException("number")
            return BigDecimal(source.substring(start, index))
        }

        private fun function(name: String, value: BigDecimal): BigDecimal {
            val x = value.toDouble()
            val angle = if (degrees) Math.toRadians(x) else x
            val result = when (name) {
                "sin" -> Math.sin(angle)
                "cos" -> Math.cos(angle)
                "tan" -> Math.tan(angle)
                "ln" -> Math.log(x)
                "lg" -> Math.log10(x)
                else -> throw IllegalArgumentException("fn")
            }
            if (!result.isFinite()) throw ArithmeticException("fn")
            return BigDecimal.valueOf(result).round(MathContext(12, RoundingMode.HALF_UP))
        }

        private fun factorial(value: BigDecimal): BigDecimal {
            val stripped = value.stripTrailingZeros()
            if (stripped.scale() > 0 || stripped.signum() < 0) {
                throw ArithmeticException("factorial")
            }
            val n = stripped.toInt()
            if (n > 170) throw ArithmeticException("factorial")
            var result = BigDecimal.ONE
            for (i in 2..n) result = result.multiply(BigDecimal(i), MC)
            return result
        }

        private fun pow(base: BigDecimal, exponent: BigDecimal): BigDecimal {
            val stripped = exponent.stripTrailingZeros()
            if (stripped.scale() <= 0 && stripped.abs() <= BigDecimal(9999)) {
                val n = stripped.toInt()
                return if (n >= 0) {
                    base.pow(n, MC)
                } else {
                    BigDecimal.ONE.divide(base.pow(-n, MC), MC)
                }
            }
            val result = Math.pow(base.toDouble(), exponent.toDouble())
            if (!result.isFinite()) throw ArithmeticException("pow")
            return BigDecimal.valueOf(result).round(MathContext(12, RoundingMode.HALF_UP))
        }

        private fun expect(c: Char) {
            skipSpaces()
            require(peek() == c)
            index++
        }

        private fun peek(): Char = if (index < source.length) source[index] else '\u0000'

        private fun skipSpaces() {
            while (index < source.length && source[index].isWhitespace()) index++
        }
    }

    private val FUNCTIONS = listOf("sin", "cos", "tan", "ln", "lg")
}

data class MathState(
    val expression: String = "",
    val result: String = "",
    val evaluated: Boolean = false,
    val error: Boolean = false,
    val page: Int = 0,
) {
    val displayExpression: String
        get() = if (evaluated) "$expression =" else expression

    val displayValue: String
        get() = when {
            error -> "错误"
            evaluated -> result
            expression.isEmpty() -> "0"
            else -> expression
        }

    fun onKey(key: String, degrees: Boolean): MathState = when (key) {
        "C" -> MathState(page = page)
        "BS" -> if (evaluated) MathState(page = page) else copy(expression = expression.dropLast(1))
        "PAGE" -> copy(page = (page + 1) % 4)
        "=" -> evaluate(degrees)
        else -> insert(key)
    }

    private fun evaluate(degrees: Boolean): MathState {
        if (evaluated || expression.isEmpty()) return this
        val open = expression.count { it == '(' }
        val close = expression.count { it == ')' }
        val balanced = expression + ")".repeat((open - close).coerceAtLeast(0))
        val value = WidgetMath.evaluate(balanced, degrees)
            ?: return copy(error = true, evaluated = true, result = "错误")
        return copy(result = WidgetMath.format(value), evaluated = true, error = false)
    }

    private fun insert(key: String): MathState {
        if (error) return MathState(page = page)
        if (evaluated) {
            return if (key in OPERATOR_TOKENS) {
                MathState(expression = result + key, page = page)
            } else {
                MathState(expression = key, page = page)
            }
        }
        val next = if (
            key in OPERATOR_TOKENS &&
            expression.isNotEmpty() &&
            expression.last().toString() in OPERATOR_TOKENS
        ) {
            expression.dropLast(1) + key
        } else {
            expression + key
        }
        return copy(expression = next)
    }

    companion object {
        private val OPERATOR_TOKENS = setOf("+", "−", "×", "÷", "^", "%", "²")
    }
}
