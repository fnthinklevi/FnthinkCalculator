import 'package:flutter/foundation.dart';

import '../../core/math/calc_value.dart';
import '../../core/math/calculator_engine.dart';
import '../../core/math/percent_mode.dart';
import '../../core/math/formatter.dart';
import '../../core/math/rational.dart';
import 'currency_data.dart';
import 'exchange_rate_repository.dart';

class CurrencyController extends ChangeNotifier {
  factory CurrencyController({
    required ExchangeRateRepository repository,
    Duration staleAfter = const Duration(hours: 12),
  }) {
    return CurrencyController._(repository, staleAfter);
  }

  CurrencyController._(this._repository, this.staleAfter);

  final ExchangeRateRepository _repository;
  final Duration staleAfter;

  final List<CurrencyDef> rows = [
    CurrencyData.cny,
    CurrencyData.usd,
    CurrencyData.eur,
  ];
  int activeIndex = 0;
  String input = '1';
  bool replaceOnNextInput = false;

  ExchangeRates? _rates;
  bool _fromCache = false;
  bool _loading = false;
  bool _initialized = false;
  String? _failure;

  ExchangeRates? get rates => _rates;
  bool get loading => _loading;
  bool get hasRates => _rates != null;
  bool get usingCache => _fromCache && _rates != null;
  bool get hasError => _rates == null && !_loading && _failure != null;
  String? get failure => _failure;
  DateTime? get updatedAt => _rates?.updatedAt;
  String get source => _rates?.source ?? '';

  CurrencyDef get from => rows[0];
  CurrencyDef get to => rows[1];

  bool supports(String code) {
    final rates = _rates;
    if (rates == null) return code == 'CNY';
    return rates.rateFor(code) != null;
  }

  bool get pairSupported {
    final active = _rateOf(rows[activeIndex].code);
    if (active == null) return false;
    for (var index = 0; index < rows.length; index++) {
      if (index == activeIndex) continue;
      if (_rateOf(rows[index].code) == null) return false;
    }
    return true;
  }

  bool rowSupported(int index) {
    final rates = _rates;
    if (rates == null) return true;
    final rate = rates.rateFor(rows[index].code);
    return rate != null && !rate.isZero;
  }

  BigRational? _rateOf(String code) {
    final rates = _rates;
    if (rates == null) return null;
    final rate = rates.rateFor(code);
    if (rate == null || rate.isZero) return null;
    return rate;
  }

  BigRational? _amount() {
    final text = input.trim();
    if (text.isEmpty) return null;
    final direct = BigRational.tryParse(text);
    if (direct != null) return direct;
    final outcome = const CalculatorEngine().evaluate(
      text.replaceAll('−', '-'),
      percentMode: PercentMode.value,
    );
    if (!outcome.isSuccess) return null;
    return BigRational.tryParse(outcome.formatted!.rawText);
  }

  FormattedNumber? resultFor(int index) {
    if (index == activeIndex) return null;
    final amount = _amount();
    final fromRate = _rateOf(rows[activeIndex].code);
    final toRate = _rateOf(rows[index].code);
    if (amount == null || fromRate == null || toRate == null) return null;
    return const NumberFormatter().format(
      RationalValue(amount / fromRate * toRate),
    );
  }

  String valueText(int index) {
    if (index == activeIndex) return input;
    return resultFor(index)?.text ?? '—';
  }

  String rawValue(int index) {
    if (index == activeIndex) return input;
    return resultFor(index)?.rawText ?? '';
  }

  FormattedNumber? get result => resultFor(activeIndex == 0 ? 1 : 0);

  String get resultText => result?.text ?? '';

  bool get resultApproximate => result?.approximate ?? false;

  String get copyText => result?.rawText ?? '';

  String get unitRateText {
    final fromRate = _rateOf(rows[0].code);
    final toRate = _rateOf(rows[1].code);
    if (fromRate == null || toRate == null) {
      return '当前数据暂不包含 ${rows[0].code} 或 ${rows[1].code}';
    }
    final value = const NumberFormatter(significantDigits: 8)
        .format(RationalValue(toRate / fromRate));
    final separator = value.approximate ? '≈' : '=';
    return '1 ${rows[0].code} $separator ${value.text} ${rows[1].code}';
  }

