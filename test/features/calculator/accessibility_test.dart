import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/app/app_scope.dart';
import 'package:fnthink_calculator/app/settings_controller.dart';
import 'package:fnthink_calculator/features/calculator/calculator_controller.dart';
import 'package:fnthink_calculator/features/calculator/calculator_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

Widget harness(CalculatorController controller, {double textScale = 1}) {
  return AppScope(
    settings: SettingsController(),
    child: MaterialApp(
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildAppTheme(Brightness.light),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: Scaffold(body: CalculatorPage(controller: controller)),
    ),
  );
}

void configureSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('按键具备读屏语义', (tester) async {
    configureSurface(tester);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harness(CalculatorController()));
    expect(find.bySemanticsLabel('1'), findsOneWidget);
    expect(find.bySemanticsLabel('加'), findsOneWidget);
    expect(find.bySemanticsLabel('科学计算'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('1.3 倍字体仍可计算且不溢出', (tester) async {
    configureSurface(tester);
    final controller = CalculatorController();
    await tester.pumpWidget(harness(controller, textScale: 1.3));
    await tester.pump();

    await tester.tap(find.byKey(const Key('key-1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('key-plus')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('key-2')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('key-equals')));
    await tester.pump();

    expect(controller.mainText, '3');
    expect(tester.takeException(), isNull);
  });
}
