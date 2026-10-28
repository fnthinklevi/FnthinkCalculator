import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/settings_controller.dart';
import 'app/settings_repository.dart';
import 'features/calculator/calculator_controller.dart';
import 'features/calculator/history_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SharedPreferences? preferences;
  try {
    preferences = await SharedPreferences.getInstance();
  } catch (_) {
    preferences = null;
  }

  final settings = preferences == null
      ? SettingsController()
      : SettingsController(repository: SettingsRepository(preferences));
  final calculatorController = CalculatorController(
    historyStore: preferences == null ? null : HistoryRepository(preferences),
  );

  runApp(
    FnthinkCalculatorApp(
      settings: settings,
      calculatorController: calculatorController,
    ),
  );
}
