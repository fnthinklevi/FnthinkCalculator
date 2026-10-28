import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/app/app.dart';
import 'package:fnthink_calculator/app/settings_controller.dart';

void main() {
  testWidgets('三标签可以切换', (tester) async {
    final settings = SettingsController();
    await tester.pumpWidget(FnthinkCalculatorApp(settings: settings));

    expect(find.byKey(const Key('calculator-page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tab-converter')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('converter-page')), findsOneWidget);
    expect(find.byKey(const Key('calculator-page')), findsNothing);

    await tester.tap(find.byKey(const Key('tab-multifunction')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('multifunction-page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tab-calculator')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calculator-page')), findsOneWidget);
  });

  testWidgets('菜单可以打开设置并切换深色模式', (tester) async {
    final settings = SettingsController();
    await tester.pumpWidget(FnthinkCalculatorApp(settings: settings));

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-theme-dark')), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-theme-dark')));
    await tester.pumpAndSettle();

    expect(settings.themeMode, ThemeMode.dark);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  testWidgets('设置页可切换主题、触感与角度单位', (tester) async {
    final settings = SettingsController(themeMode: ThemeMode.dark);
    await tester.pumpWidget(FnthinkCalculatorApp(settings: settings));

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-theme-light')));
    await tester.pumpAndSettle();
    expect(settings.themeMode, ThemeMode.light);

    await tester.tap(find.byKey(const Key('settings-theme-system')));
    await tester.pumpAndSettle();
    expect(settings.themeMode, ThemeMode.system);

    await tester.ensureVisible(find.byKey(const Key('settings-haptics')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-haptics')));
    await tester.pumpAndSettle();
    expect(settings.haptics, isFalse);

    await tester.ensureVisible(find.byKey(const Key('settings-angle-radians')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-angle-radians')));
    await tester.pumpAndSettle();
    expect(settings.angleUnit, AngleUnit.radians);
  });
}
