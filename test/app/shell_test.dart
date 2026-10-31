import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/app/app.dart';
import 'package:fnthink_calculator/app/settings_controller.dart';

void main() {
  testWidgets('两标签可以切换，换算页含工具入口', (tester) async {
    final settings = SettingsController();
    await tester.pumpWidget(FnthinkCalculatorApp(settings: settings));

    expect(find.byKey(const Key('calculator-page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tab-converter')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('converter-page')), findsOneWidget);
    expect(find.byKey(const Key('calculator-page')), findsNothing);
    expect(find.byKey(const Key('tool-mortgage')), findsOneWidget);
    expect(find.byKey(const Key('tool-uppercase')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('tool-ratio')),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byKey(const Key('tool-ratio')), findsOneWidget);

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
    expect(find.byKey(const Key('settings-page')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-theme-dark')),
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
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

    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-theme-light')),
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('settings-theme-light')));
    await tester.pumpAndSettle();
    expect(settings.themeMode, ThemeMode.light);

    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-theme-system')),
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('settings-theme-system')));
    await tester.pumpAndSettle();
    expect(settings.themeMode, ThemeMode.system);

    await tester.ensureVisible(find.byKey(const Key('settings-haptics')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-haptics')));
    await tester.pumpAndSettle();
    expect(settings.haptics, isFalse);

    await tester.drag(find.byType(Scrollable).last, const Offset(0, 400));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('settings-angle-switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-angle-switch')));
    await tester.pumpAndSettle();
    expect(settings.angleUnit, AngleUnit.radians);

    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-voice')),
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(find.text('语音播报'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('语音播报'));
    await tester.pumpAndSettle();
    expect(settings.voice, isTrue);
  });

  testWidgets('设置页可切换百分数算法并即时演示', (tester) async {
    final settings = SettingsController();
    await tester.pumpWidget(FnthinkCalculatorApp(settings: settings));

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    expect(settings.percentMode, PercentMode.value);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('settings-percent-preview')))
          .data,
      '= 100.5',
    );

    await tester.tap(find.byKey(const Key('settings-percent-proportion')));
    await tester.pumpAndSettle();
    expect(settings.percentMode, PercentMode.proportion);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('settings-percent-preview')))
          .data,
      '= 150',
    );
  });
}
