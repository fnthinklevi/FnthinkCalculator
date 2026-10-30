import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/multifunction/ratio/ratio_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

Widget harness() {
  return MaterialApp(
    theme: buildAppTheme(Brightness.light),
    home: const RatioPage(),
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

void main() {
  testWidgets('按比例分配表单使用系统数字键盘', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byKey(const Key('numeric-key-7')), findsNothing);

    await tester.tap(find.byKey(const Key('ratio-calculate')));
    await tester.pumpAndSettle();
    expect(textOf(tester, 'ratio-result-0'), '33.333333');
    expect(textOf(tester, 'ratio-result-1'), '66.666667');
  });

  testWidgets('比例求值 a:b=c:x', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tester.tap(find.byKey(const Key('ratio-tab-1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '2');
    await tester.enterText(find.byType(TextField).at(1), '3');
    await tester.enterText(find.byType(TextField).at(2), '4');
    await tester.tap(find.byKey(const Key('ratio-calculate')));
    await tester.pumpAndSettle();

    expect(textOf(tester, 'ratio-result-0'), '6');
    expect(textOf(tester, 'ratio-equation'), '2 : 3 = 4 : 6');
  });

  testWidgets('非法比例给出提示', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.enterText(find.byType(TextField).at(1), '0');
    await tester.tap(find.byKey(const Key('ratio-calculate')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ratio-error')), findsOneWidget);
  });
}
