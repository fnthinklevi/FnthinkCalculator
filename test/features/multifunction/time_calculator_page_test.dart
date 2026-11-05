import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/utils/date_calc.dart';
import 'package:fnthink_calculator/features/multifunction/time/time_history.dart';
import 'package:fnthink_calculator/features/multifunction/time/time_tool_pages.dart';
import 'package:fnthink_calculator/features/multifunction/time/time_widgets.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';
import 'package:fnthink_calculator/theme/tokens.dart';

Widget harness(Widget page) {
  return MaterialApp(
    locale: const Locale('zh', 'CN'),
    supportedLocales: const [Locale('zh', 'CN')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: buildAppTheme(Brightness.light),
    home: page,
  );
}

void configureSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

String valueOf(WidgetTester tester, String key) {
  return tester.widget<Text>(find.byKey(Key(key))).data!;
}

String displayPart(WidgetTester tester, String segment) {
  final text = find.descendant(
    of: find.byKey(Key('duration-display-$segment')),
    matching: find.byType(Text),
  );
  return tester.widget<Text>(text).data!;
}

String durationDisplay(WidgetTester tester) {
  final single = find.byKey(const Key('duration-calc-display'));
  if (single.evaluate().isNotEmpty) {
    return tester.widget<Text>(single).data!;
  }
  final sign = find.byKey(const Key('duration-display-sign'));
  final prefix = sign.evaluate().isEmpty ? '' : '-';
  return '$prefix${displayPart(tester, 'hours')}:'
      '${displayPart(tester, 'minutes')}:${displayPart(tester, 'seconds')}';
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.pump();
  await tester.tap(find.byKey(Key(key)));
  await tester.pump();
}

void main() {
  testWidgets('日期差默认同一天并支持包含起始日', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const DateDifferencePage()));
    expect(find.text('日期差'), findsOneWidget);
    expect(valueOf(tester, 'date-diff-parts'), '0 天');
    expect(valueOf(tester, 'date-diff-total-days'), '0 天');

    await tapKey(tester, 'date-diff-include-start');
    expect(valueOf(tester, 'date-diff-total-days'), '1 天');
  });

  testWidgets('日期推算默认加一天并支持预设', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const DateAddPage()));

    final today = dateOnly(DateTime.now());
    expect(
      valueOf(tester, 'date-add-result-date'),
      formatDate(addDays(today, 1)),
    );

    await tapKey(tester, 'date-add-preset-1y');
    expect(
      valueOf(tester, 'date-add-result-date'),
      formatDate(addYearsClamped(today, 1)),
    );
  });

  testWidgets('时分秒键盘、冒号、60进制与进位开关', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeCalculationPage()));
    expect(durationDisplay(tester), '00:00:00');
    expect(valueOf(tester, 'duration-calc-total-seconds'), '共 00:00:00');

    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-3');
    await tapKey(tester, 'duration-key-0');
    expect(durationDisplay(tester), '01:30:00');

    await tapKey(tester, 'duration-key-add');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-4');
    await tapKey(tester, 'duration-key-5');
    expect(durationDisplay(tester), '00:45:00');
    await tapKey(tester, 'duration-key-equals');
    expect(durationDisplay(tester), '02:15:00');
    expect(valueOf(tester, 'duration-calc-total-seconds'), '共 02:15:00');

    await tapKey(tester, 'duration-key-clear');
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-3');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-subtract');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-4');
    await tapKey(tester, 'duration-key-5');
    await tapKey(tester, 'duration-key-equals');
    expect(durationDisplay(tester), '00:45:00');

    await tapKey(tester, 'duration-key-clear');
    await tapKey(tester, 'duration-key-2');
    await tapKey(tester, 'duration-key-4');
    expect(durationDisplay(tester), '24:00:00');
    await tapKey(tester, 'duration-key-add');
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-equals');
    expect(durationDisplay(tester), '25:00:00');
    expect(valueOf(tester, 'duration-calc-total-seconds'), '共 25:00:00');

    await tapKey(tester, 'duration-carry-0');
    expect(durationDisplay(tester), '1天 01:00:00');
    await tapKey(tester, 'duration-carry-1');
    expect(durationDisplay(tester), '25:00:00');
  });

  testWidgets('时差计算为独立页', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeDifferencePage()));

    expect(find.byKey(const Key('time-difference-page')), findsOneWidget);
    expect(find.text('时差计算'), findsOneWidget);
    expect(valueOf(tester, 'time-diff-result'), '09:00:00');
    expect(find.byKey(const Key('duration-key-7')), findsNothing);
  });

  testWidgets('时长键盘只有一个退格键且逐次删除', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeCalculationPage()));
    expect(find.byKey(const Key('duration-key-backspace')), findsOneWidget);
    expect(find.byKey(const Key('duration-key-undo')), findsNothing);
    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

    await tapKey(tester, 'duration-key-3');
    await tapKey(tester, 'duration-key-2');
    await tapKey(tester, 'duration-key-add');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-2');
    await tapKey(tester, 'duration-key-5');
    expect(durationDisplay(tester), '00:25:00');

    await tapKey(tester, 'duration-key-backspace');
    expect(durationDisplay(tester), '00:02:00');
    await tapKey(tester, 'duration-key-backspace');
    expect(durationDisplay(tester), '00:00:00');
    expect(valueOf(tester, 'duration-calc-expression'), '32:00:00 + 00:00:00');
  });

  testWidgets('连续公式按左到右累计', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeCalculationPage()));

    // 12:00 +
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-2');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-add');

    // 12:01 +
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-2');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-add');

    // 13:01 =
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-3');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-equals');

    expect(
      valueOf(tester, 'duration-calc-expression'),
      '12:00:00 + 12:01:00 + 13:01:00 =',
    );
    expect(durationDisplay(tester), '37:02:00');

    await tapKey(tester, 'duration-carry-0');
    expect(durationDisplay(tester), '1天 13:02:00');
    await tapKey(tester, 'duration-carry-1');
    expect(durationDisplay(tester), '37:02:00');

    // 结果后继续累计：37:02 + 0:59 = 38:01
    await tapKey(tester, 'duration-key-add');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-5');
    await tapKey(tester, 'duration-key-9');
    await tapKey(tester, 'duration-key-equals');
    expect(
      valueOf(tester, 'duration-calc-expression'),
      '37:02:00 + 00:59:00 =',
    );
    expect(durationDisplay(tester), '38:01:00');
  });

  testWidgets('时长键盘首行顺序与跨格布局', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeCalculationPage()));

    final firstRow = [
      tester.getCenter(find.byKey(const Key('duration-key-clear'))),
      tester.getCenter(find.byKey(const Key('duration-key-00'))),
      tester.getCenter(find.byKey(const Key('duration-key-sign'))),
      tester.getCenter(find.byKey(const Key('duration-key-backspace'))),
    ];
    for (var index = 1; index < firstRow.length; index++) {
      expect(
        firstRow[index].dx,
        greaterThan(firstRow[index - 1].dx),
        reason: '第一行顺序应为 C / 00 / ± / ⌫',
      );
    }

    final gap = CalcSpacing.keyGap;
    final seven = tester.getSize(find.byKey(const Key('duration-key-7')));
    final zero = tester.getSize(find.byKey(const Key('duration-key-0')));
    final colon = tester.getSize(find.byKey(const Key('duration-key-colon')));
    final equals = tester.getSize(find.byKey(const Key('duration-key-equals')));

    expect(zero.width, closeTo(seven.width * 2 + gap, 0.6));
    expect(zero.height, closeTo(seven.height, 0.6));
    expect(colon.width, closeTo(seven.width, 0.6));
    expect(colon.height, closeTo(seven.height, 0.6));
    expect(equals.width, closeTo(seven.width * 4 + gap * 3, 0.6));
    expect(equals.height, closeTo(seven.height, 0.6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('时间乘除小数标量', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeCalculationPage()));

    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-3');
    await tapKey(tester, 'duration-key-0');
    expect(durationDisplay(tester), '01:30:00');

    await tapKey(tester, 'duration-key-multiply');
    expect(find.byKey(const Key('duration-calc-display')), findsOneWidget);
    expect(find.byKey(const Key('duration-display-hours')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('duration-key-colon')),
        matching: find.text('.'),
      ),
      findsOneWidget,
    );

    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-5');
    expect(durationDisplay(tester), '1.5');
    expect(valueOf(tester, 'duration-calc-expression'), '01:30:00 × 1.5');

    await tapKey(tester, 'duration-key-equals');
    expect(durationDisplay(tester), '02:15:00');
    expect(valueOf(tester, 'duration-calc-expression'), '01:30:00 × 1.5 =');

    await tapKey(tester, 'duration-key-clear');
    await tapKey(tester, 'duration-key-2');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-divide');
    await tapKey(tester, 'duration-key-4');
    await tapKey(tester, 'duration-key-equals');
    expect(durationDisplay(tester), '00:30:00');
  });

  testWidgets('乘除后接加减切回时间输入，结果可继续乘除', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeCalculationPage()));

    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-multiply');
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-5');
    await tapKey(tester, 'duration-key-add');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-3');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-equals');

    expect(durationDisplay(tester), '02:00:00');
    expect(find.byKey(const Key('duration-display-hours')), findsNothing);

    await tapKey(tester, 'duration-key-multiply');
    await tapKey(tester, 'duration-key-2');
    await tapKey(tester, 'duration-key-equals');
    expect(durationDisplay(tester), '04:00:00');
  });

  testWidgets('乘除优先于加减', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeCalculationPage()));

    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-3');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-add');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-3');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-multiply');
    await tapKey(tester, 'duration-key-2');
    await tapKey(tester, 'duration-key-equals');

    expect(durationDisplay(tester), '02:30:00');
    expect(
      valueOf(tester, 'duration-calc-expression'),
      '01:30:00 + 00:30:00 × 2 =',
    );
  });

  testWidgets('除以零显示错误并可恢复', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeCalculationPage()));

    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-divide');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-equals');

    expect(find.byKey(const Key('duration-calc-error')), findsOneWidget);
    expect(valueOf(tester, 'duration-calc-error'), '不能除以 0');

    await tapKey(tester, 'duration-key-clear');
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-divide');
    await tapKey(tester, 'duration-key-2');
    await tapKey(tester, 'duration-key-equals');

    expect(find.byKey(const Key('duration-calc-error')), findsNothing);
    expect(durationDisplay(tester), '00:30:00');
  });

  testWidgets('除不尽四舍五入，连续乘除保持精确', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeCalculationPage()));

    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-divide');
    await tapKey(tester, 'duration-key-7');
    await tapKey(tester, 'duration-key-equals');
    expect(durationDisplay(tester), '00:08:34');

    await tapKey(tester, 'duration-key-clear');
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-divide');
    await tapKey(tester, 'duration-key-7');
    await tapKey(tester, 'duration-key-multiply');
    await tapKey(tester, 'duration-key-7');
    await tapKey(tester, 'duration-key-equals');
    expect(durationDisplay(tester), '01:00:00');
  });

  testWidgets('乘除后只能输入标量且退回逐字删除', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeCalculationPage()));

    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-multiply');

    expect(find.byKey(const Key('duration-calc-display')), findsOneWidget);
    expect(find.byKey(const Key('duration-display-hours')), findsNothing);
    expect(find.byKey(const Key('duration-key-divide')), findsOneWidget);
    expect(find.byKey(const Key('duration-key-multiply')), findsOneWidget);

    await tapKey(tester, 'duration-key-sign');
    expect(durationDisplay(tester), '0');

    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-5');
    expect(durationDisplay(tester), '1.5');

    await tapKey(tester, 'duration-key-backspace');
    expect(durationDisplay(tester), '1.');
    await tapKey(tester, 'duration-key-backspace');
    expect(durationDisplay(tester), '1');
    await tapKey(tester, 'duration-key-backspace');
    expect(durationDisplay(tester), '0');
  });

  testWidgets('时间乘零', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeCalculationPage()));

    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-3');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-multiply');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-equals');

    expect(durationDisplay(tester), '00:00:00');
  });

  testWidgets('输入态与结果态卡片高度和按键尺寸保持一致', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeCalculationPage()));

    final card = find.byKey(const Key('duration-calc-card'));
    expect(find.byKey(const Key('duration-display-hours')), findsOneWidget);
    expect(find.byKey(const Key('duration-segment-hours')), findsNothing);
    final inputCardSize = tester.getSize(card);
    final inputKeySize = tester.getSize(
      find.byKey(const Key('duration-key-7')),
    );

    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-add');
    await tapKey(tester, 'duration-key-2');
    await tapKey(tester, 'duration-key-equals');

    expect(durationDisplay(tester), '03:00:00');
    expect(find.byKey(const Key('duration-display-hours')), findsNothing);
    expect(tester.getSize(card).height, closeTo(inputCardSize.height, 0.5));
    final resultKeySize = tester.getSize(
      find.byKey(const Key('duration-key-7')),
    );
    expect(resultKeySize.width, closeTo(inputKeySize.width, 0.5));
    expect(resultKeySize.height, closeTo(inputKeySize.height, 0.5));

    await tapKey(tester, 'duration-key-multiply');
    expect(durationDisplay(tester), '0');
    expect(tester.getSize(card).height, closeTo(inputCardSize.height, 0.5));
    final scalarKeySize = tester.getSize(
      find.byKey(const Key('duration-key-7')),
    );
    expect(scalarKeySize.width, closeTo(inputKeySize.width, 0.5));
    expect(scalarKeySize.height, closeTo(inputKeySize.height, 0.5));
  });

  testWidgets('时间历史记录连续公式为一条并可清空', (tester) async {
    configureSurface(tester);
    final store = MemoryTimeHistoryStore();
    await tester.pumpWidget(harness(TimeCalculationPage(historyStore: store)));

    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-2');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-add');
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-2');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-add');
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-3');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-equals');

    expect(store.load(), hasLength(1));
    expect(store.load().first.expression, '12:00:00 + 12:01:00 + 13:01:00 =');
    expect(store.load().first.resultText, '37:02:00');

    await tapKey(tester, 'duration-history');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('time-history-entry-0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('time-history-clear')));
    await tester.pumpAndSettle();
    expect(store.load(), isEmpty);

    await tapKey(tester, 'duration-history');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('time-history-empty')), findsOneWidget);
  });

  testWidgets('分段点击修改与冒号输入自动进位', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const TimeCalculationPage()));

    await tapKey(tester, 'duration-key-9');
    await tapKey(tester, 'duration-key-6');
    expect(durationDisplay(tester), '96:00:00');

    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-5');
    await tapKey(tester, 'duration-key-2');
    expect(durationDisplay(tester), '96:52:00');

    await tapKey(tester, 'duration-display-seconds');
    await tapKey(tester, 'duration-key-3');
    await tapKey(tester, 'duration-key-0');
    expect(durationDisplay(tester), '96:52:30');
    expect(displayPart(tester, 'seconds'), '30');

    await tapKey(tester, 'duration-display-hours');
    await tapKey(tester, 'duration-key-1');
    await tapKey(tester, 'duration-key-0');
    await tapKey(tester, 'duration-key-0');
    expect(durationDisplay(tester), '100:52:30');

    await tapKey(tester, 'duration-key-clear');
    await tapKey(tester, 'duration-key-9');
    await tapKey(tester, 'duration-key-6');
    await tapKey(tester, 'duration-key-colon');
    await tapKey(tester, 'duration-key-6');
    await tapKey(tester, 'duration-key-4');
    expect(durationDisplay(tester), '97:04:00');
    expect(displayPart(tester, 'hours'), '97');
    expect(displayPart(tester, 'minutes'), '04');
    expect(displayPart(tester, 'seconds'), '00');
  });

  testWidgets('日期推算数量使用内置键盘', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const DateAddPage()));
    await tapKey(tester, 'date-add-amount-field');
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.byKey(const Key('numeric-sheet-display')), findsOneWidget);
    await tapKey(tester, 'numeric-key-clear');
    await tapKey(tester, 'numeric-key-7');
    await tapKey(tester, 'numeric-key-done');
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const Key('date-add-amount'))).data,
      '7',
    );
    final today = dateOnly(DateTime.now());
    expect(
      valueOf(tester, 'date-add-result-date'),
      formatDate(addDays(today, 7)),
    );
  });

  testWidgets('年龄默认 20 周岁', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(const AgePage()));
    expect(valueOf(tester, 'age-years'), '20 岁');
    expect(valueOf(tester, 'age-nominal'), '21 岁');
    expect(find.byKey(const Key('age-days')), findsOneWidget);
    expect(find.byKey(const Key('age-next-birthday')), findsOneWidget);
  });
}
