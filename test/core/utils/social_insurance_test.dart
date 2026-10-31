import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/utils/social_insurance.dart';

void main() {
  test('省级社保基数表为 31 项且北京数值正确', () {
    expect(provinceSocialBases, hasLength(31));
    final beijing = provinceByName('北京')!;
    expect(beijing.averageYuan, 11937);
    expect(beijing.lowerYuan, 7162);
    expect(beijing.upperYuan, 35811);
    expect(beijing.rangeLabel, '基数 7,162–35,811 元');
  });

  test('个人五险一金估算按平均工资 10.5%', () {
    final beijing = provinceByName('北京')!;
    expect(
      estimatePersonalInsuranceYuan(beijing).toStringAsFixed(2),
      '1253.39',
    );
  });
}
