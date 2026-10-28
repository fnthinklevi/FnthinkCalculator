import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../theme/tokens.dart';
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
    final settings = AppScope.of(context);

    void press(VoidCallback action) {
      if (settings.haptics) {
        HapticFeedback.lightImpact();
      }
      action();
    }

    void longPress(VoidCallback action) {
      if (settings.haptics) {
        HapticFeedback.mediumImpact();
      }
      action();
    }

    Widget key({
      required String id,
      required String semanticLabel,
      String? label,
      IconData? icon,
      bool isOperator = false,
      bool isEquals = false,
      VoidCallback? onLongPress,
      required VoidCallback onPressed,
    }) {
      return CalcKey(
        keyId: id,
        semanticLabel: semanticLabel,
        label: label,
        icon: icon,
        isOperator: isOperator,
        isEquals: isEquals,
        onPressed: () => press(onPressed),
        onLongPress: onLongPress == null ? null : () => longPress(onLongPress),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CalcSpacing.contentMaxWidth,
          ),
          child: Column(
            children: [
              _row([
                key(
                  id: 'key-clear',
                  semanticLabel: '清空',
                  label: clearLabel,
                  isOperator: true,
                  onPressed: controller.clear,
                  onLongPress: onClearLongPress,
                ),
                key(
                  id: 'key-backspace',
                  semanticLabel: '退格',
                  icon: Icons.backspace_outlined,
                  isOperator: true,
                  onPressed: controller.backspace,
                ),
                key(
                  id: 'key-percent',
                  semanticLabel: '百分号',
                  label: '%',
                  isOperator: true,
                  onPressed: () => controller.inputPostfix('%'),
                ),
                key(
                  id: 'key-divide',
                  semanticLabel: '除',
                  label: '÷',
                  isOperator: true,
                  onPressed: () => controller.inputOperator('÷'),
                ),
              ]),
              const SizedBox(height: CalcSpacing.keyGap),
              _row([
                key(
                  id: 'key-7',
                  semanticLabel: '7',
                  label: '7',
                  onPressed: () => controller.inputDigit('7'),
                ),
                key(
                  id: 'key-8',
                  semanticLabel: '8',
                  label: '8',
                  onPressed: () => controller.inputDigit('8'),
                ),
                key(
                  id: 'key-9',
                  semanticLabel: '9',
                  label: '9',
                  onPressed: () => controller.inputDigit('9'),
                ),
                key(
                  id: 'key-multiply',
                  semanticLabel: '乘',
                  label: '×',
                  isOperator: true,
                  onPressed: () => controller.inputOperator('×'),
                ),
              ]),
              const SizedBox(height: CalcSpacing.keyGap),
              _row([
                key(
                  id: 'key-4',
                  semanticLabel: '4',
                  label: '4',
                  onPressed: () => controller.inputDigit('4'),
                ),
                key(
                  id: 'key-5',
                  semanticLabel: '5',
                  label: '5',
                  onPressed: () => controller.inputDigit('5'),
                ),
                key(
                  id: 'key-6',
                  semanticLabel: '6',
                  label: '6',
                  onPressed: () => controller.inputDigit('6'),
                ),
                key(
                  id: 'key-minus',
                  semanticLabel: '减',
                  label: '−',
                  isOperator: true,
                  onPressed: () => controller.inputOperator('−'),
                ),
              ]),
              const SizedBox(height: CalcSpacing.keyGap),
              _row([
                key(
                  id: 'key-1',
                  semanticLabel: '1',
                  label: '1',
                  onPressed: () => controller.inputDigit('1'),
                ),
                key(
                  id: 'key-2',
                  semanticLabel: '2',
                  label: '2',
                  onPressed: () => controller.inputDigit('2'),
                ),
                key(
                  id: 'key-3',
                  semanticLabel: '3',
                  label: '3',
                  onPressed: () => controller.inputDigit('3'),
                ),
                key(
                  id: 'key-plus',
                  semanticLabel: '加',
                  label: '+',
                  isOperator: true,
                  onPressed: () => controller.inputOperator('+'),
                ),
              ]),
              const SizedBox(height: CalcSpacing.keyGap),
              _row([
                key(
                  id: 'key-scientific',
                  semanticLabel: '科学计算',
                  icon: Icons.functions,
                  isOperator: true,
                  onPressed: controller.toggleScientific,
                ),
                key(
                  id: 'key-0',
                  semanticLabel: '0',
                  label: '0',
                  onPressed: () => controller.inputDigit('0'),
                ),
                key(
                  id: 'key-dot',
                  semanticLabel: '小数点',
                  label: '.',
                  onPressed: controller.inputDecimal,
                ),
                key(
                  id: 'key-equals',
                  semanticLabel: '等于',
                  label: '=',
                  isEquals: true,
                  onPressed: controller.evaluate,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(List<Widget> keys) {
    final children = <Widget>[];
    for (var index = 0; index < keys.length; index++) {
      children.add(Expanded(child: keys[index]));
      if (index != keys.length - 1) {
        children.add(const SizedBox(width: CalcSpacing.keyGap));
      }
    }
    return Expanded(child: Row(children: children));
  }
}

class CalcKey extends StatefulWidget {
  const CalcKey({
    super.key,
    required this.keyId,
    required this.semanticLabel,
    required this.onPressed,
    this.label,
    this.icon,
    this.isOperator = false,
    this.isEquals = false,
    this.onLongPress,
  });

  final String keyId;
  final String semanticLabel;
  final String? label;
  final IconData? icon;
  final bool isOperator;
  final bool isEquals;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  @override
  State<CalcKey> createState() => _CalcKeyState();
}

class _CalcKeyState extends State<CalcKey> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = widget.isEquals
        ? (_pressed ? CalcColors.orangePressed : CalcColors.orange)
        : (_pressed
              ? CalcColors.keyPressed(context)
              : CalcColors.keyBackground(context));
    final foreground = widget.isEquals
        ? Colors.white
        : widget.isOperator
        ? CalcColors.orange
        : (isDark ? CalcColors.darkText : CalcColors.lightText);

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        key: Key(widget.keyId),
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) {
          _setPressed(false);
          widget.onPressed();
        },
        onTapCancel: () => _setPressed(false),
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                _setPressed(false);
                widget.onLongPress!();
              },
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 80),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(CalcRadius.key),
            ),
            alignment: Alignment.center,
            child: widget.icon != null
                ? Icon(widget.icon, size: 28, color: foreground)
                : Text(
                    widget.label ?? '',
                    style: TextStyle(
                      fontSize: widget.isEquals ? 38 : 30,
                      height: 1,
                      color: foreground,
                      fontWeight: FontWeight.w400,
                      fontFeatures: CalcText.tabular,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
