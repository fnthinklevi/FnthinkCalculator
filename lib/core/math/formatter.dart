import 'calc_value.dart';
import 'math_error.dart';
import 'rational.dart';

class FormattedNumber {
  const FormattedNumber({
    required this.text,
    required this.rawText,
    required this.approximate,
  });

  final String text;
  final String rawText;
  final bool approximate;
}

class NumberFormatter {
  const NumberFormatter({this.significantDigits = 12, this.grouping = true});

  final int significantDigits;
  final bool grouping;

  FormattedNumber format(CalcValue value) {
    return switch (value) {
      RationalValue(:final value) => _formatRational(value),
      DoubleValue(:final value) => _formatDouble(value),
    };
  }

  FormattedNumber _formatDouble(double value) {
    if (!value.isFinite) {
      throw const MathException(MathErrorKind.overflow, '结果超出范围');
    }
    if (value == 0) {
      return const FormattedNumber(text: '0', rawText: '0', approximate: false);
    }
    final precision = value.toStringAsPrecision(significantDigits);
    final rational = BigRational.parse(precision);
    final formatted = _formatRational(rational);
    final isInteger = value == value.roundToDouble() && value.abs() < 1e15;
    return FormattedNumber(
      text: formatted.text,
      rawText: formatted.rawText,
      approximate: !isInteger,
    );
  }

  FormattedNumber _formatRational(BigRational rational) {
    if (rational.isZero) {
      return const FormattedNumber(text: '0', rawText: '0', approximate: false);
    }
    final negative = rational.isNegative;
    final numerator = rational.n.abs();
    final denominator = rational.d;
    var exponent = _estimateExponent(numerator, denominator);
    final shift = significantDigits - 1 - exponent;

    final BigInt q;
    final BigInt remainder;
    if (shift >= 0) {
      final scaledNumerator = numerator * _pow10(shift);
      q =
          (scaledNumerator * BigInt.two + denominator) ~/
          (denominator * BigInt.two);
      remainder = scaledNumerator % denominator;
    } else {
      final scaledDenominator = denominator * _pow10(-shift);
      q =
          (numerator * BigInt.two + scaledDenominator) ~/
          (scaledDenominator * BigInt.two);
      remainder = numerator % scaledDenominator;
    }

    var digits = q.toString();
    if (digits.length > significantDigits) {
      digits = (q ~/ BigInt.from(10)).toString();
      exponent++;
    }
    if (digits.length < significantDigits) {
      digits = digits.padLeft(significantDigits, '0');
    }

    final sign = negative ? '-' : '';
    final scientific = exponent >= 12 || exponent <= -10;

    if (scientific) {
      final mantissa = digits.length > 1
          ? '${digits[0]}.${digits.substring(1)}'
          : digits;
      final trimmed = _trimTrailingZeros(mantissa);
      final exponentText = exponent >= 0 ? '+$exponent' : '$exponent';
      final raw = '$sign${trimmed}e$exponentText';
      return FormattedNumber(
        text: raw,
        rawText: raw,
        approximate: remainder != BigInt.zero,
      );
    }

    String integerPart;
    String fractionPart;
    if (exponent >= 0) {
      final integerDigits = exponent + 1;
      if (digits.length <= integerDigits) {
        integerPart = digits.padRight(integerDigits, '0');
        fractionPart = '';
      } else {
        integerPart = digits.substring(0, integerDigits);
        fractionPart = digits.substring(integerDigits);
      }
    } else {
      integerPart = '0';
      fractionPart = '${'0' * (-exponent - 1)}$digits';
    }
    fractionPart = _trimFraction(fractionPart);
    final raw =
        '$sign$integerPart'
        '${fractionPart.isEmpty ? '' : '.$fractionPart'}';
    final text =
        '$sign${_group(integerPart)}'
        '${fractionPart.isEmpty ? '' : '.$fractionPart'}';
    return FormattedNumber(
      text: text,
      rawText: raw,
      approximate: remainder != BigInt.zero,
    );
  }

  int _estimateExponent(BigInt numerator, BigInt denominator) {
    var exponent = numerator.toString().length - denominator.toString().length;
    while (_compareToPowerOfTen(numerator, denominator, exponent) < 0) {
      exponent--;
    }
    while (_compareToPowerOfTen(numerator, denominator, exponent + 1) >= 0) {
      exponent++;
    }
    return exponent;
  }

  int _compareToPowerOfTen(BigInt numerator, BigInt denominator, int exponent) {
    if (exponent >= 0) {
      return numerator.compareTo(denominator * _pow10(exponent));
    }
    return (numerator * _pow10(-exponent)).compareTo(denominator);
  }

  BigInt _pow10(int exponent) => BigInt.from(10).pow(exponent);

  String _trimTrailingZeros(String value) {
    if (!value.contains('.')) {
      return value;
    }
    var end = value.length;
    while (end > 0 && value[end - 1] == '0') {
      end--;
    }
    if (end > 0 && value[end - 1] == '.') {
      end--;
    }
    return value.substring(0, end);
  }

  String _trimFraction(String value) {
    var end = value.length;
    while (end > 0 && value[end - 1] == '0') {
      end--;
    }
    return value.substring(0, end);
  }

  String _group(String digits) {
    if (!grouping || digits.length <= 3) {
      return digits;
    }
    final buffer = StringBuffer();
    final firstGroup = digits.length % 3;
    var index = 0;
    if (firstGroup > 0) {
      buffer.write(digits.substring(0, firstGroup));
      index = firstGroup;
    }
    while (index < digits.length) {
      if (buffer.isNotEmpty) {
        buffer.write(',');
      }
      buffer.write(digits.substring(index, index + 3));
      index += 3;
    }
    return buffer.toString();
  }
}
