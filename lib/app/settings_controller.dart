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
    bool? voice,
    AngleUnit? angleUnit,
    PercentMode? percentMode,
    bool? privacyAccepted,
    SettingsRepository? repository,
  }) : this._(
         themeMode ?? repository?.loadThemeMode() ?? ThemeMode.system,
         haptics ?? repository?.loadHaptics() ?? true,
         voice ?? repository?.loadVoice() ?? false,
         angleUnit ?? repository?.loadAngleUnit() ?? AngleUnit.degrees,
         percentMode ?? repository?.loadPercentMode() ?? PercentMode.value,
         privacyAccepted ?? repository?.loadPrivacyAccepted() ?? true,
         repository,
       );

  SettingsController._(
    this._themeMode,
    this._haptics,
    this._voice,
    this._angleUnit,
    this._percentMode,
    this._privacyAccepted,
    this._repository,
  );

  final SettingsRepository? _repository;
  ThemeMode _themeMode;
  bool _haptics;
  bool _voice;
  AngleUnit _angleUnit;
  PercentMode _percentMode;
  bool _privacyAccepted;

  ThemeMode get themeMode => _themeMode;
  bool get haptics => _haptics;
  bool get voice => _voice;
  AngleUnit get angleUnit => _angleUnit;
  PercentMode get percentMode => _percentMode;
  bool get privacyAccepted => _privacyAccepted;

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

  set voice(bool value) {
    if (_voice == value) return;
    _voice = value;
    unawaited(_repository?.saveVoice(value));
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

  set privacyAccepted(bool value) {
    if (_privacyAccepted == value) return;
    _privacyAccepted = value;
    unawaited(_repository?.savePrivacyAccepted(value));
    notifyListeners();
  }
}
