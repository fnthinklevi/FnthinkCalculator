import '../math/rational.dart';

class MortgageLoanPart {
  const MortgageLoanPart({
    required this.principalCents,
    required this.annualRatePercent,
  });

  final BigInt principalCents;
  final BigRational annualRatePercent;
}

class MortgagePeriod {
  const MortgagePeriod({
    required this.period,
    required this.paymentCents,
    required this.principalCents,
    required this.interestCents,
    required this.balanceCents,
  });

  final int period;
  final BigInt paymentCents;
  final BigInt principalCents;
  final BigInt interestCents;
  final BigInt balanceCents;
}

class MortgageResult {
  const MortgageResult({
    required this.periods,
    required this.principalCents,
    required this.interestCents,
    required this.repaymentCents,
    required this.firstPaymentCents,
    required this.lastPaymentCents,
    required this.monthlyDecreaseCents,
    required this.equalPayment,
  });

  final List<MortgagePeriod> periods;
  final BigInt principalCents;
  final BigInt interestCents;
  final BigInt repaymentCents;
  final BigInt firstPaymentCents;
  final BigInt lastPaymentCents;
  final BigInt monthlyDecreaseCents;
  final bool equalPayment;
}

MortgageResult calculateMortgage({
  required List<MortgageLoanPart> parts,
  required int years,
  required bool equalPayment,
}) {
  if (parts.isEmpty || years < 1 || years > 30) {
    throw ArgumentError('贷款参数不合法');
  }
  for (final part in parts) {
    if (part.principalCents <= BigInt.zero) {
      throw ArgumentError('贷款金额需大于 0');
    }
    if (part.annualRatePercent.isNegative ||
        part.annualRatePercent.compareTo(BigRational.fromInt(100)) > 0) {
      throw ArgumentError('年利率需在 0–100% 之间');
    }
  }

  final count = years * 12;
  final schedules = [
    for (final part in parts)
      _schedule(
        principalCents: part.principalCents,
        annualRatePercent: part.annualRatePercent,
        count: count,
        equalPayment: equalPayment,
      ),
  ];

  final periods = <MortgagePeriod>[];
  for (var index = 0; index < count; index++) {
    var payment = BigInt.zero;
    var principal = BigInt.zero;
    var interest = BigInt.zero;
    var balance = BigInt.zero;
    for (final schedule in schedules) {
      final row = schedule[index];
      payment += row.paymentCents;
      principal += row.principalCents;
      interest += row.interestCents;
      balance += row.balanceCents;
    }
    periods.add(
      MortgagePeriod(
        period: index + 1,
        paymentCents: payment,
        principalCents: principal,
        interestCents: interest,
        balanceCents: balance,
      ),
    );
  }

  var totalPrincipal = BigInt.zero;
  var totalInterest = BigInt.zero;
  for (final period in periods) {
    totalPrincipal += period.principalCents;
    totalInterest += period.interestCents;
  }

  return MortgageResult(
    periods: periods,
    principalCents: totalPrincipal,
    interestCents: totalInterest,
    repaymentCents: totalPrincipal + totalInterest,
    firstPaymentCents: periods.first.paymentCents,
    lastPaymentCents: periods.last.paymentCents,
    monthlyDecreaseCents: count > 1
        ? periods.first.paymentCents - periods[1].paymentCents
        : BigInt.zero,
    equalPayment: equalPayment,
  );
}

List<MortgagePeriod> _schedule({
  required BigInt principalCents,
  required BigRational annualRatePercent,
  required int count,
  required bool equalPayment,
}) {
  final monthlyRate = annualRatePercent / BigRational.fromInt(1200);
  var balance = principalCents;
  final rows = <MortgagePeriod>[];

  if (equalPayment) {
    final basePayment = monthlyRate.isZero
        ? _roundHalfUp(
            BigRational.fromBigInt(principalCents) / BigRational.fromInt(count),
          )
        : _roundHalfUp(_monthlyPayment(principalCents, monthlyRate, count));
    for (var index = 1; index <= count; index++) {
      final interest = _roundHalfUp(
        BigRational.fromBigInt(balance) * monthlyRate,
      );
      final isLast = index == count;
      var principalPart = isLast ? balance : basePayment - interest;
      if (!isLast && principalPart > balance) {
        principalPart = balance;
      }
      if (principalPart < BigInt.zero) {
        principalPart = BigInt.zero;
      }
      final payment = principalPart + interest;
      balance -= principalPart;
      rows.add(
        MortgagePeriod(
          period: index,
          paymentCents: payment,
          principalCents: principalPart,
          interestCents: interest,
          balanceCents: balance,
        ),
      );
    }
    return rows;
  }

  final basePrincipal = _roundHalfUp(
    BigRational.fromBigInt(principalCents) / BigRational.fromInt(count),
  );
  for (var index = 1; index <= count; index++) {
    final isLast = index == count;
    final principalPart = isLast
        ? balance
        : (basePrincipal < balance ? basePrincipal : balance);
    final interest = _roundHalfUp(
      BigRational.fromBigInt(balance) * monthlyRate,
    );
    balance -= principalPart;
    rows.add(
      MortgagePeriod(
        period: index,
        paymentCents: principalPart + interest,
        principalCents: principalPart,
        interestCents: interest,
        balanceCents: balance,
      ),
    );
  }
  return rows;
}

BigRational _monthlyPayment(
  BigInt principalCents,
  BigRational monthlyRate,
  int count,
) {
  final growth = (BigRational.one + monthlyRate).pow(count);
  return BigRational.fromBigInt(principalCents) *
      monthlyRate *
      growth /
      (growth - BigRational.one);
}

BigInt _roundHalfUp(BigRational value) {
  final adjusted = value.n * BigInt.two + value.d;
  return adjusted ~/ (value.d * BigInt.two);
}

String formatMoneyCents(BigInt cents) {
  final negative = cents.isNegative;
  final absolute = cents.abs();
  final yuan = absolute ~/ BigInt.from(100);
  final fen = (absolute % BigInt.from(100)).toInt().toString().padLeft(2, '0');
  final digits = yuan.toString();
  final buffer = StringBuffer();
  final firstGroup = digits.length % 3;
  var index = 0;
  if (firstGroup > 0) {
    buffer.write(digits.substring(0, firstGroup));
    index = firstGroup;
  }
  while (index < digits.length) {
    if (buffer.isNotEmpty) {
      buffer.write(',');
    }
    buffer.write(digits.substring(index, index + 3));
    index += 3;
  }
  return '${negative ? '-' : ''}$buffer.$fen';
}
