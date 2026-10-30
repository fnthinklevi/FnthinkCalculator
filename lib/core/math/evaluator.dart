import 'dart:math' as math;

import 'angle_unit.dart';
import 'ast.dart';
import 'calc_value.dart';
import 'math_error.dart';
import 'percent_mode.dart';
import 'rational.dart';

class Evaluator {
  const Evaluator({
    this.angleUnit = AngleUnit.degrees,
    this.percentMode = PercentMode.proportion,
  });

  final AngleUnit angleUnit;
  final PercentMode percentMode;

  CalcValue evaluate(Expr expression) => _evaluate(expression);

  CalcValue _evaluate(Expr expression) {
    return switch (expression) {
      NumberExpr(:final value) => RationalValue(value),
      ConstantExpr(:final name) => _constant(name),
      UnaryExpr(:final op, :final operand) => _unary(op, _evaluate(operand)),
      BinaryExpr(:final op, :final left, :final right) => _binary(
        op,
        left,
        right,
      ),
      PostfixExpr(:final op, :final operand) => _postfix(
        op,
        _evaluate(operand),
      ),
      FunctionExpr(:final name, :final argument) => _function(
        name,
        _evaluate(argument),
      ),
    };
  }

  CalcValue _constant(String name) {
    return switch (name) {
      'pi' => const DoubleValue(math.pi),
      'e' => const DoubleValue(math.e),
      _ => throw const MathException(MathErrorKind.syntax, '未知常量'),
    };
  }

  CalcValue _unary(UnaryOp op, CalcValue value) {
    return switch (op) {
      UnaryOp.plus => value,
      UnaryOp.minus => negate(value),
    };
  }

  CalcValue _binary(BinaryOp op, Expr leftExpr, Expr rightExpr) {
    final left = _evaluate(leftExpr);

    if ((op == BinaryOp.add || op == BinaryOp.subtract) &&
        rightExpr is PostfixExpr &&
        rightExpr.op == PostfixOp.percent) {
      final inner = _evaluate(rightExpr.operand);
      final hundred = RationalValue(BigRational.fromInt(100));
      final operand = percentMode == PercentMode.value
          ? divide(inner, hundred)
          : divide(multiply(left, inner), hundred);
      return op == BinaryOp.add ? add(left, operand) : subtract(left, operand);
    }

    final right = _evaluate(rightExpr);
    return switch (op) {
      BinaryOp.add => add(left, right),
      BinaryOp.subtract => subtract(left, right),
      BinaryOp.multiply => multiply(left, right),
      BinaryOp.divide => divide(left, right),
      BinaryOp.power => powValue(left, right),
    };
  }

  CalcValue _postfix(PostfixOp op, CalcValue value) {
    return switch (op) {
      PostfixOp.factorial => factorialValue(value),
      PostfixOp.percent => percent(value),
    };
  }

  CalcValue _function(String name, CalcValue argument) {
    if (name == 'abs') {
      return absValue(argument);
    }

    final value = argument.toDouble();
    final result = switch (name) {
      'sin' => math.sin(_toRadians(value)),
      'cos' => math.cos(_toRadians(value)),
      'tan' => _tan(value),
      'asin' => _asin(value),
      'acos' => _acos(value),
      'atan' => _fromRadians(math.atan(value)),
      'ln' => _ln(value, 'ln'),
      'log' => _ln(value, 'log') / math.ln10,
      'sqrt' => _sqrt(value),
      'cbrt' =>
        value < 0
            ? -math.pow(-value, 1 / 3).toDouble()
            : math.pow(value, 1 / 3).toDouble(),
      'exp' => math.exp(value),
      'reciprocal' => _reciprocal(value),
      _ => throw MathException(MathErrorKind.unknownFunction, '未知函数「$name」'),
    };
    return _finite(result);
  }

  double _tan(double value) {
    final radians = _toRadians(value);
    if (math.cos(radians).abs() < 1e-12) {
      throw const MathException(MathErrorKind.domain, 'tan 在该角度无定义');
    }
    return math.tan(radians);
  }

  double _asin(double value) {
    _requireInverseDomain(value, 'asin');
    return _fromRadians(math.asin(value.clamp(-1, 1).toDouble()));
  }

  double _acos(double value) {
    _requireInverseDomain(value, 'acos');
    return _fromRadians(math.acos(value.clamp(-1, 1).toDouble()));
  }

  double _ln(double value, String name) {
    _requirePositive(value, name);
    return math.log(value);
  }

  double _sqrt(double value) {
    if (value < -1e-12) {
      throw const MathException(MathErrorKind.domain, '负数不能开平方');
    }
    return math.sqrt(value < 0 ? 0 : value);
  }

  double _reciprocal(double value) {
    if (value == 0) {
      throw const MathException(MathErrorKind.divideByZero, '不能除以0');
    }
    return 1 / value;
  }

  void _requireInverseDomain(double value, String name) {
    if (value < -1 - 1e-12 || value > 1 + 1e-12) {
      throw MathException(MathErrorKind.domain, '$name 的输入必须在 -1 到 1 之间');
    }
  }

  void _requirePositive(double value, String name) {
    if (value <= 0) {
      throw MathException(MathErrorKind.domain, '$name 的输入必须大于 0');
    }
  }

  double _toRadians(double value) {
    return angleUnit == AngleUnit.degrees ? value * math.pi / 180 : value;
  }

  double _fromRadians(double value) {
    return angleUnit == AngleUnit.degrees ? value * 180 / math.pi : value;
  }

  DoubleValue _finite(double value) {
    if (!value.isFinite) {
      throw const MathException(MathErrorKind.overflow, '结果超出范围');
    }
    return DoubleValue(value);
  }
}
