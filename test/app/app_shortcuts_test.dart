import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/app/app.dart';
import 'package:fnthink_calculator/app/app_shortcuts.dart';
import 'package:fnthink_calculator/app/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(AppShortcuts.channel, null);
  });

  void mockInitialShortcut(String? id) {
    messenger.setMockMethodCallHandler(AppShortcuts.channel, (call) async {
      if (call.method == 'getInitialShortcut') return id;
      return null;
    });
  }

  void configureSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('冷启动快捷方式打开时间计算', (tester) async {
    configureSurface(tester);
    mockInitialShortcut('time_calculation');
    await tester.pumpWidget(
      FnthinkCalculatorApp(settings: SettingsController()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('time-calculation-page')), findsOneWidget);
  });

  testWidgets('冷启动快捷方式打开日期计算', (tester) async {
    configureSurface(tester);
    mockInitialShortcut('date_calculation');
    await tester.pumpWidget(
      FnthinkCalculatorApp(settings: SettingsController()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('date-difference-page')), findsOneWidget);
  });

  testWidgets('热启动快捷方式打开汇率换算', (tester) async {
    configureSurface(tester);
    mockInitialShortcut(null);
    await tester.pumpWidget(
      FnthinkCalculatorApp(settings: SettingsController()),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calculator-page')), findsOneWidget);

    await messenger.handlePlatformMessage(
      AppShortcuts.channel.name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('shortcut', 'currency'),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('currency-page')), findsOneWidget);
  });

  testWidgets('未同意隐私时暂存快捷方式，同意后再打开', (tester) async {
    configureSurface(tester);
    mockInitialShortcut('time_calculation');
    await tester.pumpWidget(
      FnthinkCalculatorApp(
        settings: SettingsController(privacyAccepted: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('privacy-consent-dialog')), findsOneWidget);
    expect(find.byKey(const Key('time-calculation-page')), findsNothing);

    await tester.tap(find.byKey(const Key('privacy-agree')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('time-calculation-page')), findsOneWidget);
  });

  test('快捷方式 id 映射与未知值', () {
    expect(AppShortcut.fromId('time_calculation'), AppShortcut.timeCalculation);
    expect(AppShortcut.fromId('date_calculation'), AppShortcut.dateCalculation);
    expect(AppShortcut.fromId('currency'), AppShortcut.currency);
    expect(AppShortcut.fromId('unknown'), isNull);
    expect(AppShortcut.fromId(null), isNull);
  });
}
