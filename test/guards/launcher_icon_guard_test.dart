import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const res = 'android/app/src/main/res';
  const densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

  test('日间与夜间自适应图标配置齐备', () {
    for (final folder in const [
      'mipmap-anydpi-v26',
      'mipmap-night-anydpi-v26',
    ]) {
      for (final name in const ['ic_launcher.xml', 'ic_launcher_round.xml']) {
        final file = File('$res/$folder/$name');
        expect(file.existsSync(), isTrue, reason: '缺少 $folder/$name');
        final source = file.readAsStringSync();
        expect(
          source,
          contains('@color/ic_launcher_background'),
          reason: '$folder/$name 缺少背景引用',
        );
        expect(
          source,
          contains('@mipmap/ic_launcher_foreground'),
          reason: '$folder/$name 缺少前景引用',
        );
      }
    }

    final day = File('$res/values/ic_launcher_background.xml');
    final night = File('$res/values-night/ic_launcher_background.xml');
    expect(day.existsSync(), isTrue, reason: '缺少日间背景色');
    expect(night.existsSync(), isTrue, reason: '缺少夜间背景色');
    expect(day.readAsStringSync(), contains('#FFFFFF'));
    expect(night.readAsStringSync(), contains('#1C1C1E'));
  });

  test('各密度日间与夜间图标都存在且内容不同', () {
    for (final density in densities) {
      for (final name in const [
        'ic_launcher.png',
        'ic_launcher_round.png',
        'ic_launcher_foreground.png',
      ]) {
        final day = File('$res/mipmap-$density/$name');
        final night = File('$res/mipmap-night-$density/$name');
        expect(day.existsSync(), isTrue, reason: '缺少日间 $density/$name');
        expect(night.existsSync(), isTrue, reason: '缺少夜间 $density/$name');
        expect(day.lengthSync(), greaterThan(0));
        expect(night.lengthSync(), greaterThan(0));
        expect(
          day.readAsBytesSync(),
          isNot(equals(night.readAsBytesSync())),
          reason: '$density/$name 日夜两套不应相同',
        );
      }
    }
  });

  test('生成脚本保留日夜两套输出', () {
    final script = File('tool/make_icons.py').readAsStringSync();
    expect(script, contains('mipmap-night-'));
    expect(script, contains('values-night'));
    expect(script, contains('_dark'));
    expect(script, contains('background_hex'));
  });
}
