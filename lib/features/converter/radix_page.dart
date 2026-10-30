import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../theme/tokens.dart';
import '../../widgets/anchored_picker.dart';
import '../../widgets/calc_key.dart';
import '../../widgets/page_header.dart';

class RadixPage extends StatefulWidget {
  const RadixPage({super.key});

  @override
  State<RadixPage> createState() => _RadixPageState();
}

class _RadixPageState extends State<RadixPage> {
  static const _bases = [
    _RadixDef(10, '十进制', 'DEC'),
    _RadixDef(2, '二进制', 'BIN'),
  ];
  static const _allBases = [
    _RadixDef(10, '十进制', 'DEC'),
    _RadixDef(2, '二进制', 'BIN'),
    _RadixDef(8, '八进制', 'OCT'),
    _RadixDef(16, '十六进制', 'HEX'),
  ];

  final List<_RadixDef> _rows = [..._bases];
  int _active = 0;
  String _input = '1';
  bool _replaceOnNext = false;
  final List<GlobalKey> _anchorKeys = [GlobalKey(), GlobalKey()];

  int get _activeBase => _rows[_active].base;

  BigInt? _valueOf(String text, int radix) {
    if (text.isEmpty) return BigInt.zero;
    if (!RegExp(r'^[0-9A-F]+$').hasMatch(text)) return null;
    try {
      return BigInt.parse(text, radix: radix);
    } on FormatException {
      return null;
    }
  }

  String _format(BigInt value, int radix) {
    final text = value.toRadixString(radix).toUpperCase();
    return radix == 10 ? _group(text) : text;
  }

  String _group(String digits) {
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }

  String _rawValue(int index) {
    final value = _valueOf(_input, _activeBase);
    if (value == null) return '';
    return _format(value, _rows[index].base).replaceAll(',', '');
  }

  String _displayValue(int index) {
    if (index == _active) return _input.isEmpty ? '0' : _input;
    final value = _valueOf(_input, _activeBase);
    if (value == null) return '—';
    return _format(value, _rows[index].base);
  }

  void _setActive(int index) {
    if (index == _active) return;
    _input = _rawValue(index);
    _active = index;
    _replaceOnNext = true;
    setState(() {});
  }

