import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../core/math/angle_unit.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/calc_key.dart';
import '../calculator_controller.dart';

class CalcKeypad extends StatelessWidget {
  const CalcKeypad({
    super.key,
    required this.controller,
    required this.clearLabel,
    required this.onClearLongPress,
  });

  final CalculatorController controller;
  final String clearLabel;
  final VoidCallback onClearLongPress;

  @override
  Widget build(BuildContext context) {
    return controller.scientificVisible
        ? _ScientificKeypad(
            controller: controller,
            clearLabel: clearLabel,
            onClearLongPress: onClearLongPress,
          )
        : _StandardKeypad(
            controller: controller,
            clearLabel: clearLabel,
            onClearLongPress: onClearLongPress,
          );
  }
}

class _KeyGrid extends StatelessWidget {
  const _KeyGrid({
    required this.rows,
    required this.columns,
    required this.gap,
    required this.margin,
    required this.maxDiameter,
  });

  final List<List<Widget>> rows;
  final int columns;
  final double gap;
  final double margin;
  final double maxDiameter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthFit =
            (constraints.maxWidth - margin * 2 - gap * (columns - 1)) / columns;
        final heightFit =
            (constraints.maxHeight - gap * (rows.length - 1)) / rows.length;
        final diameter = math
            .min(math.min(widthFit, heightFit), maxDiameter)
            .clamp(34.0, maxDiameter);
        return Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (
                      var index = 0;
                      index < rows[rowIndex].length;
                      index++
                    ) ...[
                      SizedBox.square(
                        dimension: diameter,
                        child: rows[rowIndex][index],
                      ),
                      if (index != rows[rowIndex].length - 1)
                        SizedBox(width: gap),
                    ],
                  ],
                ),
                if (rowIndex != rows.length - 1) SizedBox(height: gap),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StandardKeypad extends StatelessWidget {
  const _StandardKeypad({
    required this.controller,
    required this.clearLabel,
    required this.onClearLongPress,
  });

  final CalculatorController controller;
  final String clearLabel;
  final VoidCallback onClearLongPress;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);

    void press(VoidCallback action) {
      if (settings.haptics) {
        HapticFeedback.lightImpact();
      }
      action();
    }

    Widget key({
      required String id,
      required String semantic,
      String? label,
      IconData? icon,
      bool operator = false,
      bool equals = false,
      VoidCallback? onPressed,
      VoidCallback? onLongPress,
      double fontSize = CalcText.key,
    }) {
      return CalcKey(
        keyId: id,
        semanticLabel: semantic,
        label: label,
        icon: icon,
        isOperator: operator,
        isEquals: equals,
        fontSize: fontSize,
        onPressed: () => press(onPressed ?? () {}),
        onLongPress: onLongPress == null
            ? null
            : () {
                if (settings.haptics) {
                  HapticFeedback.mediumImpact();
                }
                onLongPress();
              },
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _KeyGrid(
        columns: 4,
        gap: CalcSpacing.keyGap,
        margin: CalcSpacing.keyMargin,
        maxDiameter: 80,
        rows: [
          [
            key(
              id: 'key-clear',
              semantic: '清空',
              label: clearLabel,
              operator: true,
              onPressed: controller.clear,
              onLongPress: onClearLongPress,
            ),
            key(
              id: 'key-percent',
              semantic: '百分号',
              label: '%',
              operator: true,
              onPressed: () => controller.inputPostfix('%'),
            ),
            key(
              id: 'key-divide',
              semantic: '除',
              label: '÷',
              operator: true,
              onPressed: () => controller.inputOperator('÷'),
            ),
            key(
              id: 'key-backspace',
              semantic: '退格',
              icon: Icons.backspace_outlined,
              operator: true,
              onPressed: controller.backspace,
            ),
          ],
          [
            key(
              id: 'key-7',
              semantic: '7',
              label: '7',
              onPressed: () => controller.inputDigit('7'),
            ),
            key(
              id: 'key-8',
              semantic: '8',
              label: '8',
              onPressed: () => controller.inputDigit('8'),
            ),
            key(
              id: 'key-9',
              semantic: '9',
              label: '9',
              onPressed: () => controller.inputDigit('9'),
            ),
            key(
              id: 'key-multiply',
              semantic: '乘',
              label: '×',
              operator: true,
              onPressed: () => controller.inputOperator('×'),
            ),
          ],
          [
            key(
              id: 'key-4',
              semantic: '4',
              label: '4',
              onPressed: () => controller.inputDigit('4'),
            ),
            key(
              id: 'key-5',
              semantic: '5',
              label: '5',
              onPressed: () => controller.inputDigit('5'),
            ),
            key(
              id: 'key-6',
              semantic: '6',
              label: '6',
              onPressed: () => controller.inputDigit('6'),
            ),
            key(
              id: 'key-minus',
              semantic: '减',
              label: '−',
              operator: true,
              onPressed: () => controller.inputOperator('−'),
            ),
          ],
          [
            key(
              id: 'key-1',
              semantic: '1',
              label: '1',
              onPressed: () => controller.inputDigit('1'),
            ),
            key(
              id: 'key-2',
              semantic: '2',
              label: '2',
              onPressed: () => controller.inputDigit('2'),
            ),
            key(
              id: 'key-3',
              semantic: '3',
              label: '3',
              onPressed: () => controller.inputDigit('3'),
            ),
            key(
              id: 'key-plus',
              semantic: '加',
              label: '+',
              operator: true,
              onPressed: () => controller.inputOperator('+'),
            ),
          ],
          [
            key(
              id: 'key-scientific',
              semantic: '科学计算',
              icon: Icons.swap_horiz_rounded,
              operator: true,
              onPressed: controller.toggleScientific,
            ),
            key(
              id: 'key-0',
              semantic: '0',
              label: '0',
              onPressed: () => controller.inputDigit('0'),
            ),
            key(
              id: 'key-dot',
              semantic: '小数点',
              label: '.',
              onPressed: controller.inputDecimal,
            ),
            key(
              id: 'key-equals',
              semantic: '等于',
              label: '=',
              equals: true,
              fontSize: 34,
              onPressed: controller.evaluate,
            ),
          ],
        ],
      ),
    );
  }
}

