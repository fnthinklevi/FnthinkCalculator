import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/app/app.dart';
import 'package:fnthink_calculator/app/settings_controller.dart';
import 'package:fnthink_calculator/app/wide_layout.dart';
import 'package:fnthink_calculator/features/calculator/calculator_controller.dart';
import 'package:fnthink_calculator/features/calculator/history_page.dart';
import 'package:fnthink_calculator/features/converter/converter_page.dart';
import 'package:fnthink_calculator/features/converter/radix_page.dart';
import 'package:fnthink_calculator/features/converter/unit_data.dart';
import 'package:fnthink_calculator/features/multifunction/bmi/bmi_page.dart';
import 'package:fnthink_calculator/features/multifunction/kinship/kinship_page.dart';
import 'package:fnthink_calculator/features/multifunction/mortgage/mortgage_page.dart';
import 'package:fnthink_calculator/features/multifunction/ratio/ratio_page.dart';
import 'package:fnthink_calculator/features/multifunction/tax/tax_page.dart';
import 'package:fnthink_calculator/features/multifunction/time/time_tool_pages.dart';
import 'package:fnthink_calculator/features/multifunction/uppercase_page.dart';
import 'package:fnthink_calculator/features/settings/settings_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

void setSize(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
}

Widget pageApp(Widget home) {
  return MaterialApp(
    locale: const Locale('zh', 'CN'),
    supportedLocales: const [Locale('zh', 'CN')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: buildAppTheme(Brightness.light),
    builder: (context, child) => AppWideLayout(child: child!),
    home: home,
  );
}

int gridColumns(WidgetTester tester) {
  final grid = tester.widget<GridView>(find.byType(GridView));
  final delegate =
      grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
  return delegate.crossAxisCount;
}

void main() {
  testWidgets('外屏、内屏、平板与超过 900dp 的宽度按断点重排', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cases = <(double, double, int)>[
      (405, 940, 3),
      (600, 960, 4),
      (800, 1280, 5),
      (835, 938, 5),
      (938, 835, 6),
      (1200, 1920, 6),
    ];
    for (final (width, height, columns) in cases) {
      setSize(tester, width, height);
      await tester.pumpWidget(
        FnthinkCalculatorApp(settings: SettingsController()),
      );
      await tester.pumpAndSettle();

      if (width > kAppMaxWidth) {
        final cap = find.byKey(const Key('app-width-cap'));
        expect(cap, findsOneWidget);
        expect(tester.getSize(cap).width, kAppMaxWidth);
      } else {
        expect(find.byKey(const Key('app-width-cap')), findsNothing);
      }

      await tester.tap(find.byKey(const Key('tab-converter')));
      await tester.pumpAndSettle();
      expect(gridColumns(tester), columns, reason: '$width × $height');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('折叠屏内外屏切换保留计算状态', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    setSize(tester, 405, 940);
    await tester.pumpWidget(
      FnthinkCalculatorApp(settings: SettingsController()),
    );
    await tester.pumpAndSettle();

    for (final key in ['key-1', 'key-plus', 'key-2']) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pump();
    }
    expect(
      tester.widget<Text>(find.byKey(const Key('calc-preview-text'))).data,
      '= 3',
    );

    setSize(tester, 835, 938);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('calc-preview-text'))).data,
      '= 3',
    );

    await tester.tap(find.byKey(const Key('tab-converter')));
    await tester.pumpAndSettle();
    expect(gridColumns(tester), 5);

    setSize(tester, 1200, 1920);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-width-cap')), findsOneWidget);
    expect(gridColumns(tester), 6);

    await tester.tap(find.byKey(const Key('tab-calculator')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('calc-preview-text'))).data,
      '= 3',
    );

    setSize(tester, 938, 835);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-width-cap')), findsOneWidget);
    expect(find.byKey(const Key('landscape-layout')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('calc-preview-text'))).data,
      '= 3',
    );

    await tester.tap(find.byKey(const Key('tab-converter')));
    await tester.pumpAndSettle();
    expect(gridColumns(tester), 6);

    setSize(tester, 405, 940);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-width-cap')), findsNothing);
    await tester.tap(find.byKey(const Key('tab-calculator')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('portrait-layout')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('平板与横屏下主要页面无布局溢出', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final pages = <(String, Widget Function())>[
      ('设置', () => SettingsPage(settings: SettingsController())),
      ('历史记录', () => HistoryPage(controller: CalculatorController())),
      ('单位换算', () => ConverterPage(category: UnitData.length)),
      ('进制转换', () => const RadixPage()),
      ('大写数字', () => const UppercasePage()),
      ('称呼计算', () => const KinshipPage()),
      ('个税计算', () => const TaxPage()),
      ('房贷计算', () => const MortgagePage()),
      ('BMI', () => const BmiPage()),
      ('比例计算', () => const RatioPage()),
      ('时长计算', () => const DurationPage()),
      ('日期差', () => const DateDifferencePage()),
    ];
    final sizes = <(double, double)>[
      (800, 1280),
      (835, 938),
      (938, 835),
      (1200, 1920),
      (1280, 800),
    ];
    for (final (width, height) in sizes) {
      setSize(tester, width, height);
      for (final (name, build) in pages) {
        await tester.pumpWidget(pageApp(build()));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$name 在 ${width.toInt()} × ${height.toInt()} 下溢出',
        );
      }
    }
  });
}
