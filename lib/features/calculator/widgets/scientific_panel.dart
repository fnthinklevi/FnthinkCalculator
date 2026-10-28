import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../core/math/angle_unit.dart';
import '../../../theme/tokens.dart';
import '../calculator_controller.dart';

class ScientificPanel extends StatelessWidget {
  const ScientificPanel({super.key, required this.controller});

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    final second = controller.second;

    void press(VoidCallback action) {
      if (settings.haptics) {
        HapticFeedback.selectionClick();
      }
      action();
    }

    void toggleAngle() {
      final next = controller.angleUnit == AngleUnit.degrees
          ? AngleUnit.radians
          : AngleUnit.degrees;
      settings.angleUnit = next;
      controller.setAngleUnit(next);
    }

    final keys = <Widget>[
      _SciKey(
        id: 'sci-second',
        label: '2nd',
        semanticLabel: '第二功能',
        selected: second,
        onPressed: () => press(controller.toggleSecond),
      ),
      _SciKey(
        id: 'sci-angle',
        label: controller.angleUnit == AngleUnit.degrees ? 'DEG' : 'RAD',
        semanticLabel: '角度单位',
        onPressed: () => press(toggleAngle),
      ),
      _SciKey(
        id: 'sci-sin',
        label: second ? 'sin⁻¹' : 'sin',
        semanticLabel: second ? '反正弦' : '正弦',
        onPressed: () =>
            press(() => controller.inputFunction(second ? 'asin' : 'sin')),
      ),
      _SciKey(
        id: 'sci-cos',
        label: second ? 'cos⁻¹' : 'cos',
        semanticLabel: second ? '反余弦' : '余弦',
        onPressed: () =>
            press(() => controller.inputFunction(second ? 'acos' : 'cos')),
      ),
      _SciKey(
        id: 'sci-tan',
        label: second ? 'tan⁻¹' : 'tan',
        semanticLabel: second ? '反正切' : '正切',
        onPressed: () =>
            press(() => controller.inputFunction(second ? 'atan' : 'tan')),
      ),
      _SciKey(
        id: 'sci-ln',
        label: second ? 'eˣ' : 'ln',
        semanticLabel: second ? '自然指数' : '自然对数',
        onPressed: () => press(
          second
              ? controller.inputExpPower
              : () => controller.inputFunction('ln'),
        ),
      ),
      _SciKey(
        id: 'sci-log',
        label: second ? '10ˣ' : 'log',
        semanticLabel: second ? '十的幂' : '常用对数',
        onPressed: () => press(
          second
              ? controller.inputTenPower
              : () => controller.inputFunction('log'),
        ),
      ),
      _SciKey(
        id: 'sci-sqrt',
        label: second ? '∛' : '√',
        semanticLabel: second ? '开立方' : '平方根',
        onPressed: () =>
            press(() => controller.inputFunction(second ? 'cbrt' : 'sqrt')),
      ),
      _SciKey(
        id: 'sci-square',
        label: second ? 'x³' : 'x²',
        semanticLabel: second ? '立方' : '平方',
        onPressed: () => press(() => controller.inputPower(second ? 3 : 2)),
      ),
      _SciKey(
        id: 'sci-power',
        label: 'xʸ',
        semanticLabel: '乘方',
        onPressed: () => press(() => controller.inputOperator('^')),
      ),
      _SciKey(
        id: 'sci-abs',
        label: '|x|',
        semanticLabel: '绝对值',
        onPressed: () => press(() => controller.inputFunction('abs')),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            for (var index = 0; index < keys.length; index++) ...[
              keys[index],
              if (index != keys.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
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
    this.selected = false,
  });

  final String id;
  final String label;
  final String semanticLabel;
  final VoidCallback onPressed;
  final bool selected;

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
          width: 62,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? CalcColors.orange
                : CalcColors.keyBackground(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: selected ? Colors.white : CalcColors.orange,
              fontWeight: FontWeight.w500,
              fontFeatures: CalcText.tabular,
            ),
          ),
        ),
      ),
    );
  }
}
