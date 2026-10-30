import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/converter/converter_home_page.dart';
import 'package:fnthink_calculator/features/multifunction/mortgage/mortgage_page.dart';
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
  final finder = find.byKey(Key(key));
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
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

Future<void> openResult(WidgetTester tester) async {
  await tapKey(tester, 'mortgage-calculate');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('默认商业贷表单符合标准并弹出房贷清单', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    expect(find.byKey(const Key('mortgage-page')), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(textOf(tester, 'mortgage-amount-value'), '100');
    expect(textOf(tester, 'mortgage-rate-summary'), '3.5% + 0‰ = 3.5%');
    expect(find.byKey(const Key('mortgage-method-row')), findsOneWidget);
    expect(find.byKey(const Key('mortgage-date-row')), findsOneWidget);

    await openResult(tester);
    expect(find.byKey(const Key('mortgage-result-page')), findsOneWidget);
    expect(find.byKey(const Key('mortgage-result-payment')), findsOneWidget);
    expect(textOf(tester, 'mortgage-result-loan'), '100.00');
    expect(find.textContaining('40年还款明细'), findsOneWidget);
  });

  testWidgets('切换等额本金显示首月需还款与递减', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'mortgage-method-row');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mortgage-method-1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('等额本金'), findsOneWidget);

    await openResult(tester);
    expect(find.text('首月需还款'), findsOneWidget);
  });

  testWidgets('组合贷显示两笔金额并合并贷款总额', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'mortgage-type-2');
    expect(find.byKey(const Key('mortgage-provident-amount')), findsOneWidget);
    expect(find.byKey(const Key('mortgage-provident-rate')), findsOneWidget);
    expect(find.byKey(const Key('mortgage-provident-years-row')), findsOneWidget);

    await openResult(tester);
    expect(textOf(tester, 'mortgage-result-loan'), '160.00');
  });

  testWidgets('金额使用内置键盘修改并重算', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'mortgage-amount');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('numeric-sheet-display')), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await enterValue(tester, '50');
    expect(textOf(tester, 'mortgage-amount-value'), '50');
    await openResult(tester);
    expect(textOf(tester, 'mortgage-result-loan'), '50.00');
  });

  testWidgets('年数选择器与利率标准可选', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'mortgage-years-row');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mortgage-years-option-39')));
    await tester.pumpAndSettle();
    expect(find.textContaining('39年（468个月）'), findsOneWidget);

    await tapKey(tester, 'mortgage-rate-standard-row');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mortgage-rate-standard-base')));
    await tester.pumpAndSettle();
    expect(textOf(tester, 'mortgage-rate-summary'), contains('基准利率'));
  });

  testWidgets('房贷清单按年展开明细', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());
    await openResult(tester);

    final yearToggle = find.byKey(const Key('mortgage-year-toggle-2026'));
    await tester.ensureVisible(yearToggle);
    await tester.tap(yearToggle);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mortgage-month-row-1')), findsOneWidget);
  });

  testWidgets('换算首页可进入房贷计算', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: buildAppTheme(Brightness.light),
        home: const ConverterHomePage(),
      ),
    );

    expect(find.byKey(const Key('tool-mortgage')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tool-mortgage')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mortgage-page')), findsOneWidget);
  });
}
