import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/calculator/calculator_controller.dart';
import 'package:fnthink_calculator/features/converter/converter_controller.dart';
import 'package:fnthink_calculator/features/converter/unit_data.dart';

void main() {
  test('计算器连续公式与重复等号闸门', () {
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

    controller.evaluate();
    expect(controller.mainText, '6');
    expect(controller.history, hasLength(1));
  });

  test('换算连续公式与中间运算符闸门', () {
    final controller = ConverterController(UnitData.length);
    controller.setInput('12');
    controller.appendOperator('+');
    expect(controller.error, isNull);

    controller.setInput('12+12');
    expect(controller.error, isNull);
    expect(controller.resultText, '2,400');

    controller.setInput('12+12+13');
    controller.commit();
    expect(controller.error, isNull);
    expect(controller.input, '37');
    expect(controller.resultText, '3,700');
  });
}
