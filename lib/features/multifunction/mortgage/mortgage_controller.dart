import 'package:flutter/foundation.dart';

import '../../../core/math/math_error.dart';
import '../../../core/math/rational.dart';
import '../../../core/utils/mortgage_calc.dart';

enum MortgageType { commercial, provident, combined }

enum MortgageMethod { equalPayment, equalPrincipal }

class MortgageController extends ChangeNotifier {
  MortgageController() {
    _recalculate();
  }

  MortgageType type = MortgageType.commercial;
  MortgageMethod method = MortgageMethod.equalPayment;
  String amountWan = '100';
  String ratePercent = '3.1';
  String providentAmountWan = '60';
  String providentRatePercent = '2.6';
  int years = 30;
  MortgageResult? result;
  String? error;

  bool get isCombined => type == MortgageType.combined;
  bool get isProvidentOnly => type == MortgageType.provident;
  bool get isEqualPayment => method == MortgageMethod.equalPayment;
  String get paymentLabel => isEqualPayment ? '每月月供' : '首月月供';

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

  void setAmount(String value) {
    if (amountWan == value) return;
    amountWan = value;
    _update();
  }

  void setRate(String value) {
    if (ratePercent == value) return;
    ratePercent = value;
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

  void _update() {
    _recalculate();
    notifyListeners();
  }

  void _recalculate() {
    result = null;
    error = null;
    if (years < 1 || years > 30) {
      error = '贷款期限需在 1–30 年之间';
      return;
    }

    final amount = _parseAmountCents(amountWan);
    if (amount == null) {
      if (isCombined) {
        error = '组合贷商贷金额需大于 0';
      } else {
        error = '贷款金额需大于 0';
      }
      return;
    }
    final rate = _parseRate(ratePercent);
    if (rate == null) {
      error = '年利率需在 0–100% 之间';
      return;
    }

    final parts = <MortgageLoanPart>[
      MortgageLoanPart(principalCents: amount, annualRatePercent: rate),
    ];
    if (isCombined) {
      final providentAmount = _parseAmountCents(providentAmountWan);
      if (providentAmount == null) {
        error = '组合贷公积金金额需大于 0';
        return;
      }
      final providentRate = _parseRate(providentRatePercent);
      if (providentRate == null) {
        error = '公积金年利率需在 0–100% 之间';
        return;
      }
      parts.add(
        MortgageLoanPart(
          principalCents: providentAmount,
          annualRatePercent: providentRate,
        ),
      );
    }

    result = calculateMortgage(
      parts: parts,
      years: years,
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
