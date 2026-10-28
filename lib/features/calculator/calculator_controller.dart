import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/math/angle_unit.dart';
import '../../core/math/calculator_engine.dart';
import '../../core/math/formatter.dart';
import '../../core/math/math_error.dart';
import 'history_entry.dart';
import 'history_repository.dart';

enum CalculatorMode { input, result, error }

class CalculatorController extends ChangeNotifier {
  factory CalculatorController({
    CalculatorEngine engine = const CalculatorEngine(),
    AngleUnit angleUnit = AngleUnit.degrees,
    List<HistoryEntry> initialHistory = const [],
    HistoryStore? historyStore,
    int maxHistory = 200,
  }) {
    final loaded =
        historyStore?.load() ?? List<HistoryEntry>.of(initialHistory);
    final history = loaded.take(maxHistory).toList(growable: true);
    return CalculatorController._(
      engine,
      angleUnit,
      historyStore,
      history,
      maxHistory,
    );
  }

  CalculatorController._(
    this._engine,
    this._angleUnit,
    this._historyStore,
    this._history,
    this.maxHistory,
  );

  final CalculatorEngine _engine;
  final HistoryStore? _historyStore;
  final int maxHistory;
  final List<HistoryEntry> _history;
  AngleUnit _angleUnit;

  String _expression = '';
  int _caret = 0;
  CalculatorMode _mode = CalculatorMode.input;
  String _committedExpression = '';
  FormattedNumber? _preview;
  MathException? _error;
  FormattedNumber? _result;
  bool _scientificVisible = false;
  bool _second = false;

  static const _functions = {
    'sin',
    'cos',
    'tan',
    'asin',
    'acos',
    'atan',
    'ln',
    'log',
    'sqrt',
    'cbrt',
    'abs',
    'exp',
  };

  String get expression => _expression;
  int get caret => _caret;
  CalculatorMode get mode => _mode;
  AngleUnit get angleUnit => _angleUnit;
  bool get scientificVisible => _scientificVisible;
  bool get second => _second;
  bool get isInputMode => _mode == CalculatorMode.input;
  bool get isResultMode => _mode == CalculatorMode.result;
  bool get isErrorMode => _mode == CalculatorMode.error;
  String get committedExpression => _committedExpression;
  String get errorMessage => _error?.message ?? '';
  String get previewText => _preview?.text ?? '';
  bool get previewApproximate => _preview?.approximate ?? false;
  bool get showPreview =>
      _mode == CalculatorMode.input &&
      _expression.isNotEmpty &&
      _preview != null;

  String get mainText {
    if (_mode == CalculatorMode.result) {
      return _result?.text ?? '0';
    }
    return _expression.isEmpty ? '0' : _expression;
  }

  bool get mainApproximate =>
      _mode == CalculatorMode.result && (_result?.approximate ?? false);

  String get clearLabel =>
      _expression.isEmpty && _mode == CalculatorMode.input ? 'AC' : 'C';

  FormattedNumber? get activeFormatted {
    if (_mode == CalculatorMode.result) {
      return _result;
    }
    if (_mode == CalculatorMode.input) {
      return _preview;
    }
    return null;
  }

  String get copyText => activeFormatted?.text ?? _expression;

  bool get canConvertToUppercase => activeFormatted != null;

  List<HistoryEntry> get history => List.unmodifiable(_history);

  List<HistoryEntry> get recentHistory {
    Iterable<HistoryEntry> entries = _history;
    if (_expression.isNotEmpty &&
        entries.isNotEmpty &&
        entries.first.expression == _expression) {
      entries = entries.skip(1);
    }
    return entries.take(2).toList(growable: false);
  }

  void setAngleUnit(AngleUnit value) {
    if (_angleUnit == value) return;
    _angleUnit = value;
    _refreshPreview();
    notifyListeners();
  }

  void toggleScientific() {
    _scientificVisible = !_scientificVisible;
    notifyListeners();
  }

  void toggleSecond() {
    _second = !_second;
    notifyListeners();
  }

  void setCaret(int position) {
    final clamped = position.clamp(0, _expression.length);
    if (clamped == _caret) return;
    _caret = clamped;
    notifyListeners();
  }

  void inputDigit(String digit) {
    if (digit.length != 1 || !_isDigitChar(digit)) return;
    if (_mode != CalculatorMode.input) {
      _startFreshInput();
    }
    if (_caret > 0 && _isOperandEndNonDigit(_expression[_caret - 1])) {
      _insertAtCaret('×$digit');
      return;
    }
    final numberStart = _numberStartBeforeCaret();
    final currentNumber = _expression.substring(numberStart, _caret);
    if (currentNumber == '0') {
      if (digit == '0') return;
      _expression = _expression.replaceRange(numberStart, _caret, digit);
      _caret = numberStart + digit.length;
      _afterEdit();
      return;
    }
    _insertAtCaret(digit);
  }

