import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/math/rational.dart';
import 'package:fnthink_calculator/core/utils/mortgage_calc.dart';

BigInt wanToCents(String wan) {
  final value = BigRational.parse(wan) * BigRational.fromInt(1000000);
  return (value.n * BigInt.two + value.d) ~/ (value.d * BigInt.two);
}

MortgageLoanPart part(String wan, String rate) {
  return MortgageLoanPart(
    principalCents: wanToCents(wan),
    annualRatePercent: BigRational.parse(rate),
  );
}

BigInt principalSum(MortgageResult result) {
  return result.periods.fold(
    BigInt.zero,
    (sum, period) => sum + period.principalCents,
  );
}

BigInt interestSum(MortgageResult result) {
  return result.periods.fold(
    BigInt.zero,
    (sum, period) => sum + period.interestCents,
  );
}

void main() {
  test('等额本息已知案例：100万 / 4.9% / 30年', () {
    final result = calculateMortgage(
      parts: [part('100', '4.9')],
      years: 30,
      equalPayment: true,
    );

    expect(result.periods, hasLength(360));
    expect(result.firstPaymentCents, BigInt.from(530727));
    expect(result.interestCents, BigInt.from(91061512));
    expect(result.repaymentCents, BigInt.from(191061512));
    expect(result.periods.last.balanceCents, BigInt.zero);
    expect(principalSum(result), BigInt.from(100000000));
    expect(interestSum(result), result.interestCents);
  });

  test('等额本金已知案例：100万 / 4.9% / 30年', () {
    final result = calculateMortgage(
      parts: [part('100', '4.9')],
      years: 30,
      equalPayment: false,
    );

    expect(result.periods, hasLength(360));
    expect(result.firstPaymentCents, BigInt.from(686111));
    expect(result.interestCents, BigInt.from(73704108));
    expect(result.periods.last.balanceCents, BigInt.zero);
    expect(principalSum(result), BigInt.from(100000000));
    expect(result.monthlyDecreaseCents > BigInt.zero, isTrue);
  });

  test('零利率：本金平均分摊，末期调平', () {
    final result = calculateMortgage(
      parts: [part('100', '0')],
      years: 1,
      equalPayment: true,
    );

    expect(result.periods, hasLength(12));
    expect(result.firstPaymentCents, BigInt.from(8333333));
    expect(result.periods.last.paymentCents, BigInt.from(8333337));
    expect(result.interestCents, BigInt.zero);
    expect(result.repaymentCents, BigInt.from(100000000));
    expect(principalSum(result), BigInt.from(100000000));
  });

  test('零利率等额本金同样末期调平', () {
    final result = calculateMortgage(
      parts: [part('100', '0')],
      years: 1,
      equalPayment: false,
    );

    expect(result.interestCents, BigInt.zero);
    expect(result.firstPaymentCents, BigInt.from(8333333));
    expect(principalSum(result), BigInt.from(100000000));
    expect(result.periods.last.balanceCents, BigInt.zero);
  });

  test('一周期限与 30 年边界均可计算', () {
    final oneYear = calculateMortgage(
      parts: [part('100', '3.1')],
      years: 1,
      equalPayment: true,
    );
    expect(oneYear.periods, hasLength(12));
    expect(oneYear.periods.last.balanceCents, BigInt.zero);

    final thirtyYears = calculateMortgage(
      parts: [part('100', '3.1')],
      years: 30,
      equalPayment: true,
    );
    expect(thirtyYears.periods, hasLength(360));
    expect(thirtyYears.periods.last.balanceCents, BigInt.zero);
  });

  test('组合贷汇总等于两笔分别计算之和', () {
    final commercial = calculateMortgage(
      parts: [part('60', '3.1')],
      years: 30,
      equalPayment: true,
    );
    final provident = calculateMortgage(
      parts: [part('40', '2.6')],
      years: 30,
      equalPayment: true,
    );
    final combined = calculateMortgage(
      parts: [part('60', '3.1'), part('40', '2.6')],
      years: 30,
      equalPayment: true,
    );

    expect(combined.periods, hasLength(360));
    expect(combined.principalCents, BigInt.from(100000000));
    expect(
      combined.firstPaymentCents,
      commercial.firstPaymentCents + provident.firstPaymentCents,
    );
    expect(
      combined.interestCents,
      commercial.interestCents + provident.interestCents,
    );
    expect(combined.periods.last.balanceCents, BigInt.zero);
    expect(principalSum(combined), combined.principalCents);
  });

  test('不足一分的金额四舍五入后仍能调平', () {
    final result = calculateMortgage(
      parts: [part('100.01', '3.1')],
      years: 30,
      equalPayment: true,
    );
    expect(result.principalCents, BigInt.from(100010000));
    expect(principalSum(result), BigInt.from(100010000));
    expect(result.periods.last.balanceCents, BigInt.zero);
  });

  test('非法参数抛错', () {
    expect(
      () => calculateMortgage(parts: [], years: 30, equalPayment: true),
      throwsArgumentError,
    );
    expect(
      () => calculateMortgage(
        parts: [part('100', '3.1')],
        years: 0,
        equalPayment: true,
      ),
      throwsArgumentError,
    );
    expect(
      () => calculateMortgage(
        parts: [part('100', '3.1')],
        years: 31,
        equalPayment: true,
      ),
      throwsArgumentError,
    );
    expect(
      () => calculateMortgage(
        parts: [
          MortgageLoanPart(
            principalCents: BigInt.zero,
            annualRatePercent: BigRational.parse('3.1'),
          ),
        ],
        years: 30,
        equalPayment: true,
      ),
      throwsArgumentError,
    );
    expect(
      () => calculateMortgage(
        parts: [part('100', '-1')],
        years: 30,
        equalPayment: true,
      ),
      throwsArgumentError,
    );
    expect(
      () => calculateMortgage(
        parts: [part('100', '100.1')],
        years: 30,
        equalPayment: true,
      ),
      throwsArgumentError,
    );
  });

  test('金额格式化保留两位小数与千分位', () {
    expect(formatMoneyCents(BigInt.zero), '0.00');
    expect(formatMoneyCents(BigInt.from(123456)), '1,234.56');
    expect(formatMoneyCents(BigInt.from(100000000)), '1,000,000.00');
    expect(formatMoneyCents(BigInt.from(-123456)), '-1,234.56');
  });
}
