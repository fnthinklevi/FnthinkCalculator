import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/converter/radix_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

Widget harness() {
  return MaterialApp(
    theme: buildAppTheme(Brightness.light),
    home: const RadixPage(),
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
  await tester.tap(find.byKey(Key(key)));
  await tester.pump();
}

void main() {
  testWidgets('十进制与二进制双行联动', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    expect(textOf(tester, 'radix-value-0'), '1');
    expect(textOf(tester, 'radix-value-1'), '1');
    expect(find.byType(TextField), findsNothing);

    await tapKey(tester, 'radix-key-clear');
    for (final digit in ['2', '5', '5']) {
      await tapKey(tester, 'radix-key-$digit');
    }
    expect(textOf(tester, 'radix-value-0'), '255');
    expect(textOf(tester, 'radix-value-1'), '11111111');
  });

  testWidgets('二进制禁用非法数字，激活后首键替换', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tester.tap(find.byKey(const Key('radix-row-1')));
    await tester.pump();
    expect(textOf(tester, 'radix-value-1'), '1');

    await tapKey(tester, 'radix-key-2');
    expect(textOf(tester, 'radix-value-1'), '1');

    for (final digit in ['1', '0', '1', '0']) {
      await tapKey(tester, 'radix-key-$digit');
    }
    expect(textOf(tester, 'radix-value-1'), '1010');
    expect(textOf(tester, 'radix-value-0'), '10');
  });

  testWidgets('可切换十六进制并启用 A-F', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tester.tap(find.byKey(const Key('radix-picker-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('radix-option-16')));
    await tester.pumpAndSettle();

    expect(find.text('十六进制'), findsOneWidget);
    await tester.tap(find.byKey(const Key('radix-row-1')));
    await tester.pump();
    await tapKey(tester, 'radix-key-1');
    await tapKey(tester, 'radix-key-A');
    expect(textOf(tester, 'radix-value-1'), '1A');
    expect(textOf(tester, 'radix-value-0'), '26');
  });
}
