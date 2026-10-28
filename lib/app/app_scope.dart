import 'package:flutter/widgets.dart';

import 'settings_controller.dart';

class AppScope extends InheritedNotifier<SettingsController> {
  const AppScope({
    super.key,
    required SettingsController settings,
    required super.child,
  }) : super(notifier: settings);

  static SettingsController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }

  static SettingsController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppScope>()?.notifier;
  }
}
