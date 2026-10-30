import '../math/rational.dart';

class TaxBracket {
  const TaxBracket({
    required this.upper,
    required this.ratePercent,
    required this.quickDeduction,
  });

  final int upper;
  final int ratePercent;
  final int quickDeduction;
}

const taxBrackets = <TaxBracket>[
  TaxBracket(upper: 3000, ratePercent: 3, quickDeduction: 0),
  TaxBracket(upper: 12000, ratePercent: 10, quickDeduction: 210),
  TaxBracket(upper: 25000, ratePercent: 20, quickDeduction: 1410),
  TaxBracket(upper: 35000, ratePercent: 25, quickDeduction: 2660),
  TaxBracket(upper: 55000, ratePercent: 30, quickDeduction: 4410),
  TaxBracket(upper: 80000, ratePercent: 35, quickDeduction: 7160),
  TaxBracket(upper: 1 << 62, ratePercent: 45, quickDeduction: 15160),
];

class TaxResult {
  const TaxResult({
    required this.incomeCents,
    required this.insuranceCents,
    required this.specialCents,
    required this.taxableCents,
    required this.ratePercent,
    required this.quickDeductionCents,
    required this.taxCents,
    required this.afterTaxCents,
  });

  final BigInt incomeCents;
  final BigInt insuranceCents;
  final BigInt specialCents;
  final BigInt taxableCents;
  final int ratePercent;
  final BigInt quickDeductionCents;
  final BigInt taxCents;
  final BigInt afterTaxCents;
}

TaxBracket bracketFor(int taxableYuan) {
  for (final bracket in taxBrackets) {
    if (taxableYuan <= bracket.upper) return bracket;
  }
  return taxBrackets.last;
}

TaxResult calculateMonthlyTax({
  required BigInt incomeCents,
  BigInt? insuranceCents,
  BigInt? specialCents,
}) {
  final insurance = insuranceCents ?? BigInt.zero;
  final special = specialCents ?? BigInt.zero;
  final threshold = BigInt.from(500000);
  var taxable = incomeCents - threshold - insurance - special;
  if (taxable < BigInt.zero) taxable = BigInt.zero;
  final taxableYuan = (taxable ~/ BigInt.from(100)).toInt();
  final bracket = bracketFor(taxableYuan);
  final rate = BigRational.fromInt(bracket.ratePercent, 100);
  final quick = BigInt.from(bracket.quickDeduction * 100);
  var tax = _roundHalfUp(BigRational.fromBigInt(taxable) * rate) - quick;
  if (tax < BigInt.zero) tax = BigInt.zero;
  final afterTax = incomeCents - insurance - tax;
  return TaxResult(
    incomeCents: incomeCents,
    insuranceCents: insurance,
    specialCents: special,
    taxableCents: taxable,
    ratePercent: bracket.ratePercent,
    quickDeductionCents: quick,
    taxCents: tax,
    afterTaxCents: afterTax,
  );
}

TaxResult calculateAnnualBonusTax({required BigInt bonusCents}) {
  final monthly = bonusCents ~/ BigInt.from(12);
  final monthlyYuan = (monthly ~/ BigInt.from(100)).toInt();
  final bracket = bracketFor(monthlyYuan);
  final rate = BigRational.fromInt(bracket.ratePercent, 100);
  final quick = BigInt.from(bracket.quickDeduction * 100);
  var tax = _roundHalfUp(BigRational.fromBigInt(bonusCents) * rate) - quick;
  if (tax < BigInt.zero) tax = BigInt.zero;
  return TaxResult(
    incomeCents: bonusCents,
    insuranceCents: BigInt.zero,
    specialCents: BigInt.zero,
    taxableCents: bonusCents,
    ratePercent: bracket.ratePercent,
    quickDeductionCents: quick,
    taxCents: tax,
    afterTaxCents: bonusCents - tax,
  );
}

BigInt _roundHalfUp(BigRational value) {
  final adjusted = value.n * BigInt.two + value.d;
  return adjusted ~/ (value.d * BigInt.two);
}

BigInt? parseYuanToCents(String text) {
  final value = BigRational.tryParse(text);
  if (value == null || value.isNegative) return null;
  return _roundHalfUp(value * BigRational.fromInt(100));
}
