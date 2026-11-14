import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/app/app.dart';
import 'package:fnthink_calculator/app/app_scope.dart';
import 'package:fnthink_calculator/app/settings_controller.dart';
import 'package:fnthink_calculator/features/calculator/calculator_controller.dart';
import 'package:fnthink_calculator/features/calculator/calculator_page.dart';
import 'package:fnthink_calculator/features/converter/converter_home_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';
import 'package:fnthink_calculator/theme/motion.dart';
import 'package:fnthink_calculator/widgets/motion.dart';

void configureSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

double fadeValue(WidgetTester tester, Key key) {
  final opacity = tester.widget<Opacity>(
    find.descendant(of: find.byKey(key), matching: find.byType(Opacity)).first,
  );
  return opacity.opacity;
}

void main() {
  test('所有平台使用右滑入页面转场', () {
    final theme = buildAppTheme(Brightness.light);
    for (final platform in TargetPlatform.values) {
      expect(
        theme.pageTransitionsTheme.builders[platform],
        isA<CalcPageTransitionsBuilder>(),
        reason: '$platform',
      );
    }
  });

  testWidgets('切换标签时新页面淡入', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(
      FnthinkCalculatorApp(settings: SettingsController()),
    );
    await tester.pumpAndSettle();
    expect(fadeValue(tester, const Key('tab-content-fade')), 1);

    await tester.tap(find.byKey(const Key('tab-converter')));
    await tester.pump();
    expect(fadeValue(tester, const Key('tab-content-fade')), lessThan(1));
    await tester.pumpAndSettle();
    expect(fadeValue(tester, const Key('tab-content-fade')), 1);
  });

  testWidgets('二级页从右侧滑入并落位', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: const ConverterHomePage(),
      ),
    );

    await tester.tap(find.byKey(const Key('converter-category-length')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final page = find.byKey(const Key('converter-detail-page'));
    expect(page, findsOneWidget);
    expect(tester.getTopLeft(page).dx, greaterThan(0));

    await tester.pumpAndSettle();
    expect(tester.getTopLeft(page).dx, closeTo(0, 0.5));
  });

  testWidgets('科学键盘切换只保留一套按键', (tester) async {
    configureSurface(tester);
    final controller = CalculatorController();
    await tester.pumpWidget(
      AppScope(
        settings: SettingsController(),
        child: MaterialApp(
          locale: const Locale('zh', 'CN'),
          supportedLocales: const [Locale('zh', 'CN')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: buildAppTheme(Brightness.light),
          home: Scaffold(body: CalculatorPage(controller: controller)),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('key-scientific')));
    await tester.pump();
    expect(find.byKey(const Key('key-7')), findsOneWidget);
    expect(find.byKey(const Key('sci-second')), findsOneWidget);
    expect(find.byKey(const Key('keypad-mode-fade')), findsOneWidget);
    controller.dispose();
  });

  testWidgets('系统减弱动画时直接呈现最终状态', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: FadeSlideIn(
              key: const Key('reduced-motion-fade'),
              child: const Text('内容'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const Key('reduced-motion-fade')),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
  });

  test('动效令牌保持统一口径', () {
    expect(CalcMotion.fast, const Duration(milliseconds: 120));
    expect(CalcMotion.standard, const Duration(milliseconds: 180));
    expect(CalcMotion.slow, const Duration(milliseconds: 260));
  });

  test('关闭系统预见式返回，避免与自定义转场叠加', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android:enableOnBackInvokedCallback="false"'));
  });
}
