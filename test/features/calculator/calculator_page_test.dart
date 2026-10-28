import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/app/app_scope.dart';
import 'package:fnthink_calculator/app/settings_controller.dart';
import 'package:fnthink_calculator/features/calculator/calculator_controller.dart';
import 'package:fnthink_calculator/features/calculator/calculator_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

Widget harness(CalculatorController controller) {
  return AppScope(
    settings: SettingsController(),
    child: MaterialApp(
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildAppTheme(Brightness.light),
      home: Scaffold(body: CalculatorPage(controller: controller)),
    ),
  );
}

void configureSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pump();
}

void main() {
  testWidgets('输入 1+2 得到 3', (tester) async {
    configureSurface(tester);
    final controller = CalculatorController();
    await tester.pumpWidget(harness(controller));

    await tapKey(tester, 'key-1');
    await tapKey(tester, 'key-plus');
    await tapKey(tester, 'key-2');

    final preview = tester.widget<Text>(
      find.byKey(const Key('calc-preview-text')),
    );
    expect(preview.data, '= 3');

    await tapKey(tester, 'key-equals');
    final result = tester.widget<Text>(
      find.byKey(const Key('calc-result-text')),
    );
    expect(result.data, '3');
    expect(find.byKey(const Key('calc-preview-text')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('百分比键按小米口径计算', (tester) async {
    configureSurface(tester);
    final controller = CalculatorController();
    await tester.pumpWidget(harness(controller));

    for (final key in [
      'key-1',
      'key-0',
      'key-0',
      'key-plus',
      'key-1',
      'key-0',
    ]) {
      await tapKey(tester, key);
    }
    await tapKey(tester, 'key-percent');
    final preview = tester.widget<Text>(
      find.byKey(const Key('calc-preview-text')),
    );
    expect(preview.data, '= 110');

    await tapKey(tester, 'key-equals');
    final result = tester.widget<Text>(
      find.byKey(const Key('calc-result-text')),
    );
    expect(result.data, '110');
  });

  testWidgets('除零错误可恢复', (tester) async {
    configureSurface(tester);
    final controller = CalculatorController();
    await tester.pumpWidget(harness(controller));

    await tapKey(tester, 'key-1');
    await tapKey(tester, 'key-divide');
    await tapKey(tester, 'key-0');
    await tapKey(tester, 'key-equals');

    final error = tester.widget<Text>(find.byKey(const Key('calc-error-text')));
    expect(error.data, '不能除以 0');

    await tapKey(tester, 'key-2');
    expect(
      tester.widget<Text>(find.byKey(const Key('calc-input-text'))).data,
      '2',
    );
    expect(find.byKey(const Key('calc-error-text')), findsNothing);
  });

  testWidgets('科学面板与正弦', (tester) async {
    configureSurface(tester);
    final controller = CalculatorController();
    await tester.pumpWidget(harness(controller));

    await tapKey(tester, 'key-scientific');
    expect(find.byKey(const Key('sci-sin')), findsOneWidget);

    await tapKey(tester, 'sci-sin');
    await tapKey(tester, 'key-3');
    await tapKey(tester, 'key-0');
    await tapKey(tester, 'key-equals');

    expect(controller.expression, 'sin(30)');
    final result = tester.widget<Text>(
      find.byKey(const Key('calc-result-text')),
    );
    expect(result.data, contains('0.5'));
  });

  testWidgets('历史记录可打开并复用', (tester) async {
    configureSurface(tester);
    final controller = CalculatorController();
    await tester.pumpWidget(harness(controller));

    await tapKey(tester, 'key-1');
    await tapKey(tester, 'key-plus');
    await tapKey(tester, 'key-2');
    await tapKey(tester, 'key-equals');

    await tester.tap(find.byKey(const Key('calc-history')));
    await tester.pumpAndSettle();
    expect(find.text('历史记录'), findsOneWidget);
    expect(find.byKey(const Key('history-entry-0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('history-entry-0')));
    await tester.pumpAndSettle();
    expect(controller.expression, '3');
    expect(
      tester.widget<Text>(find.byKey(const Key('calc-input-text'))).data,
      '3',
    );
  });

  testWidgets('长按清空键可清空历史', (tester) async {
    configureSurface(tester);
    final controller = CalculatorController();
    await tester.pumpWidget(harness(controller));

    await tapKey(tester, 'key-1');
    await tapKey(tester, 'key-equals');
    expect(controller.history, hasLength(1));

    await tester.longPress(find.byKey(const Key('key-clear')));
    await tester.pumpAndSettle();
    expect(find.text('清空历史记录'), findsOneWidget);
    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();
    expect(controller.history, isEmpty);
  });
}
