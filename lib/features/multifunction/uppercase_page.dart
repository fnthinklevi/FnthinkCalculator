import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../core/utils/chinese_upper.dart';
import '../../theme/tokens.dart';
import '../../widgets/calc_key.dart';
import '../../widgets/numeric_keypad.dart';
import '../../widgets/page_header.dart';

class UppercasePage extends StatefulWidget {
  const UppercasePage({super.key});

  @override
  State<UppercasePage> createState() => _UppercasePageState();
}

class _UppercasePageState extends State<UppercasePage> {
  String _input = '';

  String get _result {
    if (_input.isEmpty) return '零圆整';
    try {
      return ChineseUpper.toRmb(_input);
    } catch (_) {
      return '';
    }
  }

  String? get _error {
    if (_input.isEmpty) return null;
    try {
      ChineseUpper.toRmb(_input);
      return null;
    } catch (error) {
      return ChineseUpper.errorMessage(error);
    }
  }

  void _onKey(String key) {
    if (key == 'clear') {
      setState(() => _input = '');
      return;
    }
    if (key == 'backspace') {
      if (_input.isEmpty) return;
      setState(() => _input = _input.substring(0, _input.length - 1));
      return;
    }
    setState(() {
      _input = applyNumericKey(
        _input,
        key,
        allowDecimal: true,
        allowNegative: false,
      );
    });
  }

  String get _groupedInput {
    if (_input.isEmpty) return '0';
    final parts = _input.split('.');
    final integer = parts.first;
    final buffer = StringBuffer();
    for (var index = 0; index < integer.length; index++) {
      if (index > 0 && (integer.length - index) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integer[index]);
    }
    return parts.length > 1 ? '$buffer.${parts[1]}' : buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    return Scaffold(
      key: const Key('uppercase-page'),
      backgroundColor: CalcColors.displayBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: '大写数字',
              titleKey: const Key('uppercase-title'),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _groupedInput,
                        key: const Key('uppercase-input'),
                        style: const TextStyle(
                          fontSize: 26,
                          color: CalcColors.orange,
                          fontFeatures: CalcText.tabular,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: error != null
                            ? Text(
                                error,
                                key: const Key('uppercase-error'),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: CalcColors.error,
                                ),
                              )
                            : Text(
                                _result,
                                key: const Key('uppercase-result'),
                                textAlign: TextAlign.right,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 48,
                                  height: 1.2,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _UppercaseKeypad(onKey: _onKey),
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

class _UppercaseKeypad extends StatelessWidget {
  const _UppercaseKeypad({required this.onKey});

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
                      const SizedBox.shrink(),
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
                      const SizedBox.shrink(),
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
                  top: 0,
                  width: diameter,
                  height: diameter * 2 + gap,
                  child: _TallTextKey(
                    keyId: 'numeric-key-clear',
                    label: 'C',
                    diameter: diameter,
                    color: CalcColors.orange,
                    onPressed: () => press('clear'),
                  ),
                ),
                Positioned(
                  left: 3 * (diameter + gap),
                  top: 2 * (diameter + gap),
                  width: diameter,
                  height: diameter * 2 + gap,
                  child: _TallIconKey(
                    keyId: 'numeric-key-undo',
                    diameter: diameter,
                    onPressed: () => press('backspace'),
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

class _TallTextKey extends StatelessWidget {
  const _TallTextKey({
    required this.keyId,
    required this.label,
    required this.diameter,
    required this.color,
    required this.onPressed,
  });

  final String keyId;
  final String label;
  final double diameter;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
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
          child: Text(label, style: TextStyle(fontSize: 30, color: color)),
        ),
      ),
    );
  }
}

class _TallIconKey extends StatelessWidget {
  const _TallIconKey({
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
      label: '退格',
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
          child: const Icon(
            Icons.backspace_outlined,
            size: 30,
            color: CalcColors.orange,
          ),
        ),
      ),
    );
  }
}