  void inputDecimal() {
    if (_mode != CalculatorMode.input) {
      _startFreshInput();
    }
    if (_caret > 0 && _isOperandEndNonDigit(_expression[_caret - 1])) {
      _insertAtCaret('×0.');
      return;
    }
    if (_caret > 0 && _expression[_caret - 1] == '.') {
      return;
    }
    final numberStart = _numberStartBeforeCaret();
    final currentNumber = _expression.substring(numberStart, _caret);
    if (currentNumber.contains('.')) {
      return;
    }
    if (currentNumber.isEmpty) {
      _insertAtCaret('0.');
    } else {
      _insertAtCaret('.');
    }
  }

  void inputOperator(String operator) {
    if (!const {'+', '−', '×', '÷', '^'}.contains(operator)) {
      return;
    }
    if (_mode == CalculatorMode.error) {
      _startFreshInput();
      if (operator == '−') {
        _insertAtCaret('−');
      }
      return;
    }
    if (_mode == CalculatorMode.result) {
      final base = _result!.rawText;
      _expression = '$base$operator';
      _caret = _expression.length;
      _afterEdit();
      return;
    }
    if (_expression.isEmpty) {
      if (operator == '−') {
        _insertAtCaret('−');
      }
      return;
    }
    final index = _caret.clamp(0, _expression.length);
    if (index == 0) {
      if (operator == '−') {
        _insertAtCaret('−');
      }
      return;
    }
    final previous = _expression[index - 1];
    if (_isOperator(previous)) {
      if ((operator == '−' || operator == '+') &&
          (previous == '×' || previous == '÷')) {
        _insertAtCaret(operator);
        return;
      }
      _replaceBeforeCaret(operator);
      return;
    }
    if (previous == '(') {
      if (operator == '−' || operator == '+') {
        _insertAtCaret(operator);
      }
      return;
    }
    if (previous == '.') {
      return;
    }
    _insertAtCaret(operator);
  }

  void inputLeftParen() {
    if (_mode != CalculatorMode.input) {
      _startFreshInput();
    }
    if (_caret > 0 && _isOperandEnd(_expression[_caret - 1])) {
      _insertAtCaret('×(');
    } else {
      _insertAtCaret('(');
    }
  }

  void inputRightParen() {
    if (_mode != CalculatorMode.input || _caret == 0) {
      return;
    }
    var balance = 0;
    for (var index = 0; index < _caret; index++) {
      if (_expression[index] == '(') {
        balance++;
      } else if (_expression[index] == ')') {
        balance--;
      }
    }
    if (balance <= 0) {
      return;
    }
    final previous = _expression[_caret - 1];
    if (!_isOperandEnd(previous)) {
      return;
    }
    _insertAtCaret(')');
  }

  void inputFunction(String name) {
    if (!_functions.contains(name)) return;
    if (_mode != CalculatorMode.input) {
      _startFreshInput();
    }
    if (_caret > 0 && _isOperandEnd(_expression[_caret - 1])) {
      _insertAtCaret('×$name(');
    } else {
      _insertAtCaret('$name(');
    }
  }

  void inputConstant(String name) {
    final symbol = switch (name) {
      'pi' => 'π',
      'e' => 'e',
      _ => null,
    };
    if (symbol == null) return;
    if (_mode != CalculatorMode.input) {
      _startFreshInput();
    }
    if (_caret > 0 && _isOperandEnd(_expression[_caret - 1])) {
      _insertAtCaret('×$symbol');
    } else {
      _insertAtCaret(symbol);
    }
  }

  void inputPostfix(String postfix) {
    if (postfix != '%' && postfix != '!') return;
    if (_mode != CalculatorMode.input || _caret == 0) return;
    if (!_isOperandEnd(_expression[_caret - 1])) return;
    _insertAtCaret(postfix);
  }

  void inputPower(int exponent) {
    if (exponent != 2 && exponent != 3) {
      inputOperator('^');
      return;
    }
    if (_caret == 0 || !_isOperandEnd(_expression[_caret - 1])) return;
    _insertAtCaret('^$exponent');
  }

  void inputTenPower() {
    if (_mode != CalculatorMode.input) {
      _startFreshInput();
    }
    if (_caret > 0 && _isOperandEnd(_expression[_caret - 1])) {
      _insertAtCaret('×10^');
    } else {
      _insertAtCaret('10^');
    }
  }

  void inputExpPower() {
    if (_mode != CalculatorMode.input) {
      _startFreshInput();
    }
    if (_caret > 0 && _isOperandEnd(_expression[_caret - 1])) {
      _insertAtCaret('×e^');
    } else {
      _insertAtCaret('e^');
    }
  }