  String get provider {
    final raw = _rates?.source ?? '';
    if (raw == 'open.er-api.com') return 'open.er-api';
    if (raw.contains('frankfurter')) return 'frankfurter';
    if (raw.isEmpty) return '公开接口';
    return raw;
  }

  String get updatedLabel {
    final value = _rates?.updatedAt;
    if (value == null) return '';
    final local = value.toLocal();
    return '${local.year}年${local.month}月${local.day}日';
  }

  String get sourceLine {
    final rates = _rates;
    if (rates == null) {
      if (_loading) return '汇率数据加载中';
      return _failure ?? '暂无汇率数据';
    }
    return '汇率数据由 $provider 提供，更新于 $updatedLabel';
  }

  String? get statusSuffix {
    if (_loading) return '正在更新数据';
    if (_rates != null && (_failure != null || _fromCache)) return '缓存数据';
    return null;
  }

  String get statusText {
    if (_rates == null) {
      if (_loading) return '正在获取汇率…';
      return _failure ?? '暂无汇率数据';
    }
    final stamp = updatedLabel;
    if (_loading) return '正在刷新汇率…';
    if (_failure != null) return '网络不可用，使用缓存（更新于 $stamp）';
    if (_fromCache) return '缓存数据 · 更新于 $stamp';
    return '已更新 · $stamp · $provider';
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  void appendOperator(String operator) {
    if (!const {'+', '−', '×', '÷'}.contains(operator)) return;
    if (input.isEmpty) {
      if (operator == '−') input = '-';
      _notify();
      return;
    }
    final last = input[input.length - 1];
    if ('+−×÷-'.contains(last)) {
      input = '${input.substring(0, input.length - 1)}$operator';
    } else if (last == '.') {
      input = '${input}0$operator';
    } else {
      input = '$input$operator';
    }
    _notify();
  }

  void commit() {
    final amount = _amount();
    if (amount == null) return;
    input = const NumberFormatter().format(RationalValue(amount)).rawText;
    _notify();
  }

  void setInput(String value) {
    if (input == value) return;
    input = value;
    _notify();
  }

  void setActive(int index) {
    if (index == activeIndex || index < 0 || index >= rows.length) return;
    input = rawValue(index);
    if (input.isEmpty) input = '';
    activeIndex = index;
    replaceOnNextInput = true;
    _notify();
  }

  void consumeFreshInput() {
    replaceOnNextInput = false;
  }

  void setCurrency(int index, CurrencyDef currency) {
    if (index < 0 || index >= rows.length) return;
    if (rows[index].code == currency.code) return;
    rows[index] = currency;
    _notify();
  }

  void setFrom(CurrencyDef currency) => setCurrency(0, currency);

  void setTo(CurrencyDef currency) => setCurrency(1, currency);

  void swap() {
    final previous = rows[0];
    rows[0] = rows[1];
    rows[1] = previous;
    _notify();
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _loading = true;
    _notify();

    ExchangeRates? cached;
    try {
      cached = await _repository.loadCache();
    } on Object {
      cached = null;
    }
    if (cached != null) {
      _rates = cached;
      _fromCache = true;
      _notify();
    }

    final fresh =
        cached != null &&
        DateTime.now().difference(cached.fetchedAt) <= staleAfter;
    if (fresh) {
      _loading = false;
      _notify();
      return;
    }
    await _refreshInternal();
  }

  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    _notify();
    await _refreshInternal();
  }

  Future<void> _refreshInternal() async {
    try {
      final fresh = await _repository.refresh();
      _rates = fresh;
      _fromCache = false;
      _failure = null;
    } on Object {
      _failure = '获取汇率失败，请检查网络后重试';
    } finally {
      _loading = false;
      _notify();
    }
  }
}
