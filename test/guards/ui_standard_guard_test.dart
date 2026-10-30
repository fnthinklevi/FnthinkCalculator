import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/converter/converter_home_page.dart';
import 'package:fnthink_calculator/features/converter/currency_data.dart';
import 'package:fnthink_calculator/features/converter/unit_data.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';
import 'package:fnthink_calculator/theme/tokens.dart';

String read(String path) => File(path).readAsStringSync();

List<File> libFiles() {
  return Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
}

void main() {
  test('系统输入框只允许出现在表单/表单输入组件', () {
    const allowlist = {
      'lib/widgets/number_form_field.dart',
      'lib/features/multifunction/ratio/ratio_page.dart',
      'lib/features/multifunction/tax/tax_page.dart',
      'lib/features/multifunction/mortgage/mortgage_page.dart',
      'lib/features/multifunction/bmi/bmi_page.dart',
    };
    for (final file in libFiles()) {
      final source = file.readAsStringSync();
      final usesField =
          source.contains('TextField(') ||
          source.contains('TextFormField(') ||
          source.contains('EditableText(');
      if (!usesField) continue;
      final normalized = file.path.replaceAll(RegExp(r'\\'), '/');
      expect(allowlist.contains(normalized), isTrue, reason: file.path);
    }
  });

  test('顶部只有两个标签', () {
    final source = read('lib/app/shell.dart');
    expect(source.contains("static const _tabs = ['计算', '换算'];"), isTrue);
    expect(source.contains('多功能标签'), isFalse);
  });

  testWidgets('换算首页固定 16 个入口且顺序符合标准', (tester) async {
    tester.view.physicalSize = const Size(1080, 4200);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: const ConverterHomePage(),
      ),
    );

    const order = <String>[
      'converter-category-currency',
      'converter-category-length',
      'converter-category-weight',
      'converter-category-area',
      'tool-tax',
      'tool-mortgage',
      'tool-kinship',
      'tool-uppercase',
      'converter-category-time',
      'converter-category-volume',
      'converter-category-radix',
      'converter-category-temperature',
      'converter-category-speed',
      'tool-bmi',
      'tool-time',
      'tool-ratio',
    ];
    final rects = <String, Rect>{};
    for (final key in order) {
      final finder = find.byKey(Key(key));
      expect(finder, findsOneWidget, reason: key);
      rects[key] = tester.getRect(finder);
    }
    final sorted = [...order]
      ..sort((a, b) {
        final ra = rects[a]!;
        final rb = rects[b]!;
        final byRow = ra.top.compareTo(rb.top);
        return byRow != 0 ? byRow : ra.left.compareTo(rb.left);
      });
    expect(sorted, order);
  });

  test('单位与币种数据规模符合标准', () {
    expect(UnitData.length.units, hasLength(27));
    expect(UnitData.area.units, hasLength(19));
    expect(UnitData.volume.units, hasLength(14));
    expect(UnitData.weight.units, hasLength(21));
    expect(UnitData.temperature.units, hasLength(5));
    expect(UnitData.speed.units, hasLength(9));
    expect(UnitData.time.units, hasLength(9));
    expect(CurrencyData.all, hasLength(109));
  });

  test('不冒充第三方数据来源', () {
    for (final file in libFiles()) {
      final source = file.readAsStringSync();
      expect(source.contains('微牛'), isFalse, reason: file.path);
      expect(source.contains('东方财富'), isFalse, reason: file.path);
    }
  });

  test('深色背景为纯黑', () {
    expect(CalcColors.darkBg, const Color(0xFF000000));
    expect(CalcColors.orange, const Color(0xFFFF6900));
  });
}
