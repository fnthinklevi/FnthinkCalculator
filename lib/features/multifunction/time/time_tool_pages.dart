import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';
import '../../../widgets/page_header.dart';
import 'age_view.dart';
import 'date_add_view.dart';
import 'date_difference_view.dart';
import 'duration_view.dart';

class DateDifferencePage extends StatelessWidget {
  const DateDifferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _TimeToolPage(
      pageKey: const Key('date-difference-page'),
      title: '日期差',
      child: const DateDifferenceView(),
    );
  }
}

class DateAddPage extends StatelessWidget {
  const DateAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _TimeToolPage(
      pageKey: const Key('date-add-page'),
      title: '日期推算',
      child: const DateAddView(),
    );
  }
}

class TimeCalculationPage extends StatelessWidget {
  const TimeCalculationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _TimeToolPage(
      pageKey: const Key('time-calculation-page'),
      title: '时间计算',
      child: const TimeCalculationView(),
    );
  }
}

class TimeDifferencePage extends StatelessWidget {
  const TimeDifferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _TimeToolPage(
      pageKey: const Key('time-difference-page'),
      title: '时差计算',
      child: const TimeDifferenceView(),
    );
  }
}

class AgePage extends StatelessWidget {
  const AgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _TimeToolPage(
      pageKey: const Key('age-page'),
      title: '年龄计算',
      child: const AgeView(),
    );
  }
}

class _TimeToolPage extends StatelessWidget {
  const _TimeToolPage({
    required this.pageKey,
    required this.title,
    required this.child,
  });

  final Key pageKey;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      backgroundColor: CalcColors.displayBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(title: title, onBack: () => Navigator.of(context).pop()),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
