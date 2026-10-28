import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/multifunction/uppercase_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

void main() {
  testWidgets('默认金额转人民币大写', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: const UppercasePage(),
      ),
    );
    expect(find.text('壹仟贰佰叁拾肆元伍角陆分'), findsOneWidget);
  });

  testWidgets('输入金额与非法输入', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: const UppercasePage(),
      ),
    );
    await tester.enterText(find.byKey(const Key('uppercase-input')), '100.05');
    await tester.pump();
    expect(find.text('壹佰元零伍分'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('uppercase-input')), 'abc');
    await tester.pump();
    expect(find.textContaining('数字格式不正确'), findsOneWidget);
  });
}
