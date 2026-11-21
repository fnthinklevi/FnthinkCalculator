import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/math/angle_unit.dart';
import 'package:fnthink_calculator/features/calculator/calculator_controller.dart';
import 'package:fnthink_calculator/features/calculator/history_entry.dart';

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

  test('百分比默认按数值口径', () {
    final controller = CalculatorController();
    for (final key in ['1', '0', '0']) {
      controller.inputDigit(key);
    }
    controller.inputOperator('+');
    controller.inputDigit('1');
    controller.inputDigit('0');
    controller.inputPostfix('%');
    controller.evaluate();
    expect(controller.mainText, '100.1');
  });

  test('百分比可切换按比例口径', () {
    final controller = CalculatorController()
      ..setPercentMode(PercentMode.proportion);
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

  test('连续公式按左到右求值', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.inputOperator('+');
    controller.inputDigit('2');
    controller.inputOperator('+');
    controller.inputDigit('3');
    controller.evaluate();
    expect(controller.expression, '1+2+3');
    expect(controller.mainText, '6');
    expect(controller.history, hasLength(1));
    expect(controller.history.first.expression, '1+2+3');
  });

  test('重复等号不重复写入历史', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.inputOperator('+');
    controller.inputDigit('2');
    controller.evaluate();
    expect(controller.history, hasLength(1));

    controller.evaluate();
    expect(controller.mainText, '3');
    expect(controller.history, hasLength(1));
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

  test('退格整体删除函数名与左括号', () {
    final controller = CalculatorController();
    controller.inputFunction('cos');
    expect(controller.expression, 'cos(');
    controller.backspace();
    expect(controller.expression, '');

    controller.inputDigit('2');
    controller.inputFunction('asin');
    expect(controller.expression, '2×asin(');
    controller.inputDigit('1');
    controller.backspace();
    expect(controller.expression, '2×asin(');
    controller.backspace();
    expect(controller.expression, '2');
  });

  test('退格整体删除其他单键输入的组合片段', () {
    final controller = CalculatorController();
    controller.inputDigit('5');
    controller.inputPower(2);
    expect(controller.expression, '5^2');
    controller.backspace();
    expect(controller.expression, '5');

    controller.inputOperator('^');
    controller.inputDigit('2');
    expect(controller.expression, '5^2');
    controller.backspace();
    expect(controller.expression, '5^');

    controller.clear();
    controller.inputDigit('2');
    controller.inputTenPower();
    expect(controller.expression, '2×10^');
    controller.backspace();
    expect(controller.expression, '2');

    controller.inputExpPower();
    expect(controller.expression, '2×e^');
    controller.backspace();
    expect(controller.expression, '2');

    controller.inputLeftParen();
    expect(controller.expression, '2×(');
    controller.backspace();
    expect(controller.expression, '2');

    controller.clear();
    controller.inputConstant('pi');
    controller.inputDecimal();
    expect(controller.expression, 'π×0.');
    controller.backspace();
    expect(controller.expression, 'π');

    controller.clear();
    controller.inputDecimal();
    expect(controller.expression, '0.');
    controller.backspace();
    expect(controller.expression, '');
  });

  test('手动输入的幂与小数仍逐字符删除', () {
    final controller = CalculatorController();
    controller.inputDigit('2');
    controller.inputOperator('^');
    controller.inputDigit('2');
    controller.backspace();
    expect(controller.expression, '2^');
    controller.backspace();
    expect(controller.expression, '2');

    controller.clear();
    controller.inputDigit('0');
    controller.inputDecimal();
    expect(controller.expression, '0.');
    controller.backspace();
    expect(controller.expression, '0');
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

  test('结果算式可按点击位置继续编辑', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.inputOperator('+');
    controller.inputDigit('2');
    controller.evaluate();
    expect(controller.caretBlinking, isFalse);

    controller.editCommittedExpression(caret: 1);
    expect(controller.isInputMode, isTrue);
    expect(controller.expression, '1+2');
    expect(controller.caret, 1);
    expect(controller.previewText, '3');
    expect(controller.caretBlinking, isTrue);

    controller.inputDigit('9');
    expect(controller.expression, '19+2');

    controller.evaluate();
    expect(controller.caretBlinking, isFalse);
  });

  test('错误态可恢复', () {
    final controller = CalculatorController();
    controller.inputDigit('1');
    controller.inputOperator('÷');
    controller.inputDigit('0');
    controller.evaluate();
    expect(controller.isErrorMode, isTrue);
    expect(controller.errorMessage, contains('不能除以0'));
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

  test('1/x 倒数键可正常求值', () {
    final controller = CalculatorController();
    controller.inputDigit('4');
    controller.inputFunction('reciprocal');
    controller.inputDigit('4');
    controller.evaluate();
    expect(controller.isResultMode, isTrue);
    expect(controller.expression, '4×reciprocal(4)');
    expect(controller.mainText, '1');
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

  test('最近历史按时间正序返回，最新在最后', () {
    final controller = CalculatorController(
      initialHistory: [
        HistoryEntry(
          expression: '3+3',
          resultText: '6',
          rawResult: '6',
          approximate: false,
          createdAt: DateTime(2026, 11, 14, 10, 2),
        ),
        HistoryEntry(
          expression: '2+2',
          resultText: '4',
          rawResult: '4',
          approximate: false,
          createdAt: DateTime(2026, 11, 14, 10, 1),
        ),
        HistoryEntry(
          expression: '1+1',
          resultText: '2',
          rawResult: '2',
          approximate: false,
          createdAt: DateTime(2026, 11, 14, 10, 0),
        ),
      ],
    );
    expect(controller.recentHistory.map((entry) => entry.expression), [
      '1+1',
      '2+2',
      '3+3',
    ]);
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