  void backspace() {
    if (_mode == CalculatorMode.result) {
      _mode = CalculatorMode.input;
      _expression = _committedExpression;
      _caret = _expression.length;
      _result = null;
      _error = null;
      _refreshPreview();
      notifyListeners();
      return;
    }
    if (_mode == CalculatorMode.error) {
      _mode = CalculatorMode.input;
      _error = null;
    }
    if (_expression.isEmpty) return;
    final index = _caret.clamp(0, _expression.length);
    if (index == 0) return;
    _expression = _expression.replaceRange(index - 1, index, '');
    _caret = index - 1;
    _result = null;
    _committedExpression = '';
    _refreshPreview();
    notifyListeners();
  }

  void clear() {
    _expression = '';
    _caret = 0;
    _mode = CalculatorMode.input;
    _committedExpression = '';
    _preview = null;
    _error = null;
    _result = null;
    notifyListeners();
  }

  void evaluate() {
    if (_expression.isEmpty) return;
    final prepared = CalculatorEngine.autoCloseParentheses(_expression);
    final outcome = _engine.evaluate(prepared, angleUnit: _angleUnit);
    final error = outcome.error;
    if (error != null) {
      _expression = prepared;
      _caret = prepared.length;
      _mode = CalculatorMode.error;
      _committedExpression = prepared;
      _preview = null;
      _result = null;
      _error = error;
      notifyListeners();
      return;
    }
    final formatted = outcome.formatted!;
    _expression = prepared;
    _caret = prepared.length;
    _mode = CalculatorMode.result;
    _committedExpression = prepared;
    _preview = null;
    _error = null;
    _result = formatted;
    _history.insert(
      0,
      HistoryEntry(
        expression: prepared,
        resultText: formatted.text,
        rawResult: formatted.rawText,
        approximate: formatted.approximate,
        createdAt: DateTime.now(),
      ),
    );
    if (_history.length > maxHistory) {
      _history.removeRange(maxHistory, _history.length);
    }
    _persistHistory();
    notifyListeners();
  }

  void useHistory(HistoryEntry entry) {
    _expression = entry.rawResult;
    _caret = _expression.length;
    _mode = CalculatorMode.input;
    _committedExpression = '';
    _result = null;
    _error = null;
    _refreshPreview();
    notifyListeners();
  }

  void removeHistory(HistoryEntry entry) {
    final removed = _history.remove(entry);
    if (!removed) return;
    _persistHistory();
    notifyListeners();
  }

  void clearHistory() {
    if (_history.isEmpty) return;
    _history.clear();
    _persistHistory();
    notifyListeners();
  }

  void _persistHistory() {
    final store = _historyStore;
    if (store == null) return;
    unawaited(store.save(List<HistoryEntry>.unmodifiable(_history)));
  }

  void _startFreshInput() {
    _expression = '';
    _caret = 0;
    _mode = CalculatorMode.input;
    _committedExpression = '';
    _preview = null;
    _error = null;
    _result = null;
  }

  void _insertAtCaret(String text) {
    final index = _caret.clamp(0, _expression.length);
    _expression = _expression.replaceRange(index, index, text);
    _caret = index + text.length;
    _afterEdit();
  }

  void _replaceBeforeCaret(String text) {
    final index = _caret.clamp(0, _expression.length);
    if (index == 0) return;
    _expression = _expression.replaceRange(index - 1, index, text);
    _caret = index - 1 + text.length;
    _afterEdit();
  }

  void _afterEdit() {
    _mode = CalculatorMode.input;
    _error = null;
    _result = null;
    _committedExpression = '';
    _refreshPreview();
    notifyListeners();
  }

  void _refreshPreview() {
    _preview = null;
    if (_mode != CalculatorMode.input || _expression.isEmpty) {
      return;
    }
    final outcome = _engine.evaluate(_expression, angleUnit: _angleUnit);
    if (outcome.isSuccess) {
      _preview = outcome.formatted;
    }
  }

  int _numberStartBeforeCaret() {
    var index = _caret.clamp(0, _expression.length);
    while (index > 0) {
      final char = _expression[index - 1];
      if (_isDigitChar(char) || char == '.') {
        index--;
      } else {
        break;
      }
    }
    return index;
  }

  bool _isOperator(String char) => '+−×÷^'.contains(char);

  bool _isDigitChar(String char) {
    final code = char.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  bool _isOperandEnd(String char) {
    return _isDigitChar(char) ||
        char == ')' ||
        char == '%' ||
        char == '!' ||
        char == 'π' ||
        char == 'e';
  }

  bool _isOperandEndNonDigit(String char) {
    return char == ')' ||
        char == '%' ||
        char == '!' ||
        char == 'π' ||
        char == 'e';
  }
}
