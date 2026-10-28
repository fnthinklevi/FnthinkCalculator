import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/utils/date_calc.dart';
import 'package:fnthink_calculator/features/multifunction/time/time_calculator_page.dart';
import 'package:fnthink_calculator/features/multifunction/time/time_widgets.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

Widget harness() {
  return MaterialApp(
    locale: const Locale('zh', 'CN'),
    supportedLocales: const [Locale('zh', 'CN')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: buildAppTheme(Brightness.light),
    home: const TimeCalculatorPage(),
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

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.pump();
  await tester.tap(find.byKey(Key(key)));
  await tester.pump();
}

void main() {
  testWidgets('日期差默认同一天并支持包含起始日', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());
    expect(find.text('时间计算'), findsOneWidget);
    expect(valueOf(tester, 'date-diff-parts'), '0 天');
    expect(valueOf(tester, 'date-diff-total-days'), '0 天');

    await tapKey(tester, 'date-diff-include-start');
    expect(valueOf(tester, 'date-diff-total-days'), '1 天');
  });

  testWidgets('日期推算默认加一天并支持预设', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());
    await tapKey(tester, 'time-tab-1');

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

  testWidgets('时分秒键盘、60进制与进位开关', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());
    await tapKey(tester, 'time-tab-2');
    expect(valueOf(tester, 'duration-calc-display'), '00:00:00');
    expect(valueOf(tester, 'duration-calc-total-seconds'), '共 0 秒');

    for (final key in [
      'duration-key-1',
      'duration-key-3',
      'duration-key-0',
      'duration-key-0',
      'duration-key-0',
    ]) {
      await tapKey(tester, key);
    }
    expect(valueOf(tester, 'duration-calc-display'), '01:30:00');

    await tapKey(tester, 'duration-key-add');
    for (final key in [
      'duration-key-4',
      'duration-key-5',
      'duration-key-0',
      'duration-key-0',
    ]) {
      await tapKey(tester, key);
    }
    expect(valueOf(tester, 'duration-calc-display'), '00:45:00');
    await tapKey(tester, 'duration-key-equals');
    expect(valueOf(tester, 'duration-calc-display'), '02:15:00');
    expect(valueOf(tester, 'duration-calc-total-seconds'), '共 8,100 秒');

    await tapKey(tester, 'duration-key-clear');
    for (final key in [
      'duration-key-1',
      'duration-key-3',
      'duration-key-0',
      'duration-key-0',
      'duration-key-0',
    ]) {
      await tapKey(tester, key);
    }
    await tapKey(tester, 'duration-key-subtract');
    for (final key in [
      'duration-key-4',
      'duration-key-5',
      'duration-key-0',
      'duration-key-0',
    ]) {
      await tapKey(tester, key);
    }
    await tapKey(tester, 'duration-key-equals');
    expect(valueOf(tester, 'duration-calc-display'), '00:45:00');

    await tapKey(tester, 'duration-key-clear');
    for (final key in [
      'duration-key-2',
      'duration-key-4',
      'duration-key-0',
      'duration-key-0',
      'duration-key-0',
      'duration-key-0',
    ]) {
      await tapKey(tester, key);
    }
    await tapKey(tester, 'duration-key-add');
    for (final key in [
      'duration-key-1',
      'duration-key-0',
      'duration-key-0',
      'duration-key-0',
      'duration-key-0',
    ]) {
      await tapKey(tester, key);
    }
    await tapKey(tester, 'duration-key-equals');
    expect(valueOf(tester, 'duration-calc-display'), '1天 01:00:00');

    await tapKey(tester, 'duration-carry-1');
    expect(valueOf(tester, 'duration-calc-display'), '25:00:00');
    await tapKey(tester, 'duration-carry-0');
    expect(valueOf(tester, 'duration-calc-display'), '1天 01:00:00');

    await tapKey(tester, 'duration-sub-1');
    expect(valueOf(tester, 'time-diff-result'), '09:00:00');
  });

  testWidgets('年龄默认 20 周岁', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());
    await tapKey(tester, 'time-tab-3');
    expect(valueOf(tester, 'age-years'), '20 岁');
    expect(valueOf(tester, 'age-nominal'), '21 岁');
    expect(find.byKey(const Key('age-days')), findsOneWidget);
    expect(find.byKey(const Key('age-next-birthday')), findsOneWidget);
  });
}
