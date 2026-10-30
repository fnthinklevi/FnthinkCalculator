import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';
import '../../../widgets/number_form_field.dart';
import '../../../widgets/page_header.dart';
import '../time/time_widgets.dart' show SegmentedTabs;

class RatioPage extends StatefulWidget {
  const RatioPage({super.key});

  @override
  State<RatioPage> createState() => _RatioPageState();
}

class _RatioPageState extends State<RatioPage> {
  int _tab = 0;
  final _a = TextEditingController(text: '1');
  final _b = TextEditingController(text: '2');
  final _total = TextEditingController(text: '100');
  final _c = TextEditingController(text: '4');
  String? _error;
  String? _resultA;
  String? _resultB;
  String? _equation;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _total.dispose();
    _c.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _error = null;
      _resultA = null;
      _resultB = null;
      _equation = null;
    });
    final a = double.tryParse(_a.text);
    final b = double.tryParse(_b.text);
    if (a == null || b == null || a.isNaN || b.isNaN) {
      setState(() => _error = '请输入有效的比例数字');
      return;
    }
    if (a < 0 || b < 0 || a + b <= 0) {
      setState(() => _error = '比例需为非负数，且不能同时为 0');
      return;
    }
    if (_tab == 0) {
      final total = double.tryParse(_total.text);
      if (total == null || total < 0) {
        setState(() => _error = '总额需为非负数字');
        return;
      }
      final partA = total * a / (a + b);
      final partB = total - partA;
      setState(() {
        _resultA = _trim(partA);
        _resultB = _trim(partB);
      });
    } else {
      final c = double.tryParse(_c.text);
      if (c == null) {
        setState(() => _error = '请输入有效的第三项');
        return;
      }
      if (a == 0) {
        setState(() => _error = '第一项不能为 0');
        return;
      }
      final x = b * c / a;
      setState(() {
        _equation = '${_trim(a)} : ${_trim(b)} = ${_trim(c)} : ${_trim(x)}';
        _resultA = _trim(x);
      });
    }
  }

  String _trim(double value) {
    final text = value.toStringAsFixed(6);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    final hasResult = _resultA != null;
    return Scaffold(
      key: const Key('ratio-page'),
      backgroundColor: CalcColors.displayBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: '比例计算',
              titleKey: const Key('ratio-title'),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
                children: [
                  SegmentedTabs(
                    labels: const ['按比例分配', '比例求值'],
                    index: _tab,
                    onChanged: (index) => setState(() {
                      _tab = index;
                      _resultA = null;
                      _resultB = null;
                      _equation = null;
                      _error = null;
                    }),
                    keyPrefix: 'ratio-tab',
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: NumberFormField(
                          key: const Key('ratio-a'),
                          label: _tab == 0 ? '比例 A' : '已知 a',
                          controller: _a,
                          placeholder: '请输入',
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(12, 34, 12, 0),
                        child: Text(':', style: TextStyle(fontSize: 24)),
                      ),
                      Expanded(
                        child: NumberFormField(
                          key: const Key('ratio-b'),
                          label: _tab == 0 ? '比例 B' : '已知 b',
                          controller: _b,
                          placeholder: '请输入',
                        ),
                      ),
                    ],
                  ),
                  if (_tab == 0)
                    NumberFormField(
                      key: const Key('ratio-total'),
                      label: '总额',
                      controller: _total,
                      placeholder: '请输入总额',
                    )
                  else
                    NumberFormField(
                      key: const Key('ratio-c'),
                      label: '已知 c（a : b = c : x）',
                      controller: _c,
                      placeholder: '请输入',
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _error!,
                        key: const Key('ratio-error'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: CalcColors.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      key: const Key('ratio-calculate'),
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
                  if (hasResult) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: CalcColors.keyBackground(context),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _tab == 0 ? '分配结果' : '求解结果',
                            style: TextStyle(fontSize: 15, color: secondary),
                          ),
                          const SizedBox(height: 8),
                          if (_equation != null)
                            Text(
                              _equation!,
                              key: const Key('ratio-equation'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontFeatures: CalcText.tabular,
                              ),
                            ),
                          if (_tab == 0) ...[
                            _ResultRow(
                              label: 'A 份额',
                              value: _resultA!,
                              valueKey: const Key('ratio-result-0'),
                            ),
                            _ResultRow(
                              label: 'B 份额',
                              value: _resultB!,
                              valueKey: const Key('ratio-result-1'),
                            ),
                          ] else
                            _ResultRow(
                              label: 'x',
                              value: _resultA!,
                              valueKey: const Key('ratio-result-0'),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    _tab == 0
                        ? '按 A : B 的比例分配总额，结果保留最多 6 位小数。'
                        : '已知 a : b = c : x，x = b × c ÷ a（a 不能为 0）。',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: secondary,
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
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          const Spacer(),
          Text(
            value,
            key: valueKey,
            style: const TextStyle(
              fontSize: 22,
              color: CalcColors.orange,
              fontFeatures: CalcText.tabular,
            ),
          ),
        ],
      ),
    );
  }
}
