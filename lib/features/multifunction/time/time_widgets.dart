import 'package:flutter/material.dart';

import '../../../core/utils/date_calc.dart';
import '../../../theme/tokens.dart';

String formatDate(DateTime value) {
  return '${value.year}年${value.month}月${value.day}日';
}

Future<DateTime?> pickDate(
  BuildContext context,
  DateTime initial,
  String helpText,
) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
    helpText: helpText,
  );
  return picked == null ? null : dateOnly(picked);
}

String weekdayName(DateTime value) {
  const names = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
  return names[value.weekday - 1];
}

String formatCount(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  final firstGroup = digits.length % 3;
  var index = 0;
  if (firstGroup > 0) {
    buffer.write(digits.substring(0, firstGroup));
    index = firstGroup;
  }
  while (index < digits.length) {
    if (buffer.isNotEmpty) {
      buffer.write(',');
    }
    buffer.write(digits.substring(index, index + 3));
    index += 3;
  }
  return '${negative ? '-' : ''}$buffer';
}

String formatDateParts(DateParts parts) {
  final pieces = <String>[];
  if (parts.years > 0) pieces.add('${parts.years} 年');
  if (parts.months > 0) pieces.add('${parts.months} 个月');
  if (parts.days > 0 || pieces.isEmpty) pieces.add('${parts.days} 天');
  return pieces.join(' ');
}

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    required this.keyPrefix,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CalcColors.track(context),
        borderRadius: BorderRadius.circular(CalcRadius.pill),
      ),
      child: Row(
        children: List.generate(labels.length, (tabIndex) {
          final active = tabIndex == index;
          return Expanded(
            child: Semantics(
              button: true,
              selected: active,
              label: labels[tabIndex],
              child: GestureDetector(
                key: Key('$keyPrefix-$tabIndex'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(tabIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? CalcColors.trackSelected(context)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(CalcRadius.pill),
                  ),
                  child: Text(
                    labels[tabIndex],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label, style: TextStyle(fontSize: 15, color: secondary)),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: secondary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formatDate(value),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                weekdayName(value),
                style: TextStyle(fontSize: 15, color: secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeResultRow {
  const TimeResultRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.valueKey,
  });

  final String label;
  final String value;
  final bool emphasized;
  final Key? valueKey;
}

class TimeResultCard extends StatelessWidget {
  const TimeResultCard({super.key, required this.title, required this.rows});

  final String title;
  final List<TimeResultRow> rows;

  @override
  Widget build(BuildContext context) {
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
          Text(title, style: TextStyle(fontSize: 15, color: secondary)),
          const SizedBox(height: 6),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.label,
                    style: TextStyle(fontSize: 15, color: secondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      row.value,
                      key: row.valueKey,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: row.emphasized ? 24 : 17,
                        fontWeight: row.emphasized
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class TimeNote extends StatelessWidget {
  const TimeNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: CalcColors.secondaryText(context),
        ),
      ),
    );
  }
}
