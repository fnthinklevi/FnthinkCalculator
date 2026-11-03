import '../math/rational.dart';

enum TimeOperator { add, subtract, multiply, divide }

sealed class TimeOperand {
  const TimeOperand();
}

class TimeDurationOperand extends TimeOperand {
  const TimeDurationOperand(this.seconds);

  final BigRational seconds;
}

class TimeScalarOperand extends TimeOperand {
  const TimeScalarOperand(this.value);

  final BigRational value;
}

class TimeMathException implements Exception {
  const TimeMathException(this.message);

  final String message;

  @override
  String toString() => message;
}

BigInt evaluateTimeExpression({
  required List<TimeOperand> operands,
  required List<TimeOperator> operators,
}) {
  if (operands.length != operators.length + 1) {
    throw const TimeMathException('表达式不完整');
  }

  final values = List<TimeOperand>.from(operands);
  final pending = List<TimeOperator>.from(operators);

  var index = 0;
  while (index < pending.length) {
    final operator = pending[index];
    if (operator != TimeOperator.multiply && operator != TimeOperator.divide) {
      index++;
      continue;
    }

    final left = values[index];
    final right = values[index + 1];
    if (left is! TimeDurationOperand) {
      throw const TimeMathException('数字不能作为乘除的左操作数');
    }
    if (right is! TimeScalarOperand) {
      throw const TimeMathException('时间不能乘除时间');
    }
    if (right.value.isNegative) {
      throw const TimeMathException('倍数不能为负');
    }
    if (operator == TimeOperator.divide && right.value.isZero) {
      throw const TimeMathException('不能除以 0');
    }

    final seconds = operator == TimeOperator.multiply
        ? left.seconds * right.value
        : left.seconds / right.value;
    values.replaceRange(index, index + 2, [TimeDurationOperand(seconds)]);
    pending.removeAt(index);
  }

  var total = values.first;
  if (total is! TimeDurationOperand) {
    throw const TimeMathException('表达式需以时间开始');
  }
  for (var i = 0; i < pending.length; i++) {
    final right = values[i + 1];
    if (right is! TimeDurationOperand) {
      throw const TimeMathException('时间只能与时间加减');
    }
    total = TimeDurationOperand(
      pending[i] == TimeOperator.add
          ? (total as TimeDurationOperand).seconds + right.seconds
          : (total as TimeDurationOperand).seconds - right.seconds,
    );
  }

  return _roundHalfUp((total as TimeDurationOperand).seconds);
}

BigInt _roundHalfUp(BigRational value) {
  final negative = value.isNegative;
  final absolute = value.abs;
  final rounded =
      (absolute.n * BigInt.two + absolute.d) ~/ (absolute.d * BigInt.two);
  return negative ? -rounded : rounded;
}
