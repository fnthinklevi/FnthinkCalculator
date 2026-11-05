import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../core/math/rational.dart';
import '../../../core/utils/duration_calc.dart';
import '../../../core/utils/time_math.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/calc_key.dart';
import 'time_history.dart';
import 'time_widgets.dart';

enum _TimeSegment { hours, minutes, seconds }

class _ExprToken {
  _ExprToken.duration(BigRational seconds)
    : operand = TimeDurationOperand(seconds),
      displayText = null;

  _ExprToken.scalar(BigRational value, this.displayText)
    : operand = TimeScalarOperand(value);

  final TimeOperand operand;
  final String? displayText;

  bool get isScalar => operand is TimeScalarOperand;
  BigRational get seconds => (operand as TimeDurationOperand).seconds;
  BigRational get scalar => (operand as TimeScalarOperand).value;
}

class TimeCalculationView extends StatelessWidget {
  const TimeCalculationView({super.key, this.historyStore});

  final TimeHistoryStore? historyStore;

  @override
  Widget build(BuildContext context) =>
      _DurationArithmeticView(historyStore: historyStore);
}

class _DurationArithmeticView extends StatefulWidget {
  const _DurationArithmeticView({this.historyStore});

  final TimeHistoryStore? historyStore;

  @override
  State<_DurationArithmeticView> createState() =>
      _DurationArithmeticViewState();
}

class _DurationArithmeticViewState extends State<_DurationArithmeticView> {
  final List<_ExprToken> _operands = [];
  final List<TimeOperator> _operators = [];
  int? _result;
  bool _showResult = false;
  bool _negative = false;
  bool _carryToDays = false;