  Future<void> _pickBase(int index) async {
    final selected = await showAnchoredPicker<_RadixDef>(
      context: context,
      anchorKey: _anchorKeys[index],
      items: [
        for (final def in _allBases)
          AnchoredPickerItem(
            id: '${def.base}',
            title: def.name,
            subtitle: def.code,
            value: def,
          ),
      ],
      selected: _rows[index],
      keyPrefix: 'radix-option',
      width: 170,
    );
    if (selected == null || !mounted) return;
    setState(() {
      _rows[index] = selected;
      final value = _valueOf(_input, _activeBase);
      if (value != null) {
        _input = _format(value, _rows[_active].base).replaceAll(',', '');
      }
    });
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
    if (key == '00') {
      setState(() {
        if (_replaceOnNext) {
          _input = '0';
          _replaceOnNext = false;
        } else if (_input != '0') {
          _input = '${_input}00';
        }
      });
      return;
    }
    final digit = key.toUpperCase();
    if (!RegExp(r'^[0-9A-F]$').hasMatch(digit)) return;
    final value = int.parse(digit, radix: 16);
    if (value >= _activeBase) return;
    setState(() {
      if (_replaceOnNext) {
        _input = digit;
        _replaceOnNext = false;
      } else if (_input == '0') {
        _input = digit;
      } else {
        _input = '$_input$digit';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Scaffold(
      key: const Key('radix-page'),
      backgroundColor: CalcColors.displayBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: '进制转换',
              titleKey: const Key('radix-title'),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  for (var index = 0; index < _rows.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: _RadixRow(
                        rowKey: Key('radix-row-$index'),
                        anchorKey: _anchorKeys[index],
                        pickerKey: Key('radix-picker-$index'),
                        def: _rows[index],
                        value: _displayValue(index),
                        active: index == _active,
                        valueKey: Key('radix-value-$index'),
                        onTap: () => _setActive(index),
                        onPick: () => _pickBase(index),
                      ),
                    ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '仅支持非负整数',
                      style: TextStyle(fontSize: 15, color: secondary),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _RadixKeypad(base: _activeBase, onKey: _onKey),
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

class _RadixDef {
  const _RadixDef(this.base, this.name, this.code);

  final int base;
  final String name;
  final String code;
}

class _RadixRow extends StatelessWidget {
  const _RadixRow({
    required this.rowKey,
    required this.anchorKey,
    required this.pickerKey,
    required this.def,
    required this.value,
    required this.active,
    required this.valueKey,
    required this.onTap,
    required this.onPick,
  });

  final Key rowKey;
  final GlobalKey anchorKey;
  final Key pickerKey;
  final _RadixDef def;
  final String value;
  final bool active;
  final Key valueKey;
  final VoidCallback onTap;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return InkWell(
      key: rowKey,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: Row(
          children: [
            KeyedSubtree(
              key: pickerKey,
              child: GestureDetector(
                key: anchorKey,
                behavior: HitTestBehavior.opaque,
                onTap: onPick,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(def.name, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 6),
                    Text(
                      def.code,
                      style: TextStyle(fontSize: 17, color: secondary),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.unfold_more, size: 18, color: secondary),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  key: valueKey,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 28,
                    color: active
                        ? CalcColors.orange
                        : Theme.of(context).colorScheme.onSurface,
                    fontFeatures: CalcText.tabular,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadixKeypad extends StatelessWidget {
  const _RadixKeypad({required this.base, required this.onKey});

  final int base;
  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.maybeOf(context);
    void press(String key) {
      if (settings?.haptics ?? true) HapticFeedback.lightImpact();
      onKey(key);
    }

    bool enabledDigit(String digit) {
      final value = int.parse(digit, radix: 16);
      return value < base;
    }

    Widget digit(String id, String label, {bool enabled = true}) {
      return CalcKey(
        keyId: id,
        semanticLabel: label,
        label: label,
        enabled: enabled,
        fontSize: CalcText.key,
        onPressed: () => press(label),
      );
    }

    Widget action({
      required String id,
      required String semantic,
      String? label,
      IconData? icon,
      required String value,
    }) {
      return CalcKey(
        keyId: id,
        semanticLabel: semantic,
        label: label,
        icon: icon,
        isOperator: true,
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
                (constraints.maxHeight - gap * 4) / 5,
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

          return Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                row([
                  action(
                    id: 'radix-key-clear',
                    semantic: '清空',
                    label: 'C',
                    value: 'clear',
                  ),
                  digit('radix-key-F', 'F', enabled: enabledDigit('F')),
                  digit('radix-key-E', 'E', enabled: enabledDigit('E')),
                  action(
                    id: 'radix-key-undo',
                    semantic: '退格',
                    icon: Icons.backspace_outlined,
                    value: 'backspace',
                  ),
                ]),
                const SizedBox(height: gap),
                row([
                  digit('radix-key-7', '7', enabled: enabledDigit('7')),
                  digit('radix-key-8', '8', enabled: enabledDigit('8')),
                  digit('radix-key-9', '9', enabled: enabledDigit('9')),
                  digit('radix-key-D', 'D', enabled: enabledDigit('D')),
                ]),
                const SizedBox(height: gap),
                row([
                  digit('radix-key-4', '4', enabled: enabledDigit('4')),
                  digit('radix-key-5', '5', enabled: enabledDigit('5')),
                  digit('radix-key-6', '6', enabled: enabledDigit('6')),
                  digit('radix-key-C', 'C', enabled: enabledDigit('C')),
                ]),
                const SizedBox(height: gap),
                row([
                  digit('radix-key-1', '1', enabled: enabledDigit('1')),
                  digit('radix-key-2', '2', enabled: enabledDigit('2')),
                  digit('radix-key-3', '3', enabled: enabledDigit('3')),
                  digit('radix-key-B', 'B', enabled: enabledDigit('B')),
                ]),
                const SizedBox(height: gap),
                row([
                  digit('radix-key-00', '00', enabled: enabledDigit('0')),
                  digit('radix-key-0', '0', enabled: enabledDigit('0')),
                  digit('radix-key-dot', '.', enabled: false),
                  digit('radix-key-A', 'A', enabled: enabledDigit('A')),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}
