import 'package:flutter/foundation.dart';

import '../../core/math/calc_value.dart';
import '../../core/math/calculator_engine.dart';
import '../../core/math/formatter.dart';
import '../../core/math/math_error.dart';
import '../../core/math/percent_mode.dart';
import '../../core/math/rational.dart';
import 'unit_data.dart';

class ConverterController extends ChangeNotifier {
  ConverterController(this.category)
    : from = category.units[category.defaultFromIndex],
      to = category.units[category.defaultToIndex] {
    _recalculate();
  }

  final UnitCategory category;
  UnitDef from;
  UnitDef to;
  bool fromActive = true;
  bool replaceOnNextInput = false;
  String input = '1';
  FormattedNumber? result;
  String? error;

  String get resultText => result?.text ?? '';
  bool get approximate => result?.approximate ?? false;
  String get copyText => result?.rawText ?? '';
  String get fromText => fromActive ? input : resultText;
  String get toText => fromActive ? resultText : input;
  String get activeText => input;
  UnitDef get activeUnit => fromActive ? from : to;

  void consumeFreshInput() {
    replaceOnNextInput = false;
  }

  void setInput(String value) {
    input = value;
    _recalculate();
    notifyListeners();
  }

  void setActive({required bool from}) {
    if (from == fromActive) return;
    final targetText = from
        ? (result?.rawText ?? input)
        : (result?.rawText ?? input);
    fromActive = from;
    input = targetText;
    replaceOnNextInput = true;
    _recalculate();
    notifyListeners();
  }

  void setFrom(UnitDef unit) {
    if (from == unit) return;
    from = unit;
    _recalculate();
    notifyListeners();
  }

  void setTo(UnitDef unit) {
    if (to == unit) return;
    to = unit;
    _recalculate();
    notifyListeners();
  }

  void swap() {
    final previousFrom = from;
    from = to;
    to = previousFrom;
    _recalculate();
    notifyListeners();
  }

  void appendOperator(String operator) {
    if (!const {'+', '−', '×', '÷'}.contains(operator)) return;
    if (input.isEmpty) {
      if (operator == '−') {
        input = '−';
      }
      _recalculate();
      notifyListeners();
      return;
    }
    final last = input[input.length - 1];
    if ('+−×÷'.contains(last)) {
      input = '${input.substring(0, input.length - 1)}$operator';
    } else if (last == '.') {
      input = '${input}0$operator';
    } else {
      input = '$input$operator';
    }
    _recalculate();
    notifyListeners();
  }

  void commit() {
    if (input.isEmpty) return;
    final outcome = const CalculatorEngine().evaluate(
      input,
      percentMode: PercentMode.value,
    );
    if (outcome.isSuccess) {
      input = outcome.formatted!.rawText;
      _recalculate();
    } else {
      error = outcome.error!.message;
      result = null;
    }
    notifyListeners();
  }

  void clear() {
    input = '';
    result = null;
    error = null;
    notifyListeners();
  }

  void backspace() {
    if (input.isEmpty) return;
    input = input.substring(0, input.length - 1);
    _recalculate();
    notifyListeners();
  }

  void toggleSign() {
    if (input.isEmpty) {
      input = '-';
    } else if (input.startsWith('−')) {
      input = input.substring(1);
    } else if (input.startsWith('-')) {
      input = input.substring(1);
    } else {
      input = '-$input';
    }
    _recalculate();
    notifyListeners();
  }

  void _recalculate() {
    result = null;
    error = null;
    final text = input.trim();
    if (text.isEmpty) return;
    if (const {'+', '−', '×', '÷', '-'}.contains(text[text.length - 1])) {
      return;
    }

    BigRational? value;
    try {
      value = BigRational.tryParse(text);
    } on MathException catch (exception) {
      error = exception.message;
      return;
    }
    if (value == null) {
      final outcome = const CalculatorEngine().evaluate(
        text.replaceAll('−', '-'),
        percentMode: PercentMode.value,
      );
      if (!outcome.isSuccess) {
        error = outcome.error!.message;
        return;
      }
      value = BigRational.tryParse(outcome.formatted!.rawText);
      if (value == null) {
        error = '请输入有效数字';
        return;
      }
    }

    final converted = fromActive
        ? category.convert(value, from, to)
        : category.convert(value, to, from);
    result = const NumberFormatter().format(RationalValue(converted));
  }
}
