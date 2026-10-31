import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/app/settings_controller.dart';
import 'package:fnthink_calculator/app/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> freshPrefs([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('设置仓库可读取与保存', () async {
    final prefs = await freshPrefs({
      'settings.themeMode.v1': 'dark',
      'settings.haptics.v1': false,
      'settings.voice.v1': true,
      'settings.angleUnit.v1': 'radians',
      'settings.percentMode.v1': 'proportion',
      'settings.privacyAccepted.v1': true,
    });
    final repository = SettingsRepository(prefs);

    expect(repository.loadThemeMode(), ThemeMode.dark);
    expect(repository.loadHaptics(), isFalse);
    expect(repository.loadVoice(), isTrue);
    expect(repository.loadAngleUnit(), AngleUnit.radians);
    expect(repository.loadPercentMode(), PercentMode.proportion);
    expect(repository.loadPrivacyAccepted(), isTrue);

    await repository.saveThemeMode(ThemeMode.light);
    await repository.saveHaptics(true);
    await repository.saveVoice(false);
    await repository.saveAngleUnit(AngleUnit.degrees);
    await repository.savePercentMode(PercentMode.value);
    await repository.savePrivacyAccepted(false);

    expect(prefs.getString('settings.themeMode.v1'), 'light');
    expect(prefs.getBool('settings.haptics.v1'), isTrue);
    expect(prefs.getBool('settings.voice.v1'), isFalse);
    expect(prefs.getString('settings.angleUnit.v1'), 'degrees');
    expect(prefs.getString('settings.percentMode.v1'), 'value');
    expect(prefs.getBool('settings.privacyAccepted.v1'), isFalse);
  });

  test('设置控制器写入后可重新加载', () async {
    final prefs = await freshPrefs();
    final controller = SettingsController(
      repository: SettingsRepository(prefs),
    );
    controller.themeMode = ThemeMode.dark;
    controller.haptics = false;
    controller.voice = true;
    controller.angleUnit = AngleUnit.radians;
    controller.percentMode = PercentMode.proportion;
    controller.privacyAccepted = true;
    await Future<void>.delayed(Duration.zero);

    final reloaded = SettingsController(repository: SettingsRepository(prefs));
    expect(reloaded.themeMode, ThemeMode.dark);
    expect(reloaded.haptics, isFalse);
    expect(reloaded.voice, isTrue);
    expect(reloaded.angleUnit, AngleUnit.radians);
    expect(reloaded.percentMode, PercentMode.proportion);
    expect(reloaded.privacyAccepted, isTrue);
  });
}
