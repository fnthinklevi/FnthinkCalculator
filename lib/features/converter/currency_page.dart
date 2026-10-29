import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/tokens.dart';
import '../../widgets/numeric_keypad.dart';
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

  void _onNumericKey(String key) {
    _controller.setInput(
      applyNumericKey(
        _controller.input,
        key,
        allowDecimal: true,
        allowNegative: false,
      ),
    );
  }

  Future<void> _copy() async {
    final text = _controller.copyText;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('已复制')));
  }

  Future<void> _pickCurrency({required bool isFrom}) async {
    final current = isFrom ? _controller.from : _controller.to;
    bool available(CurrencyDef currency) {
      return !_controller.hasRates || _controller.supports(currency.code);
    }

    final selected = await showModalBottomSheet<CurrencyDef>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
                child: Row(
                  children: [
                    const Text(
                      '选择币种',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('取消'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  children: [
                    const _SheetSection(title: '常用'),
                    for (final currency in CurrencyData.common)
                      if (available(currency))
                        _currencyTile(sheetContext, currency, current),
                    const _SheetSection(title: '其他币种'),
                    for (final currency in CurrencyData.all)
                      if (!CurrencyData.commonCodes.contains(currency.code) &&
                          available(currency))
                        _currencyTile(sheetContext, currency, current),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    if (isFrom) {
      _controller.setFrom(selected);
    } else {
      _controller.setTo(selected);
    }
  }

  Widget _currencyTile(
    BuildContext sheetContext,
    CurrencyDef currency,
    CurrencyDef current,
  ) {
    return ListTile(
      key: Key('currency-option-${currency.code}'),
      title: Text('${currency.name}  ${currency.code}'),
      subtitle: currency.symbol == currency.code ? null : Text(currency.symbol),
      trailing: current.code == currency.code
          ? const Icon(Icons.check, color: CalcColors.orange, size: 20)
          : null,
      onTap: () => Navigator.of(sheetContext).pop(currency),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          key: const Key('currency-page'),
          appBar: AppBar(
            title: const Text('汇率换算'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    children: [
                      _amountCard(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Center(
                          child: IconButton.filled(
                            key: const Key('currency-swap'),
                            tooltip: '交换币种',
                            onPressed: _controller.swap,
                            style: IconButton.styleFrom(
                              backgroundColor: CalcColors.orange,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(40, 40),
                              padding: const EdgeInsets.all(8),
                            ),
                            iconSize: 20,
                            icon: const Icon(Icons.swap_vert),
                          ),
                        ),
                      ),
                      _resultCard(context),
                      const SizedBox(height: 12),
                      Text(
                        '汇率来自公开接口，仅供参考，不构成交易依据。首次使用需联网，之后可离线查看最近一次缓存。',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: CalcColors.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                NumericKeypad(
                  onKey: _onNumericKey,
                  allowDecimal: true,
                  allowNegative: false,
                  height: 260,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _amountCard(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: CalcColors.keyBackground(context),
        borderRadius: BorderRadius.circular(CalcRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('从', style: TextStyle(fontSize: 13, color: secondary)),
              const Spacer(),
              Flexible(
                child: _CurrencyPickerField(
                  key: const Key('currency-from-picker'),
                  currency: _controller.from,
                  onTap: () => _pickCurrency(isFrom: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _controller.input.isEmpty ? '0' : _controller.input,
              key: const Key('currency-input'),
              maxLines: 1,
              style: const TextStyle(
                fontSize: 34,
                fontFeatures: CalcText.tabular,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultCard(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    final result = _controller.result;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: CalcColors.keyBackground(context),
        borderRadius: BorderRadius.circular(CalcRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('到', style: TextStyle(fontSize: 13, color: secondary)),
              const Spacer(),
              Flexible(
                child: _CurrencyPickerField(
                  key: const Key('currency-to-picker'),
                  currency: _controller.to,
                  onTap: () => _pickCurrency(isFrom: false),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                key: const Key('currency-refresh'),
                tooltip: '刷新汇率',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                onPressed: _controller.loading ? null : _controller.refresh,
                icon: _controller.loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.refresh, size: 18, color: secondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    result == null
                        ? '—'
                        : '${_controller.resultApproximate ? '≈ ' : ''}${result.text}',
                    key: const Key('currency-result'),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 34,
                      fontFeatures: CalcText.tabular,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _controller.to.code,
                style: TextStyle(fontSize: 14, color: secondary),
              ),
              IconButton(
                key: const Key('currency-copy'),
                tooltip: '复制结果',
                onPressed: result == null ? null : _copy,
                icon: Icon(Icons.copy_outlined, size: 18, color: secondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _controller.unitRateText,
            key: const Key('currency-rate-line'),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12, color: secondary),
          ),
          const SizedBox(height: 2),
          Text(
            _controller.statusText,
            key: const Key('currency-status'),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: _controller.hasError ? CalcColors.error : secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyPickerField extends StatelessWidget {
  const _CurrencyPickerField({
    super.key,
    required this.currency,
    required this.onTap,
  });

  final CurrencyDef currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Semantics(
      button: true,
      label: '选择币种 ${currency.name}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: CalcColors.divider(context)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  '${currency.name} (${currency.code})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_more, size: 18, color: secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  const _SheetSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: CalcColors.secondaryText(context),
        ),
      ),
    );
  }
}
