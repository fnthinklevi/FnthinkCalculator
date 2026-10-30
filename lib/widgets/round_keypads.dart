import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_scope.dart';
import '../theme/tokens.dart';
import 'calc_key.dart';

class ConverterKeypad extends StatelessWidget {
  const ConverterKeypad({super.key, required this.onKey});

  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.maybeOf(context);
    void press(String key) {
      if (settings?.haptics ?? true) HapticFeedback.lightImpact();
      onKey(key);
    }

    Widget key({
      required String id,
      required String semantic,
      String? label,
      IconData? icon,
      bool operator = false,
      bool equals = false,
      bool enabled = true,
      required String value,
    }) {
      return CalcKey(
        keyId: id,
        semanticLabel: semantic,
        label: label,
        icon: icon,
        isOperator: operator,
        isEquals: equals,
        enabled: enabled,
        fontSize: CalcText.key,
        onPressed: () => press(value),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _RoundGrid(
        columns: 4,
        rows: [
          [
            key(
              id: 'numeric-key-clear',
              semantic: '清空',
              label: 'C',
              operator: true,
              value: 'clear',
            ),
            key(
              id: 'numeric-key-percent',
              semantic: '百分号',
              label: '%',
              operator: true,
              enabled: false,
              value: 'percent',
            ),
            key(
              id: 'numeric-key-divide',
              semantic: '除',
              label: '÷',
              operator: true,
              value: '÷',
            ),
            key(
              id: 'numeric-key-undo',
              semantic: '退格',
              icon: Icons.backspace_outlined,
              operator: true,
              value: 'backspace',
            ),
          ],
          [
            key(id: 'numeric-key-7', semantic: '7', label: '7', value: '7'),
            key(id: 'numeric-key-8', semantic: '8', label: '8', value: '8'),
            key(id: 'numeric-key-9', semantic: '9', label: '9', value: '9'),
            key(
              id: 'numeric-key-multiply',
              semantic: '乘',
              label: '×',
              operator: true,
              value: '×',
            ),
          ],
          [
            key(id: 'numeric-key-4', semantic: '4', label: '4', value: '4'),
            key(id: 'numeric-key-5', semantic: '5', label: '5', value: '5'),
            key(id: 'numeric-key-6', semantic: '6', label: '6', value: '6'),
            key(
              id: 'numeric-key-minus',
              semantic: '减',
              label: '−',
              operator: true,
              value: '−',
            ),
          ],
          [
            key(id: 'numeric-key-1', semantic: '1', label: '1', value: '1'),
            key(id: 'numeric-key-2', semantic: '2', label: '2', value: '2'),
            key(id: 'numeric-key-3', semantic: '3', label: '3', value: '3'),
            key(
              id: 'numeric-key-plus',
              semantic: '加',
              label: '+',
              operator: true,
              value: '+',
            ),
          ],
          [
            key(id: 'numeric-key-00', semantic: '双零', label: '00', value: '00'),
            key(id: 'numeric-key-0', semantic: '0', label: '0', value: '0'),
            key(id: 'numeric-key-dot', semantic: '小数点', label: '.', value: '.'),
            key(
              id: 'numeric-key-equals',
              semantic: '等于',
              label: '=',
              equals: true,
              value: 'equals',
            ),
          ],
        ],
      ),
    );
  }
}

class TemperatureKeypad extends StatelessWidget {
  const TemperatureKeypad({super.key, required this.onKey});

  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.maybeOf(context);
    void press(String key) {
      if (settings?.haptics ?? true) HapticFeedback.lightImpact();
      onKey(key);
    }

