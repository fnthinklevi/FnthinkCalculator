import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../core/utils/duration_calc.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/calc_key.dart';
import 'time_widgets.dart';

enum _TimeSegment { hours, minutes, seconds }

class DurationView extends StatefulWidget {
  const DurationView({super.key});

  @override
  State<DurationView> createState() => _DurationViewState();
}

class _DurationViewState extends State<DurationView> {
  int _mode = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SegmentedTabs(
            labels: const ['时长加减', '两时刻差'],
            index: _mode,
            onChanged: (index) => setState(() => _mode = index),
            keyPrefix: 'duration-sub',
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _mode,
            children: const [_DurationArithmeticView(), _TimeDifferenceView()],
          ),
        ),
      ],
    );
  }
}

class _DurationArithmeticView extends StatefulWidget {
  const _DurationArithmeticView();

  @override
  State<_DurationArithmeticView> createState() =>
      _DurationArithmeticViewState();
}

class _DurationArithmeticViewState extends State<_DurationArithmeticView> {
  final List<int> _values = [];
  final List<String> _operators = [];
  int? _result;
  bool _showResult = false;
  bool _negative = false;
  bool _carryToDays = true;

  _TimeSegment _active = _TimeSegment.hours;
  String _buffer = '';
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  int get _entrySeconds {
    final value = _hours * 3600 + _minutes * 60 + _seconds;
    return _negative ? -value : value;
  }

  int get _displaySeconds => _showResult ? _result! : _entrySeconds;

  String get _displayText {
    if (_showResult && _carryToDays) {
      return formatDuration(_result!);
    }
    return formatDurationAccumulated(_displaySeconds);
  }

  String get _expressionText {
    if (_showResult) {
      return '${_expressionParts(includeCurrentEntry: false).join(' ')} =';
    }
    if (_values.isEmpty) return '时 : 分 : 秒';
    return _expressionParts(includeCurrentEntry: true).join(' ');
  }

  List<String> _expressionParts({required bool includeCurrentEntry}) {
    final parts = <String>[];
    for (var index = 0; index < _values.length; index++) {
      parts.add(formatDurationAccumulated(_values[index]));
      if (index < _operators.length) parts.add(_operators[index]);
    }
    if (includeCurrentEntry &&
        _operators.isNotEmpty &&
        _values.length == _operators.length &&
        _buffer.isNotEmpty) {
      parts.add(formatDurationAccumulated(_entrySeconds));
    }
    return parts;
  }

