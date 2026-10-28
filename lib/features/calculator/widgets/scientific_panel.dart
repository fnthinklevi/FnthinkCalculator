import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../theme/tokens.dart';
import '../calculator_controller.dart';

class ScientificPanel extends StatelessWidget {
  const ScientificPanel({super.key, required this.controller});

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);

    void press(VoidCallback action) {
      if (settings.haptics) {
        HapticFeedback.selectionClick();
      }
      action();
    }

    final keys = <Widget>[
      _SciKey(
        id: 'sci-sin',
        label: 'sin',
        semanticLabel: '正弦',
        onPressed: () => press(() => controller.inputFunction('sin')),
      ),
      _SciKey(
        id: 'sci-cos',
        label: 'cos',
        semanticLabel: '余弦',
        onPressed: () => press(() => controller.inputFunction('cos')),
      ),
      _SciKey(
        id: 'sci-tan',
        label: 'tan',
        semanticLabel: '正切',
        onPressed: () => press(() => controller.inputFunction('tan')),
      ),
      _SciKey(
        id: 'sci-ln',
        label: 'ln',
        semanticLabel: '自然对数',
        onPressed: () => press(() => controller.inputFunction('ln')),
      ),
      _SciKey(
        id: 'sci-log',
        label: 'log',
        semanticLabel: '常用对数',
        onPressed: () => press(() => controller.inputFunction('log')),
      ),
      _SciKey(
        id: 'sci-sqrt',
        label: '√',
        semanticLabel: '平方根',
        onPressed: () => press(() => controller.inputFunction('sqrt')),
      ),
      _SciKey(
        id: 'sci-square',
        label: 'x²',
        semanticLabel: '平方',
        onPressed: () => press(() => controller.inputPower(2)),
      ),
      _SciKey(
        id: 'sci-power',
        label: 'xʸ',
        semanticLabel: '乘方',
        onPressed: () => press(() => controller.inputOperator('^')),
      ),
      _SciKey(
        id: 'sci-factorial',
        label: '!',
        semanticLabel: '阶乘',
        onPressed: () => press(() => controller.inputPostfix('!')),
      ),
      _SciKey(
        id: 'sci-pi',
        label: 'π',
        semanticLabel: '圆周率',
        onPressed: () => press(() => controller.inputConstant('pi')),
      ),
      _SciKey(
        id: 'sci-e',
        label: 'e',
        semanticLabel: '自然常数',
        onPressed: () => press(() => controller.inputConstant('e')),
      ),
      _SciKey(
        id: 'sci-left-paren',
        label: '(',
        semanticLabel: '左括号',
        onPressed: () => press(controller.inputLeftParen),
      ),
      _SciKey(
        id: 'sci-right-paren',
        label: ')',
        semanticLabel: '右括号',
        onPressed: () => press(controller.inputRightParen),
      ),
    ];

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: keys.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) => keys[index],
      ),
    );
  }
}

class _SciKey extends StatelessWidget {
  const _SciKey({
    required this.id,
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
  });

  final String id;
  final String label;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        key: Key(id),
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          width: 54,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: CalcColors.keyBackground(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: CalcColors.orange,
              fontWeight: FontWeight.w500,
              fontFeatures: CalcText.tabular,
            ),
          ),
        ),
      ),
    );
  }
}
