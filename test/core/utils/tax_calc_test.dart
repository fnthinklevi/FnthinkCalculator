import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/utils/tax_calc.dart';

BigInt yuan(String value) => parseYuanToCents(value)!;

void main() {
  test('月薪 10000 无扣除', () {
    final result = calculateMonthlyTax(incomeCents: yuan('10000'));
    expect(result.taxableCents, yuan('5000'));
    expect(result.ratePercent, 10);
    expect(result.taxCents, yuan('290'));
    expect(result.afterTaxCents, yuan('9710'));
  });

  test('起征点以下不缴税', () {
    final result = calculateMonthlyTax(incomeCents: yuan('5000'));
    expect(result.taxableCents, BigInt.zero);
    expect(result.taxCents, BigInt.zero);
    expect(result.afterTaxCents, yuan('5000'));
  });

  test('五险一金与专项附加扣除', () {
    final result = calculateMonthlyTax(
      incomeCents: yuan('30000'),
      insuranceCents: yuan('2000'),
      specialCents: yuan('1000'),
    );
    expect(result.taxableCents, yuan('22000'));
    expect(result.ratePercent, 20);
    expect(result.taxCents, yuan('2990'));
    expect(result.afterTaxCents, yuan('25010'));
  });

  test('税率分界点', () {
    expect(
      calculateMonthlyTax(incomeCents: yuan('8000')).ratePercent,
      3,
    );
    expect(
      calculateMonthlyTax(incomeCents: yuan('8001')).ratePercent,
      10,
    );
    expect(
      calculateMonthlyTax(incomeCents: yuan('17000')).ratePercent,
      10,
    );
    expect(
      calculateMonthlyTax(incomeCents: yuan('17001')).ratePercent,
      20,
    );
  });

  test('年终奖单独计税', () {
    final result = calculateAnnualBonusTax(bonusCents: yuan('50000'));
    expect(result.ratePercent, 10);
    expect(result.taxCents, yuan('4790'));
    expect(result.afterTaxCents, yuan('45210'));
  });
}
