import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final shortcutsXml = File('android/app/src/main/res/xml/shortcuts.xml')
      .readAsStringSync();
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();
  final dartSource = File('lib/app/app_shortcuts.dart').readAsStringSync();

  test('静态快捷方式声明与 Dart 路由 id 一致', () {
    final xmlIds = RegExp(r'android:value="([a-z_]+)"')
        .allMatches(shortcutsXml)
        .map((match) => match.group(1)!)
        .toSet();
    final dartIds = RegExp(
      r"^\s+\w+\('([a-z_]+)'\)[,;]",
      multiLine: true,
    ).allMatches(dartSource).map((match) => match.group(1)!).toSet();

    expect(xmlIds, {'time_calculation', 'date_calculation', 'currency'});
    expect(dartIds, xmlIds);
    expect(RegExp(r'<shortcut\s').allMatches(shortcutsXml).length, 3);
    for (final id in xmlIds) {
      expect(
        shortcutsXml,
        contains('android:shortcutId="$id"'),
        reason: '缺少快捷方式 $id',
      );
    }
  });

  test('Manifest 挂载 shortcuts 资源', () {
    expect(manifest, contains('android:name="android.app.shortcuts"'));
    expect(manifest, contains('android:resource="@xml/shortcuts"'));
  });

  test('每个快捷方式都带 MainActivity intent 与 shortcut_type', () {
    final intents = RegExp(r'<intent[\s\S]*?</intent>')
        .allMatches(shortcutsXml)
        .length;
    expect(intents, 3);
    expect(
      shortcutsXml,
      contains(
        'android:targetClass="com.fnthink.FnthinkCalculator.MainActivity"',
      ),
    );
    expect('android:name="shortcut_type"'.allMatches(shortcutsXml).length, 3);
  });

  test('快捷方式图标提供深色模式变体且形状一致', () {
    String pathDataOf(String source) {
      return RegExp(r'android:pathData="([^"]+)"')
          .firstMatch(source)!
          .group(1)!;
    }

    for (final name in const ['time', 'date', 'currency']) {
      final day = File(
        'android/app/src/main/res/drawable/ic_shortcut_$name.xml',
      );
      final night = File(
        'android/app/src/main/res/drawable-night/ic_shortcut_$name.xml',
      );
      expect(day.existsSync(), isTrue, reason: '缺少日间图标 $name');
      expect(night.existsSync(), isTrue, reason: '缺少深色模式图标 $name');

      final daySource = day.readAsStringSync();
      final nightSource = night.readAsStringSync();
      expect(daySource, contains('android:fillColor="#FF6900"'));
      expect(nightSource, contains('android:fillColor="#FFB27A"'));
      expect(pathDataOf(nightSource), pathDataOf(daySource));
    }
  });
}
