import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../multifunction/mortgage/mortgage_page.dart';
import '../multifunction/time/time_tool_pages.dart';
import '../multifunction/uppercase_page.dart';
import 'converter_page.dart';
import 'radix_page.dart';
import '../multifunction/bmi/bmi_page.dart';
import '../multifunction/kinship/kinship_page.dart';
import '../multifunction/ratio/ratio_page.dart';
import '../multifunction/tax/tax_page.dart';
import 'currency_page.dart';
import 'exchange_rate_repository.dart';
import 'unit_data.dart';

class ConverterHomePage extends StatelessWidget {
  const ConverterHomePage({super.key, this.currencyRepository});

  final ExchangeRateRepository? currencyRepository;

  @override
  Widget build(BuildContext context) {
    final entries = <_GridEntry>[
      _GridEntry(
        keyId: 'converter-category-currency',
        icon: Icons.currency_exchange,
        label: '汇率转换',
        onTap: () => _push(
          context,
          CurrencyConverterPage(repository: currencyRepository),
        ),
      ),
      _GridEntry(
        keyId: 'tool-time-calculation',
        icon: Icons.timer_outlined,
        label: '时间计算',
        onTap: () => _push(context, const TimeCalculationPage()),
      ),
      for (final id in const ['length', 'weight', 'area'])
        _GridEntry(
          keyId: 'converter-category-$id',
          icon: UnitData.byId(id).icon,
          label: '${UnitData.byId(id).name}转换',
          onTap: () =>
              _push(context, ConverterPage(category: UnitData.byId(id))),
        ),
      _GridEntry(
        keyId: 'tool-tax',
        icon: Icons.receipt_long_outlined,
        label: '个税计算',
        onTap: () => _push(context, const TaxPage()),
      ),
      _GridEntry(
        keyId: 'tool-mortgage',
        icon: Icons.home_work_outlined,
        label: '房贷计算',
        onTap: () => _push(context, const MortgagePage()),
      ),
      _GridEntry(
        keyId: 'tool-kinship',
        icon: Icons.people_alt_outlined,
        label: '称呼计算',
        onTap: () => _push(context, const KinshipPage()),
      ),
      _GridEntry(
        keyId: 'tool-uppercase',
        icon: Icons.text_fields,
        label: '大写数字',
        onTap: () => _push(context, const UppercasePage()),
      ),
      _GridEntry(
        keyId: 'converter-category-time',
        icon: Icons.schedule,
        label: '时间转换',
        onTap: () => _push(context, ConverterPage(category: UnitData.time)),
      ),
      for (final id in const ['volume'])
        _GridEntry(
          keyId: 'converter-category-$id',
          icon: UnitData.byId(id).icon,
          label: '${UnitData.byId(id).name}转换',
          onTap: () =>
              _push(context, ConverterPage(category: UnitData.byId(id))),
        ),
      _GridEntry(
        keyId: 'converter-category-radix',
        icon: Icons.numbers,
        label: '进制转换',
        onTap: () => _push(context, const RadixPage()),
      ),
      for (final id in const ['temperature', 'speed'])
        _GridEntry(
          keyId: 'converter-category-$id',
          icon: UnitData.byId(id).icon,
          label: '${UnitData.byId(id).name}转换',
          onTap: () =>
              _push(context, ConverterPage(category: UnitData.byId(id))),
        ),
      _GridEntry(
        keyId: 'tool-bmi',
        icon: Icons.monitor_weight_outlined,
        label: 'BMI计算',
        onTap: () => _push(context, const BmiPage()),
      ),
      _GridEntry(
        keyId: 'tool-date-diff',
        icon: Icons.date_range_outlined,
        label: '日期差',
        onTap: () => _push(context, const DateDifferencePage()),
      ),
      _GridEntry(
        keyId: 'tool-date-add',
        icon: Icons.event_available_outlined,
        label: '日期推算',
        onTap: () => _push(context, const DateAddPage()),
      ),
      _GridEntry(
        keyId: 'tool-time-difference',
        icon: Icons.timelapse,
        label: '时差计算',
        onTap: () => _push(context, const TimeDifferencePage()),
      ),
      _GridEntry(
        keyId: 'tool-age',
        icon: Icons.cake_outlined,
        label: '年龄计算',
        onTap: () => _push(context, const AgePage()),
      ),
      _GridEntry(
        keyId: 'tool-ratio',
        icon: Icons.percent,
        label: '比例计算',
        onTap: () => _push(context, const RatioPage()),
      ),
    ];

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        key: const Key('converter-page'),
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 880
              ? 6
              : width >= 760
              ? 5
              : width >= 560
              ? 4
              : 3;
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) => entries[index],
          );
        },
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _GridEntry extends StatelessWidget {
  const _GridEntry({
    required this.keyId,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String keyId;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key(keyId),
        borderRadius: BorderRadius.circular(CalcRadius.card),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: color),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(fontSize: 15, height: 1.1, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