    Widget key({
      required String id,
      required String semantic,
      String? label,
      IconData? icon,
      bool operator = false,
      required String value,
    }) {
      return CalcKey(
        keyId: id,
        semanticLabel: semantic,
        label: label,
        icon: icon,
        isOperator: operator,
        fontSize: CalcText.key,
        onPressed: () => press(value),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 10.0;
          final diameter = math
              .min(
                (constraints.maxWidth - 56 - gap * 3) / 4,
                (constraints.maxHeight - gap * 3) / 5,
              )
              .clamp(36.0, 82.0);
          Widget row(List<Widget> keys) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < keys.length; index++) ...[
                  SizedBox.square(dimension: diameter, child: keys[index]),
                  if (index != keys.length - 1) const SizedBox(width: gap),
                ],
              ],
            );
          }

          return Center(
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    row([
                      key(
                        id: 'numeric-key-7',
                        semantic: '7',
                        label: '7',
                        value: '7',
                      ),
                      key(
                        id: 'numeric-key-8',
                        semantic: '8',
                        label: '8',
                        value: '8',
                      ),
                      key(
                        id: 'numeric-key-9',
                        semantic: '9',
                        label: '9',
                        value: '9',
                      ),
                      key(
                        id: 'numeric-key-clear',
                        semantic: '清空',
                        label: 'C',
                        operator: true,
                        value: 'clear',
                      ),
                    ]),
                    const SizedBox(height: gap),
                    row([
                      key(
                        id: 'numeric-key-4',
                        semantic: '4',
                        label: '4',
                        value: '4',
                      ),
                      key(
                        id: 'numeric-key-5',
                        semantic: '5',
                        label: '5',
                        value: '5',
                      ),
                      key(
                        id: 'numeric-key-6',
                        semantic: '6',
                        label: '6',
                        value: '6',
                      ),
                      key(
                        id: 'numeric-key-undo',
                        semantic: '退格',
                        icon: Icons.backspace_outlined,
                        operator: true,
                        value: 'backspace',
                      ),
                    ]),
                    const SizedBox(height: gap),
                    row([
                      key(
                        id: 'numeric-key-1',
                        semantic: '1',
                        label: '1',
                        value: '1',
                      ),
                      key(
                        id: 'numeric-key-2',
                        semantic: '2',
                        label: '2',
                        value: '2',
                      ),
                      key(
                        id: 'numeric-key-3',
                        semantic: '3',
                        label: '3',
                        value: '3',
                      ),
                      const SizedBox.shrink(),
                    ]),
                    const SizedBox(height: gap),
                    row([
                      key(
                        id: 'numeric-key-00',
                        semantic: '双零',
                        label: '00',
                        value: '00',
                      ),
                      key(
                        id: 'numeric-key-0',
                        semantic: '0',
                        label: '0',
                        value: '0',
                      ),
                      key(
                        id: 'numeric-key-dot',
                        semantic: '小数点',
                        label: '.',
                        value: '.',
                      ),
                      const SizedBox.shrink(),
                    ]),
                  ],
                ),
                Positioned(
                  left: 3 * (diameter + gap),
                  top: 2 * (diameter + gap),
                  width: diameter,
                  height: diameter * 2 + gap,
                  child: _TallSignKey(
                    keyId: 'numeric-key-sign',
                    diameter: diameter,
                    onPressed: () => press('sign'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoundGrid extends StatelessWidget {
  const _RoundGrid({required this.columns, required this.rows});

  final int columns;
  final List<List<Widget>> rows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final diameter = math
            .min(
              (constraints.maxWidth - 56 - gap * (columns - 1)) / columns,
              (constraints.maxHeight - gap * (rows.length - 1)) / rows.length,
            )
            .clamp(36.0, 82.0);
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
                        const SizedBox(width: gap),
                    ],
                  ],
                ),
                if (rowIndex != rows.length - 1) const SizedBox(height: gap),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TallSignKey extends StatelessWidget {
  const _TallSignKey({
    required this.keyId,
    required this.diameter,
    required this.onPressed,
  });

  final String keyId;
  final double diameter;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '正负号',
      excludeSemantics: true,
      child: GestureDetector(
        key: Key(keyId),
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: CalcColors.keyBackground(context),
            borderRadius: BorderRadius.circular(diameter / 2),
          ),
          alignment: Alignment.center,
          child: const Text(
            '±',
            style: TextStyle(fontSize: 30, color: CalcColors.orange),
          ),
        ),
      ),
    );
  }
}
