import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/app/app_scope.dart';
import 'package:fnthink_calculator/app/settings_controller.dart';
import 'package:fnthink_calculator/features/calculator/calculator_controller.dart';
import 'package:fnthink_calculator/features/calculator/calculator_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

Widget harness(CalculatorController controller, SettingsController settings) {
  return AppScope(
    settings: settings,
    child: MaterialApp(
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildAppTheme(Brightness.light),
      home: Scaffold(body: CalculatorPage(controller: controller)),
    ),
  );
}

void configureSurface(WidgetTester tester, {required bool landscape}) {
  tester.view.physicalSize = landscape
      ? const Size(2400, 1080)
      : const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.pump();
  await tester.tap(find.byKey(Key(key)));
  await tester.pump();
}

void main() {
  testWidgets('2nd 切换反三角', (tester) async {
    configureSurface(tester, landscape: false);
    final controller = CalculatorController();
    final settings = SettingsController();
    await tester.pumpWidget(harness(controller, settings));

    await tapKey(tester, 'key-scientific');
    await tapKey(tester, 'sci-second');
    expect(find.text('sin⁻¹'), findsOneWidget);

    await tapKey(tester, 'sci-sin');
    await tapKey(tester, 'key-0');
    await tapKey(tester, 'key-dot');
    await tapKey(tester, 'key-5');
    await tapKey(tester, 'key-equals');

    expect(controller.expression, 'asin(0.5)');
    final result = tester.widget<Text>(
      find.byKey(const Key('calc-result-text')),
    );
    expect(result.data, contains('30'));
  });

  testWidgets('DEG/RAD 切换并影响计算', (tester) async {
    configureSurface(tester, landscape: false);
    final controller = CalculatorController();
    final settings = SettingsController();
    await tester.pumpWidget(harness(controller, settings));

    await tapKey(tester, 'key-scientific');
    await tapKey(tester, 'sci-angle');
    expect(settings.angleUnit, AngleUnit.radians);
    expect(find.text('RAD'), findsOneWidget);

    await tapKey(tester, 'sci-sin');
    await tapKey(tester, 'key-3');
    await tapKey(tester, 'key-0');
    await tapKey(tester, 'key-equals');

    final result = tester.widget<Text>(
      find.byKey(const Key('calc-result-text')),
    );
    expect(result.data, contains('-0.988'));
  });

  testWidgets('2nd 下的 10^x 与 e^x', (tester) async {
    configureSurface(tester, landscape: false);
    final controller = CalculatorController();
    final settings = SettingsController();
    await tester.pumpWidget(harness(controller, settings));

    await tapKey(tester, 'key-scientific');
    await tapKey(tester, 'sci-second');
    await tapKey(tester, 'sci-log');
    await tapKey(tester, 'key-2');
    expect(controller.expression, '10^2');
    await tapKey(tester, 'key-equals');
    expect(controller.mainText, '100');

    await tapKey(tester, 'key-clear');
    await tapKey(tester, 'sci-ln');
    await tapKey(tester, 'key-0');
    expect(controller.expression, 'e^0');
    await tapKey(tester, 'key-equals');
    expect(controller.mainText, '1');
  });

  testWidgets('横屏显示左右布局', (tester) async {
    configureSurface(tester, landscape: true);
    final controller = CalculatorController()..toggleScientific();
    final settings = SettingsController();
    await tester.pumpWidget(harness(controller, settings));

    expect(find.byKey(const Key('landscape-layout')), findsOneWidget);
    expect(find.byKey(const Key('key-7')), findsOneWidget);
    expect(find.byKey(const Key('sci-sin')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
