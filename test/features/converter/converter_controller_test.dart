import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/converter/converter_controller.dart';
import 'package:fnthink_calculator/features/converter/unit_data.dart';

void main() {
  test('连续公式与中间运算符不报错', () {
    final controller = ConverterController(UnitData.length);

    controller.setInput('12');
    controller.appendOperator('+');
    expect(controller.error, isNull);

    controller.setInput('12+12');
    expect(controller.error, isNull);
    expect(controller.resultText, '2,400');

    controller.setInput('12+12+13');
    expect(controller.error, isNull);
    controller.commit();
    expect(controller.error, isNull);
    expect(controller.input, '37');
    expect(controller.resultText, '3,700');
  });
}
