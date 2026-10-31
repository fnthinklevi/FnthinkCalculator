import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/calculator/calculator_controller.dart';
import 'package:fnthink_calculator/features/calculator/history_entry.dart';
import 'package:fnthink_calculator/features/calculator/history_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

CalculatorController controllerWithHistory() {
  return CalculatorController(
    initialHistory: [
      HistoryEntry(
        expression: '1+2',
        resultText: '3',
        rawResult: '3',
        approximate: false,
        createdAt: DateTime(2026, 10, 29, 10),
      ),
      HistoryEntry(
        expression: '5÷0',
        resultText: '不能除以0',
        rawResult: '',
        approximate: false,
        createdAt: DateTime(2026, 10, 29, 9),
      ),
      HistoryEntry(
        expression: '2×3',
        resultText: '6',
        rawResult: '6',
        approximate: false,
        createdAt: DateTime(2026, 10, 28, 20),
      ),
    ],
  );
}

Widget harness(CalculatorController controller) {
  return MaterialApp(
    theme: buildAppTheme(Brightness.light),
    home: HistoryPage(controller: controller),
  );
}

void configureSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('历史记录按日期分组并显示错误条目', (tester) async {
    configureSurface(tester);
    final controller = controllerWithHistory();
    await tester.pumpWidget(harness(controller));

    expect(find.byKey(const Key('history-page')), findsOneWidget);
    expect(find.text('2026.10.29'), findsOneWidget);
    expect(find.text('2026.10.28'), findsOneWidget);
    expect(find.textContaining('不能除以0', findRichText: true), findsOneWidget);
    expect(find.byKey(const Key('history-entry-2')), findsOneWidget);
  });

  testWidgets('长按进入多选、全选与删除', (tester) async {
    configureSurface(tester);
    final controller = controllerWithHistory();
    await tester.pumpWidget(harness(controller));

    await tester.longPress(find.byKey(const Key('history-entry-0')));
    await tester.pumpAndSettle();
    expect(find.text('已选择1项'), findsOneWidget);
    expect(find.byKey(const Key('history-action-delete')), findsOneWidget);

    await tester.tap(find.byKey(const Key('history-select-all')));
    await tester.pumpAndSettle();
    expect(find.text('已选择3项'), findsOneWidget);

    await tester.tap(find.byKey(const Key('history-action-delete')));
    await tester.pumpAndSettle();
    expect(controller.history, isEmpty);
    expect(find.text('暂无历史记录'), findsOneWidget);
  });

  testWidgets('重新计算载入结果并返回', (tester) async {
    configureSurface(tester);
    final controller = controllerWithHistory();
    await tester.pumpWidget(harness(controller));

    await tester.longPress(find.byKey(const Key('history-entry-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('history-action-recalculate')));
    await tester.pumpAndSettle();
    expect(controller.expression, '3');
  });

  testWidgets('垃圾桶清空全部需确认', (tester) async {
    configureSurface(tester);
    final controller = controllerWithHistory();
    await tester.pumpWidget(harness(controller));

    await tester.tap(find.byKey(const Key('history-clear')));
    await tester.pumpAndSettle();
    expect(find.text('清空历史记录'), findsOneWidget);
    await tester.tap(find.byKey(const Key('history-clear-confirm')));
    await tester.pumpAndSettle();
    expect(controller.history, isEmpty);
  });
}
