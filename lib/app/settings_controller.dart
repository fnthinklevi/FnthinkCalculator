import 'dart:async';

import 'package:flutter/material.dart';

import '../core/math/angle_unit.dart';
import '../core/math/percent_mode.dart';
import 'settings_repository.dart';

export '../core/math/angle_unit.dart';
export '../core/math/percent_mode.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({
    ThemeMode? themeMode,
    bool? haptics,
    AngleUnit? angleUnit,
    PercentMode? percentMode,
    SettingsRepository? repository,
  }) : this._(
         themeMode ?? repository?.loadThemeMode() ?? ThemeMode.system,
         haptics ?? repository?.loadHaptics() ?? true,
         angleUnit ?? repository?.loadAngleUnit() ?? AngleUnit.degrees,
         percentMode ?? repository?.loadPercentMode() ?? PercentMode.value,
         repository,
       );

  SettingsController._(
    this._themeMode,
    this._haptics,
    this._angleUnit,
    this._percentMode,
    this._repository,
  );

  final SettingsRepository? _repository;
  ThemeMode _themeMode;
  bool _haptics;
  AngleUnit _angleUnit;
  PercentMode _percentMode;

  ThemeMode get themeMode => _themeMode;
  bool get haptics => _haptics;
  AngleUnit get angleUnit => _angleUnit;
  PercentMode get percentMode => _percentMode;

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

  set percentMode(PercentMode value) {
    if (_percentMode == value) return;
    _percentMode = value;
    unawaited(_repository?.savePercentMode(value));
    notifyListeners();
  }
}
