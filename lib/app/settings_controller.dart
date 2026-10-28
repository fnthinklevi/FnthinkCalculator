import 'dart:async';

import 'package:flutter/material.dart';

import '../core/math/angle_unit.dart';
import 'settings_repository.dart';

export '../core/math/angle_unit.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({
    ThemeMode? themeMode,
    bool? haptics,
    AngleUnit? angleUnit,
    SettingsRepository? repository,
  }) : this._(
         themeMode ?? repository?.loadThemeMode() ?? ThemeMode.system,
         haptics ?? repository?.loadHaptics() ?? true,
         angleUnit ?? repository?.loadAngleUnit() ?? AngleUnit.degrees,
         repository,
       );

  SettingsController._(
    this._themeMode,
    this._haptics,
    this._angleUnit,
    this._repository,
  );

  final SettingsRepository? _repository;
  ThemeMode _themeMode;
  bool _haptics;
  AngleUnit _angleUnit;

  ThemeMode get themeMode => _themeMode;
  bool get haptics => _haptics;
  AngleUnit get angleUnit => _angleUnit;

  set themeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    unawaited(_repository?.saveThemeMode(value));
    notifyListeners();
  }

  set haptics(bool value) {
    if (_haptics == value) return;
    _haptics = value;
    unawaited(_repository?.saveHaptics(value));
    notifyListeners();
  }

  set angleUnit(AngleUnit value) {
    if (_angleUnit == value) return;
    _angleUnit = value;
    unawaited(_repository?.saveAngleUnit(value));
    notifyListeners();
  }
}
