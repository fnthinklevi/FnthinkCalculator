import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/math/calc_value.dart';
import 'package:fnthink_calculator/core/math/formatter.dart';
import 'package:fnthink_calculator/core/math/math_error.dart';
import 'package:fnthink_calculator/core/math/rational.dart';

void main() {
  const formatter = NumberFormatter();

  FormattedNumber formatRational(BigInt n, [BigInt? d]) {
    return formatter.format(RationalValue(BigRational(n, d)));
  }

  test('terminating decimals are exact', () {
    final value = formatRational(BigInt.one, BigInt.from(8));
    expect(value.text, '0.125');
    expect(value.approximate, isFalse);
    expect(value.rawText, '0.125');
  });

  test('non terminating decimals are rounded and marked approximate', () {
    final third = formatRational(BigInt.one, BigInt.from(3));
    expect(third.text, '0.333333333333');
    expect(third.approximate, isTrue);

    final sixth = formatRational(BigInt.one, BigInt.from(6));
    expect(sixth.text, '0.166666666667');
    expect(sixth.approximate, isTrue);
  });

  test('grouping only applies to display text', () {
    final value = formatRational(BigInt.from(123456789), BigInt.from(100));
    expect(value.text, '1,234,567.89');
    expect(value.rawText, '1234567.89');
    expect(value.approximate, isFalse);
  });

  test('scientific notation for large and small values', () {
    final large = formatRational(BigInt.parse('123456789012345'));
    expect(large.text, '1.23456789012e+14');
    expect(large.approximate, isTrue);

    final exactLarge = formatRational(BigInt.parse('1000000000000'));
    expect(exactLarge.text, '1e+12');
    expect(exactLarge.approximate, isFalse);

    final tiny = formatRational(BigInt.one, BigInt.from(10000000000));
    expect(tiny.text, '1e-10');
    expect(tiny.approximate, isFalse);

    final nano = formatRational(BigInt.one, BigInt.from(1000000000));
    expect(nano.text, '0.000000001');
  });

  test('negative values and zero', () {
    final negative = formatRational(BigInt.from(-1), BigInt.from(3));
    expect(negative.text, '-0.333333333333');
    final zero = formatRational(BigInt.zero);
    expect(zero.text, '0');
    expect(zero.approximate, isFalse);
  });

  test('custom significant digits', () {
    const short = NumberFormatter(significantDigits: 5);
    final value = short.format(RationalValue(BigRational.fromInt(1, 3)));
    expect(value.text, '0.33333');
  });

  test('grouping can be disabled', () {
    const plain = NumberFormatter(grouping: false);
    final value = plain.format(RationalValue(BigRational.fromInt(1234567, 1)));
    expect(value.text, '1234567');
  });

  test('double values are cleaned and marked approximate', () {
    final integer = formatter.format(const DoubleValue(3));
    expect(integer.text, '3');
    expect(integer.approximate, isFalse);

    final half = formatter.format(const DoubleValue(0.5));
    expect(half.text, '0.5');
    expect(half.approximate, isTrue);

    final negativeZero = formatter.format(const DoubleValue(-0.0));
    expect(negativeZero.text, '0');
    expect(negativeZero.approximate, isFalse);
  });

  test('non finite doubles are rejected', () {
    expect(
      () => formatter.format(const DoubleValue(double.nan)),
      throwsA(
        isA<MathException>().having(
          (e) => e.kind,
          'kind',
          MathErrorKind.overflow,
        ),
      ),
    );
    expect(
      () => formatter.format(const DoubleValue(double.infinity)),
      throwsA(isA<MathException>()),
    );
  });
}
