import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/multifunction/mortgage/mortgage_page.dart';
import 'package:fnthink_calculator/features/multifunction/multifunction_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

Widget harness() {
  return MaterialApp(
    locale: const Locale('zh', 'CN'),
    supportedLocales: const [Locale('zh', 'CN')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: buildAppTheme(Brightness.light),
    home: const MortgagePage(),
  );
}

void configureSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

String textOf(WidgetTester tester, String key) {
  return tester.widget<Text>(find.byKey(Key(key))).data!;
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.pump();
  await tester.tap(find.byKey(Key(key)));
  await tester.pump();
}

Future<void> reveal(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  } else {
    await tester.ensureVisible(finder);
    await tester.pump();
  }
}

Future<void> enterValue(WidgetTester tester, String value) async {
  await tapKey(tester, 'numeric-key-clear');
  for (final char in value.split('')) {
    if (char == '.') {
      await tapKey(tester, 'numeric-key-dot');
    } else {
      await tapKey(tester, 'numeric-key-$char');
    }
  }
  await tapKey(tester, 'numeric-key-done');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('默认商业贷显示月供、总额与期数', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    expect(find.byKey(const Key('mortgage-page')), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byKey(const Key('numeric-key-7')), findsNothing);
    expect(textOf(tester, 'mortgage-result-payment'), endsWith('元'));
    expect(textOf(tester, 'mortgage-result-loan'), '1,000,000.00 元');
    expect(find.textContaining('共 360 期'), findsOneWidget);
  });

  testWidgets('切换等额本金显示首月月供与递减', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'mortgage-method-1');
    expect(find.text('首月月供'), findsOneWidget);
    expect(find.byKey(const Key('mortgage-result-decrease')), findsOneWidget);
    expect(textOf(tester, 'mortgage-result-decrease').startsWith('约 '), isTrue);
  });

  testWidgets('组合贷显示公积金字段并合并本金', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'mortgage-type-2');
    expect(find.byKey(const Key('mortgage-provident-amount')), findsOneWidget);
    expect(find.byKey(const Key('mortgage-provident-rate')), findsOneWidget);
    await reveal(tester, 'mortgage-result-loan');
    expect(textOf(tester, 'mortgage-result-loan'), '1,600,000.00 元');
  });

  testWidgets('金额使用内置键盘修改并重算', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'mortgage-amount');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('numeric-sheet-display')), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await enterValue(tester, '50');
    await reveal(tester, 'mortgage-result-loan');
    expect(textOf(tester, 'mortgage-result-loan'), '500,000.00 元');
    expect(textOf(tester, 'mortgage-amount-value'), '50');
  });

  testWidgets('期限预设切换为 10 年', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'mortgage-term-10');
    await reveal(tester, 'mortgage-result-payment');
    expect(find.textContaining('共 120 期'), findsOneWidget);
    expect(textOf(tester, 'mortgage-years-value'), '10');
  });

  testWidgets('还款明细可打开并滚动到末期', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'mortgage-term-10');
    await reveal(tester, 'mortgage-schedule-button');
    await tapKey(tester, 'mortgage-schedule-button');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mortgage-schedule-sheet')), findsOneWidget);
    expect(find.byKey(const Key('mortgage-schedule-row-1')), findsOneWidget);

    final sheetScrollable = find.descendant(
      of: find.byKey(const Key('mortgage-schedule-sheet')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('mortgage-schedule-row-120')),
      300,
      scrollable: sheetScrollable,
    );
    expect(find.byKey(const Key('mortgage-schedule-row-120')), findsOneWidget);
  });

  testWidgets('清空金额显示错误并禁止查看明细', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'mortgage-amount');
    await tester.pumpAndSettle();
    await tapKey(tester, 'numeric-key-clear');
    await tapKey(tester, 'numeric-key-done');
    await tester.pumpAndSettle();

    await reveal(tester, 'mortgage-error');
    expect(find.byKey(const Key('mortgage-error')), findsOneWidget);
    final button = tester.widget<OutlinedButton>(
      find.byKey(const Key('mortgage-schedule-button')),
    );
    expect(button.onPressed, isNull);

    await tapKey(tester, 'mortgage-amount');
    await tester.pumpAndSettle();
    await enterValue(tester, '100');
    expect(find.byKey(const Key('mortgage-error')), findsNothing);
  });

  testWidgets('多功能页可进入房贷计算', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: buildAppTheme(Brightness.light),
        home: const MultifunctionPage(),
      ),
    );

    expect(find.byKey(const Key('tool-mortgage')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tool-mortgage')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mortgage-page')), findsOneWidget);
  });
}
