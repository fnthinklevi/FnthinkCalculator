import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/multifunction/kinship/kinship_page.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';

Widget harness() {
  return MaterialApp(
    theme: buildAppTheme(Brightness.light),
    home: const KinshipPage(),
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
  testWidgets('父母的父辈关系实时预览与提交', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());
    expect(textOf(tester, 'kinship-description'), '我');

    await tapKey(tester, 'kinship-key-父');
    await tapKey(tester, 'kinship-key-父');
    expect(textOf(tester, 'kinship-description'), '我的爸爸的爸爸');
    expect(textOf(tester, 'kinship-preview'), '爷爷');

    await tapKey(tester, 'kinship-equals');
    expect(textOf(tester, 'kinship-result'), '爷爷');
  });

  testWidgets('互查给出反向称呼', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'kinship-key-父');
    await tapKey(tester, 'kinship-key-父');
    await tapKey(tester, 'kinship-equals');
    await tapKey(tester, 'kinship-reverse');

    expect(find.text('TA称呼我'), findsOneWidget);
    expect(textOf(tester, 'kinship-result'), '孙女/孙子');
  });

  testWidgets('伯父与舅妈的常见路径及清空退格', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'kinship-key-父');
    await tapKey(tester, 'kinship-key-兄');
    expect(textOf(tester, 'kinship-preview'), '伯父');

    await tapKey(tester, 'kinship-backspace');
    expect(textOf(tester, 'kinship-description'), '我的爸爸');
    await tapKey(tester, 'kinship-clear');
    expect(textOf(tester, 'kinship-description'), '我');
  });

  testWidgets('无法识别的路径显示提示', (tester) async {
    configureSurface(tester);
    await tester.pumpWidget(harness());

    await tapKey(tester, 'kinship-key-夫');
    await tapKey(tester, 'kinship-key-妻');
    await tapKey(tester, 'kinship-key-夫');
    await tapKey(tester, 'kinship-equals');
    expect(textOf(tester, 'kinship-result'), '暂时无法识别');
  });
}
