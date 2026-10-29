import 'package:flutter/material.dart';

import '../../../core/utils/mortgage_calc.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/numeric_keypad.dart';
import '../time/time_widgets.dart' show SegmentedTabs;
import 'mortgage_controller.dart';

class MortgagePage extends StatefulWidget {
  const MortgagePage({super.key});

  @override
  State<MortgagePage> createState() => _MortgagePageState();
}

class _MortgagePageState extends State<MortgagePage> {
  final MortgageController _controller = MortgageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _editValue({
    required String title,
    required String initial,
    required bool allowDecimal,
    required ValueChanged<String> onValue,
  }) async {
    final value = await showNumericKeypad(
      context,
      initial: initial,
      title: title,
      allowDecimal: allowDecimal,
      allowNegative: false,
    );
    if (value == null || !mounted) return;
    onValue(value);
  }

  Future<void> _editYears() async {
    final value = await showNumericKeypad(
      context,
      initial: '${_controller.years}',
      title: '贷款期限（年）',
      allowDecimal: false,
      allowNegative: false,
    );
    if (value == null || !mounted) return;
    final years = int.tryParse(value);
    if (years != null) {
      _controller.setYears(years);
    }
  }

  void _showSchedule() {
    final result = _controller.result;
    if (result == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.85,
          child: _ScheduleSheet(result: result),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          key: const Key('mortgage-page'),
          appBar: AppBar(
            title: const Text('房贷计算'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                SegmentedTabs(
                  labels: const ['商业贷款', '公积金', '组合贷'],
                  index: _controller.type.index,
                  onChanged: (index) =>
                      _controller.setType(MortgageType.values[index]),
                  keyPrefix: 'mortgage-type',
                ),
                const SizedBox(height: 10),
                SegmentedTabs(
                  labels: const ['等额本息', '等额本金'],
                  index: _controller.method.index,
                  onChanged: (index) =>
                      _controller.setMethod(MortgageMethod.values[index]),
                  keyPrefix: 'mortgage-method',
                ),
                const SizedBox(height: 14),
                _inputCard(context),
                const SizedBox(height: 14),
                _resultCard(context),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('mortgage-schedule-button'),
                  onPressed: _controller.result == null ? null : _showSchedule,
                  icon: const Icon(Icons.table_rows_outlined, size: 20),
                  label: const Text('查看还款明细'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CalcColors.orange,
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: CalcColors.orange),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '金额四舍五入到分，末期调平；利率与结果仅供参考，不构成贷款建议。',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: CalcColors.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _inputCard(BuildContext context) {
    final isCombined = _controller.isCombined;
    return Container(
      decoration: BoxDecoration(
        color: CalcColors.keyBackground(context),
        borderRadius: BorderRadius.circular(CalcRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (isCombined) _sectionLabel(context, '商业贷款'),
          _fieldTile(
            context,
            keyId: 'mortgage-amount',
            label: isCombined ? '商贷金额' : '贷款金额',
            value: _controller.amountWan,
            suffix: '万元',
            onTap: () => _editValue(
              title: '贷款金额（万元）',
              initial: _controller.amountWan,
              allowDecimal: true,
              onValue: _controller.setAmount,
            ),
          ),
          _divider(context),
          _fieldTile(
            context,
            keyId: 'mortgage-rate',
            label: '年利率',
            value: _controller.ratePercent,
            suffix: '%',
            onTap: () => _editValue(
              title: '年利率（%）',
              initial: _controller.ratePercent,
              allowDecimal: true,
              onValue: _controller.setRate,
            ),
          ),
          if (isCombined) ...[
            const Divider(height: 1),
            _sectionLabel(context, '公积金贷款'),
            _fieldTile(
              context,
              keyId: 'mortgage-provident-amount',
              label: '公积金金额',
              value: _controller.providentAmountWan,
              suffix: '万元',
              onTap: () => _editValue(
                title: '公积金金额（万元）',
                initial: _controller.providentAmountWan,
                allowDecimal: true,
                onValue: _controller.setProvidentAmount,
              ),
            ),
            _divider(context),
            _fieldTile(
              context,
              keyId: 'mortgage-provident-rate',
              label: '公积金年利率',
              value: _controller.providentRatePercent,
              suffix: '%',
              onTap: () => _editValue(
                title: '公积金年利率（%）',
                initial: _controller.providentRatePercent,
                allowDecimal: true,
                onValue: _controller.setProvidentRate,
              ),
            ),
          ],
          _divider(context),
          _fieldTile(
            context,
            keyId: 'mortgage-years',
            label: '贷款期限',
            value: '${_controller.years}',
            suffix: '年',
            onTap: _editYears,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Row(
              children: [
                for (final term in const [10, 20, 30]) ...[
                  ChoiceChip(
                    key: Key('mortgage-term-$term'),
                    label: Text('$term 年'),
                    selected: _controller.years == term,
                    showCheckmark: false,
                    selectedColor: CalcColors.orange.withValues(alpha: 0.14),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: _controller.years == term
                          ? CalcColors.orange
                          : CalcColors.secondaryText(context),
                    ),
                    onSelected: (_) => _controller.setYears(term),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultCard(BuildContext context) {
    final result = _controller.result;
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
              Text('计算结果', style: TextStyle(fontSize: 13, color: secondary)),
              const Spacer(),
              Text(
                '${_controller.isEqualPayment ? '等额本息' : '等额本金'} · 共 ${_controller.years * 12} 期',
                style: TextStyle(fontSize: 12, color: secondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_controller.error != null)
            Text(
              _controller.error!,
              key: const Key('mortgage-error'),
              style: const TextStyle(fontSize: 14, color: CalcColors.error),
            )
          else if (result != null) ...[
            Text(
              _controller.paymentLabel,
              style: TextStyle(fontSize: 13, color: secondary),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${formatMoneyCents(result.firstPaymentCents)} 元',
                key: const Key('mortgage-result-payment'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  fontFeatures: CalcText.tabular,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (!_controller.isEqualPayment)
              _resultRow(
                context,
                label: '每月递减',
                value: '约 ${formatMoneyCents(result.monthlyDecreaseCents)} 元',
                valueKey: 'mortgage-result-decrease',
              ),
            const SizedBox(height: 8),
            _resultRow(
              context,
              label: '贷款总额',
              value: '${formatMoneyCents(result.principalCents)} 元',
              valueKey: 'mortgage-result-loan',
            ),
            _resultRow(
              context,
              label: '总利息',
              value: '${formatMoneyCents(result.interestCents)} 元',
              valueKey: 'mortgage-result-interest',
            ),
            _resultRow(
              context,
              label: '总还款',
              value: '${formatMoneyCents(result.repaymentCents)} 元',
              valueKey: 'mortgage-result-total',
            ),
          ] else
            Text('—', style: TextStyle(fontSize: 20, color: secondary)),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: CalcColors.secondaryText(context),
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: CalcColors.divider(context),
    );
  }

  Widget _fieldTile(
    BuildContext context, {
    required String keyId,
    required String label,
    required String value,
    required String suffix,
    required VoidCallback onTap,
  }) {
    final secondary = CalcColors.secondaryText(context);
    return InkWell(
      key: Key(keyId),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: secondary)),
            const Spacer(),
            Flexible(
              child: Text(
                value.isEmpty ? '0' : value,
                key: Key('$keyId-value'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFeatures: CalcText.tabular,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(suffix, style: TextStyle(fontSize: 13, color: secondary)),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right, size: 18, color: secondary),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(
    BuildContext context, {
    required String label,
    required String value,
    required String valueKey,
  }) {
    final secondary = CalcColors.secondaryText(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: secondary)),
          const Spacer(),
          Text(
            value,
            key: Key(valueKey),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFeatures: CalcText.tabular,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleSheet extends StatelessWidget {
  const _ScheduleSheet({required this.result});

  final MortgageResult result;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return SafeArea(
      top: false,
      child: Column(
        key: const Key('mortgage-schedule-sheet'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
            child: Row(
              children: [
                const Text(
                  '还款明细',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),
                Text(
                  '共 ${result.periods.length} 期',
                  style: TextStyle(fontSize: 12, color: secondary),
                ),
                const Spacer(),
                IconButton(
                  tooltip: '关闭',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, size: 20, color: secondary),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: CalcColors.divider(context)),
          _headerRow(context),
          Expanded(
            child: ListView.builder(
              itemCount: result.periods.length,
              itemBuilder: (context, index) {
                return _periodRow(context, result.periods[index], index);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: Text(
              '金额单位为元；末期已调平。',
              style: TextStyle(fontSize: 11, color: secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerRow(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Container(
      color: CalcColors.displayBackground(context),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 11,
          fontFeatures: CalcText.tabular,
          color: secondary,
        ),
        child: const Row(
          children: [
            _Cell(label: '期数', flex: 1, bold: true),
            _Cell(label: '月供', flex: 2, bold: true),
            _Cell(label: '本金', flex: 2, bold: true),
            _Cell(label: '利息', flex: 2, bold: true),
            _Cell(label: '剩余', flex: 2, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _periodRow(BuildContext context, MortgagePeriod period, int index) {
    final secondary = CalcColors.secondaryText(context);
    return Container(
      key: Key('mortgage-schedule-row-${period.period}'),
      color: index.isEven
          ? Colors.transparent
          : CalcColors.divider(context).withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 11,
          fontFeatures: CalcText.tabular,
          color: secondary,
        ),
        child: Row(
          children: [
            _Cell(label: '${period.period}', flex: 1),
            _Cell(label: formatMoneyCents(period.paymentCents), flex: 2),
            _Cell(label: formatMoneyCents(period.principalCents), flex: 2),
            _Cell(label: formatMoneyCents(period.interestCents), flex: 2),
            _Cell(label: formatMoneyCents(period.balanceCents), flex: 2),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.flex, this.bold = false});

  final String label;
  final int flex;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          fontFeatures: CalcText.tabular,
        ),
      ),
    );
  }
}
