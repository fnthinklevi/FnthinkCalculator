import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';
import '../../../widgets/numeric_keypad.dart';
import '../../../widgets/page_header.dart';
import 'bmi_result_page.dart';

class BmiPage extends StatefulWidget {
  const BmiPage({super.key});

  @override
  State<BmiPage> createState() => _BmiPageState();
}

class _BmiPageState extends State<BmiPage> {
  String _age = '';
  String _height = '';
  String _weight = '';
  bool _male = true;
  String? _error;

  Future<void> _edit({
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

  void _calculate() {
    final age = int.tryParse(_age);
    final height = double.tryParse(_height);
    final weight = double.tryParse(_weight);
    if (age == null || age < 1 || age > 120) {
      setState(() => _error = '请输入 1–120 的年龄');
      return;
    }
    if (height == null || height < 30 || height > 300) {
      setState(() => _error = '请输入 30–300 厘米的身高');
      return;
    }
    if (weight == null || weight < 1 || weight > 500) {
      setState(() => _error = '请输入 1–500 公斤的体重');
      return;
    }
    final bmi = weight / ((height / 100) * (height / 100));
    setState(() => _error = null);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BmiResultPage(bmi: bmi, heightCm: height),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Scaffold(
      key: const Key('bmi-page'),
      backgroundColor: CalcColors.displayBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'BMI指数计算',
              titleKey: const Key('bmi-title'),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _UnderlineField(
                          keyId: 'bmi-age',
                          label: '年龄',
                          value: _age,
                          placeholder: '请输入年龄',
                          onTap: () => _edit(
                            title: '年龄',
                            initial: _age,
                            allowDecimal: false,
                            onValue: (value) => setState(() => _age = value),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '性别(${_male ? '男' : '女'})',
                            style: TextStyle(fontSize: 15, color: secondary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _GenderCard(
                                keyId: 'bmi-gender-male',
                                icon: Icons.male,
                                selected: _male,
                                onTap: () => setState(() => _male = true),
                              ),
                              const SizedBox(width: 10),
                              _GenderCard(
                                keyId: 'bmi-gender-female',
                                icon: Icons.female,
                                selected: !_male,
                                onTap: () => setState(() => _male = false),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  _UnderlineField(
                    keyId: 'bmi-height',
                    label: '身高（厘米）',
                    value: _height,
                    placeholder: '请输入身高',
                    onTap: () => _edit(
                      title: '身高（厘米）',
                      initial: _height,
                      allowDecimal: true,
                      onValue: (value) => setState(() => _height = value),
                    ),
                  ),
                  _UnderlineField(
                    keyId: 'bmi-weight',
                    label: '体重（公斤）',
                    value: _weight,
                    placeholder: '请输入体重',
                    onTap: () => _edit(
                      title: '体重（公斤）',
                      initial: _weight,
                      allowDecimal: true,
                      onValue: (value) => setState(() => _weight = value),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'BMI指数：',
                    style: TextStyle(fontSize: 15, color: secondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '简称体质指数，是通过体重公斤除以身高米数平方得出的数字。是目前国际上常用的衡量人体胖瘦程度以及是否健康的一个标准。',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: secondary,
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        key: const Key('bmi-error'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: CalcColors.error,
                        ),
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
                  key: const Key('bmi-calculate'),
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

class _UnderlineField extends StatelessWidget {
  const _UnderlineField({
    required this.keyId,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final String keyId;
  final String label;
  final String value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return InkWell(
      key: Key(keyId),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 15, color: secondary)),
            const SizedBox(height: 4),
            Text(
              value.isEmpty ? placeholder : value,
              key: Key('$keyId-value'),
              style: TextStyle(
                fontSize: 22,
                color: value.isEmpty ? secondary : null,
                fontFeatures: CalcText.tabular,
              ),
            ),
            const SizedBox(height: 6),
            Divider(height: 1, color: CalcColors.divider(context)),
          ],
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.keyId,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String keyId;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CalcColors.keyBackground(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: Key(keyId),
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            icon,
            size: 30,
            color: selected
                ? CalcColors.orange
                : CalcColors.secondaryText(context),
          ),
        ),
      ),
    );
  }
}
