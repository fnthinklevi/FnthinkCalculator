import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/multifunction/multifunction_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

void main() {
  testWidgets('多功能页可进入时间计算与大写数字', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: const MultifunctionPage(),
      ),
    );
    expect(find.byKey(const Key('multifunction-page')), findsOneWidget);
    expect(find.byKey(const Key('tool-time')), findsOneWidget);
    expect(find.byKey(const Key('tool-uppercase')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tool-time')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('time-calculator-page')), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tool-uppercase')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('uppercase-page')), findsOneWidget);
  });
}
