import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';
import '../../../widgets/page_header.dart';

class BmiResultPage extends StatelessWidget {
  const BmiResultPage({super.key, required this.bmi, required this.heightCm});

  final double bmi;
  final double heightCm;

  @override
  Widget build(BuildContext context) {
    final heightM = heightCm / 100;
    final minWeight = 18.5 * heightM * heightM;
    final maxWeight = 24.0 * heightM * heightM;
    final category = _category(bmi);
    return Scaffold(
      key: const Key('bmi-result-page'),
      backgroundColor: CalcColors.displayBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'BMI计算结果',
              titleKey: const Key('bmi-result-title'),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  Text(
                    bmi.toStringAsFixed(1),
                    key: const Key('bmi-result-value'),
                    style: TextStyle(
                      fontSize: 56,
                      height: 1,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '身高体重指数',
                    style: TextStyle(
                      fontSize: 15,
                      color: CalcColors.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _BmiGauge(bmi: bmi, category: category),
                  const SizedBox(height: 18),
                  const _Legend(),
                  const SizedBox(height: 26),
                  Divider(color: CalcColors.divider(context)),
                  const SizedBox(height: 18),
                  Text(
                    '数据分析',
                    style: TextStyle(
                      fontSize: 15,
                      color: CalcColors.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DataRow(label: '身高（厘米）', value: heightCm.toStringAsFixed(1)),
                  _DataRow(
                    label: '建议体重（公斤）',
                    value:
                        '${minWeight.toStringAsFixed(1)} ~ ${maxWeight.toStringAsFixed(1)}',
                    valueKey: const Key('bmi-result-weight-range'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _BmiCategory _category(double value) {
    if (value < 18.5) return _BmiCategory.thin;
    if (value < 24) return _BmiCategory.normal;
    if (value < 28) return _BmiCategory.overweight;
    return _BmiCategory.obese;
  }
}

enum _BmiCategory {
  thin('偏瘦', Color(0xFF4A9EFF), '偏瘦'),
  normal('正常', Color(0xFF22C55E), '正常'),
  overweight('偏重', Color(0xFFFFA000), '偏重'),
  obese('肥胖', Color(0xFFFF6B4A), '肥胖');

  const _BmiCategory(this.label, this.color, this.badge);

  final String label;
  final Color color;
  final String badge;
}

class _BmiGauge extends StatelessWidget {
  const _BmiGauge({required this.bmi, required this.category});

  final double bmi;
  final _BmiCategory category;

  @override
  Widget build(BuildContext context) {
    const min = 16.0;
    const max = 32.0;
    final fraction = ((bmi - min) / (max - min)).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final badgeLeft = (fraction * width - 28).clamp(0.0, width - 56);
        double marker(double value) =>
            ((value - min) / (max - min)).clamp(0.0, 1.0) * width;
        return SizedBox(
          height: 76,
          child: Stack(
            children: [
              Positioned(
                left: badgeLeft,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category.badge,
                    key: const Key('bmi-result-badge'),
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 34,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4A9EFF),
                        Color(0xFF22C55E),
                        Color(0xFFFFD54F),
                        Color(0xFFFFA000),
                        Color(0xFFFF6B4A),
                      ],
                    ),
                  ),
                ),
              ),
              for (final value in const [18.5, 24.0, 28.0])
                Positioned(
                  left: marker(value) - 20,
                  top: 50,
                  width: 40,
                  child: Text(
                    value.toStringAsFixed(1),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: CalcColors.secondaryText(context),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('偏瘦', Color(0xFF4A9EFF)),
      ('正常', Color(0xFF22C55E)),
      ('偏重', Color(0xFFFFA000)),
      ('肥胖', Color(0xFFFF6B4A)),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final item in items)
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.$2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(item.$1, style: const TextStyle(fontSize: 15)),
            ],
          ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value, this.valueKey});

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 19)),
          const Spacer(),
          Text(
            value,
            key: valueKey,
            style: TextStyle(
              fontSize: 18,
              color: CalcColors.secondaryText(context),
              fontFeatures: CalcText.tabular,
            ),
          ),
        ],
      ),
    );
  }
}
