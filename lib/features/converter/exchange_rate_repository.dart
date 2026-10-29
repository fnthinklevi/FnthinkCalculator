import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/math/rational.dart';
import 'currency_data.dart';

class ExchangeRateException implements Exception {
  const ExchangeRateException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ExchangeRates {
  ExchangeRates({
    required Map<String, BigRational> rates,
    required this.updatedAt,
    required this.fetchedAt,
    required this.source,
  }) : rates = Map.unmodifiable(rates);

  final Map<String, BigRational> rates;
  final DateTime updatedAt;
  final DateTime fetchedAt;
  final String source;

  BigRational? rateFor(String code) => rates[code];

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'base': 'CNY',
      'source': source,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'fetchedAt': fetchedAt.toUtc().toIso8601String(),
      'rates': {
        for (final entry in rates.entries)
          entry.key: '${entry.value.n}/${entry.value.d}',
      },
    };
  }

  static ExchangeRates? tryFromJson(Object? json) {
    if (json is! Map) return null;
    if (json['base'] != 'CNY') return null;
    final rawRates = json['rates'];
    if (rawRates is! Map) return null;
    final rates = <String, BigRational>{};
    var foreignCount = 0;
    for (final entry in rawRates.entries) {
      final code = entry.key;
      if (code is! String) continue;
      if (code != 'CNY' && CurrencyData.byCode[code] == null) continue;
      final value = _parseRatio(entry.value);
      if (value == null || value.isNegative || value.isZero) continue;
      rates[code] = value;
      if (code != 'CNY') foreignCount++;
    }
    if (foreignCount == 0) return null;
    rates['CNY'] = BigRational.one;

    final updatedRaw = json['updatedAt'];
    final fetchedRaw = json['fetchedAt'];
    final updatedAt = updatedRaw is String
        ? DateTime.tryParse(updatedRaw)
        : null;
    final fetchedAt = fetchedRaw is String
        ? DateTime.tryParse(fetchedRaw)
        : null;
    final source = json['source'];
    return ExchangeRates(
      rates: rates,
      updatedAt: updatedAt ?? fetchedAt ?? DateTime.now(),
      fetchedAt: fetchedAt ?? updatedAt ?? DateTime.now(),
      source: source is String && source.isNotEmpty ? source : 'cache',
    );
  }
}

BigRational? _parseRatio(Object? value) {
  if (value is String) {
    final parts = value.split('/');
    if (parts.length == 2) {
      final numerator = BigInt.tryParse(parts[0]);
      final denominator = BigInt.tryParse(parts[1]);
      if (numerator == null ||
          denominator == null ||
          denominator == BigInt.zero) {
        return null;
      }
      return BigRational(numerator, denominator);
    }
  }
  if (value is num) {
    if (!value.isFinite) return null;
    return BigRational.tryParse(value.toString());
  }
  return null;
}

ExchangeRates _collectRates(
  Map rawRates, {
  required DateTime updatedAt,
  required DateTime fetchedAt,
  required String source,
}) {
  final rates = <String, BigRational>{};
  var foreignCount = 0;
  for (final entry in rawRates.entries) {
    final code = entry.key;
    if (code is! String) continue;
    if (code != 'CNY' && CurrencyData.byCode[code] == null) continue;
    final value = _parseRatio(entry.value);
    if (value == null || value.isNegative || value.isZero) continue;
    rates[code] = value;
    if (code != 'CNY') foreignCount++;
  }
  if (foreignCount == 0) {
    throw const ExchangeRateException('汇率数据为空');
  }
  rates['CNY'] = BigRational.one;
  return ExchangeRates(
    rates: rates,
    updatedAt: updatedAt,
    fetchedAt: fetchedAt,
    source: source,
  );
}

ExchangeRates parseOpenErApi(
  Map<String, dynamic> json, {
  required DateTime fetchedAt,
}) {
  if (json['result'] != 'success' || json['base_code'] != 'CNY') {
    throw const ExchangeRateException('汇率接口返回异常');
  }
  final rawRates = json['rates'];
  if (rawRates is! Map) {
    throw const ExchangeRateException('汇率数据缺失');
  }
  final unix = json['time_last_update_unix'];
  final updatedAt = unix is num
      ? DateTime.fromMillisecondsSinceEpoch((unix * 1000).round(), isUtc: true)
      : fetchedAt.toUtc();
  return _collectRates(
    rawRates,
    updatedAt: updatedAt,
    fetchedAt: fetchedAt,
    source: 'open.er-api.com',
  );
}

