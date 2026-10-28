import 'package:flutter/foundation.dart';

import '../../core/math/calc_value.dart';
import '../../core/math/formatter.dart';
import '../../core/math/math_error.dart';
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
  String input = '1';
  FormattedNumber? result;
  String? error;

  String get resultText => result?.text ?? '';
  bool get approximate => result?.approximate ?? false;
  String get copyText => result?.rawText ?? '';

  void setInput(String value) {
    input = value;
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

  void _recalculate() {
    result = null;
    error = null;
    final text = input.trim();
    if (text.isEmpty) {
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
      error = '请输入有效数字';
      return;
    }
    final converted = category.convert(value, from, to);
    result = const NumberFormatter().format(RationalValue(converted));
  }
}
