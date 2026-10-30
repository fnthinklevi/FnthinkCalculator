import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/math/rational.dart';
import 'package:fnthink_calculator/features/converter/currency_page.dart';
import 'package:fnthink_calculator/features/converter/exchange_rate_repository.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';
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

Widget harness(ExchangeRateRepository repository) {
  return MaterialApp(
    locale: const Locale('zh', 'CN'),
    supportedLocales: const [Locale('zh', 'CN')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: buildAppTheme(Brightness.light),
    home: CurrencyConverterPage(repository: repository),
  );
}

void configureSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

String textOf(WidgetTester tester, String key) {
  final widget = tester.widget<Text>(find.byKey(Key(key)));
  return widget.data ?? widget.textSpan?.toPlainText() ?? '';
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pump();
}

Future<void> enterNumber(WidgetTester tester, String value) async {
  await tapKey(tester, 'numeric-key-clear');
  for (final char in value.split('')) {
    if (char == '.') {
      await tapKey(tester, 'numeric-key-dot');
    } else {
      await tapKey(tester, 'numeric-key-$char');
    }
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('汇率页默认三行同时换算', (tester) async {
    configureSurface(tester);
    final repository = ExchangeRateRepository(loader: () async => fixture());
    await tester.pumpWidget(harness(repository));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(textOf(tester, 'currency-value-0'), '1');
    expect(textOf(tester, 'currency-value-1'), '0.125');
    expect(textOf(tester, 'currency-value-2'), '0.25');
    expect(textOf(tester, 'currency-status'), contains('汇率数据由 test 提供'));
    expect(textOf(tester, 'currency-status'), contains('2026年10月29日'));
    expect(find.byKey(const Key('currency-swap')), findsNothing);
  });

  testWidgets('输入金额后三行联动', (tester) async {
    configureSurface(tester);
    final repository = ExchangeRateRepository(loader: () async => fixture());
    await tester.pumpWidget(harness(repository));
    await tester.pumpAndSettle();

    await enterNumber(tester, '100');
    expect(textOf(tester, 'currency-value-0'), '100');
    expect(textOf(tester, 'currency-value-1'), '12.5');
    expect(textOf(tester, 'currency-value-2'), '25');
  });

  testWidgets('点第二行激活输入，首键替换原值', (tester) async {
    configureSurface(tester);
    final repository = ExchangeRateRepository(loader: () async => fixture());
    await tester.pumpWidget(harness(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('currency-row-1')));
    await tester.pump();
    expect(textOf(tester, 'currency-value-1'), '0.125');

    await tapKey(tester, 'numeric-key-8');
    expect(textOf(tester, 'currency-value-1'), '8');
    expect(textOf(tester, 'currency-value-0'), '64');
    expect(textOf(tester, 'currency-value-2'), '16');
  });

  testWidgets('币种选择器可切换第三行币种', (tester) async {
    configureSurface(tester);
    final repository = ExchangeRateRepository(loader: () async => fixture());
    await tester.pumpWidget(harness(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('currency-picker-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('currency-option-JPY')));
    await tester.pumpAndSettle();

    expect(textOf(tester, 'currency-value-2'), '20');
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('离线缓存可换算并提示缓存', (tester) async {
    configureSurface(tester);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      ExchangeRateRepository.cacheKey,
      jsonEncode(fixture().toJson()),
    );
    final repository = ExchangeRateRepository(
      preferences: prefs,
      loader: () async => throw const ExchangeRateException('offline'),
    );
    await tester.pumpWidget(harness(repository));
    await tester.pumpAndSettle();

    expect(textOf(tester, 'currency-status'), contains('缓存'));
    expect(textOf(tester, 'currency-value-1'), '0.125');
  });

  testWidgets('无缓存断网显示错误，点击来源行重试后恢复', (tester) async {
    configureSurface(tester);
    var fail = true;
    final repository = ExchangeRateRepository(
      loader: () async {
        if (fail) throw const ExchangeRateException('offline');
        return fixture();
      },
    );
    await tester.pumpWidget(harness(repository));
    await tester.pumpAndSettle();

    expect(textOf(tester, 'currency-status'), contains('获取汇率失败'));
    expect(textOf(tester, 'currency-value-1'), '—');

    fail = false;
    await tester.tap(find.byKey(const Key('currency-status-tap')));
    await tester.pumpAndSettle();
    expect(textOf(tester, 'currency-status'), contains('汇率数据由 test 提供'));
    expect(textOf(tester, 'currency-value-1'), '0.125');
  });
}
