import 'package:flutter/foundation.dart';

import '../../core/math/calc_value.dart';
import '../../core/math/formatter.dart';
import '../../core/math/math_error.dart';
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

  CurrencyDef from = CurrencyData.cny;
  CurrencyDef to = CurrencyData.usd;
  String input = '1';

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

  bool supports(String code) {
    final rates = _rates;
    if (rates == null) return code == 'CNY';
    return rates.rateFor(code) != null;
  }

  bool get pairSupported {
    final rates = _rates;
    if (rates == null) return false;
    final fromRate = rates.rateFor(from.code);
    final toRate = rates.rateFor(to.code);
    return fromRate != null && !fromRate.isZero && toRate != null;
  }

  FormattedNumber? get result {
    final rates = _rates;
    if (rates == null) return null;
    BigRational? amount;
    try {
      amount = BigRational.tryParse(input.trim());
    } on MathException {
      return null;
    }
    if (amount == null) return null;
    final fromRate = rates.rateFor(from.code);
    final toRate = rates.rateFor(to.code);
    if (fromRate == null || fromRate.isZero || toRate == null) return null;
    return const NumberFormatter().format(
      RationalValue(amount / fromRate * toRate),
    );
  }

  String get resultText => result?.text ?? '';

  bool get resultApproximate => result?.approximate ?? false;

  String get copyText => result?.rawText ?? '';

  String get unitRateText {
    final rates = _rates;
    if (rates == null) return '—';
    final fromRate = rates.rateFor(from.code);
    final toRate = rates.rateFor(to.code);
    if (fromRate == null || fromRate.isZero || toRate == null) {
      return '当前数据暂不包含 ${from.code} 或 ${to.code}';
    }
    final value = const NumberFormatter(significantDigits: 8)
        .format(RationalValue(toRate / fromRate));
    final separator = value.approximate ? '≈' : '=';
    return '1 ${from.code} $separator ${value.text} ${to.code}';
  }

  String get statusText {
    final rates = _rates;
    if (rates == null) {
      if (_loading) return '正在获取汇率…';
      return _failure ?? '暂无汇率数据';
    }
    final stamp = _formatStamp(rates.updatedAt);
    if (_loading) return '正在刷新汇率…';
    if (_failure != null) return '网络不可用，使用缓存（更新于 $stamp）';
    if (_fromCache) return '缓存数据 · 更新于 $stamp';
    return '已更新 · $stamp · ${rates.source}';
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

  void setInput(String value) {
    if (input == value) return;
    input = value;
    _notify();
  }

  void setFrom(CurrencyDef currency) {
    if (from.code == currency.code) return;
    from = currency;
    _notify();
  }

  void setTo(CurrencyDef currency) {
    if (to.code == currency.code) return;
    to = currency;
    _notify();
  }

  void swap() {
    final previous = from;
    from = to;
    to = previous;
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

String _formatStamp(DateTime value) {
  final local = value.toLocal();
  String two(int part) => part.toString().padLeft(2, '0');
  return '${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}
