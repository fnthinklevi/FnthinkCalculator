import 'package:flutter/material.dart';

import '../core/math/angle_unit.dart';

export '../core/math/angle_unit.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({
    ThemeMode themeMode = ThemeMode.system,
    bool haptics = true,
    AngleUnit angleUnit = AngleUnit.degrees,
  }) : this._(themeMode, haptics, angleUnit);

  SettingsController._(this._themeMode, this._haptics, this._angleUnit);

  ThemeMode _themeMode;
  bool _haptics;
  AngleUnit _angleUnit;

  ThemeMode get themeMode => _themeMode;
  bool get haptics => _haptics;
  AngleUnit get angleUnit => _angleUnit;

  set themeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
  }

  set haptics(bool value) {
    if (_haptics == value) return;
    _haptics = value;
    notifyListeners();
  }

  set angleUnit(AngleUnit value) {
    if (_angleUnit == value) return;
    _angleUnit = value;
    notifyListeners();
  }
}
