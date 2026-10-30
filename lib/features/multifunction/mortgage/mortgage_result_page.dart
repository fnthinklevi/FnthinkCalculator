import 'package:flutter/material.dart';

import '../../../core/utils/mortgage_calc.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/page_header.dart';

class MortgageResultPage extends StatelessWidget {
  const MortgageResultPage({
    super.key,
    required this.result,
    required this.paymentLabel,
    required this.firstPaymentDate,
  });

  final MortgageResult result;
  final String paymentLabel;
  final DateTime firstPaymentDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groups = _groupByYear(result.periods);
    return Scaffold(
      key: const Key('mortgage-result-page'),
      backgroundColor: CalcColors.displayBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: '房贷清单',
              titleKey: const Key('mortgage-result-title'),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _HeroCard(
                    result: result,
                    paymentLabel: paymentLabel,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${result.periods.length ~/ 12}年还款明细（元）',
                    style: TextStyle(
                      fontSize: 15,
                      color: CalcColors.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final group in groups)
                    _YearGroup(
                      year: group.year,
                      periods: group.periods,
                      firstPaymentDate: firstPaymentDate,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_YearGroupData> _groupByYear(List<MortgagePeriod> periods) {
    final map = <int, List<MortgagePeriod>>{};
    for (var index = 0; index < periods.length; index++) {
      final monthIndex = firstPaymentDate.month - 1 + index;
      final year = firstPaymentDate.year + monthIndex ~/ 12;
      map.putIfAbsent(year, () => []).add(periods[index]);
    }
    return [
      for (final entry in map.entries) _YearGroupData(entry.key, entry.value),
    ];
  }
}

class _YearGroupData {
  const _YearGroupData(this.year, this.periods);

  final int year;
  final List<MortgagePeriod> periods;
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.result,
    required this.paymentLabel,
    required this.isDark,
  });

  final MortgageResult result;
  final String paymentLabel;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF2A1A10), Color(0xFF1C1C1C)]
              : const [Color(0xFFFFF1E5), Color(0xFFFFE1C7)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -10,
            child: Icon(
              Icons.home_rounded,
              size: 96,
              color: CalcColors.orange.withValues(alpha: 0.28),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paymentLabel,
                style: TextStyle(fontSize: 15, color: secondary),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatMoneyCents(result.firstPaymentCents),
                        key: const Key('mortgage-result-payment'),
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w500,
                          color: CalcColors.orange,
                          fontFeatures: CalcText.tabular,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '元',
                    style: TextStyle(fontSize: 18, color: CalcColors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: CalcColors.orange.withValues(alpha: 0.25),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _Summary(
                    label: '还款总额（万）',
                    value: _wan(result.repaymentCents),
                    valueKey: const Key('mortgage-result-total'),
                  ),
                  _Summary(
                    label: '支付利息（万）',
                    value: _wan(result.interestCents),
                    valueKey: const Key('mortgage-result-interest'),
                  ),
                  _Summary(
                    label: '贷款总额（万）',
                    value: _wan(result.principalCents),
                    valueKey: const Key('mortgage-result-loan'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _wan(BigInt cents) {
    final value = cents.toDouble() / 1000000;
    return value.toStringAsFixed(2);
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: secondary)),
          const SizedBox(height: 2),
          Text(
            value,
            key: valueKey,
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurface,
              fontFeatures: CalcText.tabular,
            ),
          ),
        ],
      ),
    );
  }
}

class _YearGroup extends StatefulWidget {
  const _YearGroup({
    required this.year,
    required this.periods,
    required this.firstPaymentDate,
  });

  final int year;
  final List<MortgagePeriod> periods;
  final DateTime firstPaymentDate;

  @override
  State<_YearGroup> createState() => _YearGroupState();
}

class _YearGroupState extends State<_YearGroup> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    var payment = BigInt.zero;
    var interest = BigInt.zero;
    for (final period in widget.periods) {
      payment += period.paymentCents;
      interest += period.interestCents;
    }
    return Column(
      key: Key('mortgage-year-${widget.year}'),
      children: [
        InkWell(
          key: Key('mortgage-year-toggle-${widget.year}'),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: CalcColors.tertiaryText(context),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${widget.year}年',
                  style: TextStyle(fontSize: 16, color: secondary),
                ),
                const Spacer(),
                _YearValue(label: '本年还款', value: formatMoneyCents(payment)),
                const SizedBox(width: 18),
                _YearValue(label: '本年利息', value: formatMoneyCents(interest)),
                const SizedBox(width: 8),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: secondary,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          for (final period in widget.periods)
            Padding(
              key: Key('mortgage-month-row-${period.period}'),
              padding: const EdgeInsets.only(left: 18, right: 30, bottom: 8),
              child: Row(
                children: [
                  Text(
                    '${period.period}期',
                    style: TextStyle(fontSize: 13, color: secondary),
                  ),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '还款 ${formatMoneyCents(period.paymentCents)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontFeatures: CalcText.tabular,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '利息 ${formatMoneyCents(period.interestCents)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontFeatures: CalcText.tabular,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        Divider(height: 1, color: CalcColors.divider(context)),
      ],
    );
  }
}

class _YearValue extends StatelessWidget {
  const _YearValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 16,
                fontFeatures: CalcText.tabular,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: CalcColors.secondaryText(context),
            ),
          ),
        ],
      ),
    );
  }
}
