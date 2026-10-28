import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/app/app.dart';
import 'package:fnthink_calculator/app/settings_controller.dart';
import 'package:fnthink_calculator/features/calculator/calculator_controller.dart';

void configureSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

CalculatorController sampleController() {
  final controller = CalculatorController();
  controller.inputDigit('1');
  controller.inputOperator('+');
  controller.inputDigit('2');
  return controller;
}

void main() {
  testWidgets('浅色计算器布局', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(
      FnthinkCalculatorApp(
        settings: SettingsController(themeMode: ThemeMode.light),
        calculatorController: sampleController(),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('goldens/calculator_light.png'),
    );
  });

  testWidgets('深色计算器布局', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(
      FnthinkCalculatorApp(
        settings: SettingsController(themeMode: ThemeMode.dark),
        calculatorController: sampleController(),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('goldens/calculator_dark.png'),
    );
  });
}
