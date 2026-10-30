import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/multifunction/bmi/bmi_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

Widget harness() {
  return MaterialApp(
    theme: buildAppTheme(Brightness.light),
    home: const BmiPage(),
  );
}

void configureSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> fill(WidgetTester tester, String key, String value) async {
  await tester.enterText(
    find.descendant(of: find.byKey(Key(key)), matching: find.byType(TextField)),
    value,
  );
  await tester.pump();
}

String textOf(WidgetTester tester, String key) {
  return tester.widget<Text>(find.byKey(Key(key))).data!;
}

void main() {
  testWidgets('BMI 表单计算结果与建议体重', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());
    expect(find.byType(TextField), findsNWidgets(3));

    await fill(tester, 'bmi-age', '30');
    await tester.tap(find.byKey(const Key('bmi-gender-female')));
    await tester.pump();
    await fill(tester, 'bmi-height', '175');
    await fill(tester, 'bmi-weight', '70');

    await tester.ensureVisible(find.byKey(const Key('bmi-calculate')));
    await tester.tap(find.byKey(const Key('bmi-calculate')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bmi-result-page')), findsOneWidget);
    expect(textOf(tester, 'bmi-result-value'), '22.9');
    expect(textOf(tester, 'bmi-result-badge'), '正常');
    expect(textOf(tester, 'bmi-result-weight-range'), '56.7 ~ 73.5');
  });

  testWidgets('非法输入给出字段提示', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tester.ensureVisible(find.byKey(const Key('bmi-calculate')));
    await tester.tap(find.byKey(const Key('bmi-calculate')));
    await tester.pump();
    expect(find.byKey(const Key('bmi-error')), findsOneWidget);
    expect(find.textContaining('年龄'), findsWidgets);
  });
}
