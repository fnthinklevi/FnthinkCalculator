import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/math/angle_unit.dart';
import '../core/math/percent_mode.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _themeKey = 'settings.themeMode.v1';
  static const _hapticsKey = 'settings.haptics.v1';
  static const _angleKey = 'settings.angleUnit.v1';
  static const _percentKey = 'settings.percentMode.v1';

  ThemeMode loadThemeMode() {
    return switch (_prefs.getString(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  bool loadHaptics() => _prefs.getBool(_hapticsKey) ?? true;

  AngleUnit loadAngleUnit() {
    return _prefs.getString(_angleKey) == 'radians'
        ? AngleUnit.radians
        : AngleUnit.degrees;
  }

  PercentMode loadPercentMode() {
    return _prefs.getString(_percentKey) == 'proportion'
        ? PercentMode.proportion
        : PercentMode.value;
  }

  Future<void> saveThemeMode(ThemeMode mode) {
    return _prefs.setString(_themeKey, mode.name);
  }

  Future<void> saveHaptics(bool value) {
    return _prefs.setBool(_hapticsKey, value);
  }

  Future<void> saveAngleUnit(AngleUnit unit) {
    return _prefs.setString(_angleKey, unit.name);
  }

  Future<void> savePercentMode(PercentMode mode) {
    return _prefs.setString(_percentKey, mode.name);
  }
}