class _ScientificKeypad extends StatelessWidget {
  const _ScientificKeypad({
    required this.controller,
    required this.clearLabel,
    required this.onClearLongPress,
  });

  final CalculatorController controller;
  final String clearLabel;
  final VoidCallback onClearLongPress;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    final second = controller.second;
    final degrees = controller.angleUnit == AngleUnit.degrees;

    void press(VoidCallback action) {
      if (settings.haptics) {
        HapticFeedback.selectionClick();
      }
      action();
    }

    void toggleAngle() {
      final next = degrees ? AngleUnit.radians : AngleUnit.degrees;
      settings.angleUnit = next;
      controller.setAngleUnit(next);
    }

    Widget key({
      required String id,
      required String semantic,
      String? label,
      IconData? icon,
      bool operator = false,
      bool equals = false,
      bool selected = false,
      bool muted = false,
      VoidCallback? onPressed,
      VoidCallback? onLongPress,
      double fontSize = CalcText.keySmall,
    }) {
      return CalcKey(
        keyId: id,
        semanticLabel: semantic,
        label: label,
        icon: icon,
        isOperator: operator,
        isEquals: equals,
        selected: selected,
        muted: muted,
        fontSize: fontSize,
        onPressed: () => press(onPressed ?? () {}),
        onLongPress: onLongPress == null
            ? null
            : () {
                if (settings.haptics) {
                  HapticFeedback.mediumImpact();
                }
                onLongPress();
              },
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _KeyGrid(
        columns: 5,
        gap: CalcSpacing.keyGap,
        margin: CalcSpacing.keyMargin,
        maxDiameter: 64,
        rows: [
          [
            key(
              id: 'sci-second',
              semantic: '第二功能',
              label: '2nd',
              selected: second,
              onPressed: controller.toggleSecond,
            ),
            key(
              id: 'sci-angle',
              semantic: '角度单位',
              label: degrees ? 'DEG' : 'RAD',
              onPressed: toggleAngle,
            ),
            key(
              id: 'sci-sin',
              semantic: second ? '反正弦' : '正弦',
              label: second ? 'sin⁻¹' : 'sin',
              onPressed: () =>
                  controller.inputFunction(second ? 'asin' : 'sin'),
            ),
            key(
              id: 'sci-cos',
              semantic: second ? '反余弦' : '余弦',
              label: second ? 'cos⁻¹' : 'cos',
              onPressed: () =>
                  controller.inputFunction(second ? 'acos' : 'cos'),
            ),
            key(
              id: 'sci-tan',
              semantic: second ? '反正切' : '正切',
              label: second ? 'tan⁻¹' : 'tan',
              onPressed: () =>
                  controller.inputFunction(second ? 'atan' : 'tan'),
            ),
          ],
          [
            key(
              id: 'sci-power',
              semantic: '乘方',
              label: 'xʸ',
              onPressed: () => controller.inputOperator('^'),
            ),
            key(
              id: 'sci-log',
              semantic: second ? '十的幂' : '常用对数',
              label: second ? '10ˣ' : 'lg',
              onPressed: second
                  ? controller.inputTenPower
                  : () => controller.inputFunction('log'),
            ),
            key(
              id: 'sci-ln',
              semantic: second ? '自然指数' : '自然对数',
              label: second ? 'eˣ' : 'ln',
              onPressed: second
                  ? controller.inputExpPower
                  : () => controller.inputFunction('ln'),
            ),
            key(
              id: 'sci-left-paren',
              semantic: '左括号',
              label: '(',
              onPressed: controller.inputLeftParen,
            ),
            key(
              id: 'sci-right-paren',
              semantic: '右括号',
              label: ')',
              onPressed: controller.inputRightParen,
            ),
          ],
          [
            key(
              id: 'sci-sqrt',
              semantic: second ? '平方' : '平方根',
              label: second ? 'x²' : '√x',
              onPressed: second
                  ? () => controller.inputPower(2)
                  : () => controller.inputFunction('sqrt'),
            ),
            key(
              id: 'key-clear',
              semantic: '清空',
              label: clearLabel,
              operator: true,
              fontSize: CalcText.keySmall,
              onPressed: controller.clear,
              onLongPress: onClearLongPress,
            ),
            key(
              id: 'key-percent',
              semantic: '百分号',
              label: '%',
              operator: true,
              onPressed: () => controller.inputPostfix('%'),
            ),
            key(
              id: 'key-divide',
              semantic: '除',
              label: '÷',
              operator: true,
              onPressed: () => controller.inputOperator('÷'),
            ),
            key(
              id: 'key-backspace',
              semantic: '退格',
              icon: Icons.backspace_outlined,
              operator: true,
              onPressed: controller.backspace,
            ),
          ],
          [
            key(
              id: 'sci-factorial',
              semantic: '阶乘',
              label: 'x!',
              onPressed: () => controller.inputPostfix('!'),
            ),
            key(
              id: 'key-7',
              semantic: '7',
              label: '7',
              fontSize: CalcText.key,
              onPressed: () => controller.inputDigit('7'),
            ),
            key(
              id: 'key-8',
              semantic: '8',
              label: '8',
              fontSize: CalcText.key,
              onPressed: () => controller.inputDigit('8'),
            ),
            key(
              id: 'key-9',
              semantic: '9',
              label: '9',
              fontSize: CalcText.key,
              onPressed: () => controller.inputDigit('9'),
            ),
            key(
              id: 'key-multiply',
              semantic: '乘',
              label: '×',
              operator: true,
              onPressed: () => controller.inputOperator('×'),
            ),
          ],
          [
            key(
              id: 'sci-reciprocal',
              semantic: '倒数',
              label: '1/x',
              onPressed: () {
                controller.inputFunction('reciprocal');
              },
            ),
            key(
              id: 'key-4',
              semantic: '4',
              label: '4',
              fontSize: CalcText.key,
              onPressed: () => controller.inputDigit('4'),
            ),
            key(
              id: 'key-5',
              semantic: '5',
              label: '5',
              fontSize: CalcText.key,
              onPressed: () => controller.inputDigit('5'),
            ),
            key(
              id: 'key-6',
              semantic: '6',
              label: '6',
              fontSize: CalcText.key,
              onPressed: () => controller.inputDigit('6'),
            ),
            key(
              id: 'key-minus',
              semantic: '减',
              label: '−',
              operator: true,
              onPressed: () => controller.inputOperator('−'),
            ),
          ],
          [
            key(
              id: 'sci-pi',
              semantic: '圆周率',
              label: 'π',
              onPressed: () => controller.inputConstant('pi'),
            ),
            key(
              id: 'key-1',
              semantic: '1',
              label: '1',
              fontSize: CalcText.key,
              onPressed: () => controller.inputDigit('1'),
            ),
            key(
              id: 'key-2',
              semantic: '2',
              label: '2',
              fontSize: CalcText.key,
              onPressed: () => controller.inputDigit('2'),
            ),
            key(
              id: 'key-3',
              semantic: '3',
              label: '3',
              fontSize: CalcText.key,
              onPressed: () => controller.inputDigit('3'),
            ),
            key(
              id: 'key-plus',
              semantic: '加',
              label: '+',
              operator: true,
              onPressed: () => controller.inputOperator('+'),
            ),
          ],
          [
            key(
              id: 'key-scientific',
              semantic: '标准计算',
              icon: Icons.swap_horiz_rounded,
              operator: true,
              onPressed: controller.toggleScientific,
            ),
            key(
              id: 'sci-e',
              semantic: '自然常数',
              label: 'e',
              onPressed: () => controller.inputConstant('e'),
            ),
            key(
              id: 'key-0',
              semantic: '0',
              label: '0',
              fontSize: CalcText.key,
              onPressed: () => controller.inputDigit('0'),
            ),
            key(
              id: 'key-dot',
              semantic: '小数点',
              label: '.',
              fontSize: CalcText.key,
              onPressed: controller.inputDecimal,
            ),
            key(
              id: 'key-equals',
              semantic: '等于',
              label: '=',
              equals: true,
              fontSize: 32,
              onPressed: controller.evaluate,
            ),
          ],
        ],
      ),
    );
  }
}