  _TimeSegment _active = _TimeSegment.hours;
  String _buffer = '';
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  String _scalarBuffer = '';
  String? _error;
  TimeHistoryStore? _historyStore;
  List<TimeHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    final provided = widget.historyStore;
    if (provided != null) {
      _historyStore = provided;
      _history = provided.load();
    } else {
      unawaited(_loadHistoryStore());
    }
  }

  Future<void> _loadHistoryStore() async {
    final store = await defaultTimeHistoryStore();
    if (!mounted) return;
    final loaded = store.load();
    setState(() {
      _historyStore = store;
      if (_history.isEmpty) {
        _history = loaded;
      } else {
        unawaited(store.save(_history));
      }
    });
  }

  bool get _isScalarEntry =>
      !_showResult &&
      _error == null &&
      _operators.isNotEmpty &&
      (_operators.last == TimeOperator.multiply ||
          _operators.last == TimeOperator.divide);

  bool get _isCurrentEntryEmpty =>
      _isScalarEntry ? _scalarBuffer.isEmpty : _buffer.isEmpty;

  int get _entrySeconds {
    final value = _hours * 3600 + _minutes * 60 + _seconds;
    return _negative ? -value : value;
  }

  String get _displayText {
    if (_error != null) return '—';
    if (_showResult && _carryToDays) {
      return formatDuration(_result!);
    }
    if (_showResult) {
      return formatDurationAccumulated(_result!);
    }
    if (_isScalarEntry) {
      return _scalarBuffer.isEmpty ? '0' : _scalarBuffer;
    }
    return formatDurationAccumulated(_entrySeconds);
  }

  String get _expressionText {
    if (_error != null) {
      return '${_expressionParts(includeCurrentEntry: false).join(' ')} =';
    }
    if (_showResult) {
      return '${_expressionParts(includeCurrentEntry: false).join(' ')} =';
    }
    if (_operands.isEmpty) return '时 : 分 : 秒';
    return _expressionParts(includeCurrentEntry: true).join(' ');
  }

  List<String> _expressionParts({required bool includeCurrentEntry}) {
    final parts = <String>[];
    for (var index = 0; index < _operands.length; index++) {
      final token = _operands[index];
      parts.add(
        token.isScalar
            ? token.displayText ?? '0'
            : formatDurationAccumulated(token.seconds.toBigInt().toInt()),
      );
      if (index < _operators.length) {
        parts.add(_operatorSymbol(_operators[index]));
      }
    }
    if (includeCurrentEntry &&
        _operators.isNotEmpty &&
        _operands.length == _operators.length) {
      if (_isScalarEntry) {
        if (_scalarBuffer.isNotEmpty) parts.add(_scalarBuffer);
      } else if (_buffer.isNotEmpty) {
        parts.add(formatDurationAccumulated(_entrySeconds));
      }
    }
    return parts;
  }

  String _operatorSymbol(TimeOperator operator) {
    return switch (operator) {
      TimeOperator.add => '+',
      TimeOperator.subtract => '−',
      TimeOperator.multiply => '×',
      TimeOperator.divide => '÷',
    };
  }

  String get _totalText {
    if (_error != null) return '—';
    if (_showResult) {
      return '共 ${formatDurationAccumulated(_result!)}';
    }
    if (_isScalarEntry) return '倍数';
    return '共 ${formatDurationAccumulated(_entrySeconds)}';
  }

  int get _activeValue => switch (_active) {
    _TimeSegment.hours => _hours,
    _TimeSegment.minutes => _minutes,
    _TimeSegment.seconds => _seconds,
  };

  String get _activeValueText => _activeValue.toString();

  void _setActiveValue(int value) {
    switch (_active) {
      case _TimeSegment.hours:
        _hours = value;
        break;
      case _TimeSegment.minutes:
        _minutes = value;
        break;
      case _TimeSegment.seconds:
        _seconds = value;
        break;
    }
  }

  void _normalizeSegments() {
    final total = _hours * 3600 + _minutes * 60 + _seconds;
    _hours = total ~/ 3600;
    _minutes = (total % 3600) ~/ 60;
    _seconds = total % 60;
  }

  void _resetEntry() {
    _hours = 0;
    _minutes = 0;
    _seconds = 0;
    _active = _TimeSegment.hours;
    _buffer = '';
    _negative = false;
    _scalarBuffer = '';
  }

  void _resetCalculation() {
    _resetEntry();
    _operands.clear();
    _operators.clear();
    _result = null;
    _showResult = false;
    _error = null;
  }

  void _appendDigit(String digit) {
    setState(() {
      if (_error != null || _showResult) {
        _resetCalculation();
      }
      if (_isScalarEntry) {
        _appendScalarDigit(digit);
        return;
      }
      if (_buffer.isEmpty) {
        _buffer = '0';
      }
      if (_buffer == '0') {
        if (digit == '0') return;
        _buffer = digit;
      } else {
        final maxLength = _active == _TimeSegment.hours ? 5 : 2;
        if (_buffer.length >= maxLength) return;
        _buffer += digit;
      }
      _setActiveValue(int.tryParse(_buffer) ?? 0);
      _normalizeSegments();
      _buffer = _activeValueText;
    });
  }

  void _appendScalarDigit(String digit) {
    if (_scalarBuffer.length >= 12) return;
    if (_scalarBuffer.isEmpty) {
      _scalarBuffer = digit == '0' ? '0' : digit;
      return;
    }
    if (_scalarBuffer == '0') {
      if (digit == '0') return;
      _scalarBuffer = digit;
      return;
    }
    _scalarBuffer += digit;
  }

  void _appendDoubleZero() {
    _appendDigit('0');
    _appendDigit('0');
  }

  void _selectSegment(_TimeSegment segment) {
    if (_isScalarEntry) return;
    setState(() {
      if (_error != null || _showResult) {
        _resetCalculation();
      }
      _active = segment;
      _buffer = '';
    });
  }

  void _colonOrDotPressed() {
    setState(() {
      if (_error != null || _showResult) {
        _resetCalculation();
      }
      if (_isScalarEntry) {
        _appendScalarDot();
        return;
      }
      _active = switch (_active) {
        _TimeSegment.hours => _TimeSegment.minutes,
        _TimeSegment.minutes => _TimeSegment.seconds,
        _TimeSegment.seconds => _TimeSegment.hours,
      };
      _buffer = '';
    });
  }

  void _appendScalarDot() {
    if (_scalarBuffer.contains('.') || _scalarBuffer.length >= 12) return;
    if (_scalarBuffer.isEmpty) {
      _scalarBuffer = '0.';
    } else {
      _scalarBuffer += '.';
    }
  }

  void _operatorPressed(TimeOperator operator) {
    setState(() {
      if (_error != null) {
        _resetCalculation();
      }
      if (_showResult) {
        final base = _result!;
        _operands
          ..clear()
          ..add(_ExprToken.duration(BigRational.fromInt(base)));
        _operators
          ..clear()
          ..add(operator);
        _result = null;
        _showResult = false;
        _resetEntry();
        return;
      }
      if (_operators.isNotEmpty &&
          _operands.length == _operators.length &&
          _isCurrentEntryEmpty) {
        _operators[_operators.length - 1] = operator;
        _resetEntry();
        return;
      }
      _appendCurrentOperand();
      _operators.add(operator);
      _resetEntry();
    });
  }

  void _appendCurrentOperand() {
    if (_isScalarEntry) {
      final text = _scalarBuffer.isEmpty ? '0' : _scalarBuffer;
      final value = BigRational.tryParse(text) ?? BigRational.zero;
      _operands.add(_ExprToken.scalar(value, text));
      return;
    }
    _operands.add(_ExprToken.duration(BigRational.fromInt(_entrySeconds)));
  }

  void _equalsPressed() {
    if (_showResult ||
        _error != null ||
        _operands.isEmpty ||
        _operators.isEmpty) {
      return;
    }
    setState(() {
      if (_operands.length == _operators.length) {
        _appendCurrentOperand();
      }
      try {
        final seconds = evaluateTimeExpression(
          operands: [for (final token in _operands) token.operand],
          operators: List<TimeOperator>.of(_operators),
        );
        if (seconds.abs() > BigInt.from(1000000000000)) {
          throw const TimeMathException('结果过大');
        }
        _result = seconds.toInt();
        _showResult = true;
        _error = null;
        _recordHistory(
          '${_expressionParts(includeCurrentEntry: false).join(' ')} =',
          formatDurationAccumulated(_result!),
        );
      } on TimeMathException catch (exception) {
        _result = null;
        _showResult = false;
        _error = exception.message;
      }
      _resetEntry();
    });
  }

  void _signPressed() {
    if (_isScalarEntry) return;
    setState(() {
      if (_error != null || _showResult) {
        _resetCalculation();
      }
      _negative = !_negative;
    });
  }

  void _backspacePressed() {
    setState(() {
      if (_error != null) {
        _resetCalculation();
        return;
      }
      if (_showResult) {
        _resetCalculation();
        return;
      }
      if (_isScalarEntry) {
        if (_scalarBuffer.isNotEmpty) {
          _scalarBuffer = _scalarBuffer.substring(0, _scalarBuffer.length - 1);
        }
        return;
      }
      if (_buffer.isEmpty) {
        _setActiveValue(0);
        _normalizeSegments();
        _buffer = _activeValueText;
        return;
      }
      final next = _buffer.substring(0, _buffer.length - 1);
      _buffer = next.isEmpty ? '0' : next;
      _setActiveValue(int.tryParse(_buffer) ?? 0);
      _normalizeSegments();
      _buffer = _activeValueText;
    });
  }

  void _clearPressed() {
    setState(_resetCalculation);
  }

  void _setCarryToDays(bool value) {
    if (_carryToDays == value) return;
    setState(() => _carryToDays = value);
  }

  void _recordHistory(String expression, String resultText) {
    final entry = TimeHistoryEntry(
      expression: expression,
      resultText: resultText,
      createdAt: DateTime.now(),
    );
    _history = [entry, ..._history].take(100).toList();
    unawaited(_historyStore?.save(_history));
  }

  Future<void> _openHistory() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: CalcColors.keyBackground(context),
      builder: (sheetContext) => _TimeHistorySheet(
        entries: _history,
        onClear: () {
          setState(() => _history = []);
          unawaited(_historyStore?.save(const <TimeHistoryEntry>[]));
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.maybeOf(context);
    void press(VoidCallback action) {
      if (settings?.haptics ?? true) {
        HapticFeedback.lightImpact();
      }
      action();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SegmentedTabs(
            labels: const ['进到日', '累计小时'],
            index: _carryToDays ? 0 : 1,
            onChanged: (index) => _setCarryToDays(index == 0),
            keyPrefix: 'duration-carry',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: _displayCard(context),
        ),
        Expanded(child: _keypad(press)),
      ],
    );
  }

  Widget _displayCard(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Container(
      key: const Key('duration-calc-card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CalcColors.keyBackground(context),
        borderRadius: BorderRadius.circular(CalcRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                _error != null
                    ? '错误'
                    : (_showResult ? '结果' : (_isScalarEntry ? '倍数' : '输入')),
                style: TextStyle(
                  fontSize: 15,
                  color: _error != null ? CalcColors.error : secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _error != null
                      ? Text(
                          _error!,
                          key: const Key('duration-calc-error'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: CalcColors.error,
                          ),
                        )
                      : Text(
                          _totalText,
                          key: const Key('duration-calc-total-seconds'),
                          style: TextStyle(fontSize: 15, color: secondary),
                        ),
                ),
              ),
              const SizedBox(width: 4),
              Semantics(
                button: true,
                label: '时间计算历史',
                child: InkWell(
                  key: const Key('duration-history'),
                  borderRadius: BorderRadius.circular(8),
                  onTap: _openHistory,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.history, size: 18, color: secondary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _expressionText,
            key: const Key('duration-calc-expression'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 15, color: secondary),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: _showResult || _isScalarEntry || _error != null
                  ? Text(
                      _displayText,
                      key: const Key('duration-calc-display'),
                      style: _displayStyle(context),
                    )
                  : _segmentDisplay(context),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _displayStyle(BuildContext context) {
    return TextStyle(
      fontSize: 44,
      fontWeight: FontWeight.w600,
      fontFeatures: CalcText.tabular,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _segmentDisplay(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface;
    final activeColor = CalcColors.orange;
    final baseStyle = _displayStyle(context);

    Widget part(_TimeSegment segment, String text, String label) {
      return Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          key: Key('duration-display-${segment.name}'),
          behavior: HitTestBehavior.opaque,
          onTap: () => _selectSegment(segment),
          child: Text(
            text,
            style: baseStyle.copyWith(
              color: _active == segment ? activeColor : baseColor,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_negative)
          Text('-', key: const Key('duration-display-sign'), style: baseStyle),
        part(_TimeSegment.hours, _hours.toString().padLeft(2, '0'), '小时'),
        Text(':', style: baseStyle),
        part(_TimeSegment.minutes, twoDigits(_minutes), '分钟'),
        Text(':', style: baseStyle),
        part(_TimeSegment.seconds, twoDigits(_seconds), '秒'),
      ],
    );
  }

  Widget _keypad(void Function(VoidCallback) press) {
    Widget key({
      required String id,
      String label = '',
      required String semantic,
      IconData? icon,
      bool operator = false,
      bool equals = false,
      bool enabled = true,
      required VoidCallback onTap,
    }) {
      return CalcKey(
        keyId: id,
        semanticLabel: semantic,
        label: label,
        icon: icon,
        isOperator: operator,
        isEquals: equals,
        enabled: enabled,
        onPressed: () => press(onTap),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = CalcSpacing.keyGap;
          final diameter = math
              .min(
                (constraints.maxWidth - gap * 3) / 4,
                (constraints.maxHeight - gap * 5) / 6,
              )
              .clamp(32.0, 82.0);

          Widget place({
            required Widget child,
            required int col,
            required int row,
            int colSpan = 1,
          }) {
            return Positioned(
              left: col * (diameter + gap),
              top: row * (diameter + gap),
              width: diameter * colSpan + gap * (colSpan - 1),
              height: diameter,
              child: child,
            );
          }

          return Center(
            child: SizedBox(
              width: diameter * 4 + gap * 3,
              height: diameter * 6 + gap * 5,
              child: Stack(
                children: [
                  place(
                    col: 0,
                    row: 0,
                    child: key(
                      id: 'duration-key-clear',
                      label: 'C',
                      semantic: '清空',
                      operator: true,
                      onTap: _clearPressed,
                    ),
                  ),
                  place(
                    col: 1,
                    row: 0,
                    child: key(
                      id: 'duration-key-00',
                      label: '00',
                      semantic: '双零',
                      onTap: _appendDoubleZero,
                    ),
                  ),
                  place(
                    col: 2,
                    row: 0,
                    child: key(
                      id: 'duration-key-sign',
                      label: '±',
                      semantic: '正负号',
                      operator: true,
                      enabled: !_isScalarEntry,
                      onTap: _signPressed,
                    ),
                  ),
                  place(
                    col: 3,
                    row: 0,
                    child: key(
                      id: 'duration-key-backspace',
                      semantic: '退格',
                      icon: Icons.backspace_outlined,
                      operator: true,
                      onTap: _backspacePressed,
                    ),
                  ),
                  for (var index = 0; index < 3; index++)
                    place(
                      col: index,
                      row: 1,
                      child: key(
                        id: 'duration-key-${7 + index}',
                        label: '${7 + index}',
                        semantic: '${7 + index}',
                        onTap: () => _appendDigit('${7 + index}'),
                      ),
                    ),
                  place(
                    col: 3,
                    row: 1,
                    child: key(
                      id: 'duration-key-multiply',
                      label: '×',
                      semantic: '乘',
                      operator: true,
                      onTap: () => _operatorPressed(TimeOperator.multiply),
                    ),
                  ),
                  for (var index = 0; index < 3; index++)
                    place(
                      col: index,
                      row: 2,
                      child: key(
                        id: 'duration-key-${4 + index}',
                        label: '${4 + index}',
                        semantic: '${4 + index}',
                        onTap: () => _appendDigit('${4 + index}'),
                      ),
                    ),
                  place(
                    col: 3,
                    row: 2,
                    child: key(
                      id: 'duration-key-divide',
                      label: '÷',
                      semantic: '除',
                      operator: true,
                      onTap: () => _operatorPressed(TimeOperator.divide),
                    ),
                  ),
                  for (var index = 0; index < 3; index++)
                    place(
                      col: index,
                      row: 3,
                      child: key(
                        id: 'duration-key-${1 + index}',
                        label: '${1 + index}',
                        semantic: '${1 + index}',
                        onTap: () => _appendDigit('${1 + index}'),
                      ),
                    ),
                  place(
                    col: 3,
                    row: 3,
                    child: key(
                      id: 'duration-key-add',
                      label: '+',
                      semantic: '加',
                      operator: true,
                      onTap: () => _operatorPressed(TimeOperator.add),
                    ),
                  ),
                  place(
                    col: 0,
                    row: 4,
                    colSpan: 2,
                    child: _WideZeroKey(
                      diameter: diameter,
                      onPressed: () => press(() => _appendDigit('0')),
                    ),
                  ),
                  place(
                    col: 2,
                    row: 4,
                    child: key(
                      id: 'duration-key-colon',
                      label: _isScalarEntry ? '.' : ':',
                      semantic: _isScalarEntry ? '小数点' : '冒号',
                      operator: true,
                      onTap: _colonOrDotPressed,
                    ),
                  ),
                  place(
                    col: 3,
                    row: 4,
                    child: key(
                      id: 'duration-key-subtract',
                      label: '−',
                      semantic: '减',
                      operator: true,
                      onTap: () => _operatorPressed(TimeOperator.subtract),
                    ),
                  ),
                  place(
                    col: 0,
                    row: 5,
                    colSpan: 4,
                    child: _WideEqualsKey(
                      diameter: diameter,
                      onPressed: () => press(_equalsPressed),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WideZeroKey extends StatelessWidget {
  const _WideZeroKey({required this.diameter, required this.onPressed});

  final double diameter;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '0',
      excludeSemantics: true,
      child: GestureDetector(
        key: const Key('duration-key-0'),
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: CalcColors.keyBackground(context),
            borderRadius: BorderRadius.circular(diameter / 2),
          ),
          alignment: Alignment.center,
          child: Text(
            '0',
            style: TextStyle(
              fontSize: CalcText.key,
              height: 1,
              color: Theme.of(context).colorScheme.onSurface,
              fontFeatures: CalcText.tabular,
            ),
          ),
        ),
      ),
    );
  }
}

class _WideEqualsKey extends StatelessWidget {
  const _WideEqualsKey({required this.diameter, required this.onPressed});

  final double diameter;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '等于',
      excludeSemantics: true,
      child: GestureDetector(
        key: const Key('duration-key-equals'),
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: CalcColors.orange,
            borderRadius: BorderRadius.circular(diameter / 2),
          ),
          alignment: Alignment.center,
          child: Text(
            '=',
            style: TextStyle(
              fontSize: CalcText.key,
              height: 1,
              color: Colors.white,
              fontFeatures: CalcText.tabular,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeHistorySheet extends StatelessWidget {
  const _TimeHistorySheet({required this.entries, required this.onClear});

  final List<TimeHistoryEntry> entries;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  '时间计算历史',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  key: const Key('time-history-clear'),
                  onPressed: entries.isEmpty ? null : onClear,
                  child: const Text('清空'),
                ),
              ],
            ),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  '暂无历史',
                  key: const Key('time-history-empty'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: secondary),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 420),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: CalcColors.divider(context)),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      key: Key('time-history-entry-$index'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        entry.expression,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontFeatures: CalcText.tabular,
                          color: secondary,
                        ),
                      ),
                      subtitle: Text(
                        entry.resultText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFeatures: CalcText.tabular,
                          color: onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TimeDifferenceView extends StatelessWidget {
  const TimeDifferenceView({super.key});

  @override
  Widget build(BuildContext context) => const _TimeDifferenceView();
}

class _TimeDifferenceView extends StatefulWidget {
  const _TimeDifferenceView();

  @override
  State<_TimeDifferenceView> createState() => _TimeDifferenceViewState();
}

class _TimeDifferenceViewState extends State<_TimeDifferenceView> {
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 18, minute: 0);

  Future<void> _pick({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
      helpText: isStart ? '选择开始时间' : '选择结束时间',
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  String _formatTime(TimeOfDay value) {
    return '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final startMinutes = _start.hour * 60 + _start.minute;
    final endMinutes = _end.hour * 60 + _end.minute;
    var diffMinutes = endMinutes - startMinutes;
    final crossDay = diffMinutes < 0;
    if (crossDay) {
      diffMinutes += 24 * 60;
    }
    final totalSeconds = diffMinutes * 60;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      children: [
        _TimeField(
          key: const Key('time-diff-start'),
          label: '开始时间',
          value: _formatTime(_start),
          onTap: () => _pick(isStart: true),
        ),
        const SizedBox(height: 10),
        _TimeField(
          key: const Key('time-diff-end'),
          label: '结束时间',
          value: _formatTime(_end),
          onTap: () => _pick(isStart: false),
        ),
        if (crossDay)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '结束时间早于开始时间，已按次日计算。',
              style: TextStyle(
                fontSize: 13,
                color: CalcColors.secondaryText(context),
              ),
            ),
          ),
        const SizedBox(height: 10),
        TimeResultCard(
          title: '计算结果',
          rows: [
            TimeResultRow(
              label: '时长',
              value: formatDuration(totalSeconds),
              emphasized: true,
              valueKey: const Key('time-diff-result'),
            ),
            TimeResultRow(
              label: '总分钟',
              value: '${formatCount(diffMinutes)} 分钟',
            ),
            TimeResultRow(label: '跨天', value: crossDay ? '是' : '否'),
          ],
        ),
        const TimeNote(text: '两时刻差按 24 小时制；结束早于开始时自动按次日计算。'),
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Material(
      color: CalcColors.keyBackground(context),
      borderRadius: BorderRadius.circular(CalcRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(label, style: TextStyle(fontSize: 15, color: secondary)),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  fontFeatures: CalcText.tabular,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.access_time, size: 18, color: secondary),
            ],
          ),
        ),
      ),
    );
  }
}
