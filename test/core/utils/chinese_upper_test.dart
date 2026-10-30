import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/utils/chinese_upper.dart';

void main() {
  test('人民币大写整数', () {
    expect(ChineseUpper.toRmb('0'), '零圆整');
    expect(ChineseUpper.toRmb('1'), '壹圆整');
    expect(ChineseUpper.toRmb('10'), '壹拾圆整');
    expect(ChineseUpper.toRmb('1001'), '壹仟零壹圆整');
    expect(ChineseUpper.toRmb('10000'), '壹万圆整');
    expect(ChineseUpper.toRmb('100000000'), '壹亿圆整');
    expect(ChineseUpper.toRmb('1000000000000'), '壹万亿圆整');
  });

  test('人民币大写角分', () {
    expect(ChineseUpper.toRmb('0.5'), '伍角');
    expect(ChineseUpper.toRmb('0.05'), '伍分');
    expect(ChineseUpper.toRmb('100.5'), '壹佰圆伍角');
    expect(ChineseUpper.toRmb('100.05'), '壹佰圆零伍分');
    expect(ChineseUpper.toRmb('1.005'), '壹圆零壹分');
    expect(ChineseUpper.toRmb('123456789.01'), '壹亿贰仟叁佰肆拾伍万陆仟柒佰捌拾玖圆零壹分');
  });

  test('负数与科学计数法输入', () {
    expect(ChineseUpper.toRmb('-5.2'), '负伍圆贰角');
    expect(ChineseUpper.toRmb('1e+3'), '壹仟圆整');
  });

  test('超过范围时给出中文错误', () {
    expect(() => ChineseUpper.toRmb('1e+20'), throwsA(isA<FormatException>()));
  });

  test('错误消息透传', () {
    try {
      ChineseUpper.toRmb('1e+20');
    } catch (error) {
      expect(ChineseUpper.errorMessage(error), contains('数值过大'));
    }
  });
}