ExchangeRates parseFrankfurter(
  Map<String, dynamic> json, {
  required DateTime fetchedAt,
}) {
  if (json['base'] != 'CNY') {
    throw const ExchangeRateException('汇率接口返回异常');
  }
  final rawRates = json['rates'];
  if (rawRates is! Map) {
    throw const ExchangeRateException('汇率数据缺失');
  }
  final dateRaw = json['date'];
  final date = dateRaw is String ? DateTime.tryParse(dateRaw) : null;
  return _collectRates(
    rawRates,
    updatedAt: date ?? fetchedAt.toUtc(),
    fetchedAt: fetchedAt,
    source: 'frankfurter.dev',
  );
}

typedef ExchangeRateLoader = Future<ExchangeRates> Function();

Future<ExchangeRates> fetchExchangeRatesFromNetwork({
  http.Client? client,
}) async {
  final httpClient = client ?? http.Client();
  final ownsClient = client == null;
  final fetchedAt = DateTime.now().toUtc();
  Object? lastError;
  try {
    for (final endpoint in _endpoints) {
      try {
        return await endpoint(httpClient, fetchedAt);
      } on Object catch (error) {
        lastError = error;
      }
    }
    throw lastError is ExchangeRateException
        ? lastError
        : const ExchangeRateException('汇率接口不可用');
  } finally {
    if (ownsClient) {
      httpClient.close();
    }
  }
}

typedef _RateEndpoint = Future<ExchangeRates> Function(
  http.Client client,
  DateTime fetchedAt,
);

final List<_RateEndpoint> _endpoints = [
  (client, fetchedAt) async {
    final response = await client
        .get(
          Uri.https('open.er-api.com', '/v6/latest/CNY'),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw const ExchangeRateException('汇率接口不可用');
    }
    return parseOpenErApi(
      _decodeJsonObject(response.bodyBytes),
      fetchedAt: fetchedAt,
    );
  },
  (client, fetchedAt) async {
    final response = await client
        .get(
          Uri.https('api.frankfurter.dev', '/v1/latest', {'from': 'CNY'}),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw const ExchangeRateException('汇率接口不可用');
    }
    return parseFrankfurter(
      _decodeJsonObject(response.bodyBytes),
      fetchedAt: fetchedAt,
    );
  },
];

Map<String, dynamic> _decodeJsonObject(List<int> bytes) {
  final decoded = jsonDecode(utf8.decode(bytes));
  if (decoded is! Map) {
    throw const ExchangeRateException('汇率接口返回异常');
  }
  return Map<String, dynamic>.from(decoded);
}

class ExchangeRateRepository {
  factory ExchangeRateRepository({
    SharedPreferences? preferences,
    ExchangeRateLoader? loader,
  }) {
    return ExchangeRateRepository._(
      preferences,
      loader ?? fetchExchangeRatesFromNetwork,
    );
  }

  ExchangeRateRepository._(this._preferences, this._loader);

  static const cacheKey = 'fx.rates.v1';

  final SharedPreferences? _preferences;
  final ExchangeRateLoader _loader;
  bool _prefsUnavailable = false;

  Future<ExchangeRates?> loadCache() async {
    final prefs = await _prefs();
    if (prefs == null) return null;
    final raw = prefs.getString(cacheKey);
    if (raw == null) return null;
    try {
      return ExchangeRates.tryFromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  Future<ExchangeRates> refresh() async {
    final rates = await _loader();
    final prefs = await _prefs();
    if (prefs != null) {
      try {
        await prefs.setString(cacheKey, jsonEncode(rates.toJson()));
      } on Object {
        // Cache writes are best-effort; a failed write keeps the fresh rates.
      }
    }
    return rates;
  }

  Future<SharedPreferences?> _prefs() async {
    if (_preferences != null) return _preferences;
    if (_prefsUnavailable) return null;
    try {
      return await SharedPreferences.getInstance();
    } on Object {
      _prefsUnavailable = true;
      return null;
    }
  }
}
