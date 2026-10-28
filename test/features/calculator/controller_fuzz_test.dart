import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/calculator/calculator_controller.dart';

void main() {
  test('一万条随机按键序列不崩溃且可恢复', () {
    final random = Random(20261028);
    const keys = [
      '0',
      '1',
      '2',
      '3',
      '7',
      '9',
      '.',
      '+',
      '−',
      '×',
      '÷',
      '^',
      '%',
      '!',
      '(',
      ')',
    ];
    final controller = CalculatorController();

    for (var sequence = 0; sequence < 10000; sequence++) {
      final length = 4 + random.nextInt(14);
      for (var index = 0; index < length; index++) {
        final key = keys[random.nextInt(keys.length)];
        if (key == '+') {
          controller.inputOperator('+');
        } else if (key == '−') {
          controller.inputOperator('−');
        } else if (key == '×') {
          controller.inputOperator('×');
        } else if (key == '÷') {
          controller.inputOperator('÷');
        } else if (key == '^') {
          controller.inputOperator('^');
        } else if (key == '%') {
          controller.inputPostfix('%');
        } else if (key == '!') {
          controller.inputPostfix('!');
        } else if (key == '(') {
          controller.inputLeftParen();
        } else if (key == ')') {
          controller.inputRightParen();
        } else if (key == '.') {
          controller.inputDecimal();
        } else {
          controller.inputDigit(key);
        }
        if (random.nextInt(12) == 0) {
          controller.evaluate();
        }
        if (random.nextInt(25) == 0) {
          controller.backspace();
        }
      }
      controller.evaluate();
      controller.clear();
    }

    controller.inputDigit('1');
    controller.inputOperator('+');
    controller.inputDigit('1');
    controller.evaluate();
    expect(controller.mainText, '2');
  });
}
