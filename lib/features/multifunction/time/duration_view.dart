import 'package:flutter/material.dart';

import '../../../core/utils/duration_calc.dart';
import '../../../theme/tokens.dart';
import 'time_widgets.dart';

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
  final _leftDays = TextEditingController(text: '0');
  final _leftHours = TextEditingController(text: '0');
  final _leftMinutes = TextEditingController(text: '0');
  final _leftSeconds = TextEditingController(text: '0');
  final _rightDays = TextEditingController(text: '0');
  final _rightHours = TextEditingController(text: '0');
  final _rightMinutes = TextEditingController(text: '0');
  final _rightSeconds = TextEditingController(text: '0');

  bool _subtract = false;

  @override
  void dispose() {
    for (final controller in [
      _leftDays,
      _leftHours,
      _leftMinutes,
      _leftSeconds,
      _rightDays,
      _rightHours,
      _rightMinutes,
      _rightSeconds,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  int? _parse(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return 0;
    return int.tryParse(text);
  }

  int? _total(
    TextEditingController days,
    TextEditingController hours,
    TextEditingController minutes,
    TextEditingController seconds,
  ) {
    final d = _parse(days);
    final h = _parse(hours);
    final m = _parse(minutes);
    final s = _parse(seconds);
    if (d == null || h == null || m == null || s == null) return null;
    if (d < 0 || h < 0 || m < 0 || m > 59 || s < 0 || s > 59) {
      return null;
    }
    return ((d * 24 + h) * 60 + m) * 60 + s;
  }

  @override
  Widget build(BuildContext context) {
    final left = _total(_leftDays, _leftHours, _leftMinutes, _leftSeconds);
    final right = _total(_rightDays, _rightHours, _rightMinutes, _rightSeconds);
    final total = left == null || right == null
        ? null
        : (_subtract ? left - right : left + right);
    final error = total == null ? '天/时需为非负整数，分/秒需在 0–59 之间' : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _inputCard(
          title: '时长 A',
          daysKey: 'duration-left-days',
          hoursKey: 'duration-left-hours',
          minutesKey: 'duration-left-minutes',
          secondsKey: 'duration-left-seconds',
          days: _leftDays,
          hours: _leftHours,
          minutes: _leftMinutes,
          seconds: _leftSeconds,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: SizedBox(
              width: 140,
              child: SegmentedTabs(
                labels: const ['+', '−'],
                index: _subtract ? 1 : 0,
                onChanged: (index) => setState(() => _subtract = index == 1),
                keyPrefix: 'duration-op',
              ),
            ),
          ),
        ),
        _inputCard(
          title: '时长 B',
          daysKey: 'duration-right-days',
          hoursKey: 'duration-right-hours',
          minutesKey: 'duration-right-minutes',
          secondsKey: 'duration-right-seconds',
          days: _rightDays,
          hours: _rightHours,
          minutes: _rightMinutes,
          seconds: _rightSeconds,
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              error,
              style: const TextStyle(fontSize: 13, color: CalcColors.error),
            ),
          ),
        if (total != null) ...[
          const SizedBox(height: 10),
          TimeResultCard(
            title: '计算结果',
            rows: [
              TimeResultRow(
                label: '结果',
                value: formatDuration(total),
                emphasized: true,
                valueKey: const Key('duration-result'),
              ),
              TimeResultRow(label: '文字', value: formatDurationVerbose(total)),
              TimeResultRow(
                label: '总秒数',
                value: '${formatCount(total)} 秒',
                valueKey: const Key('duration-total-seconds'),
              ),
            ],
          ),
        ],
        const TimeNote(text: '时长按 天:时:分:秒 归一化；分和秒限制在 0–59，结果允许为负。'),
      ],
    );
  }

  Widget _inputCard({
    required String title,
    required String daysKey,
    required String hoursKey,
    required String minutesKey,
    required String secondsKey,
    required TextEditingController days,
    required TextEditingController hours,
    required TextEditingController minutes,
    required TextEditingController seconds,
  }) {
    final secondary = CalcColors.secondaryText(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CalcColors.keyBackground(context),
        borderRadius: BorderRadius.circular(CalcRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13, color: secondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              _field('天', daysKey, days),
              const SizedBox(width: 6),
              _field('时', hoursKey, hours),
              const SizedBox(width: 6),
              _field('分', minutesKey, minutes),
              const SizedBox(width: 6),
              _field('秒', secondsKey, seconds),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    String keyName,
    TextEditingController controller,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: CalcColors.secondaryText(context),
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            key: Key(keyName),
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: CalcColors.displayBackground(context),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
              Text(label, style: TextStyle(fontSize: 13, color: secondary)),
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
