import 'package:flutter/foundation.dart';

import '../../../core/math/math_error.dart';
import '../../../core/math/rational.dart';
import '../../../core/utils/mortgage_calc.dart';

enum MortgageType { commercial, provident, combined }

enum MortgageMethod { equalPayment, equalPrincipal }

enum MortgageRateStandard { lpr, base }

class MortgageController extends ChangeNotifier {
  MortgageController() {
    _recalculate();
  }

  MortgageType type = MortgageType.commercial;
  MortgageMethod method = MortgageMethod.equalPayment;
  MortgageRateStandard rateStandard = MortgageRateStandard.lpr;
  String amountWan = '100';
  String lprPercent = '3.5';
  String basePoint = '0';
  String providentAmountWan = '60';
  String providentRatePercent = '2.6';
  int years = 40;
  int providentYears = 40;
  DateTime firstPaymentDate = DateTime.now();
  MortgageResult? result;
  String? error;

  bool get isCombined => type == MortgageType.combined;
  bool get isProvidentOnly => type == MortgageType.provident;
  bool get isEqualPayment => method == MortgageMethod.equalPayment;
  String get paymentLabel => isEqualPayment ? '每月需还款' : '首月需还款';
  String get methodLabel => isEqualPayment ? '等额本息（每月等额还款）' : '等额本金（每月递减还款）';
  String get rateStandardLabel =>
      rateStandard == MortgageRateStandard.lpr ? 'LPR' : '基准利率';

  String get commercialRatePercent {
    final base = _parseRate(
      rateStandard == MortgageRateStandard.lpr ? lprPercent : '4.9',
    );
    final points = _parseRate(basePoint);
    if (base == null || points == null) return lprPercent;
    return _trim((base + points / BigRational.fromInt(10)).toDouble());
  }

  String get rateSummary {
    if (rateStandard == MortgageRateStandard.base) {
      return '基准利率 $commercialRatePercent%';
    }
    return '$lprPercent% + $basePoint‰ = $commercialRatePercent%';
  }

  void setType(MortgageType value) {
    if (type == value) return;
    type = value;
    _update();
  }

  void setMethod(MortgageMethod value) {
    if (method == value) return;
    method = value;
    _update();
  }

  void setRateStandard(MortgageRateStandard value) {
    if (rateStandard == value) return;
    rateStandard = value;
    _update();
  }

  void setAmount(String value) {
    if (amountWan == value) return;
    amountWan = value;
    _update();
  }

  void setLpr(String value) {
    if (lprPercent == value) return;
    lprPercent = value;
    _update();
  }

  void setRate(String value) => setLpr(value);

  void setBasePoint(String value) {
    if (basePoint == value) return;
    basePoint = value;
    _update();
  }

  void setProvidentAmount(String value) {
    if (providentAmountWan == value) return;
    providentAmountWan = value;
    _update();
  }

  void setProvidentRate(String value) {
    if (providentRatePercent == value) return;
    providentRatePercent = value;
    _update();
  }

  void setYears(int value) {
    if (years == value) return;
    years = value;
    _update();
  }

  void setProvidentYears(int value) {
    if (providentYears == value) return;
    providentYears = value;
    _update();
  }

  void setFirstPaymentDate(DateTime value) {
    firstPaymentDate = value;
    notifyListeners();
  }

  void _update() {
    _recalculate();
    notifyListeners();
  }

