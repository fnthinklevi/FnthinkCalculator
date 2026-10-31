import 'package:flutter/material.dart';

import '../../../core/utils/date_calc.dart';
import '../../../theme/tokens.dart';
import 'time_widgets.dart';

class DateDifferenceView extends StatefulWidget {
  const DateDifferenceView({super.key});

  @override
  State<DateDifferenceView> createState() => _DateDifferenceViewState();
}

class _DateDifferenceViewState extends State<DateDifferenceView> {
  DateTime _start = dateOnly(DateTime.now());
  DateTime _end = dateOnly(DateTime.now());
  bool _includeStart = false;

  Future<void> _pickStart() async {
    final picked = await pickDate(context, _start, '选择起始日期');
    if (picked == null || !mounted) return;
    setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await pickDate(context, _end, '选择结束日期');
    if (picked == null || !mounted) return;
    setState(() => _end = picked);
  }

  void _swapDates() {
    setState(() {
      final temp = _start;
      _start = _end;
      _end = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reversed = _end.isBefore(_start);
    final from = reversed ? _end : _start;
    final to = reversed ? _start : _end;
    final parts = calendarDifference(from, to);
    final baseDays = daysBetween(from, to);
    final totalDays = baseDays + (_includeStart ? 1 : 0);
    final weeks = totalDays ~/ 7;
    final restDays = totalDays % 7;
    final workdays = workdaysBetween(from, to, includeStart: _includeStart);

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      children: [
        DateField(
          key: const Key('date-diff-start'),
          label: '起始日期',
          value: _start,
          onTap: _pickStart,
        ),
        const SizedBox(height: 10),
        DateField(
          key: const Key('date-diff-end'),
          label: '结束日期',
          value: _end,
          onTap: _pickEnd,
        ),
        if (reversed)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              decoration: BoxDecoration(
                color: CalcColors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '结束日期早于起始日期，已按反向计算。',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  TextButton(
                    key: const Key('date-diff-swap'),
                    onPressed: _swapDates,
                    child: const Text('交换'),
                  ),
                ],
              ),
            ),
          ),
        SwitchListTile(
          key: const Key('date-diff-include-start'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: const Text('包含起始日'),
          subtitle: const Text('总天数与工作日各加 1 天'),
          value: _includeStart,
          onChanged: (value) => setState(() => _includeStart = value),
        ),
        const SizedBox(height: 4),
        TimeResultCard(
          title: '计算结果',
          rows: [
            TimeResultRow(
              label: '相差',
              value: formatDateParts(parts),
              emphasized: true,
              valueKey: const Key('date-diff-parts'),
            ),
            TimeResultRow(
              label: '总天数',
              value: '${formatCount(totalDays)} 天',
              valueKey: const Key('date-diff-total-days'),
            ),
            TimeResultRow(
              label: '周数',
              value: weeks == 0
                  ? '$restDays 天'
                  : '$weeks 周${restDays == 0 ? '' : ' $restDays 天'}',
              valueKey: const Key('date-diff-weeks'),
            ),
            TimeResultRow(
              label: '工作日',
              value: '${formatCount(workdays)} 天',
              valueKey: const Key('date-diff-workdays'),
            ),
          ],
        ),
        TimeNote(
          text:
              '日期按公历计算；工作日仅排除周六日，不含法定节假日。'
              '${reversed ? '当前为反向区间，差值按绝对值展示。' : ''}',
        ),
      ],
    );
  }
}
