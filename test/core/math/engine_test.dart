import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/math/angle_unit.dart';
import 'package:fnthink_calculator/core/math/calculator_engine.dart';
import 'package:fnthink_calculator/core/math/math_error.dart';

void main() {
  const engine = CalculatorEngine();

  EvalOutcome eval(String source, {AngleUnit angleUnit = AngleUnit.degrees}) {
    return engine.evaluate(source, angleUnit: angleUnit);
  }

  void expectText(
    String source,
    String expected, {
    AngleUnit angleUnit = AngleUnit.degrees,
    bool? approximate,
  }) {
    final outcome = eval(source, angleUnit: angleUnit);
    expect(
      outcome.error,
      isNull,
      reason: '$source -> ${outcome.error?.message}',
    );
    expect(outcome.formatted!.text, expected, reason: source);
    if (approximate != null) {
      expect(outcome.formatted!.approximate, approximate, reason: source);
    }
  }

  void expectError(String source, MathErrorKind kind) {
    final outcome = eval(source);
    expect(outcome.error, isNotNull, reason: source);
    expect(outcome.error!.kind, kind, reason: source);
  }

  group('precedence and parentheses', () {
    test('basic arithmetic', () {
      expectText('1+2', '3');
      expectText('2+3×4', '14');
      expectText('(2+3)×4', '20');
      expectText('10÷4', '2.5');
      expectText('0.1+0.2', '0.3', approximate: false);
      expectText('0.1+0.2-0.3', '0');
    });

    test('power and unary minus', () {
      expectText('2^3^2', '512');
      expectText('-2^2', '-4');
      expectText('(-2)^2', '4');
      expectText('0^0', '1');
      expectText('2^3!', '64');
      expectText('3!^2', '36');
    });

    test('factorial', () {
      expectText('5!', '120');
      expectText('0!', '1');
    });

    test('exact division stays exact', () {
      expectText('1÷8', '0.125', approximate: false);
      expectText('1÷3×3', '1', approximate: false);
      expectText('1÷3', '0.333333333333', approximate: true);
      expectText('2÷3', '0.666666666667', approximate: true);
    });

    test('formatting and grouping', () {
      expectText('1234567.89', '1,234,567.89');
      expectText('1000000+1', '1,000,001');
      expectText('-0', '0');
      expectText('0.000001×0.000001', '1e-12');
      expectText('1e12', '1e+12', approximate: false);
      expectText('1e-10', '1e-10', approximate: false);
      expectText('1e-9', '0.000000001', approximate: false);
    });
  });

  group('Xiaomi percent semantics', () {
    test('standalone percent', () {
      expectText('10%', '0.1');
    });

    test('add and subtract are relative to the left operand', () {
      expectText('100+10%', '110');
      expectText('100−10%', '90');
      expectText('200-10%', '180');
      expectText('10%+10%', '0.11');
      expectText('50%+50%', '0.75');
      expectText('100+10%+10%', '121');
    });

    test('multiply and divide use plain percent', () {
      expectText('100×10%', '10');
      expectText('100÷10%', '1,000');
    });

    test('percent respects precedence', () {
      expectText('100+10%×2', '100.2');
    });
  });

  group('scientific functions', () {
    test('trigonometry in degrees', () {
      expectText('sin(30)', '0.5', approximate: true);
      expectText('cos(60)', '0.5', approximate: true);
      expectText('tan(45)', '1', approximate: true);
      expectText('asin(0.5)', '30', approximate: true);
      expectText('acos(0.5)', '60', approximate: true);
      expectText('atan(1)', '45');
    });

    test('trigonometry in radians', () {
      expectText('sin(30)', '-0.988031624093', angleUnit: AngleUnit.radians);
      expectText('asin(1)', '1.57079632679', angleUnit: AngleUnit.radians);
    });

    test('logarithms and roots', () {
      expectText('ln(2)', '0.69314718056', approximate: true);
      expectText('log(100)', '2');
      expectText('sqrt(9)', '3', approximate: false);
      expectText('cbrt(-27)', '-3');
      expectText('exp(0)', '1', approximate: false);
      expectText('abs(-3)', '3', approximate: false);
      expectText('sqrt(2)^2', '2', approximate: true);
    });

    test('constants', () {
      expectText('π', '3.14159265359', approximate: true);
      expectText('e', '2.71828182846', approximate: true);
      expectText('π×2', '6.28318530718', approximate: true);
    });
  });

  group('errors', () {
    test('division by zero', () {
      expectError('1÷0', MathErrorKind.divideByZero);
      expectError('0^-1', MathErrorKind.divideByZero);
    });

    test('domain errors', () {
      expectError('sqrt(-1)', MathErrorKind.domain);
      expectError('ln(0)', MathErrorKind.domain);
      expectError('log(-1)', MathErrorKind.domain);
      expectError('tan(90)', MathErrorKind.domain);
      expectError('asin(2)', MathErrorKind.domain);
      expectError('1.5!', MathErrorKind.domain);
      expectError('(-1)!', MathErrorKind.domain);
      expectError('(-8)^(1÷3)', MathErrorKind.domain);
    });

    test('syntax and parentheses', () {
      expectError('1+', MathErrorKind.syntax);
      expectError('2(3)', MathErrorKind.syntax);
      expectError('1.2.3', MathErrorKind.syntax);
      expectError('1+2)', MathErrorKind.parentheses);
      expectError('foo(1)', MathErrorKind.unknownFunction);
      expectError('', MathErrorKind.empty);
      expectError('sin()', MathErrorKind.parentheses);
    });

    test('auto closes missing parentheses', () {
      expectText('(1+2', '3');
      expectText('sin(30', '0.5', approximate: true);
      expectText('((1)', '1');
    });
  });

  test('1000 factorial remains calculable', () {
    final outcome = engine.evaluate('1000!');
    expect(outcome.error, isNull);
    expect(outcome.formatted!.text, contains('e+'));
  });

  test('random token sequences never throw', () {
    final random = Random(42);
    const alphabet = [
      '1',
      '2',
      '3',
      '9',
      '.',
      '+',
      '-',
      '×',
      '÷',
      '(',
      ')',
      '!',
      '%',
      '^',
      'sin(',
      'cos(',
      'π',
      'e',
      ' ',
      '',
    ];
    for (var i = 0; i < 3000; i++) {
      final buffer = StringBuffer();
      final length = random.nextInt(18);
      for (var j = 0; j < length; j++) {
        buffer.write(alphabet[random.nextInt(alphabet.length)]);
      }
      final outcome = engine.evaluate(buffer.toString());
      if (outcome.isSuccess) {
        expect(outcome.formatted, isNotNull);
        expect(outcome.formatted!.text, isNotEmpty);
      } else {
        expect(outcome.error, isNotNull);
        expect(outcome.error!.message, isNotEmpty);
      }
    }
  });
}