  void _recalculate() {
    result = null;
    error = null;
    final commercialYears = years;
    final providentTerm = providentYears;
    if (commercialYears < 1 ||
        commercialYears > 40 ||
        providentTerm < 1 ||
        providentTerm > 40) {
      error = '贷款期限需在 1–40 年之间';
      return;
    }

    try {
      if (type == MortgageType.commercial) {
        final amount = _parseAmountCents(amountWan);
        if (amount == null) {
          error = '贷款金额需大于 0';
          return;
        }
        final rate = _parseRate(commercialRatePercent);
        if (rate == null) {
          error = '贷款利率需在 0–100% 之间';
          return;
        }
        result = calculateMortgage(
          parts: [
            MortgageLoanPart(principalCents: amount, annualRatePercent: rate),
          ],
          years: commercialYears,
          equalPayment: isEqualPayment,
        );
        return;
      }

      final providentAmount = _parseAmountCents(providentAmountWan);
      if (providentAmount == null) {
        error = '公积金贷款金额需大于 0';
        return;
      }
      final providentRate = _parseRate(providentRatePercent);
      if (providentRate == null) {
        error = '公积金利率需在 0–100% 之间';
        return;
      }
      final providentResult = calculateMortgage(
        parts: [
          MortgageLoanPart(
            principalCents: providentAmount,
            annualRatePercent: providentRate,
          ),
        ],
        years: providentTerm,
        equalPayment: isEqualPayment,
      );
      if (type == MortgageType.provident) {
        result = providentResult;
        return;
      }

      final amount = _parseAmountCents(amountWan);
      if (amount == null) {
        error = '商业贷款金额需大于 0';
        return;
      }
      final rate = _parseRate(commercialRatePercent);
      if (rate == null) {
        error = '贷款利率需在 0–100% 之间';
        return;
      }
      final commercialResult = calculateMortgage(
        parts: [
          MortgageLoanPart(principalCents: amount, annualRatePercent: rate),
        ],
        years: commercialYears,
        equalPayment: isEqualPayment,
      );
      result = _merge(commercialResult, providentResult);
    } on ArgumentError catch (error) {
      this.error = error.message.toString();
    }
  }

  MortgageResult _merge(MortgageResult first, MortgageResult second) {
    final count = first.periods.length > second.periods.length
        ? first.periods.length
        : second.periods.length;
    final periods = <MortgagePeriod>[];
    for (var index = 0; index < count; index++) {
      final a = index < first.periods.length ? first.periods[index] : null;
      final b = index < second.periods.length ? second.periods[index] : null;
      periods.add(
        MortgagePeriod(
          period: index + 1,
          paymentCents:
              (a?.paymentCents ?? BigInt.zero) +
              (b?.paymentCents ?? BigInt.zero),
          principalCents:
              (a?.principalCents ?? BigInt.zero) +
              (b?.principalCents ?? BigInt.zero),
          interestCents:
              (a?.interestCents ?? BigInt.zero) +
              (b?.interestCents ?? BigInt.zero),
          balanceCents:
              (a?.balanceCents ?? BigInt.zero) +
              (b?.balanceCents ?? BigInt.zero),
        ),
      );
    }
    final principal = first.principalCents + second.principalCents;
    final interest = first.interestCents + second.interestCents;
    return MortgageResult(
      periods: periods,
      principalCents: principal,
      interestCents: interest,
      repaymentCents: principal + interest,
      firstPaymentCents: periods.first.paymentCents,
      lastPaymentCents: periods.last.paymentCents,
      monthlyDecreaseCents: periods.length > 1
          ? periods[0].paymentCents - periods[1].paymentCents
          : BigInt.zero,
      equalPayment: isEqualPayment,
    );
  }
}

BigInt? _parseAmountCents(String text) {
  BigRational? wan;
  try {
    wan = BigRational.tryParse(text);
  } on MathException {
    return null;
  }
  if (wan == null || wan.isNegative || wan.isZero) {
    return null;
  }
  return _roundHalfUp(wan * BigRational.fromInt(1000000));
}

BigRational? _parseRate(String text) {
  BigRational? value;
  try {
    value = BigRational.tryParse(text);
  } on MathException {
    return null;
  }
  if (value == null || value.isNegative) {
    return null;
  }
  if (value.compareTo(BigRational.fromInt(100)) > 0) {
    return null;
  }
  return value;
}

BigInt _roundHalfUp(BigRational value) {
  final adjusted = value.n * BigInt.two + value.d;
  return adjusted ~/ (value.d * BigInt.two);
}

String _trim(double value) {
  final text = value.toStringAsFixed(4);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}
