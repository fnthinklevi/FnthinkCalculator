import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/multifunction/uppercase_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

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

Future<void> enterNumber(WidgetTester tester, String value) async {
  await tapKey(tester, 'numeric-key-clear');
  for (final char in value.split('')) {
    if (char == '.') {
      await tapKey(tester, 'numeric-key-dot');
    } else if (char == '-') {
      await tapKey(tester, 'numeric-key-sign');
    } else {
      await tapKey(tester, 'numeric-key-$char');
    }
  }
}

Widget harness() {
  return MaterialApp(
    theme: buildAppTheme(Brightness.light),
    home: const UppercasePage(),
  );
}

void main() {
  testWidgets('默认金额转人民币大写且不使用系统键盘', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());
    expect(find.text('壹仟贰佰叁拾肆元伍角陆分'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byKey(const Key('numeric-key-7')), findsOneWidget);
  });

  testWidgets('内置键盘输入金额与负号', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await enterNumber(tester, '100.05');
    expect(find.text('壹佰元零伍分'), findsOneWidget);

    await enterNumber(tester, '-12');
    expect(find.text('负壹拾贰元整'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
