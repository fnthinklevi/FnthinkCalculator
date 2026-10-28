import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_scope.dart';
import '../features/calculator/widgets/calc_keypad.dart';
import '../theme/tokens.dart';

String applyNumericKey(
  String current,
  String key, {
  required bool allowDecimal,
  required bool allowNegative,
}) {
  if (key == 'clear') {
    return '';
  }
  if (key == 'backspace') {
    if (current.isEmpty) return '';
    final next = current.substring(0, current.length - 1);
    return next == '-' ? '' : next;
  }
  if (key == 'sign') {
    if (!allowNegative) return current;
    if (current.isEmpty) return '-0';
    if (current.startsWith('-')) return current.substring(1);
    return '-$current';
  }
  if (key == '.') {
    if (!allowDecimal || current.contains('.')) return current;
    if (current.isEmpty) return '0.';
    if (current == '-') return '-0.';
    return '$current.';
  }
  if (key == '00') {
    return _appendDigits(current, '00');
  }
  if (key.length == 1) {
    final code = key.codeUnitAt(0);
    if (code >= 48 && code <= 57) {
      return _appendDigits(current, key);
    }
  }
  return current;
}

String _appendDigits(String current, String digits) {
  final negative = current.startsWith('-');
  var body = negative ? current.substring(1) : current;
  final digitCount = body.replaceAll('.', '').length;
  if (digitCount >= 15) return current;
  if (body.isEmpty) {
    body = digits == '00' ? '0' : digits;
  } else if (body == '0') {
    body = (digits == '0' || digits == '00') ? '0' : digits;
  } else {
    body += digits;
  }
  return '${negative ? '-' : ''}$body';
}

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onKey,
    this.allowDecimal = true,
    this.allowNegative = true,
    this.showDone = false,
    this.onDone,
    this.height = 300,
  });

  final ValueChanged<String> onKey;
  final bool allowDecimal;
  final bool allowNegative;
  final bool showDone;
  final VoidCallback? onDone;
  final double height;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.maybeOf(context);
    void press(String key) {
      if (settings?.haptics ?? true) {
        HapticFeedback.lightImpact();
      }
      onKey(key);
    }

    Widget key({
      required String id,
      required String label,
      required String semantic,
      IconData? icon,
      bool operator = false,
      bool equals = false,
      bool enabled = true,
      required VoidCallback onTap,
    }) {
      return CalcKey(
        keyId: id,
        semanticLabel: semantic,
        label: label,
        icon: icon,
        isOperator: operator,
        isEquals: equals,
        enabled: enabled,
        onPressed: onTap,
      );
    }

    Widget row(List<Widget> keys) {
      final children = <Widget>[];
      for (var index = 0; index < keys.length; index++) {
        children.add(Expanded(child: keys[index]));
        if (index != keys.length - 1) {
          children.add(const SizedBox(width: CalcSpacing.keyGap));
        }
      }
      return Expanded(child: Row(children: children));
    }

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          children: [
            row([
              key(
                id: 'numeric-key-7',
                label: '7',
                semantic: '7',
                onTap: () => press('7'),
              ),
              key(
                id: 'numeric-key-8',
                label: '8',
                semantic: '8',
                onTap: () => press('8'),
              ),
              key(
                id: 'numeric-key-9',
                label: '9',
                semantic: '9',
                onTap: () => press('9'),
              ),
              key(
                id: 'numeric-key-backspace',
                label: '',
                semantic: '退格',
                icon: Icons.backspace_outlined,
                operator: true,
                onTap: () => press('backspace'),
              ),
            ]),
            const SizedBox(height: CalcSpacing.keyGap),
            row([
              key(
                id: 'numeric-key-4',
                label: '4',
                semantic: '4',
                onTap: () => press('4'),
              ),
              key(
                id: 'numeric-key-5',
                label: '5',
                semantic: '5',
                onTap: () => press('5'),
              ),
              key(
                id: 'numeric-key-6',
                label: '6',
                semantic: '6',
                onTap: () => press('6'),
              ),
              key(
                id: 'numeric-key-clear',
                label: 'C',
                semantic: '清空',
                operator: true,
                onTap: () => press('clear'),
              ),
            ]),
            const SizedBox(height: CalcSpacing.keyGap),
            row([
              key(
                id: 'numeric-key-1',
                label: '1',
                semantic: '1',
                onTap: () => press('1'),
              ),
              key(
                id: 'numeric-key-2',
                label: '2',
                semantic: '2',
                onTap: () => press('2'),
              ),
              key(
                id: 'numeric-key-3',
                label: '3',
                semantic: '3',
                onTap: () => press('3'),
              ),
              key(
                id: 'numeric-key-sign',
                label: '±',
                semantic: '正负号',
                operator: true,
                enabled: allowNegative,
                onTap: () => press('sign'),
              ),
            ]),
            const SizedBox(height: CalcSpacing.keyGap),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: key(
                      id: 'numeric-key-0',
                      label: '0',
                      semantic: '0',
                      onTap: () => press('0'),
                    ),
                  ),
                  const SizedBox(width: CalcSpacing.keyGap),
                  Expanded(
                    child: key(
                      id: 'numeric-key-dot',
                      label: '.',
                      semantic: '小数点',
                      enabled: allowDecimal,
                      onTap: () => press('.'),
                    ),
                  ),
                  const SizedBox(width: CalcSpacing.keyGap),
                  Expanded(
                    child: showDone
                        ? key(
                            id: 'numeric-key-done',
                            label: '',
                            semantic: '完成',
                            icon: Icons.check,
                            equals: true,
                            onTap: onDone ?? () {},
                          )
                        : key(
                            id: 'numeric-key-00',
                            label: '00',
                            semantic: '双零',
                            onTap: () => press('00'),
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

Future<String?> showNumericKeypad(
  BuildContext context, {
  required String initial,
  required String title,
  bool allowDecimal = true,
  bool allowNegative = true,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: CalcColors.displayBackground(context),
    builder: (context) {
      return _NumericKeypadSheet(
        initial: initial,
        title: title,
        allowDecimal: allowDecimal,
        allowNegative: allowNegative,
      );
    },
  );
}

class _NumericKeypadSheet extends StatefulWidget {
  const _NumericKeypadSheet({
    required this.initial,
    required this.title,
    required this.allowDecimal,
    required this.allowNegative,
  });

  final String initial;
  final String title;
  final bool allowDecimal;
  final bool allowNegative;

  @override
  State<_NumericKeypadSheet> createState() => _NumericKeypadSheetState();
}

class _NumericKeypadSheetState extends State<_NumericKeypadSheet> {
  late String _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: CalcColors.keyBackground(context),
                borderRadius: BorderRadius.circular(CalcRadius.card),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _value.isEmpty ? '0' : _value,
                  key: const Key('numeric-sheet-display'),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                    fontFeatures: CalcText.tabular,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.allowDecimal ? '支持小数与正负号' : '仅支持非负整数',
              style: TextStyle(fontSize: 12, color: secondary),
            ),
            NumericKeypad(
              height: 300,
              allowDecimal: widget.allowDecimal,
              allowNegative: widget.allowNegative,
              showDone: true,
              onKey: (key) {
                setState(() {
                  _value = applyNumericKey(
                    _value,
                    key,
                    allowDecimal: widget.allowDecimal,
                    allowNegative: widget.allowNegative,
                  );
                });
              },
              onDone: () => Navigator.of(context).pop(_value),
            ),
          ],
        ),
      ),
    );
  }
}
