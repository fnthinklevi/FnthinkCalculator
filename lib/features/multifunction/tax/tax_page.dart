import 'package:flutter/material.dart';

import '../../../core/utils/mortgage_calc.dart' show formatMoneyCents;
import '../../../core/utils/social_insurance.dart';
import '../../../core/utils/tax_calc.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/anchored_picker.dart';
import '../../../widgets/number_form_field.dart';
import '../../../widgets/page_header.dart';
import '../time/time_widgets.dart' show SegmentedTabs;

class TaxPage extends StatefulWidget {
  const TaxPage({super.key});

  @override
  State<TaxPage> createState() => _TaxPageState();
}

class _TaxDeduction {
  const _TaxDeduction(this.id, this.name, this.yuan);

  final String id;
  final String name;
  final int yuan;
}

const _deductions = <_TaxDeduction>[
  _TaxDeduction('child', '子女教育', 2000),
  _TaxDeduction('continue', '继续教育', 400),
  _TaxDeduction('medical', '大病医疗', 0),
  _TaxDeduction('loan', '住房贷款利息', 1000),
  _TaxDeduction('rent', '住房租金', 1500),
  _TaxDeduction('elderly', '赡养老人', 3000),
  _TaxDeduction('baby', '3岁以下婴幼儿照护', 2000),
];

class _TaxPageState extends State<TaxPage> {
  bool _monthly = true;
  final _income = TextEditingController(text: '10000');
  final _insurance = TextEditingController();
  final _bonus = TextEditingController(text: '50000');
  int _installments = 10;
  final Set<String> _selected = {};
  String? _error;
  final _installmentsKey = GlobalKey();
  final _locationKey = GlobalKey();
  String? _provinceName;
  String? _autoInsurance;

  @override
  void dispose() {
    _income.dispose();
    _insurance.dispose();
    _bonus.dispose();
    super.dispose();
  }

  int get _specialYuan {
    var total = 0;
    for (final item in _deductions) {
      if (_selected.contains(item.id)) total += item.yuan;
    }
    return total;
  }

  Future<void> _pickInstallments() async {
    final selected = await showAnchoredPicker<int>(
      context: context,
      anchorKey: _installmentsKey,
      items: [
        for (var month = 1; month <= 12; month++)
          AnchoredPickerItem(id: '$month', title: '$month', value: month),
      ],
      selected: _installments,
      keyPrefix: 'tax-installments-option',
      width: 120,
    );
    if (selected == null || !mounted) return;
    setState(() => _installments = selected);
  }