  int get _totalSeconds => _showResult ? _result! : _entrySeconds;

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
  }

  void _resetCalculation() {
    _resetEntry();
    _values.clear();
    _operators.clear();
    _result = null;
    _showResult = false;
  }

  void _appendDigit(String digit) {
    setState(() {
      if (_showResult) {
        _resetCalculation();
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

  void _appendDoubleZero() {
    _appendDigit('0');
    _appendDigit('0');
  }

  void _selectSegment(_TimeSegment segment) {
    setState(() {
      if (_showResult) {
        _resetCalculation();
      }
      _active = segment;
      _buffer = '';
    });
  }

  void _colonPressed() {
    setState(() {
      if (_showResult) {
        _resetCalculation();
      }
      _active = switch (_active) {
        _TimeSegment.hours => _TimeSegment.minutes,
        _TimeSegment.minutes => _TimeSegment.seconds,
        _TimeSegment.seconds => _TimeSegment.hours,
      };
      _buffer = '';
    });
  }

  void _operatorPressed(String operator) {
    setState(() {
      if (_showResult) {
        final base = _result!;
        _values
          ..clear()
          ..add(base);
        _operators
          ..clear()
          ..add(operator);
        _result = null;
        _showResult = false;
        _resetEntry();
        return;
      }
      if (_operators.isNotEmpty &&
          _values.length == _operators.length &&
          _buffer.isEmpty) {
        _operators[_operators.length - 1] = operator;
        return;
      }
      _values.add(_entrySeconds);
      _operators.add(operator);
      _resetEntry();
    });
  }

  void _equalsPressed() {
    if (_showResult || _values.isEmpty || _operators.isEmpty) return;
    setState(() {
      if (_values.length == _operators.length) {
        _values.add(_entrySeconds);
      }
      var total = _values.first;
      for (var index = 0; index < _operators.length; index++) {
        total = _operators[index] == '+'
            ? total + _values[index + 1]
            : total - _values[index + 1];
      }
      _result = total;
      _showResult = true;
      _resetEntry();
    });
  }

  void _signPressed() {
    setState(() {
      if (_showResult) {
        _resetCalculation();
      }
      _negative = !_negative;
    });
  }

  void _backspacePressed() {
    setState(() {
      if (_showResult) {
        _resetCalculation();
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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _displayCard(context),
        ),
        Expanded(child: _keypad(press)),
      ],
    );
  }

  Widget _displayCard(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Container(
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
                _showResult ? '结果' : '输入',
                style: TextStyle(fontSize: 15, color: secondary),
              ),
              const Spacer(),
              Text(
                '共 ${formatCount(_totalSeconds)} 秒',
                key: const Key('duration-calc-total-seconds'),
                style: TextStyle(fontSize: 15, color: secondary),
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
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                _displayText,
                key: const Key('duration-calc-display'),
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w600,
                  fontFeatures: CalcText.tabular,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (!_showResult) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                _segmentChip(_TimeSegment.hours, '时', _hours.toString()),
                const SizedBox(width: 6),
                _segmentChip(_TimeSegment.minutes, '分', twoDigits(_minutes)),
                const SizedBox(width: 6),
                _segmentChip(_TimeSegment.seconds, '秒', twoDigits(_seconds)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _segmentChip(_TimeSegment segment, String label, String value) {
    final active = _active == segment;
    final secondary = CalcColors.secondaryText(context);
    return Expanded(
      child: Material(
        color: active ? CalcColors.orange : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          key: Key('duration-segment-${segment.name}'),
          borderRadius: BorderRadius.circular(10),
          onTap: () => _selectSegment(segment),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: active ? CalcColors.orange : CalcColors.divider(context),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: active ? Colors.white70 : secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  key: Key('duration-segment-${segment.name}-value'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFeatures: CalcText.tabular,
                    color: active
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
      required VoidCallback onTap,
    }) {
      return CalcKey(
        keyId: id,
        semanticLabel: semantic,
        label: label,
        icon: icon,
        isOperator: operator,
        isEquals: equals,
        onPressed: () => press(onTap),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = CalcSpacing.keyGap;
          final diameter = math
              .min(
                (constraints.maxWidth - gap * 3) / 4,
                (constraints.maxHeight - gap * 4) / 5,
              )
              .clamp(32.0, 82.0);

          Widget place({
            required Widget child,
            required int col,
            required int row,
            int colSpan = 1,
            int rowSpan = 1,
          }) {
            return Positioned(
              left: col * (diameter + gap),
              top: row * (diameter + gap),
              width: diameter * colSpan + gap * (colSpan - 1),
              height: diameter * rowSpan + gap * (rowSpan - 1),
              child: child,
            );
          }

          return Center(
            child: SizedBox(
              width: diameter * 4 + gap * 3,
              height: diameter * 5 + gap * 4,
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
                      id: 'duration-key-add',
                      label: '+',
                      semantic: '加',
                      operator: true,
                      onTap: () => _operatorPressed('+'),
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
                      id: 'duration-key-subtract',
                      label: '−',
                      semantic: '减',
                      operator: true,
                      onTap: () => _operatorPressed('−'),
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
                    rowSpan: 2,
                    child: _TallEqualsKey(
                      diameter: diameter,
                      onPressed: () => press(_equalsPressed),
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
                      label: ':',
                      semantic: '冒号',
                      operator: true,
                      onTap: _colonPressed,
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

class _TallEqualsKey extends StatelessWidget {
  const _TallEqualsKey({required this.diameter, required this.onPressed});

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
