import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();
  final layout = File('android/app/src/main/res/layout/widget_calculator.xml')
      .readAsStringSync();

  String provider(String name) =>
      File('android/app/src/main/res/xml/$name.xml').readAsStringSync();

  test('三种小组件在 Manifest 注册并挂载 AppWidget 配置', () {
    const providers = {
      'StandardWidgetProvider': 'widget_standard_info',
      'TimeWidgetProvider': 'widget_time_info',
      'ScientificWidgetProvider': 'widget_scientific_info',
    };
    for (final entry in providers.entries) {
      expect(
        manifest,
        contains('.widget.${entry.key}'),
        reason: '缺少 ${entry.key}',
      );
      expect(
        manifest,
        contains('@xml/${entry.value}'),
        reason: '缺少 ${entry.value}',
      );
    }
    expect(
      'android.appwidget.action.APPWIDGET_UPDATE'.allMatches(manifest).length,
      3,
    );
  });

  test('标准与时间组件支持 3×3，科学组件固定 4×4', () {
    for (final name in const ['widget_standard_info', 'widget_time_info']) {
      final xml = provider(name);
      expect(xml, contains('android:targetCellWidth="3"'), reason: name);
      expect(xml, contains('android:targetCellHeight="3"'), reason: name);
      expect(xml, contains('android:minResizeWidth="140dp"'), reason: name);
    }
    final scientific = provider('widget_scientific_info');
    expect(scientific, contains('android:targetCellWidth="4"'));
    expect(scientific, contains('android:targetCellHeight="4"'));
    expect(scientific, contains('android:minWidth="250dp"'));
    expect(scientific, contains('android:minHeight="250dp"'));
    expect(scientific, contains('android:minResizeWidth="250dp"'));
  });

  test('组件布局与状态引擎文件齐全', () {
    expect(layout, contains('@+id/widget_display'));
    expect(layout, contains('@+id/widget_expression'));
    for (var index = 0; index < 16; index++) {
      expect(layout, contains('@+id/widget_key_$index'));
    }

    final scientificLayout = File(
      'android/app/src/main/res/layout/widget_calculator_scientific.xml',
    ).readAsStringSync();
    for (var index = 0; index < 20; index++) {
      expect(scientificLayout, contains('@+id/widget_sci_key_$index'));
    }

    for (final file in const [
      'WidgetMath.kt',
      'WidgetTime.kt',
      'WidgetStateStore.kt',
      'CalculatorWidgetProvider.kt',
    ]) {
      expect(
        File(
          'android/app/src/main/kotlin/com/fnthink/FnthinkCalculator/widget/$file',
        ).existsSync(),
        isTrue,
        reason: '缺少 $file',
      );
    }
  });
}
