import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/calculator/calculator_controller.dart';
import '../theme/app_theme.dart';
import 'app_scope.dart';
import 'settings_controller.dart';
import 'shell.dart';
import 'wide_layout.dart';

class FnthinkCalculatorApp extends StatelessWidget {
  const FnthinkCalculatorApp({
    super.key,
    required this.settings,
    this.calculatorController,
  });

  final SettingsController settings;
  final CalculatorController? calculatorController;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      settings: settings,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          return MaterialApp(
            title: '幻念计算器',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(Brightness.light),
            darkTheme: buildAppTheme(Brightness.dark),
            themeMode: settings.themeMode,
            locale: const Locale('zh', 'CN'),
            supportedLocales: const [Locale('zh', 'CN')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            builder: (context, child) => AppWideLayout(child: child!),
            home: AppShell(calculatorController: calculatorController),
          );
        },
      ),
    );
  }
}
