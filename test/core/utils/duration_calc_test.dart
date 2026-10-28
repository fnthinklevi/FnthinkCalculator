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

  test('时分秒数字分组与累计小时格式', () {
    expect(secondsFromTimeDigits(''), 0);
    expect(secondsFromTimeDigits('1'), 1);
    expect(secondsFromTimeDigits('12'), 12);
    expect(secondsFromTimeDigits('123'), 83);
    expect(secondsFromTimeDigits('1234'), 754);
    expect(secondsFromTimeDigits('12345'), 5025);
    expect(secondsFromTimeDigits('123456'), 45296);
    expect(secondsFromTimeDigits('250000'), 90000);
    expect(secondsFromTimeDigits('675'), 435);

    expect(formatDurationAccumulated(0), '00:00:00');
    expect(formatDurationAccumulated(90000), '25:00:00');
    expect(formatDurationAccumulated(-5025), '-01:23:45');
    expect(formatDurationAccumulated(435), '00:07:15');
    expect(formatDurationAccumulated(123 * 3600 + 45), '123:00:45');
  });

  test('时分秒范围校验', () {
    expect(isValidClockPart(59, allowAny: false), isTrue);
    expect(isValidClockPart(60, allowAny: false), isFalse);
    expect(isValidClockPart(-1, allowAny: false), isFalse);
    expect(isValidClockPart(24, allowAny: true), isTrue);
  });
}
