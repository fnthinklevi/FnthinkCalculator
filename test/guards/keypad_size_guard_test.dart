import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/app/app_scope.dart';
import 'package:fnthink_calculator/app/settings_controller.dart';
import 'package:fnthink_calculator/features/calculator/calculator_controller.dart';
import 'package:fnthink_calculator/features/calculator/calculator_page.dart';
import 'package:fnthink_calculator/features/converter/converter_page.dart';
import 'package:fnthink_calculator/features/converter/radix_page.dart';
import 'package:fnthink_calculator/features/converter/unit_data.dart';
import 'package:fnthink_calculator/features/multifunction/kinship/kinship_page.dart';
import 'package:fnthink_calculator/features/multifunction/time/time_tool_pages.dart';
import 'package:fnthink_calculator/features/multifunction/uppercase_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

Widget app(Widget home) {
  return MaterialApp(
    locale: const Locale('zh', 'CN'),
    supportedLocales: const [Locale('zh', 'CN')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: buildAppTheme(Brightness.light),
    home: home,
  );
}

void configureSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 3000);
  tester.view.devicePixelRatio = 3.75;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Size keySize(WidgetTester tester, String key) {
  return tester.getSize(find.byKey(Key(key)));
}

double visualDiameter(WidgetTester tester, String key) {
  final size = keySize(tester, key);
  return math.min(size.width, size.height);
}

void expectConsistentKey(
  WidgetTester tester,
  String page,
  String key,
  double baseline,
) {
  final diameter = visualDiameter(tester, key);
  expect(
    diameter,
    greaterThanOrEqualTo(baseline * 0.9),
    reason: '$page 的 $key 圆键明显小于换算页基准：$diameter < ${baseline * 0.9}',
  );
  expect(
    diameter,
    greaterThanOrEqualTo(64),
    reason: '$page 的 $key 圆键小于 64dp：$diameter',
  );
}

void main() {
  testWidgets('各内置键盘圆键直径与换算页基准一致', (tester) async {
    configureSurface(tester);

    await tester.pumpWidget(app(ConverterPage(category: UnitData.length)));
    final baseline = visualDiameter(tester, 'numeric-key-7');
    expect(baseline, greaterThanOrEqualTo(70));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(app(ConverterPage(category: UnitData.temperature)));
    expectConsistentKey(tester, '温度换算', 'numeric-key-7', baseline);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(app(const UppercasePage()));
    final uppercase = keySize(tester, 'numeric-key-7');
    expect(uppercase.width, closeTo(uppercase.height, 0.5));
    expectConsistentKey(tester, '大写数字', 'numeric-key-7', baseline);
    final tall = keySize(tester, 'numeric-key-clear');
    expect(tall.width, closeTo(uppercase.width, 0.5));
    expect(tall.height, closeTo(uppercase.height * 2 + 10, 1));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(app(const RadixPage()));
    final radix = keySize(tester, 'radix-key-7');
    expect(radix.width, closeTo(radix.height, 0.5));
    expectConsistentKey(tester, '进制转换', 'radix-key-7', baseline);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(app(const TimeCalculationPage()));
    expectConsistentKey(tester, '时间计算', 'duration-key-7', baseline);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(app(const KinshipPage()));
    expectConsistentKey(tester, '称呼计算', 'kinship-key-父', baseline);
    expect(tester.takeException(), isNull);

    final controller = CalculatorController();
    await tester.pumpWidget(
      AppScope(
        settings: SettingsController(),
        child: app(Scaffold(body: CalculatorPage(controller: controller))),
      ),
    );
    expectConsistentKey(tester, '计算器', 'key-7', baseline);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });
}
