import 'angle_unit.dart';
import 'calc_value.dart';
import 'evaluator.dart';
import 'formatter.dart';
import 'lexer.dart';
import 'math_error.dart';
import 'parser.dart';
import 'percent_mode.dart';

class EvalOutcome {
  const EvalOutcome.success(this.value, this.formatted) : error = null;

  const EvalOutcome.failure(this.error) : value = null, formatted = null;

  final CalcValue? value;
  final FormattedNumber? formatted;
  final MathException? error;

  bool get isSuccess => error == null;
}

class CalculatorEngine {
  const CalculatorEngine();

  EvalOutcome evaluate(
    String source, {
    AngleUnit angleUnit = AngleUnit.degrees,
    PercentMode percentMode = PercentMode.proportion,
    int significantDigits = 12,
  }) {
    final text = source.trim();
    if (text.isEmpty) {
      return const EvalOutcome.failure(
        MathException(MathErrorKind.empty, '请输入算式'),
      );
    }
    try {
      final prepared = autoCloseParentheses(text);
      final tokens = Lexer(prepared).tokenize();
      final expression = Parser(tokens).parse();
      final value = Evaluator(
        angleUnit: angleUnit,
        percentMode: percentMode,
      ).evaluate(expression);
      final formatted = NumberFormatter(significantDigits: significantDigits)
          .format(value);
      return EvalOutcome.success(value, formatted);
    } on MathException catch (error) {
      return EvalOutcome.failure(error);
    } catch (_) {
      return const EvalOutcome.failure(
        MathException(MathErrorKind.syntax, '无法计算该算式'),
      );
    }
  }

  static String autoCloseParentheses(String source) {
    var balance = 0;
    for (final code in source.codeUnits) {
      if (code == 0x28) {
        balance++;
      } else if (code == 0x29) {
        balance--;
        if (balance < 0) {
          return source;
        }
      }
    }
    return balance > 0 ? '$source${')' * balance}' : source;
  }
}
