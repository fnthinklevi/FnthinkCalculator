import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/app/app.dart';
import 'package:fnthink_calculator/app/settings_controller.dart';

void main() {
  testWidgets('首次启动显示隐私弹窗，同意后关闭并保存', (tester) async {
    final settings = SettingsController(privacyAccepted: false);
    await tester.pumpWidget(FnthinkCalculatorApp(settings: settings));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('privacy-consent-dialog')), findsOneWidget);
    expect(find.byKey(const Key('privacy-agree')), findsOneWidget);
    expect(find.byKey(const Key('privacy-disagree')), findsOneWidget);

    await tester.tap(find.byKey(const Key('privacy-agree')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('privacy-consent-dialog')), findsNothing);
    expect(settings.privacyAccepted, isTrue);
  });

  testWidgets('隐私弹窗可打开完整隐私政策', (tester) async {
    final settings = SettingsController(privacyAccepted: false);
    await tester.pumpWidget(FnthinkCalculatorApp(settings: settings));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('privacy-view-policy')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('privacy-policy-page')), findsOneWidget);
    expect(find.text('幻念计算器隐私政策'), findsOneWidget);
  });
}
