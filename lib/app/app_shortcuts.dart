import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/converter/currency_page.dart';
import '../features/multifunction/time/time_tool_pages.dart';

enum AppShortcut {
  timeCalculation('time_calculation'),
  dateCalculation('date_calculation'),
  currency('currency');

  const AppShortcut(this.id);

  final String id;

  static AppShortcut? fromId(String? id) {
    for (final shortcut in AppShortcut.values) {
      if (shortcut.id == id) return shortcut;
    }
    return null;
  }
}

class AppShortcuts {
  AppShortcuts._();

  static const channel = MethodChannel('fnthink/app_shortcuts');

  static Future<AppShortcut?> initialShortcut() async {
    try {
      final id = await channel.invokeMethod<String>('getInitialShortcut');
      return AppShortcut.fromId(id);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  static void listen(ValueChanged<AppShortcut?> onShortcut) {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'shortcut') {
        onShortcut(AppShortcut.fromId(call.arguments as String?));
      }
      return null;
    });
  }

  static void stopListening() {
    channel.setMethodCallHandler(null);
  }

  static Widget pageFor(AppShortcut shortcut) {
    return switch (shortcut) {
      AppShortcut.timeCalculation => const TimeCalculationPage(),
      AppShortcut.dateCalculation => const DateDifferencePage(),
      AppShortcut.currency => const CurrencyConverterPage(),
    };
  }

  static void open(BuildContext context, AppShortcut shortcut) {
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    navigator.push(MaterialPageRoute<void>(builder: (_) => pageFor(shortcut)));
  }
}
