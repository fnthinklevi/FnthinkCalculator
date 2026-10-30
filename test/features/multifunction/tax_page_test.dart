import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/multifunction/tax/tax_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

Widget harness() {
  return MaterialApp(
    theme: buildAppTheme(Brightness.light),
    home: const TaxPage(),
  );
}

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

String textOf(WidgetTester tester, String key) {
  return tester.widget<Text>(find.byKey(Key(key))).data!;
}

void main() {
  testWidgets('月薪个税计算结果', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byKey(const Key('numeric-key-7')), findsNothing);
    await tapKey(tester, 'tax-calculate');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tax-result-page')), findsOneWidget);
    expect(textOf(tester, 'tax-result-tax'), '290.00 元');
    expect(textOf(tester, 'tax-result-after'), '税后收入 9,710.00 元');
    expect(textOf(tester, 'tax-result-taxable'), '5,000.00 元');
  });

  testWidgets('年终奖单独计税', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'tax-tab-1');
    await tester.pumpAndSettle();
    await tapKey(tester, 'tax-calculate');
    await tester.pumpAndSettle();

    expect(textOf(tester, 'tax-result-tax'), '4,790.00 元');
    expect(textOf(tester, 'tax-result-after'), '税后收入 45,210.00 元');
  });

  testWidgets('专项附加扣除影响结果', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'tax-deduction');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tax-deduction-child')));
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(find.textContaining('合计 2000 元'), findsOneWidget);

    await tapKey(tester, 'tax-calculate');
    await tester.pumpAndSettle();
    expect(textOf(tester, 'tax-result-tax'), '90.00 元');
    expect(textOf(tester, 'tax-result-after'), '税后收入 9,910.00 元');
  });

  testWidgets('缴纳期数与所在地入口可用', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'tax-installments');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tax-installments-option-12')));
    await tester.pumpAndSettle();
    expect(find.text('12'), findsWidgets);

    await tapKey(tester, 'tax-location');
    await tester.pumpAndSettle();
    expect(find.text('全国统一税率'), findsWidgets);
    await tester.tap(find.text('知道了'));
    await tester.pumpAndSettle();
  });
}
