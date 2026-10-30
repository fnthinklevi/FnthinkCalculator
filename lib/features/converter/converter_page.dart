import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/anchored_picker.dart';
import '../../widgets/numeric_keypad.dart';
import '../../widgets/round_keypads.dart';
import '../../widgets/page_header.dart';
import 'converter_controller.dart';
import 'unit_data.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key, required this.category});

  final UnitCategory category;

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  late final ConverterController _controller;
  final _fromUnitKey = GlobalKey();
  final _toUnitKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = ConverterController(widget.category);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onKey(String key) {
    switch (key) {
      case 'clear':
        _controller.clear();
        return;
      case 'backspace':
        _controller.backspace();
        return;
      case 'sign':
        _controller.toggleSign();
        return;
      case 'equals':
        _controller.commit();
        return;
      case '+':
      case '−':
      case '×':
      case '÷':
        _controller.appendOperator(key);
        return;
    }
    if (_controller.replaceOnNextInput) {
      if (key == '.') {
        _controller.setInput('0.');
        _controller.consumeFreshInput();
        return;
      }
      if (key == '00') {
        _controller.setInput('0');
        _controller.consumeFreshInput();
        return;
      }
      if (RegExp(r'^[0-9]$').hasMatch(key)) {
        _controller.setInput(key);
        _controller.consumeFreshInput();
        return;
      }
    }
    _controller.setInput(
      applyNumericKey(
        _controller.input,
        key,
        allowDecimal: true,
        allowNegative: true,
      ),
    );
  }

  Future<void> _pickUnit({required bool isFrom}) async {
    final anchor = isFrom ? _fromUnitKey : _toUnitKey;
    final current = isFrom ? _controller.from : _controller.to;
    final selected = await showAnchoredPicker<UnitDef>(
      context: context,
      anchorKey: anchor,
      items: [
        for (final unit in widget.category.units)
          AnchoredPickerItem(
            id: unit.id,
            title: unit.name,
            subtitle: unit.symbol,
            value: unit,
          ),
      ],
      selected: current,
      keyPrefix: 'unit-option',
    );
    if (selected == null || !mounted) return;
    if (isFrom) {
      _controller.setFrom(selected);
    } else {
      _controller.setTo(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          key: const Key('converter-detail-page'),
          backgroundColor: CalcColors.displayBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                PageHeader(
                  title: '${widget.category.name}转换',
                  titleKey: const Key('converter-title'),
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _ValueRow(
                        key: const Key('converter-from-row'),
                        unitKey: _fromUnitKey,
                        pickerKey: const Key('unit-from-picker'),
                        unit: _controller.from,
                        value: _controller.fromText,
                        active: _controller.fromActive,
                        valueKey: _controller.fromActive
                            ? const Key('converter-input')
                            : const Key('converter-result'),
                        onTap: () => _controller.setActive(from: true),
                        onPick: () => _pickUnit(isFrom: true),
                      ),
                      const SizedBox(height: 22),
                      _ValueRow(
                        key: const Key('converter-to-row'),
                        unitKey: _toUnitKey,
                        pickerKey: const Key('unit-to-picker'),
                        unit: _controller.to,
                        value: _controller.toText,
                        active: !_controller.fromActive,
                        valueKey: _controller.fromActive
                            ? const Key('converter-result')
                            : const Key('converter-input'),
                        onTap: () => _controller.setActive(from: false),
                        onPick: () => _pickUnit(isFrom: false),
                      ),
                      if (_controller.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _controller.error!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: CalcColors.error,
                            ),
                          ),
                        ),
                      if (widget.category.note != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            widget.category.note!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: secondary),
                          ),
                        ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: widget.category.id == 'temperature'
                              ? TemperatureKeypad(onKey: _onKey)
                              : ConverterKeypad(onKey: _onKey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    super.key,
    required this.unitKey,
    required this.pickerKey,
    required this.unit,
    required this.value,
    required this.active,
    required this.valueKey,
    required this.onTap,
    required this.onPick,
  });

  final GlobalKey unitKey;
  final Key pickerKey;
  final UnitDef unit;
  final String value;
  final bool active;
  final Key valueKey;
  final VoidCallback onTap;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    final valueColor = active
        ? CalcColors.orange
        : Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: Row(
          children: [
            KeyedSubtree(
              key: pickerKey,
              child: GestureDetector(
                key: unitKey,
                behavior: HitTestBehavior.opaque,
                onTap: onPick,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      unit.name,
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      unit.symbol,
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
                  value.isEmpty ? '0' : value,
                  key: valueKey,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 28,
                    color: valueColor,
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
