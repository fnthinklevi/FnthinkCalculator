import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('内置语音包存在且小于 1MB', () {
    final dir = Directory('assets/voice');
    final files = dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.wav'))
        .toList();
    expect(files.length, greaterThanOrEqualTo(40));
    final total = files.fold<int>(0, (sum, file) => sum + file.lengthSync());
    expect(total, lessThan(1024 * 1024));
    for (final name in ['zero', 'seven', 'plus', 'multiply', 'equals']) {
      expect(File('assets/voice/$name.wav').existsSync(), isTrue);
    }
  });
}
