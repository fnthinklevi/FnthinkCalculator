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

void configureSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

String resultText(WidgetTester tester) {
  return tester.widget<Text>(find.byKey(const Key('converter-result'))).data!;
}

String inputText(WidgetTester tester) {
  return tester.widget<Text>(find.byKey(const Key('converter-input'))).data!;
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

void main() {
  testWidgets('长度默认 m→cm，内置键盘输入与交换正确', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(UnitData.length));
    expect(find.byType(TextField), findsNothing);
    expect(resultText(tester), '100');

    await enterNumber(tester, '100');
    expect(inputText(tester), '100');
    expect(resultText(tester), '10,000');

    await tapKey(tester, 'converter-swap');
    expect(resultText(tester), '1');
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('单位选择器可切换目标单位', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(UnitData.length));
    await tapKey(tester, 'converter-swap');
    await enterNumber(tester, '100');

    await tester.tap(find.byKey(const Key('unit-to-picker')));
    await tester.pumpAndSettle();
    expect(find.text('选择单位'), findsOneWidget);
    await tester.tap(find.byKey(const Key('unit-option-km')));
    await tester.pumpAndSettle();

    expect(resultText(tester), '0.001');
  });

  testWidgets('换算页不使用系统键盘', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(UnitData.length));
    expect(find.byType(TextField), findsNothing);
    expect(find.byKey(const Key('numeric-key-7')), findsOneWidget);
    expect(find.byKey(const Key('numeric-key-done')), findsNothing);
  });

  testWidgets('温度默认 C→F，支持负号', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness(UnitData.temperature));
    expect(resultText(tester), '33.8');

    await enterNumber(tester, '100');
    expect(resultText(tester), '212');

    await enterNumber(tester, '-40');
    expect(inputText(tester), '-40');
    expect(resultText(tester), '-40');
  });

  testWidgets('时间换算显示口径说明', (tester) async {
    configureSurface(tester);
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
    expect(find.byKey(const Key('numeric-key-7')), findsOneWidget);
  });
}
