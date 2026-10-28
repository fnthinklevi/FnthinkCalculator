import 'package:flutter/material.dart';

import '../../../core/utils/date_calc.dart';
import '../../../theme/tokens.dart';
import 'time_widgets.dart';

class AgeView extends StatefulWidget {
  const AgeView({super.key});

  @override
  State<AgeView> createState() => _AgeViewState();
}

class _AgeViewState extends State<AgeView> {
  DateTime _reference = dateOnly(DateTime.now());
  late DateTime _birth = addYearsClamped(_reference, -20);

  Future<void> _pickBirth() async {
    final picked = await pickDate(context, _birth, '选择出生日期');
    if (picked == null || !mounted) return;
    setState(() => _birth = picked);
  }

  Future<void> _pickReference() async {
    final picked = await pickDate(context, _reference, '选择参考日期');
    if (picked == null || !mounted) return;
    setState(() => _reference = picked);
  }

  @override
  Widget build(BuildContext context) {
    final invalid = _birth.isAfter(_reference);
    final years = ageInYears(_birth, _reference);
    final nominal = nominalAge(_birth, _reference);
    final days = daysBetween(_birth, _reference);
    final next = nextBirthday(_birth, _reference);
    final until = daysUntilNextBirthday(_birth, _reference);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        DateField(
          key: const Key('age-birth'),
          label: '出生日期',
          value: _birth,
          onTap: _pickBirth,
        ),
        const SizedBox(height: 10),
        DateField(
          key: const Key('age-reference'),
          label: '参考日期',
          value: _reference,
          onTap: _pickReference,
        ),
        if (invalid)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              '出生日期不能晚于参考日期。',
              style: TextStyle(fontSize: 13, color: CalcColors.error),
            ),
          )
        else ...[
          const SizedBox(height: 10),
          TimeResultCard(
            title: '年龄结果',
            rows: [
              TimeResultRow(
                label: '周岁',
                value: '$years 岁',
                emphasized: true,
                valueKey: const Key('age-years'),
              ),
              TimeResultRow(
                label: '虚岁',
                value: '$nominal 岁',
                valueKey: const Key('age-nominal'),
              ),
              TimeResultRow(
                label: '已出生',
                value: '${formatCount(days)} 天',
                valueKey: const Key('age-days'),
              ),
              TimeResultRow(
                label: '下次生日',
                value: until == 0
                    ? '${formatDate(next)}（今天）'
                    : '${formatDate(next)}（还有 ${formatCount(until)} 天）',
                valueKey: const Key('age-next-birthday'),
              ),
            ],
          ),
        ],
        const TimeNote(
          text:
              '周岁按满年计算；虚岁按年份口径，仅供参考。'
              '2 月 29 日在非闰年按 2 月 28 日处理。',
        ),
      ],
    );
  }
}
