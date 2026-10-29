import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/math/rational.dart';
import 'package:fnthink_calculator/features/converter/converter_home_page.dart';
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
  return tester.widget<Text>(find.byKey(Key(key))).data!;
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

  testWidgets('汇率页默认 CNY→USD，内置键盘输入与交换正确', (tester) async {
    configureSurface(tester);
    final repository = ExchangeRateRepository(loader: () async => fixture());
    await tester.pumpWidget(harness(repository));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(textOf(tester, 'currency-input'), '1');
    expect(textOf(tester, 'currency-result'), '0.125');
    expect(textOf(tester, 'currency-status'), contains('已更新'));
    expect(textOf(tester, 'currency-rate-line'), '1 CNY = 0.125 USD');

    await enterNumber(tester, '100');
    expect(textOf(tester, 'currency-input'), '100');
    expect(textOf(tester, 'currency-result'), '12.5');

    await tapKey(tester, 'numeric-key-undo');
    expect(textOf(tester, 'currency-input'), '10');
    expect(textOf(tester, 'currency-result'), '1.25');

    await tapKey(tester, 'currency-swap');
    expect(textOf(tester, 'currency-result'), '80');
  });

  testWidgets('币种选择器可切换目标币种', (tester) async {
    configureSurface(tester);
    final repository = ExchangeRateRepository(loader: () async => fixture());
    await tester.pumpWidget(harness(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('currency-to-picker')));
    await tester.pumpAndSettle();
    expect(find.text('选择币种'), findsOneWidget);
    await tester.tap(find.byKey(const Key('currency-option-EUR')));
    await tester.pumpAndSettle();

    expect(textOf(tester, 'currency-result'), '0.25');
    expect(textOf(tester, 'currency-rate-line'), '1 CNY = 0.25 EUR');
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('离线缓存可换算并在刷新失败后提示', (tester) async {
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

    expect(textOf(tester, 'currency-status'), contains('缓存数据'));
    expect(textOf(tester, 'currency-result'), '0.125');

    await tapKey(tester, 'currency-refresh');
    await tester.pumpAndSettle();
    expect(textOf(tester, 'currency-status'), contains('网络不可用'));
    expect(textOf(tester, 'currency-result'), '0.125');
  });

  testWidgets('无缓存断网显示错误，重试后恢复', (tester) async {
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
    expect(textOf(tester, 'currency-result'), '—');
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('currency-copy')))
          .onPressed,
      isNull,
    );

    fail = false;
    await tapKey(tester, 'currency-refresh');
    await tester.pumpAndSettle();
    expect(textOf(tester, 'currency-status'), contains('已更新'));
    expect(textOf(tester, 'currency-result'), '0.125');
  });

  testWidgets('换算首页提供汇率入口且进入后无需系统键盘', (tester) async {
    configureSurface(tester);
    final repository = ExchangeRateRepository(loader: () async => fixture());
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: buildAppTheme(Brightness.light),
        home: ConverterHomePage(currencyRepository: repository),
      ),
    );

    expect(
      find.byKey(const Key('converter-category-currency')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('converter-category-currency')));
    await tester.pumpAndSettle();

    expect(find.text('汇率换算'), findsOneWidget);
    expect(find.byKey(const Key('currency-page')), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byKey(const Key('numeric-key-7')), findsOneWidget);
  });
}
