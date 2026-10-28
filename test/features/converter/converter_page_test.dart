import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/converter/converter_home_page.dart';
import 'package:fnthink_calculator/features/converter/converter_page.dart';
import 'package:fnthink_calculator/features/converter/unit_data.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

Widget harness(UnitCategory category) {
  return MaterialApp(
    locale: const Locale('zh', 'CN'),
    supportedLocales: const [Locale('zh', 'CN')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: buildAppTheme(Brightness.light),
    home: ConverterPage(category: category),
  );
}

String resultText(WidgetTester tester) {
  return tester.widget<Text>(find.byKey(const Key('converter-result'))).data!;
}

void main() {
  testWidgets('长度默认 m→cm，输入与交换正确', (tester) async {
    await tester.pumpWidget(harness(UnitData.length));
    expect(resultText(tester), '100');

    await tester.enterText(find.byKey(const Key('converter-input')), '100');
    await tester.pump();
    expect(resultText(tester), '10,000');

    await tester.tap(find.byKey(const Key('converter-swap')));
    await tester.pump();
    expect(resultText(tester), '1');
  });

  testWidgets('单位选择器可切换目标单位', (tester) async {
    await tester.pumpWidget(harness(UnitData.length));
    await tester.tap(find.byKey(const Key('converter-swap')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('converter-input')), '100');
    await tester.pump();

    await tester.tap(find.byKey(const Key('unit-to-picker')));
    await tester.pumpAndSettle();
    expect(find.text('选择单位'), findsOneWidget);
    await tester.tap(find.byKey(const Key('unit-option-km')));
    await tester.pumpAndSettle();

    expect(resultText(tester), '0.001');
  });

  testWidgets('非法输入显示错误', (tester) async {
    await tester.pumpWidget(harness(UnitData.length));
    await tester.enterText(find.byKey(const Key('converter-input')), 'abc');
    await tester.pump();
    expect(find.text('请输入有效数字'), findsOneWidget);
  });

  testWidgets('温度默认 C→F', (tester) async {
    await tester.pumpWidget(harness(UnitData.temperature));
    expect(resultText(tester), '33.8');

    await tester.enterText(find.byKey(const Key('converter-input')), '100');
    await tester.pump();
    expect(resultText(tester), '212');

    await tester.enterText(find.byKey(const Key('converter-input')), '-40');
    await tester.pump();
    expect(resultText(tester), '-40');
  });

  testWidgets('时间换算显示口径说明', (tester) async {
    await tester.pumpWidget(harness(UnitData.time));
    expect(find.textContaining('1 月 = 30 天'), findsOneWidget);
  });

  testWidgets('换算首页可进入长度详情', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: const ConverterHomePage(),
      ),
    );
    expect(find.byKey(const Key('converter-page')), findsOneWidget);
    expect(find.byKey(const Key('converter-category-length')), findsOneWidget);

    await tester.tap(find.byKey(const Key('converter-category-length')));
    await tester.pumpAndSettle();
    expect(find.text('长度换算'), findsOneWidget);
    expect(find.byKey(const Key('converter-input')), findsOneWidget);
  });
}
