import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/features/multifunction/mortgage/mortgage_controller.dart';

void main() {
  test('默认商业贷款 100 万 / 3.1% / 30 年', () {
    final controller = MortgageController();
    expect(controller.error, isNull);
    expect(controller.result, isNotNull);
    expect(controller.result!.periods, hasLength(360));
    expect(controller.result!.principalCents, BigInt.from(100000000));
    expect(controller.paymentLabel, '每月月供');
    controller.dispose();
  });

  test('等额本金切换后首月月供与递减', () {
    final controller = MortgageController();
    controller.setMethod(MortgageMethod.equalPrincipal);

    expect(controller.error, isNull);
    expect(controller.paymentLabel, '首月月供');
    expect(controller.result!.equalPayment, isFalse);
    expect(controller.result!.monthlyDecreaseCents > BigInt.zero, isTrue);
    controller.dispose();
  });

  test('组合贷合并商业与公积金本金', () {
    final controller = MortgageController();
    controller.setType(MortgageType.combined);

    expect(controller.error, isNull);
    expect(controller.result!.principalCents, BigInt.from(160000000));
    expect(controller.result!.periods, hasLength(360));
    controller.dispose();
  });

  test('公积金贷款沿用金额与利率字段', () {
    final controller = MortgageController();
    controller.setType(MortgageType.provident);
    controller.setAmount('60');
    controller.setRate('2.6');

    expect(controller.error, isNull);
    expect(controller.result!.principalCents, BigInt.from(60000000));
    controller.dispose();
  });

  test('金额、利率、期限校验与恢复', () {
    final controller = MortgageController();
    controller.setAmount('0');
    expect(controller.error, contains('贷款金额'));
    expect(controller.result, isNull);

    controller.setAmount('100');
    controller.setRate('101');
    expect(controller.error, contains('年利率'));

    controller.setRate('3.1');
    controller.setYears(31);
    expect(controller.error, contains('期限'));

    controller.setYears(30);
    expect(controller.error, isNull);
    expect(controller.result, isNotNull);
    controller.dispose();
  });

  test('组合贷公积金部分不可为零', () {
    final controller = MortgageController();
    controller.setType(MortgageType.combined);
    controller.setProvidentAmount('0');
    expect(controller.error, contains('公积金金额'));

    controller.setProvidentAmount('60');
    expect(controller.error, isNull);
    expect(controller.result, isNotNull);
    controller.dispose();
  });

  test('小数金额与零利率', () {
    final controller = MortgageController();
    controller.setAmount('50.5');
    expect(controller.result!.principalCents, BigInt.from(50500000));

    controller.setRate('0');
    expect(controller.result!.interestCents, BigInt.zero);
    expect(controller.result!.repaymentCents, BigInt.from(50500000));
    controller.dispose();
  });

  test('一年期限生成 12 期', () {
    final controller = MortgageController();
    controller.setYears(1);
    expect(controller.result!.periods, hasLength(12));
    controller.dispose();
  });
}
