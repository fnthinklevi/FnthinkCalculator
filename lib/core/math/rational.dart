import 'math_error.dart';

/// Exact rational number backed by BigInt.
class BigRational implements Comparable<BigRational> {
  BigRational._(this.n, this.d);

  factory BigRational(BigInt numerator, [BigInt? denominator]) {
    final den = denominator ?? BigInt.one;
    if (den == BigInt.zero) {
      throw const MathException(MathErrorKind.divideByZero, '不能除以0');
    }
    var num = numerator;
    var den2 = den;
    if (den2.isNegative) {
      num = -num;
      den2 = -den2;
    }
    if (num == BigInt.zero) {
      return BigRational._(BigInt.zero, BigInt.one);
    }
    final divisor = num.abs().gcd(den2);
    if (divisor > BigInt.one) {
      num = num ~/ divisor;
      den2 = den2 ~/ divisor;
    }
    return BigRational._(num, den2);
  }

  factory BigRational.fromInt(int numerator, [int denominator = 1]) {
    return BigRational(BigInt.from(numerator), BigInt.from(denominator));
  }

  factory BigRational.fromBigInt(BigInt value) {
    return BigRational(value, BigInt.one);
  }

  static final zero = BigRational.fromInt(0);
  static final one = BigRational.fromInt(1);
  static final ten = BigRational.fromInt(10);

  static final RegExp _numberPattern = RegExp(
    r'^([+-]?)(?:(\d+)(?:\.(\d*))?|\.(\d+))(?:[eE]([+-]?\d+))?$',
  );

  factory BigRational.parse(String source) {
    final value = tryParse(source);
    if (value == null) {
      throw const MathException(MathErrorKind.syntax, '数字格式不正确');
    }
    return value;
  }

  static BigRational? tryParse(String source) {
    final text = source.trim();
    final match = _numberPattern.firstMatch(text);
    if (match == null) {
      return null;
    }
    final intPart = match.group(2) ?? '';
    final fractionPart = match.group(3) ?? match.group(4) ?? '';
    if (intPart.isEmpty && fractionPart.isEmpty) {
      return null;
    }
    final exponentText = match.group(5);
    final exponent = exponentText == null ? 0 : int.tryParse(exponentText);
    if (exponent == null || exponent.abs() > 1000) {
      throw const MathException(MathErrorKind.tooLarge, '数字指数过大');
    }
    final sign = match.group(1) == '-' ? -1 : 1;
    final digits = '$intPart$fractionPart'.replaceFirst(RegExp(r'^0+'), '');
    final numerator = digits.isEmpty ? BigInt.zero : BigInt.parse(digits);
    final scale = fractionPart.length - exponent;
    if (scale > 5000) {
      throw const MathException(MathErrorKind.tooLarge, '数字位数过多');
    }
    final adjusted = scale > 0
        ? BigRational(numerator, BigInt.from(10).pow(scale))
        : BigRational(numerator * BigInt.from(10).pow(-scale), BigInt.one);
    return sign < 0 ? -adjusted : adjusted;
  }

  final BigInt n;
  final BigInt d;

  bool get isZero => n == BigInt.zero;
  bool get isNegative => n.isNegative;
  bool get isInteger => d == BigInt.one;

  BigRational get abs => isNegative ? BigRational(-n, d) : this;

  BigRational operator -() => BigRational(-n, d);

  BigRational operator +(BigRational other) {
    return BigRational(n * other.d + other.n * d, d * other.d);
  }

  BigRational operator -(BigRational other) {
    return BigRational(n * other.d - other.n * d, d * other.d);
  }

  BigRational operator *(BigRational other) {
    return BigRational(n * other.n, d * other.d);
  }

  BigRational operator /(BigRational other) {
    if (other.isZero) {
      throw const MathException(MathErrorKind.divideByZero, '不能除以0');
    }
    return BigRational(n * other.d, d * other.n);
  }

  BigRational pow(int exponent) {
    if (exponent == 0) {
      return one;
    }
    if (exponent.abs() > 100000) {
      throw const MathException(MathErrorKind.tooLarge, '指数过大');
    }
    if (exponent > 0) {
      return BigRational(n.pow(exponent), d.pow(exponent));
    }
    if (isZero) {
      throw const MathException(MathErrorKind.divideByZero, '不能除以0');
    }
    return BigRational(d.pow(-exponent), n.pow(-exponent));
  }

  BigInt toBigInt() {
    assert(isInteger, 'not an integer');
    return n;
  }

  double toDouble() {
    if (isZero) return 0;
    return n.toDouble() / d.toDouble();
  }

  @override
  int compareTo(BigRational other) {
    return (n * other.d).compareTo(other.n * d);
  }

  @override
  bool operator ==(Object other) {
    return other is BigRational && n == other.n && d == other.d;
  }

  @override
  int get hashCode => Object.hash(n, d);

  @override
  String toString() => isInteger ? '$n' : '$n/$d';
}
