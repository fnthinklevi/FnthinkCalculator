import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/utils/duration_calc.dart';

void main() {
  test('时长格式化', () {
    expect(formatDuration(0), '00:00:00');
    expect(formatDuration(3661), '01:01:01');
    expect(formatDuration(90061), '1天 01:01:01');
    expect(formatDuration(-3661), '-01:01:01');
    expect(formatDuration(86399), '23:59:59');
    expect(formatDurationVerbose(90061), '1 天 1 小时 1 分 1 秒');
    expect(formatDurationVerbose(0), '0 秒');
    expect(formatDurationVerbose(-3600), '负1 小时');
  });

  test('时分秒范围校验', () {
    expect(isValidClockPart(59, allowAny: false), isTrue);
    expect(isValidClockPart(60, allowAny: false), isFalse);
    expect(isValidClockPart(-1, allowAny: false), isFalse);
    expect(isValidClockPart(24, allowAny: true), isTrue);
  });
}
