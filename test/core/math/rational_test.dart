import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/math/math_error.dart';
import 'package:fnthink_calculator/core/math/rational.dart';

void main() {
  group('BigRational parse', () {
    test('parses decimal and exponent forms', () {
      expect(BigRational.parse('1.5'), BigRational.fromInt(3, 2));
      expect(BigRational.parse('0.1'), BigRational.fromInt(1, 10));
      expect(BigRational.parse('1e3'), BigRational.fromInt(1000));
      expect(BigRational.parse('2.5e-2'), BigRational.fromInt(1, 40));
      expect(BigRational.parse('.5'), BigRational.fromInt(1, 2));
      expect(BigRational.parse('5.'), BigRational.fromInt(5));
      expect(BigRational.parse('-0'), BigRational.zero);
    });

    test('rejects invalid values', () {
      expect(BigRational.tryParse('abc'), isNull);
      expect(BigRational.tryParse('1.2.3'), isNull);
      expect(BigRational.tryParse('.'), isNull);
      expect(BigRational.tryParse('1e'), isNull);
    });
  });

  group('BigRational normalization and arithmetic', () {
    test('normalizes sign and gcd', () {
      expect(BigRational.fromInt(-2, -4).toString(), '1/2');
      expect(BigRational.fromInt(2, 4).toString(), '1/2');
      expect(BigRational.fromInt(0, 5).toString(), '0');
    });

    test('adds and subtracts exactly', () {
      final oneThird = BigRational.fromInt(1, 3);
      final oneSixth = BigRational.fromInt(1, 6);
      expect(oneThird + oneSixth, BigRational.fromInt(1, 2));
      expect(oneThird - oneSixth, BigRational.fromInt(1, 6));
      expect(
        BigRational.parse('0.1') + BigRational.parse('0.2'),
        BigRational.parse('0.3'),
      );
    });

    test('multiplies and divides exactly', () {
      final oneThird = BigRational.fromInt(1, 3);
      expect(oneThird * BigRational.fromInt(3), BigRational.one);
      expect(oneThird / BigRational.fromInt(1, 2), BigRational.fromInt(2, 3));
    });

    test('division by zero throws', () {
      expect(
        () => BigRational.one / BigRational.zero,
        throwsA(
          isA<MathException>().having(
            (e) => e.kind,
            'kind',
            MathErrorKind.divideByZero,
          ),
        ),
      );
    });

    test('powers and negative powers', () {
      expect(BigRational.fromInt(2).pow(3), BigRational.fromInt(8));
      expect(BigRational.fromInt(2).pow(-2), BigRational.fromInt(1, 4));
      expect(BigRational.zero.pow(0), BigRational.one);
      expect(() => BigRational.zero.pow(-1), throwsA(isA<MathException>()));
    });

    test('compares and converts', () {
      expect(
        BigRational.fromInt(1, 3).compareTo(BigRational.fromInt(1, 2)),
        lessThan(0),
      );
      expect(BigRational.fromInt(1, 2).toDouble(), 0.5);
      expect(BigRational.fromInt(6, 3).toBigInt(), BigInt.from(2));
      expect(BigRational.fromInt(6, 3).isInteger, isTrue);
    });
  });
}
