import 'dart:math' as math;

import 'math_error.dart';
import 'rational.dart';

sealed class CalcValue {
  const CalcValue();

  bool get isZero;
  double toDouble();
}

class RationalValue extends CalcValue {
  const RationalValue(this.value);

  final BigRational value;

  @override
  bool get isZero => value.isZero;

  @override
  double toDouble() => value.toDouble();

  @override
  String toString() => value.toString();
}

class DoubleValue extends CalcValue {
  const DoubleValue(this.value);

  final double value;

  @override
  bool get isZero => value == 0;

  @override
  double toDouble() => value;

  @override
  String toString() => '$value';
}

CalcValue add(CalcValue a, CalcValue b) {
  if (a is RationalValue && b is RationalValue) {
    return RationalValue(a.value + b.value);
  }
  return _finite(a.toDouble() + b.toDouble());
}

CalcValue subtract(CalcValue a, CalcValue b) {
  if (a is RationalValue && b is RationalValue) {
    return RationalValue(a.value - b.value);
  }
  return _finite(a.toDouble() - b.toDouble());
}

CalcValue multiply(CalcValue a, CalcValue b) {
  if (a is RationalValue && b is RationalValue) {
    return RationalValue(a.value * b.value);
  }
  return _finite(a.toDouble() * b.toDouble());
}

CalcValue divide(CalcValue a, CalcValue b) {
  if (b.isZero) {
    throw const MathException(MathErrorKind.divideByZero, '不能除以 0');
  }
  if (a is RationalValue && b is RationalValue) {
    return RationalValue(a.value / b.value);
  }
  return _finite(a.toDouble() / b.toDouble());
}

CalcValue negate(CalcValue value) {
  if (value is RationalValue) {
    return RationalValue(-value.value);
  }
  return DoubleValue(-value.toDouble());
}

CalcValue percent(CalcValue value) {
  if (value is RationalValue) {
    return RationalValue(value.value / BigRational.fromInt(100));
  }
  return DoubleValue(value.toDouble() / 100);
}

CalcValue absValue(CalcValue value) {
  if (value is RationalValue) {
    return RationalValue(value.value.abs);
  }
  return DoubleValue(value.toDouble().abs());
}

CalcValue powValue(CalcValue base, CalcValue exponent) {
  final integerExponent = _asIntegerOrNull(exponent);
  if (integerExponent != null) {
    if (integerExponent.abs() > BigInt.from(10000)) {
      throw const MathException(MathErrorKind.tooLarge, '指数过大');
    }
    if (integerExponent.isNegative && base.isZero) {
      throw const MathException(MathErrorKind.divideByZero, '不能除以 0');
    }
    if (base is RationalValue) {
      return RationalValue(base.value.pow(integerExponent.toInt()));
    }
    final result = _mathPow(base.toDouble(), integerExponent.toDouble());
    return _finite(result);
  }

  final baseDouble = base.toDouble();
  final exponentDouble = exponent.toDouble();
  if (baseDouble < 0) {
    throw const MathException(MathErrorKind.domain, '负数不能开非整数次方');
  }
  if (baseDouble == 0 && exponentDouble <= 0) {
    throw const MathException(MathErrorKind.divideByZero, '不能除以 0');
  }
  return _finite(_mathPow(baseDouble, exponentDouble));
}

CalcValue factorialValue(CalcValue value) {
  final integer = _asIntegerOrNull(value);
  if (integer == null || integer.isNegative) {
    throw const MathException(MathErrorKind.domain, '阶乘只支持非负整数');
  }
  if (integer > BigInt.from(1000)) {
    throw const MathException(MathErrorKind.tooLarge, '阶乘数值过大');
  }
  var result = BigInt.one;
  for (var i = BigInt.two; i <= integer; i += BigInt.one) {
    result *= i;
  }
  return RationalValue(BigRational.fromBigInt(result));
}

BigInt? _asIntegerOrNull(CalcValue value) {
  if (value is RationalValue) {
    return value.value.isInteger ? value.value.toBigInt() : null;
  }
  if (value is DoubleValue) {
    final number = value.value;
    if (!number.isFinite || number != number.roundToDouble()) {
      return null;
    }
    if (number.abs() > 1e15) {
      return null;
    }
    return BigInt.from(number.toInt());
  }
  return null;
}

double _mathPow(double base, double exponent) {
  final result = base == 0 && exponent == 0
      ? 1.0
      : math.pow(base, exponent).toDouble();
  if (!result.isFinite) {
    throw const MathException(MathErrorKind.overflow, '结果超出范围');
  }
  return result;
}

DoubleValue _finite(double value) {
  if (!value.isFinite) {
    throw const MathException(MathErrorKind.overflow, '结果超出范围');
  }
  return DoubleValue(value);
}
