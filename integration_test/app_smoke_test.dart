import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/app/app.dart';
import 'package:fnthink_calculator/app/settings_controller.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('应用冷启动、计算与换算冒烟', (tester) async {
    await tester.pumpWidget(
      FnthinkCalculatorApp(settings: SettingsController()),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calculator-page')), findsOneWidget);

    for (final key in ['key-1', 'key-plus', 'key-2']) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('key-equals')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('calc-result-text'))).data,
      '3',
    );

    await tester.tap(find.byKey(const Key('tab-converter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('converter-category-length')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('converter-detail-page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('numeric-key-clear')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('numeric-key-5')));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('converter-input'))).data,
      '5',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('converter-result'))).data,
      '500',
    );
  });
}
