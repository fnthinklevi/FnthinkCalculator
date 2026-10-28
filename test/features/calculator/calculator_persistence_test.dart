import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/calculator/calculator_controller.dart';
import 'package:fnthink_calculator/features/calculator/history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> freshPrefs() async {
    SharedPreferences.setMockInitialValues({});
    return SharedPreferences.getInstance();
  }

  test('历史在控制器重建后仍然存在', () async {
    final prefs = await freshPrefs();
    final controller = CalculatorController(
      historyStore: HistoryRepository(prefs),
    );
    controller.inputDigit('1');
    controller.inputOperator('+');
    controller.inputDigit('2');
    controller.evaluate();
    await Future<void>.delayed(Duration.zero);

    final reloaded = CalculatorController(
      historyStore: HistoryRepository(prefs),
    );
    expect(reloaded.history, hasLength(1));
    expect(reloaded.history.first.expression, '1+2');
    expect(reloaded.history.first.resultText, '3');
  });

  test('删除与清空会同步写回', () async {
    final prefs = await freshPrefs();
    final controller = CalculatorController(
      historyStore: HistoryRepository(prefs),
    );
    controller.inputDigit('1');
    controller.evaluate();
    controller.clear();
    controller.inputDigit('2');
    controller.evaluate();
    await Future<void>.delayed(Duration.zero);
    expect(controller.history, hasLength(2));

    controller.removeHistory(controller.history.first);
    await Future<void>.delayed(Duration.zero);
    final afterRemove = CalculatorController(
      historyStore: HistoryRepository(prefs),
    );
    expect(afterRemove.history, hasLength(1));
    expect(afterRemove.history.first.expression, '1');

    afterRemove.clearHistory();
    await Future<void>.delayed(Duration.zero);
    final afterClear = CalculatorController(
      historyStore: HistoryRepository(prefs),
    );
    expect(afterClear.history, isEmpty);
  });
}
