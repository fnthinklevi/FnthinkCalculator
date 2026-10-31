import 'package:flutter/material.dart';

import '../../../core/utils/date_calc.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/numeric_keypad.dart';
import 'time_widgets.dart';

class DateAddView extends StatefulWidget {
  const DateAddView({super.key});

  @override
  State<DateAddView> createState() => _DateAddViewState();
}

class _DateAddViewState extends State<DateAddView> {
  static const _unitLabels = ['年', '月', '周', '天'];

  DateTime _base = dateOnly(DateTime.now());
  bool _after = true;
  int _unitIndex = 3;
  String _amount = '1';

  Future<void> _pickBase() async {
    final picked = await pickDate(context, _base, '选择基准日期');
    if (picked == null || !mounted) return;
    setState(() => _base = picked);
  }

  Future<void> _editAmount() async {
    final result = await showNumericKeypad(
      context,
      initial: _amount,
      title: '输入数量',
      allowDecimal: false,
      allowNegative: false,
    );
    if (result == null || !mounted) return;
    setState(() => _amount = result);
  }

  void _setPreset(int amount, int unitIndex) {
    setState(() {
      _after = true;
      _unitIndex = unitIndex;
      _amount = '$amount';
    });
  }

  DateTime? _resultDate(int amount) {
    final signed = _after ? amount : -amount;
    return switch (_unitIndex) {
      0 => addYearsClamped(_base, signed),
      1 => addMonthsClamped(_base, signed),
      2 => addDays(_base, signed * 7),
      _ => addDays(_base, signed),
    };
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    final amount = int.tryParse(_amount.trim());
    final valid = amount != null && amount >= 0 && amount <= 9999;
    final result = valid ? _resultDate(amount) : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      children: [
        DateField(
          key: const Key('date-add-base'),
          label: '基准日期',
          value: _base,
          onTap: _pickBase,
        ),
        const SizedBox(height: 10),
        SegmentedTabs(
          labels: const ['之后', '之前'],
          index: _after ? 0 : 1,
          onChanged: (index) => setState(() => _after = index == 0),
          keyPrefix: 'date-add-direction',
        ),
        const SizedBox(height: 10),
        Container(
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
                  Text('数量', style: TextStyle(fontSize: 15, color: secondary)),
                  const Spacer(),
                  InkWell(
                    key: const Key('date-add-amount-field'),
                    borderRadius: BorderRadius.circular(10),
                    onTap: _editAmount,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _amount.isEmpty ? '0' : _amount,
                            key: const Key('date-add-amount'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontFeatures: CalcText.tabular,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _unitLabels[_unitIndex],
                            style: const TextStyle(fontSize: 17),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_outlined,
                            size: 18,
                            color: secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(_unitLabels.length, (index) {
                  return ChoiceChip(
                    key: Key('date-add-unit-$index'),
                    label: Text(_unitLabels[index]),
                    selected: _unitIndex == index,
                    onSelected: (_) => setState(() => _unitIndex = index),
                  );
                }),
              ),
              if (!valid)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '请输入 0–9999 的整数',
                    style: TextStyle(fontSize: 14, color: CalcColors.error),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
              key: const Key('date-add-preset-7d'),
              label: const Text('+7天'),
              onPressed: () => _setPreset(7, 3),
            ),
            ActionChip(
              key: const Key('date-add-preset-30d'),
              label: const Text('+30天'),
              onPressed: () => _setPreset(30, 3),
            ),
            ActionChip(
              key: const Key('date-add-preset-100d'),
              label: const Text('+100天'),
              onPressed: () => _setPreset(100, 3),
            ),
            ActionChip(
              key: const Key('date-add-preset-1y'),
              label: const Text('+1年'),
              onPressed: () => _setPreset(1, 0),
            ),
          ],
        ),
        if (result != null) ...[
          const SizedBox(height: 10),
          TimeResultCard(
            title: '计算结果',
            rows: [
              TimeResultRow(
                label: '结果日期',
                value: formatDate(result),
                emphasized: true,
                valueKey: const Key('date-add-result-date'),
              ),
              TimeResultRow(label: '星期', value: weekdayName(result)),
              TimeResultRow(
                label: '相对基准',
                value: _relativeLabel(result),
                valueKey: const Key('date-add-diff'),
              ),
            ],
          ),
        ],
        const TimeNote(text: '日期推算按公历；月末自动夹取到目标月份最后一天。'),
      ],
    );
  }

  String _relativeLabel(DateTime result) {
    final diff = daysBetween(_base, result);
    if (diff == 0) return '0 天';
    return diff > 0
        ? '晚 ${formatCount(diff)} 天'
        : '早 ${formatCount(diff.abs())} 天';
  }
}
