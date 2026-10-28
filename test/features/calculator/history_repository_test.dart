import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/calculator/history_entry.dart';
import 'package:fnthink_calculator/features/calculator/history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> freshPrefs([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  HistoryEntry entry(int index) {
    return HistoryEntry(
      expression: '$index+1',
      resultText: '${index + 1}',
      rawResult: '${index + 1}',
      approximate: false,
      createdAt: DateTime(2026, 10, 28, 12, index % 60),
    );
  }

  test('历史仓库可保存与读取', () async {
    final prefs = await freshPrefs();
    final repository = HistoryRepository(prefs);
    await repository.save([entry(1), entry(2)]);

    final loaded = repository.load();
    expect(loaded, hasLength(2));
    expect(loaded.first.expression, '1+1');
    expect(loaded.first.resultText, '2');
    expect(loaded.last.expression, '2+1');
  });

  test('损坏 JSON 返回空历史', () async {
    final prefs = await freshPrefs({'history.v1': '{not-json'});
    final repository = HistoryRepository(prefs);
    expect(repository.load(), isEmpty);
  });

  test('历史最多保留 200 条', () async {
    final prefs = await freshPrefs();
    final repository = HistoryRepository(prefs);
    await repository.save(List.generate(205, entry));

    final loaded = repository.load();
    expect(loaded, hasLength(200));
    expect(loaded.first.expression, '0+1');
    expect(loaded.last.expression, '199+1');
  });
}
