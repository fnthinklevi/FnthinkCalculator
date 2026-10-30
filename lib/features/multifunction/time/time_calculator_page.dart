import 'package:flutter/material.dart';

import '../../../widgets/page_header.dart';
import 'age_view.dart';
import 'date_add_view.dart';
import 'date_difference_view.dart';
import 'duration_view.dart';
import 'time_widgets.dart';

class TimeCalculatorPage extends StatefulWidget {
  const TimeCalculatorPage({super.key});

  @override
  State<TimeCalculatorPage> createState() => _TimeCalculatorPageState();
}

class _TimeCalculatorPageState extends State<TimeCalculatorPage> {
  int _tab = 0;

  static const _labels = ['日期差', '日期推算', '时长', '年龄'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('time-calculator-page'),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: '时间计算',
              titleKey: const Key('time-title'),
              onBack: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
              child: SegmentedTabs(
                labels: _labels,
                index: _tab,
                onChanged: (index) => setState(() => _tab = index),
                keyPrefix: 'time-tab',
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: const [
                  DateDifferenceView(),
                  DateAddView(),
                  DurationView(),
                  AgeView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
