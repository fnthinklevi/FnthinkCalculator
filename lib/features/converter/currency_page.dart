import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/anchored_picker.dart';
import '../../widgets/numeric_keypad.dart';
import '../../widgets/page_header.dart';
import '../../widgets/round_keypads.dart';
import 'currency_controller.dart';
import 'currency_data.dart';
import 'exchange_rate_repository.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key, this.repository});

  final ExchangeRateRepository? repository;

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  late final CurrencyController _controller;
  final List<GlobalKey> _pickerKeys = [GlobalKey(), GlobalKey(), GlobalKey()];

  @override
  void initState() {
    super.initState();
    _controller = CurrencyController(
      repository: widget.repository ?? ExchangeRateRepository(),
    );
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onKey(String key) {
    switch (key) {
      case 'clear':
        _controller.setInput('');
        return;
      case 'backspace':
        final text = _controller.input;
        if (text.isNotEmpty) {
          _controller.setInput(text.substring(0, text.length - 1));
        }
        return;
      case 'sign':
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
        allowNegative: false,
      ),
    );
  }

  Future<void> _pickCurrency(int index) async {
    final selected = await showAnchoredPicker<CurrencyDef>(
      context: context,
      anchorKey: _pickerKeys[index],
      items: [
        for (final currency in CurrencyData.all)
          if (!_controller.hasRates || _controller.supports(currency.code))
            AnchoredPickerItem(
              id: currency.code,
              title: currency.name,
              subtitle: currency.code,
              value: currency,
            ),
      ],
      selected: _controller.rows[index],
      keyPrefix: 'currency-option',
    );
    if (selected == null || !mounted) return;
    _controller.setCurrency(index, selected);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          key: const Key('currency-page'),
          backgroundColor: CalcColors.displayBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                PageHeader(
                  title: '汇率转换',
                  titleKey: const Key('currency-title'),
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      for (
                        var index = 0;
                        index < _controller.rows.length;
                        index++
                      )
                        Padding(
                          padding: const EdgeInsets.only(bottom: 22),
                          child: _CurrencyRow(
                            key: Key('currency-row-$index'),
                            pickerKey: _pickerKeys[index],
                            pickerTestKey: Key('currency-picker-$index'),
                            currency: _controller.rows[index],
                            value: _controller.valueText(index),
                            active: _controller.activeIndex == index,
                            valueKey: Key('currency-value-$index'),
                            onTap: () => _controller.setActive(index),
                            onPick: () => _pickCurrency(index),
                          ),
                        ),
                      const Spacer(),
                      _SourceLine(controller: _controller),
                      const SizedBox(height: 8),
                      ConverterKeypad(onKey: _onKey),
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

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    super.key,
    required this.pickerKey,
    required this.pickerTestKey,
    required this.currency,
    required this.value,
    required this.active,
    required this.valueKey,
    required this.onTap,
    required this.onPick,
  });

  final GlobalKey pickerKey;
  final Key pickerTestKey;
  final CurrencyDef currency;
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
              key: pickerTestKey,
              child: GestureDetector(
                key: pickerKey,
                behavior: HitTestBehavior.opaque,
                onTap: onPick,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currency.name,
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      currency.code,
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

class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.controller});

  final CurrencyController controller;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    final suffix = controller.statusSuffix;
    final hasError = controller.hasError;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        key: const Key('currency-status-tap'),
        behavior: HitTestBehavior.opaque,
        onTap: controller.refresh,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: controller.sourceLine,
                style: TextStyle(
                  fontSize: 15,
                  color: hasError ? CalcColors.error : secondary,
                ),
              ),
              if (suffix != null)
                TextSpan(
                  text: '，$suffix',
                  style: const TextStyle(
                    fontSize: 15,
                    color: CalcColors.orange,
                  ),
                ),
            ],
          ),
          key: const Key('currency-status'),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
