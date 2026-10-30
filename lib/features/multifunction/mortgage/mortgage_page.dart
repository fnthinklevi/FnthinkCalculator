import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';
import '../../../widgets/anchored_picker.dart';
import '../../../widgets/number_form_field.dart';
import '../../../widgets/page_header.dart';
import '../time/time_widgets.dart' show SegmentedTabs;
import 'mortgage_controller.dart';
import 'mortgage_result_page.dart';

class MortgagePage extends StatefulWidget {
  const MortgagePage({super.key});

  @override
  State<MortgagePage> createState() => _MortgagePageState();
}

class _MortgagePageState extends State<MortgagePage> {
  final MortgageController _controller = MortgageController();
  final _methodKey = GlobalKey();
  final _yearsKey = GlobalKey();
  final _providentYearsKey = GlobalKey();
  final _rateStandardKey = GlobalKey();
  final _amount = TextEditingController(text: '100');
  final _providentAmount = TextEditingController(text: '60');
  final _lpr = TextEditingController(text: '3.5');
  final _basePoint = TextEditingController(text: '0');
  final _providentRate = TextEditingController(text: '2.6');

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => _controller.setAmount(_amount.text));
    _providentAmount.addListener(
      () => _controller.setProvidentAmount(_providentAmount.text),
    );
    _lpr.addListener(() => _controller.setLpr(_lpr.text));
    _basePoint.addListener(() => _controller.setBasePoint(_basePoint.text));
    _providentRate.addListener(
      () => _controller.setProvidentRate(_providentRate.text),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _amount.dispose();
    _providentAmount.dispose();
    _lpr.dispose();
    _basePoint.dispose();
    _providentRate.dispose();
    super.dispose();
  }

  Future<void> _pickMethod() async {
    final selected = await showAnchoredPicker<MortgageMethod>(
      context: context,
      anchorKey: _methodKey,
      items: const [
        AnchoredPickerItem(
          id: '0',
          title: '等额本息（每月等额还款）',
          value: MortgageMethod.equalPayment,
        ),
        AnchoredPickerItem(
          id: '1',
          title: '等额本金（每月递减还款）',
          value: MortgageMethod.equalPrincipal,
        ),
      ],
      selected: _controller.method,
      keyPrefix: 'mortgage-method',
      width: 220,
    );
    if (selected == null || !mounted) return;
    _controller.setMethod(selected);
  }

  Future<void> _pickYears({required bool provident}) async {
    final anchor = provident ? _providentYearsKey : _yearsKey;
    final current = provident ? _controller.providentYears : _controller.years;
    final selected = await showAnchoredPicker<int>(
      context: context,
      anchorKey: anchor,
      items: [
        for (var year = 1; year <= 40; year++)
          AnchoredPickerItem(
            id: '$year',
            title: '$year年',
            subtitle: '${year * 12}个月',
            value: year,
          ),
      ],
      selected: current,
      keyPrefix: provident
          ? 'mortgage-provident-years-option'
          : 'mortgage-years-option',
    );
    if (selected == null || !mounted) return;
    if (provident) {
      _controller.setProvidentYears(selected);
    } else {
      _controller.setYears(selected);
    }
  }

  Future<void> _pickRateStandard() async {
    final selected = await showAnchoredPicker<MortgageRateStandard>(
      context: context,
      anchorKey: _rateStandardKey,
      items: const [
        AnchoredPickerItem(
          id: 'lpr',
          title: 'LPR',
          value: MortgageRateStandard.lpr,
        ),
        AnchoredPickerItem(
          id: 'base',
          title: '基准利率',
          value: MortgageRateStandard.base,
        ),
      ],
      selected: _controller.rateStandard,
      keyPrefix: 'mortgage-rate-standard',
      width: 160,
    );
    if (selected == null || !mounted) return;
    _controller.setRateStandard(selected);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.firstPaymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: '首次还款日期',
    );
    if (picked == null || !mounted) return;
    _controller.setFirstPaymentDate(picked);
  }

  void _calculate() {
    final result = _controller.result;
    if (result == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MortgageResultPage(
          result: result,
          paymentLabel: _controller.paymentLabel,
          firstPaymentDate: _controller.firstPaymentDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final combined = _controller.isCombined;
        final commercial = _controller.type == MortgageType.commercial;
        return Scaffold(
          key: const Key('mortgage-page'),
          backgroundColor: CalcColors.displayBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                PageHeader(
                  title: '房贷计算',
                  titleKey: const Key('mortgage-title'),
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 12),
                    children: [
                      SegmentedTabs(
                        labels: const ['商业贷款', '公积金贷款', '组合贷款'],
                        index: _controller.type.index,
                        onChanged: (index) =>
                            _controller.setType(MortgageType.values[index]),
                        keyPrefix: 'mortgage-type',
                      ),
                      const SizedBox(height: 18),
                      if (combined || commercial)
                        NumberFormField(
                          key: const Key('mortgage-amount'),
                          label: combined ? '商业贷款金额（万）' : '贷款总额（万）',
                          controller: _amount,
                          placeholder: '请输入您的贷款总额',
                          suffix: '万',
                        )
                      else
                        NumberFormField(
                          key: const Key('mortgage-provident-amount'),
                          label: '公积金贷款金额（万）',
                          controller: _providentAmount,
                          placeholder: '请输入公积金贷款金额',
                          suffix: '万',
                        ),
                      if (combined)
                        NumberFormField(
                          key: const Key('mortgage-provident-amount'),
                          label: '公积金贷款金额（万）',
                          controller: _providentAmount,
                          placeholder: '请输入公积金贷款金额',
                          suffix: '万',
                        ),
                      const SizedBox(height: 14),
                      _SettingRow(
                        key: const Key('mortgage-method-row'),
                        anchorKey: _methodKey,
                        label: '还款方式',
                        value: _controller.methodLabel,
                        onTap: _pickMethod,
                      ),
                      _SettingRow(
                        key: const Key('mortgage-years-row'),
                        anchorKey: _yearsKey,
                        label: combined ? '商业贷款年数' : '贷款年数',
                        value:
                            '${_controller.years}年（${_controller.years * 12}个月）',
                        onTap: () => _pickYears(provident: false),
                      ),
                      if (combined ||
                          _controller.type == MortgageType.provident)
                        _SettingRow(
                          key: const Key('mortgage-provident-years-row'),
                          anchorKey: _providentYearsKey,
                          label: '公积金贷款年数',
                          value:
                              '${_controller.providentYears}年（${_controller.providentYears * 12}个月）',
                          onTap: () => _pickYears(provident: true),
                        ),
                      _SettingRow(
                        key: const Key('mortgage-date-row'),
                        picker: false,
                        label: '首次还款日期',
                        value:
                            '${_controller.firstPaymentDate.year}年${_controller.firstPaymentDate.month}月${_controller.firstPaymentDate.day}日',
                        onTap: _pickDate,
                      ),
                      if (commercial || combined) ...[
                        _SettingRow(
                          key: const Key('mortgage-rate-standard-row'),
                          anchorKey: _rateStandardKey,
                          label: '利率标准',
                          value: _controller.rateStandardLabel,
                          onTap: _pickRateStandard,
                        ),
                        if (_controller.rateStandard ==
                            MortgageRateStandard.lpr) ...[
                          NumberFormField(
                            key: const Key('mortgage-lpr'),
                            label: 'LPR（%）',
                            controller: _lpr,
                            placeholder: '请输入 LPR',
                          ),
                          NumberFormField(
                            key: const Key('mortgage-base-point'),
                            label: '基点（‰）',
                            controller: _basePoint,
                            placeholder: '请输入基点',
                          ),
                        ],
                        _SummaryRow(
                          label: '贷款利率',
                          value: _controller.rateSummary,
                        ),
                      ],
                      if (combined ||
                          _controller.type == MortgageType.provident)
                        NumberFormField(
                          key: const Key('mortgage-provident-rate'),
                          label: '公积金贷款利率（%）',
                          controller: _providentRate,
                          placeholder: '请输入公积金利率',
                        ),
                      if (_controller.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _controller.error!,
                            key: const Key('mortgage-error'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: CalcColors.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),
                      Text(
                        '数据仅供参考，不构成贷款建议。',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: CalcColors.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      key: const Key('mortgage-calculate'),
                      onPressed: _controller.result == null ? null : _calculate,
                      style: FilledButton.styleFrom(
                        backgroundColor: CalcColors.orange,
                        disabledBackgroundColor: CalcColors.orange.withValues(
                          alpha: 0.35,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(CalcRadius.pill),
                        ),
                      ),
                      child: const Text('开始计算', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.anchorKey,
    this.picker = true,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final GlobalKey? anchorKey;
  final bool picker;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    final row = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  color: secondary,
                  fontFeatures: CalcText.tabular,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              picker ? Icons.unfold_more : Icons.chevron_right,
              size: 18,
              color: secondary,
            ),
          ],
        ),
      ),
    );
    if (anchorKey == null) return row;
    return KeyedSubtree(key: anchorKey, child: row);
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 20)),
          const Spacer(),
          Text(
            value,
            key: const Key('mortgage-rate-summary'),
            style: TextStyle(
              fontSize: 17,
              color: CalcColors.secondaryText(context),
              fontFeatures: CalcText.tabular,
            ),
          ),
        ],
      ),
    );
  }
}
