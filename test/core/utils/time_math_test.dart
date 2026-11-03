import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/math/rational.dart';
import 'package:fnthink_calculator/core/utils/time_math.dart';

TimeDurationOperand duration(int seconds) {
  return TimeDurationOperand(BigRational.fromInt(seconds));
}

TimeScalarOperand scalar(String value) {
  return TimeScalarOperand(BigRational.parse(value));
}

BigInt evaluate(List<TimeOperand> operands, List<TimeOperator> operators) {
  return evaluateTimeExpression(operands: operands, operators: operators);
}

void main() {
  test('时间加减', () {
    expect(
      evaluate([duration(5400), duration(1800)], [TimeOperator.add]),
      BigInt.from(7200),
    );
    expect(
      evaluate([duration(5400), duration(1800)], [TimeOperator.subtract]),
      BigInt.from(3600),
    );
  });

  test('时间乘除标量', () {
    expect(
      evaluate([duration(5400), scalar('1.5')], [TimeOperator.multiply]),
      BigInt.from(8100),
    );
    expect(
      evaluate([duration(5400), scalar('2')], [TimeOperator.divide]),
      BigInt.from(2700),
    );
    expect(
      evaluate([duration(10), scalar('0.1')], [TimeOperator.multiply]),
      BigInt.from(1),
    );
  });

  test('乘除优先于加减', () {
    expect(
      evaluate(
        [duration(5400), duration(1800), scalar('2')],
        [TimeOperator.add, TimeOperator.multiply],
      ),
      BigInt.from(9000),
    );
    expect(
      evaluate(
        [duration(5400), scalar('2'), duration(1800)],
        [TimeOperator.multiply, TimeOperator.add],
      ),
      BigInt.from(12600),
    );
  });

  test('乘除混合链保持精确计算', () {
    expect(
      evaluate(
        [duration(3600), scalar('7'), scalar('7')],
        [TimeOperator.divide, TimeOperator.multiply],
      ),
      BigInt.from(3600),
    );
  });

  test('结果四舍五入到秒', () {
    expect(
      evaluate([duration(1), scalar('3')], [TimeOperator.divide]),
      BigInt.zero,
    );
    expect(
      evaluate([duration(1), scalar('2')], [TimeOperator.divide]),
      BigInt.one,
    );
    expect(
      evaluate([duration(3), scalar('2')], [TimeOperator.divide]),
      BigInt.from(2),
    );
    expect(
      evaluate([duration(-1), scalar('2')], [TimeOperator.divide]),
      BigInt.from(-1),
    );
    expect(
      evaluate([duration(-1), scalar('3')], [TimeOperator.divide]),
      BigInt.zero,
    );
  });

  test('乘零与除零', () {
    expect(
      evaluate([duration(5400), scalar('0')], [TimeOperator.multiply]),
      BigInt.zero,
    );
    expect(
      () => evaluate([duration(5400), scalar('0')], [TimeOperator.divide]),
      throwsA(
        isA<TimeMathException>().having(
          (error) => error.message,
          'message',
          '不能除以 0',
        ),
      ),
    );
  });

  test('禁止时间乘除时间与数字左乘除', () {
    for (final operator in [TimeOperator.multiply, TimeOperator.divide]) {
      expect(
        () => evaluate([duration(60), duration(2)], [operator]),
        throwsA(
          isA<TimeMathException>().having(
            (error) => error.message,
            'message',
            '时间不能乘除时间',
          ),
        ),
      );
      expect(
        () => evaluate([scalar('2'), duration(60)], [operator]),
        throwsA(
          isA<TimeMathException>().having(
            (error) => error.message,
            'message',
            '数字不能作为乘除的左操作数',
          ),
        ),
      );
    }
  });

  test('禁止时间与标量加减', () {
    expect(
      () => evaluate([duration(60), scalar('2')], [TimeOperator.add]),
      throwsA(
        isA<TimeMathException>().having(
          (error) => error.message,
          'message',
          '时间只能与时间加减',
        ),
      ),
    );
  });

  test('表达式必须以时间开始且结构完整', () {
    expect(
      () => evaluate([scalar('2')], const []),
      throwsA(
        isA<TimeMathException>().having(
          (error) => error.message,
          'message',
          '表达式需以时间开始',
        ),
      ),
    );
    expect(
      () => evaluate([duration(60), duration(60)], const []),
      throwsA(
        isA<TimeMathException>().having(
          (error) => error.message,
          'message',
          '表达式不完整',
        ),
      ),
    );
  });

  test('倍数不能为负', () {
    expect(
      () => evaluate([duration(60), scalar('-2')], [TimeOperator.multiply]),
      throwsA(
        isA<TimeMathException>().having(
          (error) => error.message,
          'message',
          '倍数不能为负',
        ),
      ),
    );
  });
}
