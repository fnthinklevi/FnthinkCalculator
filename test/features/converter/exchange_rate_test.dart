import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/math/rational.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:fnthink_calculator/features/converter/currency_controller.dart';
import 'package:fnthink_calculator/features/converter/currency_data.dart';
import 'package:fnthink_calculator/features/converter/exchange_rate_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

ExchangeRates fixture({DateTime? fetchedAt}) {
  return ExchangeRates(
    rates: {
      'CNY': BigRational.one,
      'USD': BigRational.parse('0.125'),
      'EUR': BigRational.parse('0.25'),
      'JPY': BigRational.parse('20'),
    },
    updatedAt: DateTime(2026, 10, 29, 8, 0),
    fetchedAt: fetchedAt ?? DateTime.now(),
    source: 'test',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('接口解析', () {
    test('open.er-api 成功响应解析并过滤未知币种', () {
      final rates = parseOpenErApi({
        'result': 'success',
        'base_code': 'CNY',
        'time_last_update_unix': 1761724800,
        'rates': {'USD': 0.14, 'EUR': 0.12, 'XXX': 5, 'CNY': 1},
      }, fetchedAt: DateTime.utc(2026, 10, 29, 9));

      expect(rates.rateFor('USD'), BigRational.parse('0.14'));
      expect(rates.rateFor('EUR'), BigRational.parse('0.12'));
      expect(rates.rateFor('XXX'), isNull);
      expect(rates.rateFor('CNY'), BigRational.one);
      expect(rates.source, 'open.er-api.com');
      expect(rates.updatedAt, isNot(DateTime.utc(2026, 10, 29, 9)));
    });

    test('open.er-api 失败状态抛错', () {
      expect(
        () => parseOpenErApi({
          'result': 'error',
          'base_code': 'CNY',
          'rates': {'USD': 1},
        }, fetchedAt: DateTime.utc(2026)),
        throwsA(isA<ExchangeRateException>()),
      );
    });

    test('frankfurter 解析日期与汇率', () {
      final rates = parseFrankfurter({
        'base': 'CNY',
        'date': '2026-10-28',
        'rates': {'USD': 0.14, 'JPY': 21.5},
      }, fetchedAt: DateTime.now());

      expect(rates.rateFor('USD'), BigRational.parse('0.14'));
      expect(rates.rateFor('JPY'), BigRational.parse('21.5'));
      expect(rates.updatedAt.year, 2026);
      expect(rates.updatedAt.month, 10);
      expect(rates.updatedAt.day, 28);
      expect(rates.source, 'frankfurter.dev');
    });

    test('空汇率表抛错', () {
      expect(
        () => parseFrankfurter({
          'base': 'CNY',
          'date': '2026-10-28',
          'rates': {'XXX': 1},
        }, fetchedAt: DateTime.now()),
        throwsA(isA<ExchangeRateException>()),
      );
    });

    test('主接口失败时回退到备用接口', () async {
      final client = MockClient((request) async {
        if (request.url.host == 'open.er-api.com') {
          return http.Response('unavailable', 503);
        }
        return http.Response(
          jsonEncode({
            'base': 'CNY',
            'date': '2026-10-28',
            'rates': {'USD': 0.14},
          }),
          200,
        );
      });
      final rates = await fetchExchangeRatesFromNetwork(client: client);
      expect(rates.source, 'frankfurter.dev');
      expect(rates.rateFor('USD'), BigRational.parse('0.14'));
    });

    test('两个接口都失败时抛错', () async {
      final client = MockClient((request) async {
        return http.Response('unavailable', 500);
      });
      expect(
        () => fetchExchangeRatesFromNetwork(client: client),
        throwsA(isA<ExchangeRateException>()),
      );
    });
  });

  group('缓存', () {
    test('刷新后写入缓存并可读回', () async {
      final prefs = await SharedPreferences.getInstance();
      final repository = ExchangeRateRepository(
        preferences: prefs,
        loader: () async => fixture(),
      );
      await repository.refresh();

      final cached = await ExchangeRateRepository(preferences: prefs)
          .loadCache();
      expect(cached, isNotNull);
      expect(cached!.rateFor('USD'), BigRational.parse('0.125'));
      expect(cached.rateFor('CNY'), BigRational.one);
      expect(cached.source, 'test');
    });

    test('缓存损坏返回空', () async {
      SharedPreferences.setMockInitialValues({
        ExchangeRateRepository.cacheKey: '{"base":"CNY","rates":{"USD":"1/0"}}',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(
        await ExchangeRateRepository(preferences: prefs).loadCache(),
        isNull,
      );

      await prefs.setString(ExchangeRateRepository.cacheKey, 'not-json');
      expect(
        await ExchangeRateRepository(preferences: prefs).loadCache(),
        isNull,
      );
    });

    test('缓存序列化保留精确分数', () async {
      final prefs = await SharedPreferences.getInstance();
      final repository = ExchangeRateRepository(
        preferences: prefs,
        loader: () async => fixture(),
      );
      await repository.refresh();
      final raw = prefs.getString(ExchangeRateRepository.cacheKey)!;
      expect(raw, contains('1/8'));
      expect(raw, contains('USD'));
      expect(jsonDecode(raw), isA<Map<String, dynamic>>());
    });
  });

  group('控制器', () {
    test('换算、交换与汇率说明', () async {
      final controller = CurrencyController(
        repository: ExchangeRateRepository(loader: () async => fixture()),
      );
      await controller.initialize();

      expect(controller.hasRates, isTrue);
      expect(controller.usingCache, isFalse);
      expect(controller.resultText, '0.125');
      expect(controller.unitRateText, '1 CNY = 0.125 USD');

      controller.setInput('100');
      expect(controller.resultText, '12.5');

      controller.swap();
      expect(controller.from.code, 'USD');
      expect(controller.to.code, 'CNY');
      expect(controller.resultText, '800');

      controller.setTo(CurrencyData.eur);
      expect(controller.resultText, '200');

      controller.setFrom(CurrencyData.jpy);
      controller.setTo(CurrencyData.usd);
      controller.setInput('20');
      expect(controller.resultText, '0.125');
      controller.dispose();
    });

    test('非整数汇率使用约等号', () async {
      final controller = CurrencyController(
        repository: ExchangeRateRepository(
          loader: () async => ExchangeRates(
            rates: {
              'CNY': BigRational.one,
              'USD': BigRational.parse('0.14969'),
            },
            updatedAt: DateTime(2026, 10, 29, 8),
            fetchedAt: DateTime.now(),
            source: 'test',
          ),
        ),
      );
      await controller.initialize();
      controller.swap();
      expect(controller.unitRateText, '1 USD ≈ 6.680473 CNY');
      controller.dispose();
    });

    test('缺失币种时结果为空并提示', () async {
      final controller = CurrencyController(
        repository: ExchangeRateRepository(loader: () async => fixture()),
      );
      await controller.initialize();
      controller.setTo(CurrencyData.twd);
      expect(controller.pairSupported, isFalse);
      expect(controller.result, isNull);
      expect(controller.unitRateText, contains('暂不包含'));
      controller.dispose();
    });

    test('新鲜缓存直接可用且不发起网络请求', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        ExchangeRateRepository.cacheKey,
        jsonEncode(fixture().toJson()),
      );
      var calls = 0;
      final controller = CurrencyController(
        repository: ExchangeRateRepository(
          preferences: prefs,
          loader: () async {
            calls++;
            return fixture();
          },
        ),
      );
      await controller.initialize();

      expect(calls, 0);
      expect(controller.usingCache, isTrue);
      expect(controller.statusText, contains('缓存数据'));
      expect(controller.resultText, '0.125');
      controller.dispose();
    });

    test('过期缓存刷新失败仍可换算并提示离线', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        ExchangeRateRepository.cacheKey,
        jsonEncode(
          fixture(fetchedAt: DateTime.now().subtract(const Duration(days: 2)))
              .toJson(),
        ),
      );
      final controller = CurrencyController(
        repository: ExchangeRateRepository(
          preferences: prefs,
          loader: () async => throw const ExchangeRateException('offline'),
        ),
      );
      await controller.initialize();

      expect(controller.hasRates, isTrue);
      expect(controller.failure, isNotNull);
      expect(controller.statusText, contains('网络不可用'));
      expect(controller.resultText, '0.125');
      controller.dispose();
    });

    test('初始化未完成即销毁不抛异常', () async {
      final completer = Completer<ExchangeRates>();
      final controller = CurrencyController(
        repository: ExchangeRateRepository(loader: () => completer.future),
      );
      final pending = controller.initialize();
      controller.dispose();
      completer.complete(fixture());
      await pending;
    });

    test('无缓存且网络失败后可重试', () async {
      var fail = true;
      final controller = CurrencyController(
        repository: ExchangeRateRepository(
          loader: () async {
            if (fail) throw const ExchangeRateException('offline');
            return fixture();
          },
        ),
      );
      await controller.initialize();

      expect(controller.hasError, isTrue);
      expect(controller.result, isNull);
      expect(controller.statusText, contains('获取汇率失败'));

      fail = false;
      await controller.refresh();
      expect(controller.hasError, isFalse);
      expect(controller.resultText, '0.125');
      controller.dispose();
    });
  });
}
