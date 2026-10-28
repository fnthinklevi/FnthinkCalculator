import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/math/angle_unit.dart';
import 'package:fnthink_calculator/features/calculator/calculator_controller.dart';

void main() {
  test('1+2= 产生结果与历史', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.inputOperator('+');
    controller.inputDigit('2');
    expect(controller.previewText, '3');
    controller.evaluate();
    expect(controller.isResultMode, isTrue);
    expect(controller.mainText, '3');
    expect(controller.history, hasLength(1));
    expect(controller.history.first.expression, '1+2');
    expect(controller.history.first.approximate, isFalse);
  });

  test('0.1+0.2 精确等于 0.3', () {
    final controller = CalculatorController();
    controller.inputDigit('0');
    controller.inputDecimal();
    controller.inputDigit('1');
    controller.inputOperator('+');
    controller.inputDigit('0');
    controller.inputDecimal();
    controller.inputDigit('2');
    controller.evaluate();
    expect(controller.mainText, '0.3');
    expect(controller.history.first.approximate, isFalse);
  });

  test('小米百分比口径', () {
    final controller = CalculatorController();
    for (final key in ['1', '0', '0']) {
      controller.inputDigit(key);
    }
    controller.inputOperator('+');
    controller.inputDigit('1');
    controller.inputDigit('0');
    controller.inputPostfix('%');
    controller.evaluate();
    expect(controller.mainText, '110');
  });

  test('结果可以继续参与计算', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.inputOperator('+');
    controller.inputDigit('2');
    controller.evaluate();
    controller.inputOperator('×');
    controller.inputDigit('2');
    expect(controller.expression, '3×2');
    controller.evaluate();
    expect(controller.mainText, '6');
  });

  test('结果后输入数字会开始新算式', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.evaluate();
    controller.inputDigit('7');
    expect(controller.expression, '7');
    expect(controller.isInputMode, isTrue);
  });

  test('前导零与小数点校验', () {
    final controller = CalculatorController();
    controller.inputDigit('0');
    controller.inputDigit('0');
    expect(controller.expression, '0');
    controller.inputDigit('5');
    expect(controller.expression, '5');
    controller.inputDecimal();
    expect(controller.expression, '5.');
    controller.inputDigit('2');
    expect(controller.expression, '5.2');
    controller.inputDecimal();
    expect(controller.expression, '5.2');
  });

  test('运算符替换与一元负号', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.inputOperator('+');
    controller.inputOperator('×');
    expect(controller.expression, '1×');
    controller.inputOperator('−');
    expect(controller.expression, '1×−');
    controller.inputDigit('3');
    expect(controller.expression, '1×−3');
  });

  test('退格与清空', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.inputOperator('+');
    controller.inputDigit('2');
    controller.backspace();
    expect(controller.expression, '1+');
    controller.backspace();
    expect(controller.expression, '1');
    controller.clear();
    expect(controller.expression, '');
    expect(controller.clearLabel, 'AC');
  });

  test('结果后退格回到可编辑表达式', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.inputOperator('+');
    controller.inputDigit('2');
    controller.evaluate();
    controller.backspace();
    expect(controller.isInputMode, isTrue);
    expect(controller.expression, '1+2');
    expect(controller.previewText, '3');
  });

  test('错误态可恢复', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.inputOperator('÷');
    controller.inputDigit('0');
    controller.evaluate();
    expect(controller.isErrorMode, isTrue);
    expect(controller.errorMessage, contains('不能除以 0'));
    controller.inputDigit('2');
    expect(controller.isInputMode, isTrue);
    expect(controller.expression, '2');
    expect(controller.isErrorMode, isFalse);
  });

  test('自动补右括号', () {
    final controller = CalculatorController();
    controller.inputFunction('sin');
    controller.inputDigit('3');
    controller.inputDigit('0');
    controller.evaluate();
    expect(controller.expression, 'sin(30)');
    expect(controller.mainText, '0.5');
    expect(controller.mainApproximate, isTrue);
  });

  test('历史复用', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.inputOperator('+');
    controller.inputDigit('2');
    controller.evaluate();
    controller.clear();
    final entry = controller.history.first;
    controller.useHistory(entry);
    expect(controller.expression, '3');
    expect(controller.previewText, '3');
  });

  test('光标位置插入', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.inputOperator('+');
    controller.inputDigit('2');
    controller.setCaret(1);
    controller.inputDigit('9');
    expect(controller.expression, '19+2');
    expect(controller.previewText, '21');
  });

  test('历史条数上限', () {
    final controller = CalculatorController(maxHistory: 3);
    for (var index = 1; index <= 5; index++) {
      controller.inputDigit('$index');
      controller.evaluate();
      controller.clear();
    }
    expect(controller.history, hasLength(3));
    expect(controller.history.first.expression, '5');
  });

  test('最近历史跳过当前表达式', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.evaluate();
    expect(controller.recentHistory, isEmpty);
    controller.inputDigit('2');
    controller.evaluate();
    expect(controller.recentHistory, hasLength(1));
    expect(controller.recentHistory.first.expression, '1');
  });

  test('角度单位切换影响预览', () {
    final controller = CalculatorController();
    controller.inputFunction('sin');
    controller.inputDigit('3');
    controller.inputDigit('0');
    expect(controller.previewText, '0.5');
    controller.setAngleUnit(
      controller.angleUnit == AngleUnit.degrees
          ? AngleUnit.radians
          : AngleUnit.degrees,
    );
    expect(controller.previewText, '-0.988031624093');
  });

  test('平方、立方与十的幂', () {
    final controller = CalculatorController();
    controller.inputDigit('2');
    controller.inputPower(3);
    expect(controller.expression, '2^3');
    expect(controller.previewText, '8');

    controller.clear();
    controller.inputDigit('2');
    controller.inputTenPower();
    controller.inputDigit('3');
    expect(controller.expression, '2×10^3');
    expect(controller.previewText, '2,000');

    controller.clear();
    controller.inputExpPower();
    controller.inputDigit('0');
    expect(controller.expression, 'e^0');
    expect(controller.previewText, '1');
  });

  test('2nd 状态可切换', () {
    final controller = CalculatorController();
    expect(controller.second, isFalse);
    controller.toggleSecond();
    expect(controller.second, isTrue);
    controller.toggleSecond();
    expect(controller.second, isFalse);
  });

  test('常见错误均可恢复', () {
    final setups = <void Function(CalculatorController)>[
      (controller) {
        controller.inputDigit('1');
        controller.inputOperator('÷');
        controller.inputDigit('0');
      },
      (controller) {
        controller.inputFunction('sqrt');
        controller.inputOperator('−');
        controller.inputDigit('1');
      },
      (controller) {
        controller.inputFunction('tan');
        controller.inputDigit('9');
        controller.inputDigit('0');
      },
      (controller) {
        controller.inputDigit('1');
        controller.inputDecimal();
        controller.inputDigit('5');
        controller.inputPostfix('!');
      },
    ];

    for (final setup in setups) {
      final controller = CalculatorController();
      setup(controller);
      controller.evaluate();
      expect(controller.isErrorMode, isTrue);
      expect(controller.errorMessage, isNotEmpty);
      controller.inputDigit('2');
      expect(controller.isInputMode, isTrue);
      expect(controller.expression, '2');
    }
  });
}