  Future<void> _pickDeductions() async {
    final selected = <String>{..._selected};
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(sheetContext).height * 0.75,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '专项附加扣除',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          for (final item in _deductions)
                            CheckboxListTile(
                              key: Key('tax-deduction-${item.id}'),
                              value: selected.contains(item.id),
                              title: Text(item.name),
                              subtitle: item.yuan == 0
                                  ? const Text('按实际发生额')
                                  : Text('${item.yuan} 元/月'),
                              onChanged: (value) {
                                setSheetState(() {
                                  if (value == true) {
                                    selected.add(item.id);
                                  } else {
                                    selected.remove(item.id);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _selected
                                ..clear()
                                ..addAll(selected);
                            });
                            Navigator.of(sheetContext).pop();
                          },
                          child: const Text('确定'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickProvince() async {
    final selected = await showAnchoredPicker<ProvinceSocialBase>(
      context: context,
      anchorKey: _locationKey,
      items: [
        for (final province in provinceSocialBases)
          AnchoredPickerItem(
            id: province.name,
            title: province.name,
            subtitle: province.rangeLabel,
            value: province,
          ),
      ],
      selected: provinceByName(_provinceName),
      keyPrefix: 'tax-province',
      width: 260,
      maxHeight: 420,
    );
    if (selected == null || !mounted) return;
    final estimateText = (estimatePersonalInsuranceCents(selected) / 100)
        .toStringAsFixed(2);
    setState(() {
      _provinceName = selected.name;
      if (_insurance.text.isEmpty || _insurance.text == _autoInsurance) {
        _insurance.text = estimateText;
        _autoInsurance = estimateText;
      }
    });
  }

  void _calculate() {
    final income = parseYuanToCents(_monthly ? _income.text : _bonus.text);
    if (income == null || income == BigInt.zero) {
      setState(() => _error = '请输入大于 0 的金额');
      return;
    }
    if (_monthly) {
      final insurance = _insurance.text.isEmpty
          ? BigInt.zero
          : parseYuanToCents(_insurance.text);
      if (insurance == null) {
        setState(() => _error = '五险一金金额不正确');
        return;
      }
      final special = BigInt.from(_specialYuan * 100);
      final result = calculateMonthlyTax(
        incomeCents: income,
        insuranceCents: insurance,
        specialCents: special,
      );
      setState(() => _error = null);
      _openResult(result, '月薪个税');
    } else {
      final result = calculateAnnualBonusTax(bonusCents: income);
      setState(() => _error = null);
      _openResult(result, '年终奖个税');
    }
  }

  void _openResult(TaxResult result, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _TaxResultPage(result: result, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Scaffold(
      key: const Key('tax-page'),
      backgroundColor: CalcColors.displayBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: '个税计算',
              titleKey: const Key('tax-title'),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
                children: [
                  SegmentedTabs(
                    labels: const ['月薪', '年终奖'],
                    index: _monthly ? 0 : 1,
                    onChanged: (index) => setState(() => _monthly = index == 0),
                    keyPrefix: 'tax-tab',
                  ),
                  const SizedBox(height: 18),
                  if (_monthly)
                    NumberFormField(
                      key: const Key('tax-income'),
                      label: '税前收入（元）',
                      controller: _income,
                      placeholder: '请输入您的税前收入',
                    )
                  else
                    NumberFormField(
                      key: const Key('tax-bonus'),
                      label: '税前年终奖（元）',
                      controller: _bonus,
                      placeholder: '请输入您的年终奖',
                    ),
                  if (_monthly) ...[
                    _SettingRow(
                      key: const Key('tax-installments'),
                      anchorKey: _installmentsKey,
                      label: '缴纳期数',
                      value: '$_installments',
                      onTap: _pickInstallments,
                    ),
                    _SettingRow(
                      key: const Key('tax-location'),
                      anchorKey: _locationKey,
                      label: '所在地',
                      value: _provinceName ?? '去选择',
                      onTap: _pickProvince,
                    ),
                    _SettingRow(
                      key: const Key('tax-deduction'),
                      picker: false,
                      label: '专项附加扣除',
                      value: _selected.isEmpty
                          ? '无'
                          : '${_selected.length} 项 · 合计 $_specialYuan 元',
                      onTap: _pickDeductions,
                    ),
                    NumberFormField(
                      key: const Key('tax-insurance'),
                      label: '五险一金（元）',
                      controller: _insurance,
                      placeholder: '选填，合计金额',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 4),
                      child: Text(
                        _provinceName == null
                            ? '选择所在地后，可按当地 2025 平均工资估算五险一金'
                            : '按 2025 ${_provinceName!} 平均工资 ${provinceByName(_provinceName)!.averageYuan.toStringAsFixed(0)} 元、${provinceByName(_provinceName)!.rangeLabel}、个人费率 10.5% 估算，不含公积金',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: CalcColors.secondaryText(context),
                        ),
                      ),
                    ),
                  ],
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _error!,
                        key: const Key('tax-error'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: CalcColors.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 22),
                  Text(
                    '采用新个税法计算，数据仅供参考。',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: secondary),
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
                  key: const Key('tax-calculate'),
                  onPressed: _calculate,
                  style: FilledButton.styleFrom(
                    backgroundColor: CalcColors.orange,
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
    final row = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
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
                  color: CalcColors.secondaryText(context),
                  fontFeatures: CalcText.tabular,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              picker ? Icons.unfold_more : Icons.chevron_right,
              size: 18,
              color: CalcColors.secondaryText(context),
            ),
          ],
        ),
      ),
    );
    if (anchorKey == null) return row;
    return KeyedSubtree(key: anchorKey, child: row);
  }
}

class _TaxResultPage extends StatelessWidget {
  const _TaxResultPage({required this.result, required this.title});

  final TaxResult result;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      key: const Key('tax-result-page'),
      backgroundColor: CalcColors.displayBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: title,
              titleKey: const Key('tax-result-title'),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [Color(0xFF2A1A10), Color(0xFF1C1C1C)]
                            : const [Color(0xFFFFF1E5), Color(0xFFFFE1C7)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '应纳税额',
                          style: TextStyle(
                            fontSize: 15,
                            color: CalcColors.secondaryText(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatMoneyCents(result.taxCents)} 元',
                          key: const Key('tax-result-tax'),
                          style: const TextStyle(
                            fontSize: 40,
                            color: CalcColors.orange,
                            fontFeatures: CalcText.tabular,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '税后收入 ${formatMoneyCents(result.afterTaxCents)} 元',
                          key: const Key('tax-result-after'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontFeatures: CalcText.tabular,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _row('税前收入', result.incomeCents),
                  if (result.insuranceCents > BigInt.zero)
                    _row('五险一金', result.insuranceCents),
                  if (result.specialCents > BigInt.zero)
                    _row('专项附加扣除', result.specialCents),
                  _row(
                    '应纳税所得额',
                    result.taxableCents,
                    valueKey: const Key('tax-result-taxable'),
                  ),
                  _textRow('适用税率', '${result.ratePercent}%'),
                  _row('速算扣除数', result.quickDeductionCents),
                  _row('应纳税额', result.taxCents),
                  _row('税后收入', result.afterTaxCents),
                  const SizedBox(height: 18),
                  Text(
                    '采用新个税法计算，数据仅供参考。',
                    style: TextStyle(
                      fontSize: 14,
                      color: CalcColors.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, BigInt cents, {Key? valueKey}) {
    return _textRow(label, '${formatMoneyCents(cents)} 元', valueKey: valueKey);
  }

  Widget _textRow(String label, String value, {Key? valueKey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 17)),
          const Spacer(),
          Text(
            value,
            key: valueKey,
            style: const TextStyle(
              fontSize: 17,
              fontFeatures: CalcText.tabular,
            ),
          ),
        ],
      ),
    );
  }
}
